//
//  DashboardView.swift
//  DevTaskManager
//
//  Created by Assistant on 2/20/26.
//
import SwiftData
import SwiftUI

struct DashboardView: View
{
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @Query var tasks: [Task]
    @Query var projects: [Project]
    @Query var users: [User]

    @State private var path: [AppNavigationDestination] = []

    var body: some View
    {
        NavigationStack(path: $path)
        {
            ZStack
            {
                // Solid background to prevent content showing through
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()

                // Modern gradient background overlay
                AppGradients.mainBackground
                    .ignoresSafeArea()

                VStack(spacing: 0)
                {
                    // Modern header
                    ModernHeaderView(
                        icon: "chart.bar.fill",
                        title: "Dashboard",
                        subtitle: "Overview of your projects",
                        gradientColors: [.blue, .purple]
                    )

                    ScrollView
                    {
                        VStack(spacing: 16)
                        {
                            // Quick Stats Row
                            quickStatsSection

                            // Task Status Breakdown
                            taskStatusSection

                            // Priority Breakdown
                            priorityBreakdownSection

                            // Recent Activity
                            recentActivitySection

                            // Project Progress
                            projectProgressSection
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar
            {
                ToolbarItem(placement: .navigationBarLeading)
                {
                    Button(action: {
                        dismiss()
                    })
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
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(for: AppNavigationDestination.self)
            { destination in
                destinationView(for: destination)
            }
        }
    }

    // MARK: - Quick Stats Section

    private var quickStatsSection: some View
    {
        VStack(spacing: 0)
        {
            HStack(spacing: 12)
            {
                // Total Tasks
                StatCard(
                    icon: "checklist",
                    title: "Tasks",
                    value: "\(tasks.count)",
                    gradientColors: [.orange, .red]
                )

                // Total Projects
                StatCard(
                    icon: "folder.fill",
                    title: "Projects",
                    value: "\(projects.count)",
                    gradientColors: [.blue, .cyan]
                )

                // Total Users
                StatCard(
                    icon: "person.3.fill",
                    title: "Users",
                    value: "\(users.count)",
                    gradientColors: [.purple, .pink]
                )
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Task Status Section

    private var taskStatusSection: some View
    {
        DashboardCard(title: "Task Status", icon: "chart.pie.fill")
        {
            VStack(spacing: 12)
            {
                StatusRow(
                    label: "Unassigned",
                    count: tasksByStatus(.unassigned).count,
                    total: tasks.count,
                    color: .orange,
                    icon: "circle.dashed"
                )

                StatusRow(
                    label: "In Progress",
                    count: tasksByStatus(.inProgress).count,
                    total: tasks.count,
                    color: .blue,
                    icon: "clock.fill"
                )

                StatusRow(
                    label: "Completed",
                    count: tasksByStatus(.completed).count,
                    total: tasks.count,
                    color: .green,
                    icon: "checkmark.circle.fill"
                )

                StatusRow(
                    label: "Deferred",
                    count: tasksByStatus(.deferred).count,
                    total: tasks.count,
                    color: .gray,
                    icon: "pause.circle.fill"
                )
            }
        }
    }

    // MARK: - Priority Breakdown Section

    private var priorityBreakdownSection: some View
    {
        DashboardCard(title: "Priority Breakdown", icon: "exclamationmark.triangle.fill")
        {
            VStack(spacing: 12)
            {
                PriorityRow(
                    label: "High",
                    count: tasksByPriority(.high).count,
                    total: tasks.count,
                    color: .red,
                    icon: "exclamationmark.circle.fill"
                )

                PriorityRow(
                    label: "Medium",
                    count: tasksByPriority(.medium).count,
                    total: tasks.count,
                    color: .orange,
                    icon: "exclamationmark.circle.fill"
                )

                PriorityRow(
                    label: "Low",
                    count: tasksByPriority(.low).count,
                    total: tasks.count,
                    color: .green,
                    icon: "minus.circle.fill"
                )

                PriorityRow(
                    label: "Enhancement",
                    count: tasksByPriority(.enhancement).count,
                    total: tasks.count,
                    color: .blue,
                    icon: "star.fill"
                )
            }
        }
    }

    // MARK: - Recent Activity Section

    private var recentActivitySection: some View
    {
        DashboardCard(title: "Recent Tasks", icon: "clock.arrow.circlepath")
        {
            if tasks.isEmpty
            {
                Text("No tasks yet")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
            else
            {
                VStack(spacing: 8)
                {
                    ForEach(recentTasks.prefix(5))
                    { task in
                        Button(action: {
                            path.append(.taskDetail(task, context: .taskList))
                        })
                        {
                            RecentTaskRow(task: task)
                        }
                        .buttonStyle(.plain)

                        if task != recentTasks.prefix(5).last
                        {
                            Divider()
                                .padding(.leading, 8)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Project Progress Section

    private var projectProgressSection: some View
    {
        DashboardCard(title: "Project Progress", icon: "chart.bar.fill")
        {
            if projects.isEmpty
            {
                Text("No projects yet")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
            else
            {
                VStack(spacing: 16)
                {
                    ForEach(projects.prefix(5))
                    { project in
                        Button(action: {
                            path.append(.projectDetail(project))
                        })
                        {
                            ProjectProgressRow(project: project)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Navigation

    @ViewBuilder
    private func destinationView(for destination: AppNavigationDestination) -> some View
    {
        switch destination
        {
        case let .taskDetail(task, context):
            TaskDetailView(task: task, path: $path, onDismissToMain: { dismiss() }, sourceContext: context)
        case let .projectDetail(project):
            ProjectDetailView(project: project, path: $path, onDismissToMain: { dismiss() })
        case let .userDetail(user):
            UserDetailView(user: user, path: $path)
        case let .projectTasks(project):
            ProjectTasksView(project: project, path: $path)
        case let .userTasks(user):
            UserTasksView(user: user, path: $path)
        }
    }

    // MARK: - Helper Functions

    private func tasksByStatus(_ status: TaskStatusEnum) -> [Task]
    {
        tasks.filter { $0.taskStatus == status.title }
    }

    private func tasksByPriority(_ priority: TaskPriorityEnum) -> [Task]
    {
        tasks.filter { $0.taskPriority == priority.title }
    }

    private var recentTasks: [Task]
    {
        tasks.sorted { $0.dateCreated > $1.dateCreated }
    }

    private func completionPercentage(for project: Project) -> Double
    {
        guard !project.tasks.isEmpty else { return 0.0 }
        let completedCount = project.tasks.filter { $0.taskStatus == TaskStatusEnum.completed.title }.count
        return Double(completedCount) / Double(project.tasks.count)
    }
}

// MARK: - Stat Card Component

struct StatCard: View
{
    let icon: String
    let title: String
    let value: String
    let gradientColors: [Color]

    var body: some View
    {
        VStack(spacing: 8)
        {
            ZStack
            {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: gradientColors.first?.opacity(0.3) ?? .clear, radius: 6, x: 0, y: 3)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        )
    }
}

// MARK: - Dashboard Card Component

struct DashboardCard<Content: View>: View
{
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content)
    {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            HStack
            {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(.blue)

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()
            }

            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Status Row Component

struct StatusRow: View
{
    let label: String
    let count: Int
    let total: Int
    let color: Color
    let icon: String

    private var percentage: Double
    {
        guard total > 0 else { return 0.0 }
        return Double(count) / Double(total)
    }

    var body: some View
    {
        VStack(spacing: 6)
        {
            HStack
            {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                    .frame(width: 20)

                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer()

                Text("\(count)")
                    .font(.subheadline.bold())
                    .foregroundStyle(color)

                Text("(\(Int(percentage * 100))%)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Progress bar
            GeometryReader
            { geometry in
                ZStack(alignment: .leading)
                {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * percentage, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Priority Row Component

struct PriorityRow: View
{
    let label: String
    let count: Int
    let total: Int
    let color: Color
    let icon: String

    private var percentage: Double
    {
        guard total > 0 else { return 0.0 }
        return Double(count) / Double(total)
    }

    var body: some View
    {
        VStack(spacing: 6)
        {
            HStack
            {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
                    .frame(width: 20)

                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer()

                Text("\(count)")
                    .font(.subheadline.bold())
                    .foregroundStyle(color)

                Text("(\(Int(percentage * 100))%)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Progress bar
            GeometryReader
            { geometry in
                ZStack(alignment: .leading)
                {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * percentage, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Recent Task Row Component

struct RecentTaskRow: View
{
    let task: Task

    var body: some View
    {
        HStack(spacing: 12)
        {
            // Priority icon
            Image(systemName: priorityIcon)
                .font(.title3)
                .foregroundStyle(priorityColor)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4)
            {
                Text(task.taskName.isEmpty ? "Untitled Task" : task.taskName)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 8)
                {
                    if let project = task.project
                    {
                        Label(project.title.isEmpty ? "No Project" : project.title, systemImage: "folder.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .lineLimit(1)
                    }

                    Label(task.taskStatus, systemImage: statusIcon)
                        .font(.caption)
                        .foregroundStyle(statusColor)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }

    private var priorityIcon: String
    {
        switch task.taskPriority.lowercased()
        {
        case "high":
            return "exclamationmark.circle.fill"
        case "medium":
            return "exclamationmark.circle.fill"
        case "low":
            return "minus.circle.fill"
        default:
            return "circle.fill"
        }
    }

    private var priorityColor: Color
    {
        switch task.taskPriority.lowercased()
        {
        case "high":
            return .red
        case "medium":
            return .orange
        case "low":
            return .green
        default:
            return .gray
        }
    }

    private var statusIcon: String
    {
        switch task.taskStatus.lowercased()
        {
        case "completed":
            return "checkmark.circle.fill"
        case "in progress", "inprogress":
            return "clock.fill"
        case "unassigned":
            return "circle.dashed"
        default:
            return "circle"
        }
    }

    private var statusColor: Color
    {
        switch task.taskStatus.lowercased()
        {
        case "unassigned":
            return .orange.opacity(0.8)
        case "completed":
            return .green
        case "in progress", "inprogress":
            return .blue.opacity(0.7)
        default:
            return .secondary
        }
    }
}

// MARK: - Project Progress Row Component

struct ProjectProgressRow: View
{
    let project: Project

    private var completionPercentage: Double
    {
        guard !project.tasks.isEmpty else { return 0.0 }
        let completedCount = project.tasks.filter { $0.taskStatus == TaskStatusEnum.completed.title }.count
        return Double(completedCount) / Double(project.tasks.count)
    }

    private var completedTasksCount: Int
    {
        project.tasks.filter { $0.taskStatus == TaskStatusEnum.completed.title }.count
    }

    var body: some View
    {
        VStack(alignment: .leading, spacing: 8)
        {
            HStack
            {
                Image(systemName: "folder.fill")
                    .font(.headline)
                    .foregroundStyle(.blue)

                Text(project.title.isEmpty ? "Untitled Project" : project.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Spacer()

                Text("\(completedTasksCount)/\(project.tasks.count)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            // Progress bar
            GeometryReader
            { geometry in
                ZStack(alignment: .leading)
                {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.blue.opacity(0.2))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * completionPercentage, height: 8)
                }
            }
            .frame(height: 8)

            HStack
            {
                Text("\(Int(completionPercentage * 100))% Complete")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if project.tasks.isEmpty
                {
                    Text("No tasks")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                else if completionPercentage == 1.0
                {
                    HStack(spacing: 4)
                    {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                        Text("Complete")
                            .font(.caption)
                    }
                    .foregroundStyle(.green)
                }
                else
                {
                    Text("\(project.tasks.count - completedTasksCount) remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

#Preview("With Sample Data", traits: .modifier(SampleDataPreviewModifier()))
{
    DashboardView()
}

#Preview("Empty State", traits: .modifier(EmptyDataPreviewModifier()))
{
    DashboardView()
}
