//
//  UserTasksView.swift
//  DevTaskManager
//
//  Created by Assistant on 2/19/26.
//
import SwiftData
import SwiftUI

struct UserTasksView: View
{
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @Bindable var user: User

    var isFromUserList: Bool = false
    var onDismissToMain: (() -> Void)? = nil

    @Binding var path: [AppNavigationDestination]
    @State private var sortOrder = SortOrder.dateNewest

    // Sort order options
    enum SortOrder: String, CaseIterable
    {
        case taskNameAscending = "Task Name A-Z"
        case taskNameDescending = "Task Name Z-A"
        case projectAscending = "Project A-Z"
        case projectDescending = "Project Z-A"

        // Task Type options
        case taskTypeDevelopment = "Development"
        case taskTypeRequirements = "Requirements"
        case taskTypeDesign = "Design"
        case taskTypeUseCases = "Use Cases"
        case taskTypeTesting = "Testing"
        case taskTypeDocumentation = "Documentation"
        case taskTypeDatabase = "Database"
        case taskTypeDefectCorrection = "Defect Correction"

        // Priority options
        case priorityHigh = "High"
        case priorityMedium = "Medium"
        case priorityLow = "Low"
        case priorityEnhancement = "Enhancement"

        // Status options
        case statusUnassigned = "Unassigned"
        case statusInProgress = "In Progress"
        case statusCompleted = "Completed"
        case statusDeferred = "Deferred"

        case dateNewest = "Newest First"
        case dateOldest = "Oldest First"
    }

    // Computed property for sorted tasks
    private var sortedTasks: [Task]
    {
        let tasks = user.tasks

        switch sortOrder
        {
        case .taskNameAscending:
            return tasks.sorted { $0.taskName < $1.taskName }
        case .taskNameDescending:
            return tasks.sorted { $0.taskName > $1.taskName }
        case .projectAscending:
            return tasks.sorted { ($0.project?.title ?? "") < ($1.project?.title ?? "") }
        case .projectDescending:
            return tasks.sorted { ($0.project?.title ?? "") > ($1.project?.title ?? "") }

        // Task Type filtering and sorting
        case .taskTypeDevelopment:
            return tasks.filter { $0.taskType == "Development" }.sorted { $0.taskName < $1.taskName }
        case .taskTypeRequirements:
            return tasks.filter { $0.taskType == "Requirements" }.sorted { $0.taskName < $1.taskName }
        case .taskTypeDesign:
            return tasks.filter { $0.taskType == "Design" }.sorted { $0.taskName < $1.taskName }
        case .taskTypeUseCases:
            return tasks.filter { $0.taskType == "Use Cases" }.sorted { $0.taskName < $1.taskName }
        case .taskTypeTesting:
            return tasks.filter { $0.taskType == "Testing" }.sorted { $0.taskName < $1.taskName }
        case .taskTypeDocumentation:
            return tasks.filter { $0.taskType == "Documentation" }.sorted { $0.taskName < $1.taskName }
        case .taskTypeDatabase:
            return tasks.filter { $0.taskType == "Database" }.sorted { $0.taskName < $1.taskName }
        case .taskTypeDefectCorrection:
            return tasks.filter { $0.taskType == "Defect Correction" }.sorted { $0.taskName < $1.taskName }

        // Priority filtering and sorting
        case .priorityHigh:
            return tasks.filter { $0.taskPriority == "High" }.sorted { $0.taskName < $1.taskName }
        case .priorityMedium:
            return tasks.filter { $0.taskPriority == "Medium" }.sorted { $0.taskName < $1.taskName }
        case .priorityLow:
            return tasks.filter { $0.taskPriority == "Low" }.sorted { $0.taskName < $1.taskName }
        case .priorityEnhancement:
            return tasks.filter { $0.taskPriority == "Enhancement" }.sorted { $0.taskName < $1.taskName }

        // Status filtering and sorting
        case .statusUnassigned:
            return tasks.filter { $0.taskStatus == "Unassigned" }.sorted { $0.taskName < $1.taskName }
        case .statusInProgress:
            return tasks.filter { $0.taskStatus == "In Progress" }.sorted { $0.taskName < $1.taskName }
        case .statusCompleted:
            return tasks.filter { $0.taskStatus == "Completed" }.sorted { $0.taskName < $1.taskName }
        case .statusDeferred:
            return tasks.filter { $0.taskStatus == "Deferred" }.sorted { $0.taskName < $1.taskName }

        case .dateNewest:
            return tasks.sorted { $0.dateCreated > $1.dateCreated }
        case .dateOldest:
            return tasks.sorted { $0.dateCreated < $1.dateCreated }
        }
    }

    var body: some View
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
                    icon: "person.fill",
                    title: user.fullName(),
                    subtitle: "\(sortedTasks.count) assigned task\(sortedTasks.count == 1 ? "" : "s")",
                    gradientColors: [.purple, .pink]
                )

                if !user.tasks.isEmpty
                {
                    ScrollView
                    {
                        LazyVStack(spacing: 8)
                        {
                            ForEach(sortedTasks)
                            { task in
                                NavigationLink(value: AppNavigationDestination.taskDetail(task, context: .userTasksList))
                                {
                                    ModernListRow
                                    {
                                        VStack(alignment: .leading, spacing: 8)
                                        {
                                            // Project name at the top
                                            if let project = task.project
                                            {
                                                HStack
                                                {
                                                    Image(systemName: "folder.fill")
                                                        .font(.caption)
                                                        .foregroundStyle(.blue)
                                                    Text(project.title.isEmpty ? "Untitled Project" : project.title)
                                                        .font(.caption)
                                                        .foregroundStyle(.blue)
                                                }
                                            }

                                            // Task Name with Priority
                                            HStack(spacing: 8)
                                            {
                                                Image(systemName: priorityIcon(for: task.taskPriority))
                                                    .font(.headline)
                                                    .foregroundStyle(priorityColor(for: task.taskPriority))

                                                Text(task.taskName.isEmpty ? "Untitled Task" : task.taskName)
                                                    .font(.headline)
                                            }

                                            // Task Details
                                            HStack(spacing: 12)
                                            {
                                                Label(task.taskType, systemImage: "hammer.fill")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)

                                                Spacer()

                                                Label(task.taskStatus, systemImage: statusIcon(for: task.taskStatus))
                                                    .font(.caption)
                                                    .foregroundStyle(statusColor(for: task.taskStatus))
                                                    .labelStyle(.titleAndIcon)
                                            }

                                            // Date Assigned
                                            if let dateAssigned = task.dateAssigned
                                            {
                                                HStack
                                                {
                                                    Image(systemName: "calendar")
                                                        .font(.caption2)
                                                        .foregroundStyle(.secondary)
                                                    Text("Assigned: \(dateAssigned.formatted(date: .abbreviated, time: .omitted))")
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                }
                                            }
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                else
                {
                    Spacer()
                    EmptyStateCard(
                        icon: "checkmark.circle",
                        title: "No Tasks Assigned",
                        message: "\(user.fullName()) has no tasks currently assigned"
                    )
                    Spacer()
                }
            }
        }
        .toolbar
        {
            ToolbarItem(placement: .topBarLeading)
            {
                Menu
                {
                    Button(action: {
                        // Navigate back to User List by clearing the path
                        withAnimation
                        {
                            path.removeAll()
                        }
                    })
                    {
                        Label("Back to User List", systemImage: "person.3.fill")
                    }

                    Button(action: {
                        // Return to Main Menu - use provided closure or fallback to dismiss
                        if let onDismissToMain = onDismissToMain
                        {
                            onDismissToMain()
                        }
                        else
                        {
                            path.removeAll()
                            dismiss()
                        }
                    })
                    {
                        Label("Return To Main Menu", systemImage: "house.fill")
                    }
                } label: {
                    HStack(spacing: 4)
                    {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundStyle(AppGradients.userGradient)
                }
            }

            ToolbarItemGroup(placement: .topBarTrailing)
            {
                Menu
                {
                    Picker("Sort by", selection: $sortOrder)
                    {
                        Text("Task Name A-Z").tag(SortOrder.taskNameAscending)
                        Text("Task Name Z-A").tag(SortOrder.taskNameDescending)
                        Text("Project A-Z").tag(SortOrder.projectAscending)
                        Text("Project Z-A").tag(SortOrder.projectDescending)
                        Text("Newest First").tag(SortOrder.dateNewest)
                        Text("Oldest First").tag(SortOrder.dateOldest)
                    }
                    .pickerStyle(.inline)

                    Divider()

                    Menu("Filter by Task Type")
                    {
                        Button("Development") { sortOrder = .taskTypeDevelopment }
                        Button("Requirements") { sortOrder = .taskTypeRequirements }
                        Button("Design") { sortOrder = .taskTypeDesign }
                        Button("Use Cases") { sortOrder = .taskTypeUseCases }
                        Button("Testing") { sortOrder = .taskTypeTesting }
                        Button("Documentation") { sortOrder = .taskTypeDocumentation }
                        Button("Database") { sortOrder = .taskTypeDatabase }
                        Button("Defect Correction") { sortOrder = .taskTypeDefectCorrection }
                    }

                    Menu("Filter by Priority")
                    {
                        Button("High") { sortOrder = .priorityHigh }
                        Button("Medium") { sortOrder = .priorityMedium }
                        Button("Low") { sortOrder = .priorityLow }
                        Button("Enhancement") { sortOrder = .priorityEnhancement }
                    }

                    Menu("Filter by Status")
                    {
                        Button("Unassigned") { sortOrder = .statusUnassigned }
                        Button("In Progress") { sortOrder = .statusInProgress }
                        Button("Completed") { sortOrder = .statusCompleted }
                        Button("Deferred") { sortOrder = .statusDeferred }
                    }

                    Divider()

                    Button(action: {
                        path.append(.userDetail(user))
                    })
                    {
                        Label("Edit User", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(AppGradients.userGradient)
                }
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Helper Functions

    private func priorityIcon(for priority: String) -> String
    {
        switch priority.lowercased()
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

    private func priorityColor(for priority: String) -> Color
    {
        switch priority.lowercased()
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

    private func statusIcon(for status: String) -> String
    {
        switch status.lowercased()
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

    private func statusColor(for status: String) -> Color
    {
        switch status.lowercased()
        {
            case "unassigned":
                return .orange.opacity(0.8) // Light orange
            case "completed":
                return .green
            case "in progress", "inprogress":
                return .blue.opacity(0.7) // Light blue
            default:
                return .secondary
        }
    }
}
