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
            filteredTasks = tasks.filter {
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
            withAnimation {
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
            VStack(spacing: 0)
            {
                // Search bar at the top
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search tasks", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)
                
                if !tasks.isEmpty
                {
                    VStack(spacing: 15)
                    {
                        List
                        {
                            //  Display all the tasks in a navigation link
                            ForEach(sortedTasks)
                            {
                                task in

                                NavigationLink(value: AppNavigationDestination.taskDetail(task)) {
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
                                        HStack(spacing: 12) {
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
                                        HStack {
                                            Image(systemName: "calendar")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                            Text(task.dateCreated.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .onDelete(perform: deleteTasks)
                        }
                        .padding()
                        .listStyle(.plain)
                        .navigationDestination(for: AppNavigationDestination.self) { destination in
                            switch destination {
                            case .taskDetail(let task):
                                TaskDetailView(task: task, path: $path, onDismissToMain: { dismiss() })
                            case .projectDetail(let project):
                                ProjectDetailView(project: project, path: $path, onDismissToMain: { dismiss() })
                            case .projectTasks(let project):
                                ProjectTasksView(project: project, path: $path)
                            case .userDetail(let user):
                                UserDetailView(user: user, path: $path)
                            case .userTasks(let user):
                                UserTasksView(user: user, path: $path)
                            }
                        }
                    }
                }
                else
                {
                    //  No tasks were found
                    ContentUnavailableView
                    {
                        Label("No tasks were found for display.", systemImage: "calendar.badge.clock")
                    }
                    description:
                    {
                        Text("\nPlease click the 'Add Task' button to create your first task record.")
                    }
                }
            }
            .toolbar
            {
                ToolbarItem(placement: .navigationBarLeading)
                {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing)
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
                            
                            Button(action: { sortOrder = .projectNewest })
                            {
                                HStack {
                                    if sortOrder == .projectNewest {
                                        Image(systemName: "checkmark")
                                    }
                                    Text("Newest First")
                                }
                            }
                            
                            Button(action: { sortOrder = .projectOldest })
                            {
                                HStack {
                                    if sortOrder == .projectOldest {
                                        Image(systemName: "checkmark")
                                    }
                                    Text("Oldest First")
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
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    
                    Button(action:
                    {
                        let task = Task(taskName: Constants.EMPTY_STRING)

                        // Don't insert or save yet - let the detail view handle it
                        path.append(.taskDetail(task))
                    })
                    {
                        Label("Add Task", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Task List")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .successToast(
            isShowing: $showDeleteToast,
            message: "'\(deletedTaskName)' deleted"
        )
        .background(Color(UIColor.systemBackground))
        .ignoresSafeArea(.all, edges: .top)
    }
    
    // MARK: - Helper Functions
    
    private func priorityIcon(for priority: String) -> String {
        switch priority.lowercased() {
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
    
    private func priorityColor(for priority: String) -> Color {
        switch priority.lowercased() {
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
    
    private func statusIcon(for status: String) -> String {
        switch status.lowercased() {
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
    
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
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

#Preview("With Sample Data", traits: .modifier(SampleDataPreviewModifier())) {
    TaskListView()
}

#Preview("Empty State", traits: .modifier(EmptyDataPreviewModifier())) {
    TaskListView()
}
