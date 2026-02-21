//
//  ProjectTasksView.swift
//  DevTaskManager
//
//  Created by Assistant on 2/17/26.
//
import SwiftData
import SwiftUI

struct ProjectTasksView: View
{
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @Bindable var project: Project
    @Binding var path: [AppNavigationDestination]
    
    // Optional binding for macOS NavigationSplitView detail column
    var detailSelection: Binding<AppNavigationDestination?>?

    @State private var showDeleteToast = false
    @State private var deletedTaskName = ""
    @State private var sortOrder = SortOrder.dateNewest

    // Sort order options
    enum SortOrder: String, CaseIterable
    {
        case taskNameAscending = "Task Name A-Z"
        case taskNameDescending = "Task Name Z-A"

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
    private var activeFilterBadges: [FilterBadgesContainer.FilterBadge]
    {
        var badges: [FilterBadgesContainer.FilterBadge] = []

        // Add badge for task type filters
        switch sortOrder
        {
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

    // Computed property for sorted tasks
    private var sortedTasks: [Task]
    {
        let tasks = project.tasks

        switch sortOrder
        {
            case .taskNameAscending:
                return tasks.sorted { $0.taskName < $1.taskName }
            case .taskNameDescending:
                return tasks.sorted { $0.taskName > $1.taskName }

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

    // Delete tasks from this project
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

    // Create new task for this project
    func createNewTask()
    {
        let task = Task(
            taskName: Constants.EMPTY_STRING,
            project: project
        )

        // Don't insert or save yet - let the detail view handle it
        #if os(macOS)
        if let detailSelection = detailSelection {
            // On macOS with NavigationSplitView, update the detail selection
            detailSelection.wrappedValue = .taskDetail(task, context: .projectTasksList)
        } else {
            path.append(.taskDetail(task, context: .projectTasksList))
        }
        #else
        path.append(.taskDetail(task, context: .projectTasksList))
        #endif
    }
    
    // Navigate to task detail
    func navigateToTask(_ task: Task)
    {
        #if os(macOS)
        if let detailSelection = detailSelection {
            // On macOS with NavigationSplitView, update the detail selection
            detailSelection.wrappedValue = .taskDetail(task, context: .projectTasksList)
        } else {
            path.append(.taskDetail(task, context: .projectTasksList))
        }
        #else
        path.append(.taskDetail(task, context: .projectTasksList))
        #endif
    }

    var body: some View
    {
        ZStack
        {
            // Solid background to prevent content showing through
            Color.systemBackground
                .platformIgnoreSafeArea()

            // Modern gradient background overlay
            AppGradients.mainBackground
                .platformIgnoreSafeArea()

            VStack(spacing: 0)
            {
                // Modern header
                ModernHeaderView(
                    icon: "folder.fill",
                    title: project.title.isEmpty ? "Untitled Project" : project.title,
                    subtitle: "\(sortedTasks.count) task\(sortedTasks.count == 1 ? "" : "s")",
                    gradientColors: [.blue, .cyan]
                )

                // Filter badges - shows active filters
                FilterBadgesContainer(badges: activeFilterBadges)

                if !project.tasks.isEmpty
                {
                    ScrollView
                    {
                        LazyVStack(spacing: 8)
                        {
                            ForEach(sortedTasks)
                            { task in
                                #if os(macOS)
                                // macOS: Use button with detail selection for NavigationSplitView
                                Button(action: {
                                    navigateToTask(task)
                                }) {
                                    taskRow(for: task)
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
                                #else
                                // iOS: Use NavigationLink for full-screen presentation
                                NavigationLink(value: AppNavigationDestination.taskDetail(task, context: .projectTasksList))
                                {
                                    taskRow(for: task)
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
                                #endif
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
                        message: "Add tasks to \(project.title.isEmpty ? "this project" : project.title)",
                        buttonTitle: "Add Task",
                        buttonAction: createNewTask
                    )
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar
        {
            #if canImport(UIKit)
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
                        .foregroundStyle(AppGradients.projectGradient)
                    }
                }
                
                ToolbarItemGroup(placement: .primaryAction)
                {
                    // Only show sort/filter menu when there are tasks
                    if !project.tasks.isEmpty
                    {
                        Menu
                        {
                            // Task Name submenu
                            Menu("Task Name")
                            {
                                Button(action: { sortOrder = .taskNameAscending })
                                {
                                    if sortOrder == .taskNameAscending
                                    {
                                        Label("A-Z", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("A-Z")
                                    }
                                }

                                Button(action: { sortOrder = .taskNameDescending })
                                {
                                    if sortOrder == .taskNameDescending
                                    {
                                        Label("Z-A", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Z-A")
                                    }
                                }
                            }

                            // Task Type submenu
                            Menu("Task Type")
                            {
                                Button(action: { sortOrder = .taskTypeDevelopment })
                                {
                                    if sortOrder == .taskTypeDevelopment
                                    {
                                        Label("Development", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Development")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeRequirements })
                                {
                                    if sortOrder == .taskTypeRequirements
                                    {
                                        Label("Requirements", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Requirements")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeDesign })
                                {
                                    if sortOrder == .taskTypeDesign
                                    {
                                        Label("Design", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Design")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeUseCases })
                                {
                                    if sortOrder == .taskTypeUseCases
                                    {
                                        Label("Use Cases", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Use Cases")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeTesting })
                                {
                                    if sortOrder == .taskTypeTesting
                                    {
                                        Label("Testing", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Testing")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeDocumentation })
                                {
                                    if sortOrder == .taskTypeDocumentation
                                    {
                                        Label("Documentation", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Documentation")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeDatabase })
                                {
                                    if sortOrder == .taskTypeDatabase
                                    {
                                        Label("Database", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Database")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeDefectCorrection })
                                {
                                    if sortOrder == .taskTypeDefectCorrection
                                    {
                                        Label("Defect Correction", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Defect Correction")
                                    }
                                }
                            }

                            // Priority submenu
                            Menu("Priority")
                            {
                                Button(action: { sortOrder = .priorityHigh })
                                {
                                    if sortOrder == .priorityHigh
                                    {
                                        Label("High", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("High")
                                    }
                                }

                                Button(action: { sortOrder = .priorityMedium })
                                {
                                    if sortOrder == .priorityMedium
                                    {
                                        Label("Medium", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Medium")
                                    }
                                }

                                Button(action: { sortOrder = .priorityLow })
                                {
                                    if sortOrder == .priorityLow
                                    {
                                        Label("Low", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Low")
                                    }
                                }

                                Button(action: { sortOrder = .priorityEnhancement })
                                {
                                    if sortOrder == .priorityEnhancement
                                    {
                                        Label("Enhancement", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Enhancement")
                                    }
                                }
                            }

                            // Status submenu
                            Menu("Status")
                            {
                                Button(action: { sortOrder = .statusUnassigned })
                                {
                                    if sortOrder == .statusUnassigned
                                    {
                                        Label("Unassigned", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Unassigned")
                                    }
                                }

                                Button(action: { sortOrder = .statusInProgress })
                                {
                                    if sortOrder == .statusInProgress
                                    {
                                        Label("In Progress", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("In Progress")
                                    }
                                }

                                Button(action: { sortOrder = .statusCompleted })
                                {
                                    if sortOrder == .statusCompleted
                                    {
                                        Label("Completed", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Completed")
                                    }
                                }

                                Button(action: { sortOrder = .statusDeferred })
                                {
                                    if sortOrder == .statusDeferred
                                    {
                                        Label("Deferred", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Deferred")
                                    }
                                }
                            }

                            // Date Created submenu
                            Menu("Date Created")
                            {
                                Button(action: { sortOrder = .dateNewest })
                                {
                                    if sortOrder == .dateNewest
                                    {
                                        Label("Newest First", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Newest First")
                                    }
                                }

                                Button(action: { sortOrder = .dateOldest })
                                {
                                    if sortOrder == .dateOldest
                                    {
                                        Label("Oldest First", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Oldest First")
                                    }
                                }
                            }

                            Divider()

                            Button(action: {
                                path.append(.projectDetail(project))
                            })
                            {
                                Label("Edit Project", systemImage: "pencil")
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundStyle(AppGradients.projectGradient)
                        }
                    }

                    Button(action: createNewTask)
                    {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(AppGradients.projectGradient)
                    }
                }
            #elseif canImport(AppKit)
                ToolbarItemGroup(placement: .automatic)
                {
                    // Only show sort/filter menu when there are tasks
                    if !project.tasks.isEmpty
                    {
                        Menu
                        {
                            // Task Name submenu
                            Menu("Task Name")
                            {
                                Button(action: { sortOrder = .taskNameAscending })
                                {
                                    if sortOrder == .taskNameAscending
                                    {
                                        Label("A-Z", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("A-Z")
                                    }
                                }

                                Button(action: { sortOrder = .taskNameDescending })
                                {
                                    if sortOrder == .taskNameDescending
                                    {
                                        Label("Z-A", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Z-A")
                                    }
                                }
                            }

                            // Task Type submenu
                            Menu("Task Type")
                            {
                                Button(action: { sortOrder = .taskTypeDevelopment })
                                {
                                    if sortOrder == .taskTypeDevelopment
                                    {
                                        Label("Development", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Development")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeRequirements })
                                {
                                    if sortOrder == .taskTypeRequirements
                                    {
                                        Label("Requirements", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Requirements")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeDesign })
                                {
                                    if sortOrder == .taskTypeDesign
                                    {
                                        Label("Design", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Design")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeUseCases })
                                {
                                    if sortOrder == .taskTypeUseCases
                                    {
                                        Label("Use Cases", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Use Cases")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeTesting })
                                {
                                    if sortOrder == .taskTypeTesting
                                    {
                                        Label("Testing", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Testing")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeDocumentation })
                                {
                                    if sortOrder == .taskTypeDocumentation
                                    {
                                        Label("Documentation", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Documentation")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeDatabase })
                                {
                                    if sortOrder == .taskTypeDatabase
                                    {
                                        Label("Database", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Database")
                                    }
                                }

                                Button(action: { sortOrder = .taskTypeDefectCorrection })
                                {
                                    if sortOrder == .taskTypeDefectCorrection
                                    {
                                        Label("Defect Correction", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Defect Correction")
                                    }
                                }
                            }

                            // Priority submenu
                            Menu("Priority")
                            {
                                Button(action: { sortOrder = .priorityHigh })
                                {
                                    if sortOrder == .priorityHigh
                                    {
                                        Label("High", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("High")
                                    }
                                }

                                Button(action: { sortOrder = .priorityMedium })
                                {
                                    if sortOrder == .priorityMedium
                                    {
                                        Label("Medium", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Medium")
                                    }
                                }

                                Button(action: { sortOrder = .priorityLow })
                                {
                                    if sortOrder == .priorityLow
                                    {
                                        Label("Low", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Low")
                                    }
                                }

                                Button(action: { sortOrder = .priorityEnhancement })
                                {
                                    if sortOrder == .priorityEnhancement
                                    {
                                        Label("Enhancement", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Enhancement")
                                    }
                                }
                            }

                            // Status submenu
                            Menu("Status")
                            {
                                Button(action: { sortOrder = .statusUnassigned })
                                {
                                    if sortOrder == .statusUnassigned
                                    {
                                        Label("Unassigned", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Unassigned")
                                    }
                                }

                                Button(action: { sortOrder = .statusInProgress })
                                {
                                    if sortOrder == .statusInProgress
                                    {
                                        Label("In Progress", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("In Progress")
                                    }
                                }

                                Button(action: { sortOrder = .statusCompleted })
                                {
                                    if sortOrder == .statusCompleted
                                    {
                                        Label("Completed", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Completed")
                                    }
                                }

                                Button(action: { sortOrder = .statusDeferred })
                                {
                                    if sortOrder == .statusDeferred
                                    {
                                        Label("Deferred", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Deferred")
                                    }
                                }
                            }

                            // Date Created submenu
                            Menu("Date Created")
                            {
                                Button(action: { sortOrder = .dateNewest })
                                {
                                    if sortOrder == .dateNewest
                                    {
                                        Label("Newest First", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Newest First")
                                    }
                                }

                                Button(action: { sortOrder = .dateOldest })
                                {
                                    if sortOrder == .dateOldest
                                    {
                                        Label("Oldest First", systemImage: "checkmark")
                                    }
                                    else
                                    {
                                        Text("Oldest First")
                                    }
                                }
                            }

                            Divider()

                            Button(action: {
                                path.append(.projectDetail(project))
                            })
                            {
                                Label("Edit Project", systemImage: "pencil")
                            }
                        } label: {
                            Label("Sort", systemImage: "arrow.up.arrow.down")
                        }
                    }

                    Button(action: createNewTask)
                    {
                        Label("Add Task", systemImage: "plus.circle.fill")
                    }
                }
            #endif
        }
        .platformNavigationBar()
        .successToast(
            isShowing: $showDeleteToast,
            message: "'\(deletedTaskName)' deleted"
        )
    }

    // MARK: - Helper Functions
    
    // Helper function to create task row
    @ViewBuilder
    private func taskRow(for task: Task) -> some View
    {
        ModernListRow
        {
            VStack(alignment: .leading, spacing: 8)
            {
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
                    HStack
                    {
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                        if let dateAssigned = task.dateAssigned
                        {
                            Text("Assigned to \(assignedUser.fullName()) on \(dateAssigned.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                        else
                        {
                            Text("Assigned to \(assignedUser.fullName())")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }
                    }
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
    }

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
