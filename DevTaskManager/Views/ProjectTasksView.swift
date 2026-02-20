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
        path.append(.taskDetail(task, context: .projectTasksList))
    }

    var body: some View
    {
        ZStack {
            // Solid background to prevent content showing through
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            // Modern gradient background overlay
            AppGradients.mainBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Modern header
                ModernHeaderView(
                    icon: "folder.fill",
                    title: project.title.isEmpty ? "Untitled Project" : project.title,
                    subtitle: "\(sortedTasks.count) task\(sortedTasks.count == 1 ? "" : "s")",
                    gradientColors: [.blue, .cyan]
                )
                
                if !project.tasks.isEmpty
                {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(sortedTasks) { task in
                                NavigationLink(value: AppNavigationDestination.taskDetail(task, context: .projectTasksList)) {
                                    ModernListRow {
                                        VStack(alignment: .leading, spacing: 8)
                                        {
                                            // Task Name with Priority
                                            HStack(spacing: 8) {
                                                Image(systemName: priorityIcon(for: task.taskPriority))
                                                    .font(.headline)
                                                    .foregroundStyle(priorityColor(for: task.taskPriority))
                                                
                                                Text(task.taskName.isEmpty ? "Untitled Task" : task.taskName)
                                                    .font(.headline)
                                            }
                                            
                                            // Assigned User (if any)
                                            if let assignedUser = task.assignedUser {
                                                HStack {
                                                    Image(systemName: "person.fill")
                                                        .font(.caption)
                                                        .foregroundStyle(.green)
                                                    if let dateAssigned = task.dateAssigned {
                                                        Text("Assigned to \(assignedUser.fullName()) on \(dateAssigned.formatted(date: .abbreviated, time: .omitted))")
                                                            .font(.caption)
                                                            .foregroundStyle(.green)
                                                    } else {
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
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        if let index = sortedTasks.firstIndex(where: { $0.id == task.id }) {
                                            deleteTasks(at: IndexSet(integer: index))
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
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
        .toolbar
        {
            ToolbarItemGroup(placement: .topBarTrailing)
            {
                Menu
                {
                    Picker("Sort by", selection: $sortOrder)
                    {
                        Text("Task Name A-Z").tag(SortOrder.taskNameAscending)
                        Text("Task Name Z-A").tag(SortOrder.taskNameDescending)
                        Text("Newest First").tag(SortOrder.dateNewest)
                        Text("Oldest First").tag(SortOrder.dateOldest)
                    }
                    .pickerStyle(.inline)
                    
                    Divider()
                    
                    Menu("Filter by Task Type") {
                        Button("Development") { sortOrder = .taskTypeDevelopment }
                        Button("Requirements") { sortOrder = .taskTypeRequirements }
                        Button("Design") { sortOrder = .taskTypeDesign }
                        Button("Use Cases") { sortOrder = .taskTypeUseCases }
                        Button("Testing") { sortOrder = .taskTypeTesting }
                        Button("Documentation") { sortOrder = .taskTypeDocumentation }
                        Button("Database") { sortOrder = .taskTypeDatabase }
                        Button("Defect Correction") { sortOrder = .taskTypeDefectCorrection }
                    }
                    
                    Menu("Filter by Priority") {
                        Button("High") { sortOrder = .priorityHigh }
                        Button("Medium") { sortOrder = .priorityMedium }
                        Button("Low") { sortOrder = .priorityLow }
                        Button("Enhancement") { sortOrder = .priorityEnhancement }
                    }
                    
                    Menu("Filter by Status") {
                        Button("Unassigned") { sortOrder = .statusUnassigned }
                        Button("In Progress") { sortOrder = .statusInProgress }
                        Button("Completed") { sortOrder = .statusCompleted }
                        Button("Deferred") { sortOrder = .statusDeferred }
                    }
                    
                    Divider()
                    
                    Button(action: {
                        path.append(.projectDetail(project))
                    })
                    {
                        Label("Edit Project", systemImage: "pencil")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(AppGradients.projectGradient)
                }
                
                Button(action: createNewTask)
                {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppGradients.projectGradient)
                }
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .successToast(
            isShowing: $showDeleteToast,
            message: "'\(deletedTaskName)' deleted"
        )
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
