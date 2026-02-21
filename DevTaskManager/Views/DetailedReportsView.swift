//
//  DetailedReportsView.swift
//  DevTaskManager
//
//  Created by Assistant on 2/20/26.
//  Renamed from ReportView.swift for clarity
//

import SwiftUI
import SwiftData

/// A detailed, tabbed report view with separate sections for Summary, Projects, Users, and Tasks
/// Includes export functionality for Text and CSV formats
struct DetailedReportsView: View
{
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var report: DevTaskManagerReport?
    @State private var isGenerating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedTab: ReportTab = .summary
    @State private var showShareSheet = false
    @State private var shareText = ""
    @State private var sharePDFData: Data?
    @State private var isGeneratingPDF = false
    
    enum ReportTab: String, CaseIterable
    {
        case summary = "Summary"
        case projects = "Projects"
        case users = "Users"
        case tasks = "Tasks"
    }
    
    var body: some View
    {
        NavigationStack
        {
            ZStack
            {
                // Background
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
                
                AppGradients.mainBackground
                    .ignoresSafeArea()
                
                if isGenerating
                {
                    ProgressView("Generating Report...")
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                        )
                }
                else if let report = report
                {
                    reportContent(report: report)
                }
                else
                {
                    emptyState
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
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.large)
            .toolbar
            {
                ToolbarItem(placement: .navigationBarLeading)
                {
                    Button("Close")
                    {
                        dismiss()
                    }
                }
                
                if report != nil
                {
                    ToolbarItemGroup(placement: .navigationBarTrailing)
                    {
                        Menu
                        {
                            Button(action: exportAsText)
                            {
                                Label("Export as Text", systemImage: "doc.text")
                            }
                            
                            Button(action: exportAsCSV)
                            {
                                Label("Export as CSV", systemImage: "tablecells")
                            }
                            
                            Button(action: exportAsPDF)
                            {
                                Label("Export as PDF", systemImage: "doc.richtext")
                            }
                            
                            Divider()
                            
                            Button(action: shareReport)
                            {
                                Label("Share Report", systemImage: "square.and.arrow.up")
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        
                        Button(action: generateReport)
                        {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            .sheet(isPresented: $showShareSheet)
            {
                if let pdfData = sharePDFData {
                    PDFShareSheet(pdfData: pdfData)
                } else if !shareText.isEmpty {
                    ReportShareSheet(items: [shareText])
                }
            }
            .alert("Error", isPresented: $showError)
            {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear
            {
                if report == nil
                {
                    generateReport()
                }
            }
        }
    }
    
    // MARK: - Content Views
    
    @ViewBuilder
    private func reportContent(report: DevTaskManagerReport) -> some View
    {
        VStack(spacing: 0)
        {
            // Report Header
            reportHeader(date: report.generatedDate)
            
            // Tab Picker
            Picker("Report Section", selection: $selectedTab)
            {
                ForEach(ReportTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Tab Content
            ScrollView
            {
                VStack(spacing: 16)
                {
                    switch selectedTab
                    {
                    case .summary:
                        summaryView(report: report)
                    case .projects:
                        projectsView(projects: report.detailedProjects)
                    case .users:
                        usersView(users: report.detailedUsers)
                    case .tasks:
                        tasksView(tasks: report.detailedTasks)
                    }
                }
                .padding()
            }
        }
    }
    
    private func reportHeader(date: Date) -> some View
    {
        VStack(spacing: 4)
        {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Generated Report")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text(date.formatted(date: .long, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
    }
    
    private var emptyState: some View
    {
        VStack(spacing: 20)
        {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 60))
                .foregroundStyle(.secondary.opacity(0.5))
            
            Text("No Report Generated")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Generate a report to see comprehensive data about your projects, users, and tasks.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: generateReport)
            {
                Label("Generate Report", systemImage: "chart.bar.doc.horizontal")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .padding(40)
    }
    
    // MARK: - Summary View
    
    @ViewBuilder
    private func summaryView(report: DevTaskManagerReport) -> some View
    {
        VStack(spacing: 16)
        {
            // Projects Summary Card
            SummaryCard(
                title: "Projects",
                icon: "folder.fill",
                gradient: AppGradients.projectGradient,
                content: {
                    VStack(spacing: 8) {
                        summaryRow("Total Projects", value: "\(report.projectsSummary.totalProjects)")
                        summaryRow("With Tasks", value: "\(report.projectsSummary.projectsWithTasks)")
                        summaryRow("Without Tasks", value: "\(report.projectsSummary.projectsWithoutTasks)")
                        summaryRow("Total Tasks", value: "\(report.projectsSummary.totalTasksAcrossProjects)")
                        summaryRow("Avg Tasks/Project", value: String(format: "%.1f", report.projectsSummary.averageTasksPerProject))
                    }
                }
            )
            
            // Users Summary Card
            SummaryCard(
                title: "Users",
                icon: "person.3.fill",
                gradient: AppGradients.userGradient,
                content: {
                    VStack(spacing: 8) {
                        summaryRow("Total Users", value: "\(report.usersSummary.totalUsers)")
                        summaryRow("With Tasks", value: "\(report.usersSummary.usersWithTasks)")
                        summaryRow("Without Tasks", value: "\(report.usersSummary.usersWithoutTasks)")
                        summaryRow("Total Assigned", value: "\(report.usersSummary.totalTasksAssigned)")
                        summaryRow("Avg Tasks/User", value: String(format: "%.1f", report.usersSummary.averageTasksPerUser))
                        if let mostActive = report.usersSummary.mostActiveUser {
                            summaryRow("Most Active", value: "\(mostActive) (\(report.usersSummary.mostActiveUserTaskCount))")
                        }
                    }
                }
            )
            
            // Tasks Summary Card
            SummaryCard(
                title: "Tasks",
                icon: "checklist",
                gradient: AppGradients.taskGradient,
                content: {
                    VStack(spacing: 8) {
                        summaryRow("Total Tasks", value: "\(report.tasksSummary.totalTasks)")
                        Divider()
                        summaryRow("Unassigned", value: "\(report.tasksSummary.unassignedTasks)", badge: .orange)
                        summaryRow("In Progress", value: "\(report.tasksSummary.inProgressTasks)", badge: .blue)
                        summaryRow("Completed", value: "\(report.tasksSummary.completedTasks)", badge: .green)
                        summaryRow("Deferred", value: "\(report.tasksSummary.deferredTasks)", badge: .gray)
                        Divider()
                        summaryRow("Completed This Week", value: "\(report.tasksSummary.completedThisWeek)")
                        summaryRow("Completed This Month", value: "\(report.tasksSummary.completedThisMonth)")
                    }
                }
            )
        }
    }
    
    // MARK: - Projects View
    
    @ViewBuilder
    private func projectsView(projects: [ProjectReport]) -> some View
    {
        if projects.isEmpty
        {
            Text("No projects found")
                .foregroundStyle(.secondary)
                .padding()
        }
        else
        {
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
                            Label("Created", systemImage: "calendar")
                                .font(.caption)
                            Text(project.dateCreated.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                            
                            Spacer()
                            
                            Label("\(project.taskCount)", systemImage: "checkmark.circle")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                        
                        // Task breakdown
                        HStack(spacing: 12)
                        {
                            taskBadge("✓ \(project.completedTaskCount)", color: .green)
                            taskBadge("⏳ \(project.inProgressTaskCount)", color: .blue)
                            taskBadge("○ \(project.unassignedTaskCount)", color: .orange)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Users View
    
    @ViewBuilder
    private func usersView(users: [UserReport]) -> some View
    {
        if users.isEmpty
        {
            Text("No users found")
                .foregroundStyle(.secondary)
                .padding()
        }
        else
        {
            ForEach(users) { user in
                ModernListRow
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        Text(user.name)
                            .font(.headline)
                        
                        if !user.roles.isEmpty
                        {
                            Text(user.roles.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundStyle(.purple)
                        }
                        
                        HStack
                        {
                            Label("Joined", systemImage: "calendar")
                                .font(.caption)
                            Text(user.dateCreated.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                            
                            Spacer()
                            
                            Label("\(user.totalTasksAssigned) tasks", systemImage: "checkmark.circle")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                        
                        // Task breakdown
                        HStack(spacing: 12)
                        {
                            taskBadge("✓ \(user.completedTasks)", color: .green)
                            taskBadge("⏳ \(user.inProgressTasks)", color: .blue)
                            taskBadge("○ \(user.unassignedTasks)", color: .orange)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Tasks View
    
    @ViewBuilder
    private func tasksView(tasks: [TaskReport]) -> some View
    {
        if tasks.isEmpty
        {
            Text("No tasks found")
                .foregroundStyle(.secondary)
                .padding()
        }
        else
        {
            ForEach(tasks) { task in
                ModernListRow
                {
                    VStack(alignment: .leading, spacing: 8)
                    {
                        HStack
                        {
                            Text(task.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            priorityBadge(task.taskPriority)
                        }
                        
                        HStack
                        {
                            Image(systemName: "folder.fill")
                                .font(.caption)
                                .foregroundStyle(.blue)
                            Text(task.projectName)
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                        
                        if let assignee = task.assignedUserName
                        {
                            HStack
                            {
                                Image(systemName: "person.fill")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                                Text("Assigned to \(assignee)")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                            }
                        }
                        
                        HStack
                        {
                            Label(task.taskType, systemImage: "hammer.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            statusBadge(task.taskStatus)
                        }
                        
                        Text("Created: \(task.dateCreated.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func summaryRow(_ label: String, value: String, badge: Color? = nil) -> some View
    {
        HStack
        {
            Text(label)
                .font(.body)
            
            Spacer()
            
            if let badge = badge
            {
                Text(value)
                    .font(.body)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badge.opacity(0.2))
                    .foregroundStyle(badge)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            else
            {
                Text(value)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
        }
    }
    
    private func taskBadge(_ text: String, color: Color) -> some View
    {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    private func statusBadge(_ status: String) -> some View
    {
        let color: Color = {
            switch status.lowercased() {
            case "completed": return .green
            case "in progress": return .blue
            case "unassigned": return .orange
            case "deferred": return .gray
            default: return .secondary
            }
        }()
        
        return Text(status)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    private func priorityBadge(_ priority: String) -> some View
    {
        let color: Color = {
            switch priority.lowercased() {
            case "high": return .red
            case "medium": return .orange
            case "low": return .green
            default: return .gray
            }
        }()
        
        return Text(priority)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    // MARK: - Actions
    
    private func generateReport()
    {
        isGenerating = true
        
        _Concurrency.Task {
            do
            {
                let generatedReport = try ReportGenerator.generateDetailedReport(context: modelContext)
                await MainActor.run {
                    self.report = generatedReport
                    self.isGenerating = false
                }
            }
            catch
            {
                await MainActor.run {
                    self.errorMessage = "Failed to generate report: \(error.localizedDescription)"
                    self.showError = true
                    self.isGenerating = false
                }
            }
        }
    }
    
    private func exportAsText()
    {
        guard let report = report else { return }
        
        let text = ReportGenerator.generateTextReport(report: report)
        sharePDFData = nil
        shareText = text
        showShareSheet = true
    }
    
    private func exportAsCSV()
    {
        guard let report = report else { return }
        
        let csv = ReportGenerator.generateCSVReport(report: report)
        sharePDFData = nil
        shareText = csv
        showShareSheet = true
    }
    
    private func exportAsPDF()
    {
        guard let report = report else { return }
        
        isGeneratingPDF = true
        
        _Concurrency.Task { @MainActor in
            if let pdfData = PDFReportGenerator.generatePDF(from: report) {
                shareText = ""
                sharePDFData = pdfData
                showShareSheet = true
            } else {
                errorMessage = "Failed to generate PDF"
                showError = true
            }
            isGeneratingPDF = false
        }
    }
    
    private func shareReport()
    {
        guard let report = report else { return }
        
        let text = ReportGenerator.generateTextReport(report: report)
        sharePDFData = nil
        shareText = text
        showShareSheet = true
    }
}

// MARK: - Summary Card Component

struct SummaryCard<Content: View>: View
{
    let title: String
    let icon: String
    let gradient: LinearGradient
    @ViewBuilder let content: () -> Content
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 12)
        {
            HStack
            {
                ZStack
                {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(gradient)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        )
    }
}

// MARK: - Preview

// Commented out temporarily to resolve compilation issues
/*
#Preview("With Sample Data") {
    DetailedReportsView()
        .modelContainer(createPreviewContainer())
}

@MainActor
private func createPreviewContainer() -> ModelContainer {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Project.self, User.self, Role.self, Task.self, TaskItem.self,
        configurations: configuration
    )
    SampleData.createSampleData(in: container.mainContext)
    return container
}
*/
