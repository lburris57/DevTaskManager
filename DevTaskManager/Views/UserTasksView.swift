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
        Group
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

                                        Label(task.taskStatus, systemImage: statusIcon(for: task.taskStatus))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
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
        }
        .toolbar
        {
            ToolbarItem(placement: .topBarLeading)
            {
                Button(action: {
                    // Navigate back to User List by clearing the path
                    withAnimation {
                        path.removeAll()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                        Text("Back")
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
                            Label("A-Z", systemImage: sortOrder == .taskNameAscending ? "checkmark" : "")
                        }
                        
                        Button(action: { sortOrder = .taskNameDescending })
                        {
                            Label("Z-A", systemImage: sortOrder == .taskNameDescending ? "checkmark" : "")
                        }
                    }
                    
                    // Project submenu
                    Menu("Project")
                    {
                        Button(action: { sortOrder = .projectAscending })
                        {
                            Label("A-Z", systemImage: sortOrder == .projectAscending ? "checkmark" : "")
                        }
                        
                        Button(action: { sortOrder = .projectDescending })
                        {
                            Label("Z-A", systemImage: sortOrder == .projectDescending ? "checkmark" : "")
                        }
                    }
                    
                    // Task Type submenu
                    Menu("Task Type")
                    {
                        Button(action: { sortOrder = .taskTypeDevelopment })
                        {
                            Label("Development", systemImage: sortOrder == .taskTypeDevelopment ? "checkmark" : "")
                        }
                        Button(action: { sortOrder = .taskTypeRequirements })
                        {
                            Label("Requirements", systemImage: sortOrder == .taskTypeRequirements ? "checkmark" : "")
                        }
                        Button(action: { sortOrder = .taskTypeDesign })
                        {
                            Label("Design", systemImage: sortOrder == .taskTypeDesign ? "checkmark" : "")
                        }
                        Button(action: { sortOrder = .taskTypeUseCases })
                        {
                            Label("Use Cases", systemImage: sortOrder == .taskTypeUseCases ? "checkmark" : "")
                        }
                        Button(action: { sortOrder = .taskTypeTesting })
                        {
                            Label("Testing", systemImage: sortOrder == .taskTypeTesting ? "checkmark" : "")
                        }
                        Button(action: { sortOrder = .taskTypeDocumentation })
                        {
                            Label("Documentation", systemImage: sortOrder == .taskTypeDocumentation ? "checkmark" : "")
                        }
                        Button(action: { sortOrder = .taskTypeDatabase })
                        {
                            Label("Database", systemImage: sortOrder == .taskTypeDatabase ? "checkmark" : "")
                        }
                        Button(action: { sortOrder = .taskTypeDefectCorrection })
                        {
                            Label("Defect Correction", systemImage: sortOrder == .taskTypeDefectCorrection ? "checkmark" : "")
                        }
                    }
                    
                    // Priority submenu
                    Menu("Priority")
                    {
                        Button(action: { sortOrder = .priorityHigh })
                        {
                            Label("High", systemImage: sortOrder == .priorityHigh ? "checkmark" : "")
                        }
                        Button(action: { sortOrder = .priorityMedium })
                        {
                            Label("Medium", systemImage: sortOrder == .priorityMedium ? "checkmark" : "")
                        }
                        Button(action: { sortOrder = .priorityLow })
                        {
                            Label("Low", systemImage: sortOrder == .priorityLow ? "checkmark" : "")
                        }
                        Button(action: { sortOrder = .priorityEnhancement })
                        {
                            Label("Enhancement", systemImage: sortOrder == .priorityEnhancement ? "checkmark" : "")
                        }
                    }
                    
                    // Status submenu
                    Menu("Status")
                    {
                        Button(action: { sortOrder = .statusUnassigned })
                        {
                            Label("Unassigned", systemImage: sortOrder == .statusUnassigned ? "checkmark" : "")
                        }
                        Button(action: { sortOrder = .statusInProgress })
                        {
                            Label("In Progress", systemImage: sortOrder == .statusInProgress ? "checkmark" : "")
                        }
                        Button(action: { sortOrder = .statusCompleted })
                        {
                            Label("Completed", systemImage: sortOrder == .statusCompleted ? "checkmark" : "")
                        }
                        Button(action: { sortOrder = .statusDeferred })
                        {
                            Label("Deferred", systemImage: sortOrder == .statusDeferred ? "checkmark" : "")
                        }
                    }
                    
                    // Date Created submenu
                    Menu("Date Created")
                    {
                        Button(action: { sortOrder = .dateNewest })
                        {
                            Label("Newest First", systemImage: sortOrder == .dateNewest ? "checkmark" : "")
                        }
                        
                        Button(action: { sortOrder = .dateOldest })
                        {
                            Label("Oldest First", systemImage: sortOrder == .dateOldest ? "checkmark" : "")
                        }
                    }
                    
                    Divider()
                    
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
                TaskDetailView(task: task, path: $path)
            case .projectDetail(let project):
                ProjectDetailView(project: project, path: $path)
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
}
