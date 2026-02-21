//
//  TaskListView.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/20/25.
//
import SwiftData
import SwiftUI

struct TaskListView: View
{
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var path: [AppNavigationDestination] = []
    @State private var showDeleteToast = false
    @State private var deletedTaskName = ""
    @State private var sortOrder = SortOrder.dateNewest
    @State private var searchText = ""

    @Query(sort: \Task.taskName) var tasks: [Task]

    @Query(sort: \User.lastName) var users: [User]

    @Query(sort: \Role.roleName) var roles: [Role]

    // Sort order options
    enum SortOrder: String, CaseIterable
    {
        case taskNameAscending = "Task Name A-Z"
        case taskNameDescending = "Task Name Z-A"
        case projectAscending = "Project A-Z"
        case projectDescending = "Project Z-A"
        case projectNewest = "Project Newest First"
        case projectOldest = "Project Oldest First"

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
    
    // Computed property for active filter badges
    private var activeFilterBadges: [FilterBadgesContainer.FilterBadge] {
        var badges: [FilterBadgesContainer.FilterBadge] = []
        
        // Add badge for task type filters
        switch sortOrder {
        case .taskTypeDevelopment:
            badges.append(.init(
                text: "Type: Development",
                icon: "hammer.fill",
                onClear: { sortOrder = .dateNewest }
            ))
        case .taskTypeRequirements:
            badges.append(.init(
                text: "Type: Requirements",
                icon: "hammer.fill",
                onClear: { sortOrder = .dateNewest }
            ))
        case .taskTypeDesign:
            badges.append(.init(
                text: "Type: Design",
                icon: "hammer.fill",
                onClear: { sortOrder = .dateNewest }
            ))
        case .taskTypeUseCases:
            badges.append(.init(
                text: "Type: Use Cases",
                icon: "hammer.fill",
                onClear: { sortOrder = .dateNewest }
            ))
        case .taskTypeTesting:
            badges.append(.init(
                text: "Type: Testing",
                icon: "hammer.fill",
                onClear: { sortOrder = .dateNewest }
            ))
        case .taskTypeDocumentation:
            badges.append(.init(
                text: "Type: Documentation",
                icon: "hammer.fill",
                onClear: { sortOrder = .dateNewest }
            ))
        case .taskTypeDatabase:
            badges.append(.init(
                text: "Type: Database",
                icon: "hammer.fill",
                onClear: { sortOrder = .dateNewest }
            ))
        case .taskTypeDefectCorrection:
            badges.append(.init(
                text: "Type: Defect Correction",
                icon: "hammer.fill",
                onClear: { sortOrder = .dateNewest }
            ))
            
        // Add badge for priority filters
        case .priorityHigh:
            badges.append(.init(
                text: "Priority: High",
                icon: "exclamationmark.circle.fill",
                onClear: { sortOrder = .dateNewest }
            ))
        case .priorityMedium:
            badges.append(.init(
                text: "Priority: Medium",
                icon: "exclamationmark.circle.fill",
                onClear: { sortOrder = .dateNewest }
            ))
        case .priorityLow:
            badges.append(.init(
                text: "Priority: Low",
                icon: "minus.circle.fill",
                onClear: { sortOrder = .dateNewest }
            ))
        case .priorityEnhancement:
            badges.append(.init(
                text: "Priority: Enhancement",
                icon: "star.fill",
                onClear: { sortOrder = .dateNewest }
            ))
            
        // Add badge for status filters
        case .statusUnassigned:
            badges.append(.init(
                text: "Status: Unassigned",
                icon: "circle.dashed",
                onClear: { sortOrder = .dateNewest }
            ))
        case .statusInProgress:
            badges.append(.init(
                text: "Status: In Progress",
                icon: "clock.fill",
                onClear: { sortOrder = .dateNewest }
            ))
        case .statusCompleted:
            badges.append(.init(
                text: "Status: Completed",
                icon: "checkmark.circle.fill",
                onClear: { sortOrder = .dateNewest }
            ))
        case .statusDeferred:
            badges.append(.init(
                text: "Status: Deferred",
                icon: "pause.circle.fill",
                onClear: { sortOrder = .dateNewest }
            ))
            
        default:
            break // No badge for sort-only options
        }
        
        return badges
    }

    // Computed property for sorted and filtered tasks
    private var sortedTasks: [Task]
    {
        // First apply search filter
        let filteredTasks: [Task]
        if searchText.isEmpty
        {
            filteredTasks = tasks
        }
        else
        {
            filteredTasks = tasks.filter
            {
                $0.taskName.localizedCaseInsensitiveContains(searchText) ||
                    $0.taskComment.localizedCaseInsensitiveContains(searchText) ||
                    ($0.project?.title ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }

        // Then apply sorting/filtering based on sort order
        switch sortOrder
        {
        case .taskNameAscending:
            return filteredTasks.sorted { $0.taskName < $1.taskName }
        case .taskNameDescending:
            return filteredTasks.sorted { $0.taskName > $1.taskName }
        case .projectAscending:
            return filteredTasks.sorted { ($0.project?.title ?? "") < ($1.project?.title ?? "") }
        case .projectDescending:
            return filteredTasks.sorted { ($0.project?.title ?? "") > ($1.project?.title ?? "") }
        case .projectNewest:
            return filteredTasks.sorted { ($0.project?.dateCreated ?? Date.distantPast) > ($1.project?.dateCreated ?? Date.distantPast) }
        case .projectOldest:
            return filteredTasks.sorted { ($0.project?.dateCreated ?? Date.distantPast) < ($1.project?.dateCreated ?? Date.distantPast) }

        // Task Type filtering and sorting
        case .taskTypeDevelopment:
            return filteredTasks.filter { $0.taskType == "Development" }.sorted { $0.taskName < $1.taskName }
        case .taskTypeRequirements:
            return filteredTasks.filter { $0.taskType == "Requirements" }.sorted { $0.taskName < $1.taskName }
        case .taskTypeDesign:
            return filteredTasks.filter { $0.taskType == "Design" }.sorted { $0.taskName < $1.taskName }
        case .taskTypeUseCases:
            return filteredTasks.filter { $0.taskType == "Use Cases" }.sorted { $0.taskName < $1.taskName }
        case .taskTypeTesting:
            return filteredTasks.filter { $0.taskType == "Testing" }.sorted { $0.taskName < $1.taskName }
        case .taskTypeDocumentation:
            return filteredTasks.filter { $0.taskType == "Documentation" }.sorted { $0.taskName < $1.taskName }
        case .taskTypeDatabase:
            return filteredTasks.filter { $0.taskType == "Database" }.sorted { $0.taskName < $1.taskName }
        case .taskTypeDefectCorrection:
            return filteredTasks.filter { $0.taskType == "Defect Correction" }.sorted { $0.taskName < $1.taskName }

        // Priority filtering and sorting
        case .priorityHigh:
            return filteredTasks.filter { $0.taskPriority == "High" }.sorted { $0.taskName < $1.taskName }
        case .priorityMedium:
            return filteredTasks.filter { $0.taskPriority == "Medium" }.sorted { $0.taskName < $1.taskName }
        case .priorityLow:
            return filteredTasks.filter { $0.taskPriority == "Low" }.sorted { $0.taskName < $1.taskName }
        case .priorityEnhancement:
            return filteredTasks.filter { $0.taskPriority == "Enhancement" }.sorted { $0.taskName < $1.taskName }

        // Status filtering and sorting
        case .statusUnassigned:
            return filteredTasks.filter { $0.taskStatus == "Unassigned" }.sorted { $0.taskName < $1.taskName }
        case .statusInProgress:
            return filteredTasks.filter { $0.taskStatus == "In Progress" }.sorted { $0.taskName < $1.taskName }
        case .statusCompleted:
            return filteredTasks.filter { $0.taskStatus == "Completed" }.sorted { $0.taskName < $1.taskName }
        case .statusDeferred:
            return filteredTasks.filter { $0.taskStatus == "Deferred" }.sorted { $0.taskName < $1.taskName }

        case .dateNewest:
            return filteredTasks.sorted { $0.dateCreated > $1.dateCreated }
        case .dateOldest:
            return filteredTasks.sorted { $0.dateCreated < $1.dateCreated }
        }
    }

    // Helper function to assign numeric values to priorities for sorting
    private func priorityValue(for priority: String) -> Int
    {
        switch priority.lowercased()
        {
        case "high":
            return 3
        case "medium":
            return 2
        case "low":
            return 1
        default:
            return 0
        }
    }

    // Delete tasks
    func deleteTasks(at offsets: IndexSet)
    {
        for index in offsets
        {
            let task = sortedTasks[index]
            deletedTaskName = task.taskName.isEmpty ? "Untitled Task" : task.taskName
            modelContext.delete(task)
        }

        do
        {
            try modelContext.save()
            withAnimation
            {
                showDeleteToast = true
            }
        }
        catch
        {
            Log.error("Failed to delete task: \(error.localizedDescription)")
        }
    }

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
                        icon: "checklist",
                        title: "Tasks",
                        subtitle: "\(sortedTasks.count) total",
                        gradientColors: [.orange, .red]
                    )

                    // Modern search bar
                    HStack
                    {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search tasks", text: $searchText)
                            .textFieldStyle(.plain)

                        if !searchText.isEmpty
                        {
                            Button(action: { searchText = "" })
                            {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    
                    // Filter badges - shows active filters
                    FilterBadgesContainer(badges: activeFilterBadges)

                    if !tasks.isEmpty
                    {
                        ScrollView
                        {
                            LazyVStack(spacing: 8)
                            {
                                ForEach(sortedTasks)
                                { task in
                                    NavigationLink(value: AppNavigationDestination.taskDetail(task, context: .taskList))
                                    {
                                        ModernListRow
                                        {
                                            taskRowContent(for: task)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu
                                    {
                                        Button(role: .destructive)
                                        {
                                            if let index = sortedTasks.firstIndex(where: { $0.id == task.id })
                                            {
                                                deleteTasks(at: IndexSet(integer: index))
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .id(task.taskId)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    else
                    {
                        Spacer()
                        EmptyStateCard(
                            icon: "checklist.unchecked",
                            title: "No Tasks Yet",
                            message: "Create your first task to start tracking your work",
                            buttonTitle: "Add Task",
                            buttonAction: {
                                let task = Task(taskName: Constants.EMPTY_STRING)
                                path.append(.taskDetail(task, context: .taskList))
                            }
                        )
                        Spacer()
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
                        .foregroundStyle(AppGradients.taskGradient)
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing)
                {
                    // Only show sort/filter menu when there are tasks
                    if !tasks.isEmpty
                    {
                        Menu
                        {
                            // Task Name submenu
                            Menu("Task Name")
                            {
                                Button(action: { sortOrder = .taskNameAscending })
                                {
                                    if sortOrder == .taskNameAscending {
                                        Label("A-Z", systemImage: "checkmark")
                                    } else {
                                        Text("A-Z")
                                    }
                                }

                                Button(action: { sortOrder = .taskNameDescending })
                                {
                                    if sortOrder == .taskNameDescending {
                                        Label("Z-A", systemImage: "checkmark")
                                    } else {
                                        Text("Z-A")
                                    }
                                }
                            }

                            // Project submenu
                            Menu("Project")
                            {
                                Button(action: { sortOrder = .projectAscending })
                                {
                                    if sortOrder == .projectAscending {
                                        Label("A-Z", systemImage: "checkmark")
                                    } else {
                                        Text("A-Z")
                                    }
                                }

                                Button(action: { sortOrder = .projectDescending })
                                {
                                    if sortOrder == .projectDescending {
                                        Label("Z-A", systemImage: "checkmark")
                                    } else {
                                        Text("Z-A")
                                    }
                                }

                                Button(action: { sortOrder = .projectNewest })
                                {
                                    if sortOrder == .projectNewest {
                                        Label("Newest First", systemImage: "checkmark")
                                    } else {
                                        Text("Newest First")
                                    }
                                }

                                Button(action: { sortOrder = .projectOldest })
                                {
                                    if sortOrder == .projectOldest {
                                        Label("Oldest First", systemImage: "checkmark")
                                    } else {
                                        Text("Oldest First")
                                    }
                                }
                            }

                            // Task Type submenu
                            Menu("Task Type")
                            {
                                Button(action: { sortOrder = .taskTypeDevelopment })
                                {
                                    if sortOrder == .taskTypeDevelopment {
                                        Label("Development", systemImage: "checkmark")
                                    } else {
                                        Text("Development")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeRequirements })
                                {
                                    if sortOrder == .taskTypeRequirements {
                                        Label("Requirements", systemImage: "checkmark")
                                    } else {
                                        Text("Requirements")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeDesign })
                                {
                                    if sortOrder == .taskTypeDesign {
                                        Label("Design", systemImage: "checkmark")
                                    } else {
                                        Text("Design")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeUseCases })
                                {
                                    if sortOrder == .taskTypeUseCases {
                                        Label("Use Cases", systemImage: "checkmark")
                                    } else {
                                        Text("Use Cases")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeTesting })
                                {
                                    if sortOrder == .taskTypeTesting {
                                        Label("Testing", systemImage: "checkmark")
                                    } else {
                                        Text("Testing")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeDocumentation })
                                {
                                    if sortOrder == .taskTypeDocumentation {
                                        Label("Documentation", systemImage: "checkmark")
                                    } else {
                                        Text("Documentation")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeDatabase })
                                {
                                    if sortOrder == .taskTypeDatabase {
                                        Label("Database", systemImage: "checkmark")
                                    } else {
                                        Text("Database")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeDefectCorrection })
                                {
                                    if sortOrder == .taskTypeDefectCorrection {
                                        Label("Defect Correction", systemImage: "checkmark")
                                    } else {
                                        Text("Defect Correction")
                                    }
                                }
                            }

                            // Priority submenu
                            Menu("Priority")
                            {
                                Button(action: { sortOrder = .priorityHigh })
                                {
                                    if sortOrder == .priorityHigh {
                                        Label("High", systemImage: "checkmark")
                                    } else {
                                        Text("High")
                                    }
                                }

                                Button(action: { sortOrder = .priorityMedium })
                                {
                                    if sortOrder == .priorityMedium {
                                        Label("Medium", systemImage: "checkmark")
                                    } else {
                                        Text("Medium")
                                    }
                                }

                                Button(action: { sortOrder = .priorityLow })
                                {
                                    if sortOrder == .priorityLow {
                                        Label("Low", systemImage: "checkmark")
                                    } else {
                                        Text("Low")
                                    }
                                }

                                Button(action: { sortOrder = .priorityEnhancement })
                                {
                                    if sortOrder == .priorityEnhancement {
                                        Label("Enhancement", systemImage: "checkmark")
                                    } else {
                                        Text("Enhancement")
                                    }
                                }
                            }

                            // Status submenu
                            Menu("Status")
                            {
                                Button(action: { sortOrder = .statusUnassigned })
                                {
                                    if sortOrder == .statusUnassigned {
                                        Label("Unassigned", systemImage: "checkmark")
                                    } else {
                                        Text("Unassigned")
                                    }
                                }

                                Button(action: { sortOrder = .statusInProgress })
                                {
                                    if sortOrder == .statusInProgress {
                                        Label("In Progress", systemImage: "checkmark")
                                    } else {
                                        Text("In Progress")
                                    }
                                }

                                Button(action: { sortOrder = .statusCompleted })
                                {
                                    if sortOrder == .statusCompleted {
                                        Label("Completed", systemImage: "checkmark")
                                    } else {
                                        Text("Completed")
                                    }
                                }

                                Button(action: { sortOrder = .statusDeferred })
                                {
                                    if sortOrder == .statusDeferred {
                                        Label("Deferred", systemImage: "checkmark")
                                    } else {
                                        Text("Deferred")
                                    }
                                }
                            }

                            // Date Created submenu
                            Menu("Date Created")
                            {
                                Button(action: { sortOrder = .dateNewest })
                                {
                                    if sortOrder == .dateNewest {
                                        Label("Newest First", systemImage: "checkmark")
                                    } else {
                                        Text("Newest First")
                                    }
                                }

                                Button(action: { sortOrder = .dateOldest })
                                {
                                    if sortOrder == .dateOldest {
                                        Label("Oldest First", systemImage: "checkmark")
                                    } else {
                                        Text("Oldest First")
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundStyle(AppGradients.taskGradient)
                        }
                    }

                    Button(action:
                        {
                            let task = Task(taskName: Constants.EMPTY_STRING)

                            // Don't insert or save yet - let the detail view handle it
                            path.append(.taskDetail(task, context: .taskList))
                        })
                    {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppGradients.taskGradient)
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(for: AppNavigationDestination.self)
            {
                destination in
                destinationView(for: destination)
            }
        }
        .successToast(
            isShowing: $showDeleteToast,
            message: "'\(deletedTaskName)' deleted"
        )
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

    // MARK: - Task Row Content

    @ViewBuilder
    private func taskRowContent(for task: Task) -> some View
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

            // Assigned User (if any)
            if let assignedUser = task.assignedUser
            {
                assignedUserRow(for: task, user: assignedUser)
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

            // Date Created
            HStack
            {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(task.dateCreated.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func assignedUserRow(for task: Task, user: User) -> some View
    {
        HStack
        {
            Image(systemName: "person.fill")
                .font(.caption)
                .foregroundStyle(.green)
            if let dateAssigned = task.dateAssigned
            {
                Text("Assigned to \(user.fullName()) on \(dateAssigned.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
            else
            {
                Text("Assigned to \(user.fullName())")
                    .font(.caption)
                    .foregroundStyle(.green)
            }
        }
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

#Preview("With Sample Data", traits: .modifier(SampleDataPreviewModifier()))
{
    TaskListView()
}

#Preview("Empty State", traits: .modifier(EmptyDataPreviewModifier()))
{
    TaskListView()
}
