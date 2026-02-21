//
//  SimpleReportsView.swift
//  DevTaskManager
//
//  Created by Assistant on 2/20/26.
//  Renamed from ReportsView.swift for clarity
//
import SwiftData
import SwiftUI
import Charts

/// Date range options for filtering reports
enum DateRangeFilter: String, CaseIterable, Identifiable {
    case allTime = "All Time"
    case last7Days = "Last 7 Days"
    case last30Days = "Last 30 Days"
    case last90Days = "Last 90 Days"
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case thisYear = "This Year"
    case custom = "Custom Range"
    
    var id: String { rawValue }
    
    func dateRange() -> (start: Date?, end: Date?) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .allTime:
            return (nil, nil)
        case .last7Days:
            return (calendar.date(byAdding: .day, value: -7, to: now), now)
        case .last30Days:
            return (calendar.date(byAdding: .day, value: -30, to: now), now)
        case .last90Days:
            return (calendar.date(byAdding: .day, value: -90, to: now), now)
        case .thisMonth:
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))
            return (startOfMonth, now)
        case .lastMonth:
            let startOfThisMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let startOfLastMonth = calendar.date(byAdding: .month, value: -1, to: startOfThisMonth)
            let endOfLastMonth = calendar.date(byAdding: .day, value: -1, to: startOfThisMonth)
            return (startOfLastMonth, endOfLastMonth)
        case .thisYear:
            let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: now))
            return (startOfYear, now)
        case .custom:
            return (nil, nil) // Will be set by user
        }
    }
}

/// A simple, single-page report view showing overview statistics, projects, users, and task analysis
struct SimpleReportsView: View
{
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var reportData: ReportData?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showShareSheet = false
    @State private var shareType: ShareType = .text
    @State private var sharePDFData: Data?
    @State private var isGeneratingPDF = false
    
    enum ShareType {
        case text, csv, pdf
    }
    
    // Date range filtering
    @State private var selectedDateRange: DateRangeFilter = .allTime
    @State private var showDateRangePicker = false
    @State private var customStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var customEndDate = Date()
    
    var body: some View
    {
        NavigationStack
        {
            ZStack
            {
                // Background
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                AppGradients.mainBackground
                    .ignoresSafeArea()
                
                if isLoading
                {
                    ProgressView("Generating Report...")
                        .font(.headline)
                }
                else if let error = errorMessage
                {
                    VStack(spacing: 20)
                    {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.red)
                        
                        Text("Error Generating Report")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(error)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Try Again", action: generateReport)
                            .buttonStyle(.borderedProminent)
                    }
                }
                else if let data = reportData
                {
                    reportContent(data: data)
                }
                else
                {
                    EmptyStateCard(
                        icon: "chart.bar.doc.horizontal.fill",
                        title: "No Report Generated",
                        message: "Generate a report to view your project statistics",
                        buttonTitle: "Generate Report",
                        buttonAction: generateReport
                    )
                }
                
                // PDF generation overlay
                if isGeneratingPDF
                {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16)
                    {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        
                        Text("Generating PDF...")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("This may take a moment")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar
            {
                ToolbarItem(placement: .navigationBarLeading)
                {
                    Button(action: { dismiss() })
                    {
                        HStack(spacing: 4)
                        {
                            Image(systemName: "chevron.left")
                                .font(.body.weight(.semibold))
                            Text("Back")
                                .font(.body)
                        }
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.indigo, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }
                }
                
                if reportData != nil
                {
                    ToolbarItemGroup(placement: .topBarTrailing)
                    {
                        Menu {
                            Button(action: { showDateRangePicker = true }) {
                                Label("Filter by Date", systemImage: "calendar")
                            }
                            
                            Divider()
                            
                            Button(action: exportAsText) {
                                Label("Export as Text", systemImage: "doc.text")
                            }
                            
                            Button(action: exportAsCSV) {
                                Label("Export as CSV", systemImage: "tablecells")
                            }
                            
                            Button(action: exportAsPDF) {
                                Label("Export as PDF", systemImage: "doc.richtext")
                            }
                            
                            Divider()
                            
                            Button(action: { shareType = .text; showShareSheet = true }) {
                                Label("Share Report", systemImage: "square.and.arrow.up")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.indigo, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                        
                        Button(action: generateReport)
                        {
                            Image(systemName: "arrow.clockwise")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.indigo, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        }
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                if reportData == nil {
                    generateReport()
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let pdfData = sharePDFData, shareType == .pdf {
                    PDFShareSheet(pdfData: pdfData)
                } else if let data = reportData {
                    let content = shareType == .csv ? generateCSVReport(data: data) : generateReportText(data: data)
                    ReportShareSheet(items: [content])
                }
            }
            .sheet(isPresented: $showDateRangePicker) {
                DateRangePickerView(
                    selectedRange: $selectedDateRange,
                    customStartDate: $customStartDate,
                    customEndDate: $customEndDate,
                    onApply: {
                        showDateRangePicker = false
                        generateReport()
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    private func reportContent(data: ReportData) -> some View
    {
        ScrollView
        {
            VStack(spacing: 20)
            {
                // Header
                ModernHeaderView(
                    icon: "chart.bar.doc.horizontal.fill",
                    title: "Project Report",
                    subtitle: "Generated: \(data.generatedDate.formatted(date: .abbreviated, time: .shortened))",
                    gradientColors: [.indigo, .purple]
                )
                
                // Date Range Filter Badge
                if selectedDateRange != .allTime {
                    dateRangeFilterBadge()
                }
                
                // Summary Statistics
                VStack(spacing: 16)
                {
                    statisticsSection(data: data)
                    
                    // Task Status Chart
                    taskStatusChartSection(data: data)
                    
                    // Task Type Distribution Chart
                    if !data.tasksByType.isEmpty
                    {
                        taskTypeChartSection(data: data)
                    }
                    
                    // Task Priority Chart
                    if !data.tasksByPriority.isEmpty
                    {
                        taskPriorityChartSection(data: data)
                    }
                    
                    // Project Completion Chart
                    if !data.projectsList.isEmpty
                    {
                        projectCompletionChartSection(projects: data.projectsList)
                    }
                    
                    // User Productivity Chart
                    if !data.usersList.isEmpty
                    {
                        userProductivityChartSection(users: data.usersList)
                    }
                    
                    // Projects Section
                    if !data.projectsList.isEmpty
                    {
                        projectsSection(projects: data.projectsList)
                    }
                    
                    // Users Section
                    if !data.usersList.isEmpty
                    {
                        usersSection(users: data.usersList)
                    }
                    
                    // Tasks Breakdown
                    if !data.tasksList.isEmpty
                    {
                        tasksBreakdownSection(data: data)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    @ViewBuilder
    private func statisticsSection(data: ReportData) -> some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            sectionHeader(icon: "chart.pie.fill", title: "Overview Statistics")
            
            ModernFormCard
            {
                VStack(spacing: 12)
                {
                    statRow(label: "Total Projects", value: "\(data.totalProjects)", color: .blue)
                    Divider()
                    statRow(label: "Total Users", value: "\(data.totalUsers)", color: .purple)
                    Divider()
                    statRow(label: "Total Tasks", value: "\(data.totalTasks)", color: .orange)
                    Divider()
                    statRow(label: "Completed Tasks", value: "\(data.completedTasks)", color: .green)
                    Divider()
                    statRow(label: "In Progress", value: "\(data.inProgressTasks)", color: .blue)
                    Divider()
                    statRow(label: "Unassigned", value: "\(data.unassignedTasks)", color: .orange)
                    Divider()
                    statRow(label: "Deferred", value: "\(data.deferredTasks)", color: .gray)
                    Divider()
                    statRow(label: "Completion Rate", value: String(format: "%.1f%%", data.completionRate), color: .green)
                }
            }
        }
    }
    
    // MARK: - Chart Sections
    
    @ViewBuilder
    private func taskStatusChartSection(data: ReportData) -> some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            sectionHeader(icon: "chart.bar.fill", title: "Task Status Distribution")
            
            ModernFormCard
            {
                VStack(alignment: .leading, spacing: 16)
                {
                    Chart
                    {
                        BarMark(
                            x: .value("Count", data.completedTasks),
                            y: .value("Status", "Completed")
                        )
                        .foregroundStyle(.green.gradient)
                        .annotation(position: .trailing) {
                            Text("\(data.completedTasks)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        BarMark(
                            x: .value("Count", data.inProgressTasks),
                            y: .value("Status", "In Progress")
                        )
                        .foregroundStyle(.blue.gradient)
                        .annotation(position: .trailing) {
                            Text("\(data.inProgressTasks)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        BarMark(
                            x: .value("Count", data.unassignedTasks),
                            y: .value("Status", "Unassigned")
                        )
                        .foregroundStyle(.orange.gradient)
                        .annotation(position: .trailing) {
                            Text("\(data.unassignedTasks)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        BarMark(
                            x: .value("Count", data.deferredTasks),
                            y: .value("Status", "Deferred")
                        )
                        .foregroundStyle(.gray.gradient)
                        .annotation(position: .trailing) {
                            Text("\(data.deferredTasks)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(position: .bottom)
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    @ViewBuilder
    private func taskTypeChartSection(data: ReportData) -> some View
    {
        let sortedTypes = data.tasksByType.sorted { $0.value > $1.value }
        
        VStack(alignment: .leading, spacing: 16)
        {
            sectionHeader(icon: "square.stack.3d.up.fill", title: "Tasks by Type")
            
            ModernFormCard
            {
                VStack(alignment: .leading, spacing: 16)
                {
                    Chart(sortedTypes, id: \.key) { item in
                        SectorMark(
                            angle: .value("Count", item.value),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(by: .value("Type", item.key))
                        .cornerRadius(4)
                    }
                    .frame(height: 250)
                    .chartLegend(position: .bottom, alignment: .center)
                    
                    // Legend with counts
                    VStack(alignment: .leading, spacing: 8)
                    {
                        ForEach(sortedTypes, id: \.key) { type, count in
                            HStack
                            {
                                Text(type)
                                    .font(.caption)
                                Spacer()
                                Text("\(count)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text(String(format: "(%.1f%%)", Double(count) / Double(data.totalTasks) * 100))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    @ViewBuilder
    private func taskPriorityChartSection(data: ReportData) -> some View
    {
        let priorityOrder = ["High", "Medium", "Low"]
        let sortedPriorities = data.tasksByPriority.sorted { 
            let index1 = priorityOrder.firstIndex(of: $0.key) ?? 999
            let index2 = priorityOrder.firstIndex(of: $1.key) ?? 999
            return index1 < index2
        }
        
        VStack(alignment: .leading, spacing: 16)
        {
            sectionHeader(icon: "exclamationmark.triangle.fill", title: "Tasks by Priority")
            
            ModernFormCard
            {
                VStack(alignment: .leading, spacing: 16)
                {
                    Chart(sortedPriorities, id: \.key) { item in
                        BarMark(
                            x: .value("Priority", item.key),
                            y: .value("Count", item.value)
                        )
                        .foregroundStyle(priorityColor(for: item.key).gradient)
                        .annotation(position: .top) {
                            Text("\(item.value)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(position: .bottom)
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    @ViewBuilder
    private func projectCompletionChartSection(projects: [ProjectSummary]) -> some View
    {
        let topProjects = Array(projects.prefix(10))
        
        VStack(alignment: .leading, spacing: 16)
        {
            sectionHeader(icon: "chart.line.uptrend.xyaxis", title: "Project Completion Rates")
            
            ModernFormCard
            {
                VStack(alignment: .leading, spacing: 16)
                {
                    Chart(topProjects) { project in
                        BarMark(
                            x: .value("Completion", project.completionRate),
                            y: .value("Project", project.title)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .annotation(position: .trailing) {
                            Text(String(format: "%.0f%%", project.completionRate))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: CGFloat(topProjects.count * 40 + 50))
                    .chartXScale(domain: 0...100)
                    .chartXAxis {
                        AxisMarks(position: .bottom) { _ in
                            AxisValueLabel()
                            AxisGridLine()
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisValueLabel {
                                if let project = topProjects.first(where: { $0.title == value.as(String.self) }) {
                                    Text(project.title)
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    
                    if projects.count > 10
                    {
                        Text("Showing top 10 of \(projects.count) projects")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    @ViewBuilder
    private func userProductivityChartSection(users: [UserSummary]) -> some View
    {
        // Filter out users with zero tasks, then get top 10
        let usersWithTasks = users.filter { $0.assignedTaskCount > 0 }
        let topUsers = Array(usersWithTasks.sorted { $0.assignedTaskCount > $1.assignedTaskCount }.prefix(10))
        
        // Only show chart if there are users with tasks
        if !topUsers.isEmpty {
            VStack(alignment: .leading, spacing: 16)
            {
                sectionHeader(icon: "person.2.fill", title: "Team Productivity")
                
                ForEach(topUsers) { user in
                    ModernFormCard
                    {
                        VStack(alignment: .leading, spacing: 16)
                        {
                            // User name and role as subsection header
                            Text("\(user.name) - \(user.roleName)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            Chart {
                                // Assigned tasks bar
                                BarMark(
                                    x: .value("Count", user.assignedTaskCount),
                                    y: .value("Type", "Assigned")
                                )
                                .foregroundStyle(.orange.gradient)
                                .annotation(position: .trailing) {
                                    Text("\(user.assignedTaskCount)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                // Completed tasks bar
                                BarMark(
                                    x: .value("Count", user.completedTaskCount),
                                    y: .value("Type", "Completed")
                                )
                                .foregroundStyle(.green.gradient)
                                .annotation(position: .trailing) {
                                    Text("\(user.completedTaskCount)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(height: 80)
                            .chartXAxis {
                                AxisMarks(position: .bottom)
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                if usersWithTasks.count > 10
                {
                    Text("Showing top 10 of \(usersWithTasks.count) users with tasks")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                }
            }
        }
    }
    
    // Helper function for priority colors
    private func priorityColor(for priority: String) -> Color
    {
        switch priority.lowercased() {
        case "high": return .red
        case "medium": return .orange
        case "low": return .green
        default: return .gray
        }
    }
    
    // MARK: - Original Sections
    
    @ViewBuilder
    private func dateRangeFilterBadge() -> some View
    {
        HStack {
            Image(systemName: "calendar")
                .font(.caption)
            Text(dateRangeText())
                .font(.caption)
                .fontWeight(.medium)
            
            Button(action: {
                selectedDateRange = .allTime
                generateReport()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.indigo.opacity(0.15))
        )
        .foregroundStyle(.indigo)
    }
    
    private func dateRangeText() -> String {
        if selectedDateRange == .custom {
            return "\(customStartDate.formatted(date: .abbreviated, time: .omitted)) - \(customEndDate.formatted(date: .abbreviated, time: .omitted))"
        } else {
            return selectedDateRange.rawValue
        }
    }
    
    @ViewBuilder
    private func projectsSection(projects: [ProjectSummary]) -> some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            sectionHeader(icon: "folder.fill", title: "Projects (\(projects.count))")
            
            ForEach(projects) { project in
                ModernListRow
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text(project.title)
                            .font(.headline)
                        
                        if !project.description.isEmpty
                        {
                            Text(project.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        
                        HStack
                        {
                            Label("\(project.taskCount) tasks", systemImage: "checklist")
                                .font(.caption)
                                .foregroundStyle(.blue)
                            
                            Spacer()
                            
                            Text(String(format: "%.0f%% complete", project.completionRate))
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func usersSection(users: [UserSummary]) -> some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            sectionHeader(icon: "person.3.fill", title: "Team Members (\(users.count))")
            
            ForEach(users) { user in
                ModernListRow
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text(user.name)
                            .font(.headline)
                        
                        Text(user.roleName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HStack
                        {
                            Label("\(user.assignedTaskCount) tasks", systemImage: "list.bullet")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            
                            Spacer()
                            
                            Label("\(user.completedTaskCount) completed", systemImage: "checkmark.circle")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func tasksBreakdownSection(data: ReportData) -> some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            sectionHeader(icon: "chart.bar.fill", title: "Task Analysis")
            
            ModernFormCard
            {
                VStack(alignment: .leading, spacing: 12)
                {
                    Text("By Type")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(data.tasksByType.sorted(by: { $0.value > $1.value }), id: \.key) { type, count in
                        HStack
                        {
                            Text(type)
                                .font(.caption)
                            Spacer()
                            Text("\(count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    Text("By Priority")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(data.tasksByPriority.sorted(by: { $0.value > $1.value }), id: \.key) { priority, count in
                        HStack
                        {
                            Text(priority)
                                .font(.caption)
                            Spacer()
                            Text("\(count)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
    }
    
    private func sectionHeader(icon: String, title: String) -> some View
    {
        HStack(spacing: 8)
        {
            Image(systemName: icon)
                .foregroundStyle(.indigo)
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
    
    private func statRow(label: String, value: String, color: Color) -> some View
    {
        HStack
        {
            Text(label)
                .font(.body)
            Spacer()
            Text(value)
                .font(.body)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
    }
    
    private func generateReport()
    {
        isLoading = true
        errorMessage = nil
        
        _Concurrency.Task
        {
            do
            {
                // Get date range based on filter
                let (startDate, endDate) = selectedDateRange == .custom 
                    ? (customStartDate, customEndDate)
                    : selectedDateRange.dateRange()
                
                let data = try ReportGenerator.generateReport(
                    context: modelContext,
                    startDate: startDate,
                    endDate: endDate
                )
                await MainActor.run {
                    reportData = data
                    isLoading = false
                }
            }
            catch
            {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    // MARK: - Export Functions
    
    private func exportAsText()
    {
        shareType = .text
        sharePDFData = nil
        showShareSheet = true
    }
    
    private func exportAsCSV()
    {
        shareType = .csv
        sharePDFData = nil
        showShareSheet = true
    }
    
    private func exportAsPDF()
    {
        guard let data = reportData else { return }
        
        isGeneratingPDF = true
        
        _Concurrency.Task {
            // First, we need to convert ReportData to DevTaskManagerReport
            // We'll generate a detailed report from the model context
            do {
                let detailedReport = try await generateDetailedReportForPDF()
                
                await MainActor.run {
                    if let pdfData = PDFReportGenerator.generatePDF(from: detailedReport) {
                        shareType = .pdf
                        sharePDFData = pdfData
                        showShareSheet = true
                    } else {
                        errorMessage = "Failed to generate PDF"
                    }
                    isGeneratingPDF = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to generate PDF: \(error.localizedDescription)"
                    isGeneratingPDF = false
                }
            }
        }
    }
    
    private func generateDetailedReportForPDF() async throws -> DevTaskManagerReport
    {
        return try await _Concurrency.Task { @MainActor in
            try ReportGenerator.generateDetailedReport(context: modelContext)
        }.value
    }
    
    private func generateReportText(data: ReportData) -> String
    {
        var text = """
        DEV TASK MANAGER REPORT
        Generated: \(data.generatedDate.formatted(date: .long, time: .standard))
        
        ═══════════════════════════════════════
        OVERVIEW STATISTICS
        ═══════════════════════════════════════
        Total Projects: \(data.totalProjects)
        Total Users: \(data.totalUsers)
        Total Tasks: \(data.totalTasks)
        Completed Tasks: \(data.completedTasks)
        In Progress: \(data.inProgressTasks)
        Unassigned: \(data.unassignedTasks)
        Deferred: \(data.deferredTasks)
        Completion Rate: \(String(format: "%.1f%%", data.completionRate))
        
        """
        
        if !data.projectsList.isEmpty
        {
            text += """
            
            ═══════════════════════════════════════
            PROJECTS (\(data.projectsList.count))
            ═══════════════════════════════════════
            
            """
            
            for project in data.projectsList
            {
                text += """
                • \(project.title)
                  Tasks: \(project.taskCount) (\(String(format: "%.0f%%", project.completionRate)) complete)
                  Created: \(project.dateCreated.formatted(date: .abbreviated, time: .omitted))
                
                """
            }
        }
        
        if !data.usersList.isEmpty
        {
            text += """
            
            ═══════════════════════════════════════
            TEAM MEMBERS (\(data.usersList.count))
            ═══════════════════════════════════════
            
            """
            
            for user in data.usersList
            {
                text += """
                • \(user.name) (\(user.roleName))
                  Assigned: \(user.assignedTaskCount) tasks
                  Completed: \(user.completedTaskCount) tasks
                
                """
            }
        }
        
        text += """
        
        ═══════════════════════════════════════
        TASK ANALYSIS
        ═══════════════════════════════════════
        
        By Type:
        
        """
        
        for (type, count) in data.tasksByType.sorted(by: { $0.value > $1.value })
        {
            text += "  \(type): \(count)\n"
        }
        
        text += "\nBy Priority:\n"
        for (priority, count) in data.tasksByPriority.sorted(by: { $0.value > $1.value })
        {
            text += "  \(priority): \(count)\n"
        }
        
        text += "\n═══════════════════════════════════════\n"
        
        return text
    }
    
    private func generateCSVReport(data: ReportData) -> String
    {
        var csv = "DevTaskManager Report - Generated \(data.generatedDate.formatted())\n\n"
        
        csv += "OVERVIEW\n"
        csv += "Metric,Value\n"
        csv += "Total Projects,\(data.totalProjects)\n"
        csv += "Total Users,\(data.totalUsers)\n"
        csv += "Total Tasks,\(data.totalTasks)\n"
        csv += "Completed Tasks,\(data.completedTasks)\n"
        csv += "In Progress Tasks,\(data.inProgressTasks)\n"
        csv += "Unassigned Tasks,\(data.unassignedTasks)\n"
        csv += "Deferred Tasks,\(data.deferredTasks)\n"
        csv += "Completion Rate,\(String(format: "%.1f%%", data.completionRate))\n\n"
        
        csv += "PROJECTS\n"
        csv += "Title,Description,Tasks,Completed,Completion Rate,Date Created\n"
        for project in data.projectsList {
            csv += "\"\(project.title)\",\"\(project.description)\",\(project.taskCount),\(project.completedTaskCount),\(String(format: "%.1f%%", project.completionRate)),\(project.dateCreated.formatted(date: .abbreviated, time: .omitted))\n"
        }
        
        csv += "\nUSERS\n"
        csv += "Name,Role,Assigned Tasks,Completed Tasks,Date Created\n"
        for user in data.usersList {
            csv += "\"\(user.name)\",\"\(user.roleName)\",\(user.assignedTaskCount),\(user.completedTaskCount),\(user.dateCreated.formatted(date: .abbreviated, time: .omitted))\n"
        }
        
        csv += "\nTASKS BY TYPE\n"
        csv += "Type,Count\n"
        for (type, count) in data.tasksByType.sorted(by: { $0.key < $1.key }) {
            csv += "\(type),\(count)\n"
        }
        
        csv += "\nTASKS BY PRIORITY\n"
        csv += "Priority,Count\n"
        for (priority, count) in data.tasksByPriority.sorted(by: { $0.key < $1.key }) {
            csv += "\(priority),\(count)\n"
        }
        
        return csv
    }
}

// MARK: - Date Range Picker View

struct DateRangePickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedRange: DateRangeFilter
    @Binding var customStartDate: Date
    @Binding var customEndDate: Date
    let onApply: () -> Void
    
    @State private var tempRange: DateRangeFilter
    @State private var tempStartDate: Date
    @State private var tempEndDate: Date
    
    init(selectedRange: Binding<DateRangeFilter>, 
         customStartDate: Binding<Date>,
         customEndDate: Binding<Date>,
         onApply: @escaping () -> Void) {
        self._selectedRange = selectedRange
        self._customStartDate = customStartDate
        self._customEndDate = customEndDate
        self.onApply = onApply
        
        // Initialize temp values
        self._tempRange = State(initialValue: selectedRange.wrappedValue)
        self._tempStartDate = State(initialValue: customStartDate.wrappedValue)
        self._tempEndDate = State(initialValue: customEndDate.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Date Range", selection: $tempRange) {
                        ForEach(DateRangeFilter.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Select Time Period")
                }
                
                if tempRange == .custom {
                    Section {
                        DatePicker("Start Date", selection: $tempStartDate, displayedComponents: [.date])
                        DatePicker("End Date", selection: $tempEndDate, displayedComponents: [.date])
                    } header: {
                        Text("Custom Date Range")
                    } footer: {
                        if tempStartDate > tempEndDate {
                            Label("Start date must be before end date", systemImage: "exclamationmark.triangle")
                                .foregroundStyle(.red)
                                .font(.caption)
                        }
                    }
                }
                
                Section {
                    if tempRange != .allTime {
                        let (start, end) = tempRange == .custom 
                            ? (tempStartDate, tempEndDate)
                            : tempRange.dateRange()
                        
                        if let startDate = start {
                            LabeledContent("From", value: startDate.formatted(date: .long, time: .omitted))
                        }
                        if let endDate = end {
                            LabeledContent("To", value: endDate.formatted(date: .long, time: .omitted))
                        }
                    } else {
                        Text("Showing all data regardless of date")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Date Range Preview")
                }
            }
            .navigationTitle("Filter by Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        // Validate custom date range
                        if tempRange == .custom && tempStartDate > tempEndDate {
                            return
                        }
                        
                        // Apply changes
                        selectedRange = tempRange
                        customStartDate = tempStartDate
                        customEndDate = tempEndDate
                        onApply()
                    }
                    .fontWeight(.semibold)
                    .disabled(tempRange == .custom && tempStartDate > tempEndDate)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Previews

// Commented out temporarily to resolve compilation issues
/*
#Preview("With Sample Data") {
    SimpleReportsView()
        .modelContainer(createSampleDataContainer())
}

#Preview("Empty State") {
    SimpleReportsView()
        .modelContainer(createEmptyContainer())
}

@MainActor
private func createSampleDataContainer() -> ModelContainer {
    let schema = Schema([Project.self, Task.self, User.self, Role.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [configuration])
    SampleData.createSampleData(in: container.mainContext)
    return container
}

@MainActor
private func createEmptyContainer() -> ModelContainer {
    let schema = Schema([Project.self, Task.self, User.self, Role.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [configuration])
    return container
}
*/

