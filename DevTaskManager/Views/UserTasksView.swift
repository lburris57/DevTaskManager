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
        VStack
        {
            if !user.tasks.isEmpty
            {
                List
                {
                    ForEach(sortedTasks)
                    {
                        task in

                        NavigationLink(value: AppNavigationDestination.taskDetail(task))
                        {
                            VStack(alignment: .leading, spacing: 8)
                            {
                                // Project name at the top
                                if let project = task.project {
                                    HStack {
                                        Image(systemName: "folder.fill")
                                            .font(.caption)
                                            .foregroundStyle(.blue)
                                        Text(project.title.isEmpty ? "Untitled Project" : project.title)
                                            .font(.caption)
                                            .foregroundStyle(.blue)
                                    }
                                }
                                
                                // Task Name with Priority
                                HStack(spacing: 8) {
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
                                if let dateAssigned = task.dateAssigned {
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
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.plain)
            }
            else
            {
                // No tasks
                ContentUnavailableView
                {
                    Label("No tasks assigned", systemImage: "checkmark.circle")
                } description: {
                    Text("\(user.fullName()) has no tasks currently assigned")
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
                        withAnimation {
                            path.removeAll()
                        }
                    })
                    {
                        Label("Back to User List", systemImage: "person.3.fill")
                    }
                    
                    Button(action: {
                        // Return to Main Menu - use provided closure or fallback to dismiss
                        if let onDismissToMain = onDismissToMain {
                            onDismissToMain()
                        } else {
                            path.removeAll()
                            dismiss()
                        }
                    })
                    {
                        Label("Return To Main Menu", systemImage: "house.fill")
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                }
            }
            
            ToolbarItem(placement: .principal)
            {
                VStack(spacing: 2)
                {
                    Text(user.fullName())
                        .font(.headline)
                        .lineLimit(1)
                    Text("Assigned Tasks")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            ToolbarItem(placement: .topBarTrailing)
            {
                Menu
                {
                    // Task Name submenu
                    Menu("Task Name")
                    {
                        Button(action: { sortOrder = .taskNameAscending })
                        {
                            HStack {
                                if sortOrder == .taskNameAscending {
                                    Image(systemName: "checkmark")
                                }
                                Text("A-Z")
                            }
                        }
                        
                        Button(action: { sortOrder = .taskNameDescending })
                        {
                            HStack {
                                if sortOrder == .taskNameDescending {
                                    Image(systemName: "checkmark")
                                }
                                Text("Z-A")
                            }
                        }
                    }
                    
                    // Project submenu
                    Menu("Project")
                    {
                        Button(action: { sortOrder = .projectAscending })
                        {
                            HStack {
                                if sortOrder == .projectAscending {
                                    Image(systemName: "checkmark")
                                }
                                Text("A-Z")
                            }
                        }
                        
                        Button(action: { sortOrder = .projectDescending })
                        {
                            HStack {
                                if sortOrder == .projectDescending {
                                    Image(systemName: "checkmark")
                                }
                                Text("Z-A")
                            }
                        }
                    }
                    
                    // Task Type submenu
                    Menu("Task Type")
                    {
                        Button(action: { sortOrder = .taskTypeDevelopment })
                        {
                            HStack {
                                if sortOrder == .taskTypeDevelopment {
                                    Image(systemName: "checkmark")
                                }
                                Text("Development")
                            }
                        }
                        Button(action: { sortOrder = .taskTypeRequirements })
                        {
                            HStack {
                                if sortOrder == .taskTypeRequirements {
                                    Image(systemName: "checkmark")
                                }
                                Text("Requirements")
                            }
                        }
                        Button(action: { sortOrder = .taskTypeDesign })
                        {
                            HStack {
                                if sortOrder == .taskTypeDesign {
                                    Image(systemName: "checkmark")
                                }
                                Text("Design")
                            }
                        }
                        Button(action: { sortOrder = .taskTypeUseCases })
                        {
                            HStack {
                                if sortOrder == .taskTypeUseCases {
                                    Image(systemName: "checkmark")
                                }
                                Text("Use Cases")
                            }
                        }
                        Button(action: { sortOrder = .taskTypeTesting })
                        {
                            HStack {
                                if sortOrder == .taskTypeTesting {
                                    Image(systemName: "checkmark")
                                }
                                Text("Testing")
                            }
                        }
                        Button(action: { sortOrder = .taskTypeDocumentation })
                        {
                            HStack {
                                if sortOrder == .taskTypeDocumentation {
                                    Image(systemName: "checkmark")
                                }
                                Text("Documentation")
                            }
                        }
                        Button(action: { sortOrder = .taskTypeDatabase })
                        {
                            HStack {
                                if sortOrder == .taskTypeDatabase {
                                    Image(systemName: "checkmark")
                                }
                                Text("Database")
                            }
                        }
                        Button(action: { sortOrder = .taskTypeDefectCorrection })
                        {
                            HStack {
                                if sortOrder == .taskTypeDefectCorrection {
                                    Image(systemName: "checkmark")
                                }
                                Text("Defect Correction")
                            }
                        }
                    }
                    
                    // Priority submenu
                    Menu("Priority")
                    {
                        Button(action: { sortOrder = .priorityHigh })
                        {
                            HStack {
                                if sortOrder == .priorityHigh {
                                    Image(systemName: "checkmark")
                                }
                                Text("High")
                            }
                        }
                        Button(action: { sortOrder = .priorityMedium })
                        {
                            HStack {
                                if sortOrder == .priorityMedium {
                                    Image(systemName: "checkmark")
                                }
                                Text("Medium")
                            }
                        }
                        Button(action: { sortOrder = .priorityLow })
                        {
                            HStack {
                                if sortOrder == .priorityLow {
                                    Image(systemName: "checkmark")
                                }
                                Text("Low")
                            }
                        }
                        Button(action: { sortOrder = .priorityEnhancement })
                        {
                            HStack {
                                if sortOrder == .priorityEnhancement {
                                    Image(systemName: "checkmark")
                                }
                                Text("Enhancement")
                            }
                        }
                    }
                    
                    // Status submenu
                    Menu("Status")
                    {
                        Button(action: { sortOrder = .statusUnassigned })
                        {
                            HStack {
                                if sortOrder == .statusUnassigned {
                                    Image(systemName: "checkmark")
                                }
                                Text("Unassigned")
                            }
                        }
                        Button(action: { sortOrder = .statusInProgress })
                        {
                            HStack {
                                if sortOrder == .statusInProgress {
                                    Image(systemName: "checkmark")
                                }
                                Text("In Progress")
                            }
                        }
                        Button(action: { sortOrder = .statusCompleted })
                        {
                            HStack {
                                if sortOrder == .statusCompleted {
                                    Image(systemName: "checkmark")
                                }
                                Text("Completed")
                            }
                        }
                        Button(action: { sortOrder = .statusDeferred })
                        {
                            HStack {
                                if sortOrder == .statusDeferred {
                                    Image(systemName: "checkmark")
                                }
                                Text("Deferred")
                            }
                        }
                    }
                    
                    // Date Created submenu
                    Menu("Date Created")
                    {
                        Button(action: { sortOrder = .dateNewest })
                        {
                            HStack {
                                if sortOrder == .dateNewest {
                                    Image(systemName: "checkmark")
                                }
                                Text("Newest First")
                            }
                        }
                        
                        Button(action: { sortOrder = .dateOldest })
                        {
                            HStack {
                                if sortOrder == .dateOldest {
                                    Image(systemName: "checkmark")
                                }
                                Text("Oldest First")
                            }
                        }
                    }
                    
                    Divider()
                }
                label:
                {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(for: AppNavigationDestination.self) { destination in
            switch destination {
            case .taskDetail(let task):
                TaskDetailView(task: task, path: $path, onDismissToMain: onDismissToMain)
            case .projectDetail(let project):
                ProjectDetailView(project: project, path: $path, onDismissToMain: onDismissToMain)
            case .projectTasks(let project):
                ProjectTasksView(project: project, path: $path)
            case .userDetail(let user):
                UserDetailView(user: user, path: $path)
            case .userTasks:
                EmptyView()
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
