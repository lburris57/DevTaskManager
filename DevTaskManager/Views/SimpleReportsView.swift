//
//  SimpleReportsView.swift
//  DevTaskManager
//
//  Created by Assistant on 2/20/26.
//  Renamed from ReportsView.swift for clarity
//
import SwiftData
import SwiftUI

/// A simple, single-page report view showing overview statistics, projects, users, and task analysis
struct SimpleReportsView: View
{
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var reportData: ReportData?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showShareSheet = false
    
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
                        Button(action: { showShareSheet = true })
                        {
                            Image(systemName: "square.and.arrow.up")
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
                if let data = reportData {
                    ReportShareSheet(items: [generateReportText(data: data)])
                }
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
                
                // Summary Statistics
                VStack(spacing: 16)
                {
                    statisticsSection(data: data)
                    
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
                    statRow(label: "Unassigned", value: "\(data.unassignedTasks)", color: .gray)
                    Divider()
                    statRow(label: "Completion Rate", value: String(format: "%.1f%%", data.completionRate), color: .green)
                }
            }
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
                let data = try ReportGenerator.generateReport(context: modelContext)
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
}

// MARK: - Share Sheet

struct ReportShareSheet: UIViewControllerRepresentable
{
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController
    {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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

