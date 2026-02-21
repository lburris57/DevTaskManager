//
//  TaskDetailView.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/20/25.
//
import SwiftData
import SwiftUI

struct TaskDetailView: View
{
    //  This is the task sent from the list view
    @Bindable var task: Task

    //  This is the navigation path sent from the list view
    @Binding var path: [AppNavigationDestination]

    // Optional callback to dismiss to main menu
    var onDismissToMain: (() -> Void)?

    // Track where we came from for proper navigation
    var sourceContext: TaskDetailSourceContext = .taskList
    
    // Optional binding for macOS NavigationSplitView detail column
    var detailSelection: Binding<AppNavigationDestination?>?

    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @Query(sort: \Project.title) var projects: [Project]

    @Query(sort: \User.lastName) var users: [User]

    @State private var selectedRole = Constants.EMPTY_STRING
    @State private var selectedTaskType: String
    @State private var selectedTaskStatus: String
    @State private var selectedTaskPriority: String
    @State private var selectedProject: Project?
    @State private var selectedUser: User?
    @State private var isNewTask: Bool
    @State private var taskSaved = false

    // Initialize state from task
    init(task: Task, path: Binding<[AppNavigationDestination]>, onDismissToMain: (() -> Void)? = nil, sourceContext: TaskDetailSourceContext = .taskList, detailSelection: Binding<AppNavigationDestination?>? = nil)
    {
        _task = Bindable(wrappedValue: task)
        _path = path
        
        self.onDismissToMain = onDismissToMain
        self.sourceContext = sourceContext
        self.detailSelection = detailSelection

        // Initialize state values from task (with defaults for empty strings)
        _selectedTaskType = State(initialValue: task.taskType.isEmpty ? TaskTypeEnum.development.title : task.taskType)
        _selectedTaskStatus = State(initialValue: task.taskStatus.isEmpty ? TaskStatusEnum.unassigned.title : task.taskStatus)
        _selectedTaskPriority = State(initialValue: task.taskPriority.isEmpty ? TaskPriorityEnum.medium.title : task.taskPriority)
        _selectedProject = State(initialValue: task.project)
        _selectedUser = State(initialValue: task.assignedUser)
        _isNewTask = State(initialValue: task.taskName == Constants.EMPTY_STRING)
    }

    //  Check whether to enable/disable Save button
    func validateFields() -> Bool
    {
        if task.taskName == Constants.EMPTY_STRING
        {
            return false
        }

        if selectedProject == nil
        {
            return false
        }

        return true
    }

    //  Clean up if needed - delete unsaved new tasks
    func validateTask()
    {
        // If this is a new task that was never saved, we need to ensure it's not in the context
        // This handles the case where user cancels or navigates away without saving
        if isNewTask && !taskSaved
        {
            // Check if task is in the model context and remove it
            if modelContext.model(for: task.id) != nil
            {
                modelContext.delete(task)
                try? modelContext.save()
            }
        }
    }

    //  Set the last updated date value when saving changes
    func saveTask()
    {
        task.taskType = selectedTaskType
        task.taskStatus = selectedTaskStatus
        task.taskPriority = selectedTaskPriority
        task.project = selectedProject
        task.assignedUser = selectedUser

        // Update task status based on user assignment
        if selectedUser != nil
        {
            // When a user is assigned, set status to In Progress
            task.taskStatus = TaskStatusEnum.inProgress.title
            task.dateAssigned = Date()
        }
        else
        {
            // When unassigned, set status to Unassigned
            task.taskStatus = TaskStatusEnum.unassigned.title
            task.dateAssigned = nil
        }

        task.lastUpdated = Date()

        // Update the selected status to reflect the automatic change
        selectedTaskStatus = task.taskStatus

        // Insert task if it's new (not already in context)
        if isNewTask
        {
            modelContext.insert(task)
        }

        try? modelContext.save()
        
        // Mark task as saved so validateTask won't delete it
        taskSaved = true
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
                    icon: "checklist",
                    title: isNewTask ? "New Task" : "Edit Task",
                    subtitle: task.project?.title ?? "No Project",
                    gradientColors: [.orange, .red]
                )

                ScrollView
                {
                    VStack(spacing: 12)
                    {
                        // Project Picker Card
                        ModernFormCard
                        {
                            HStack
                            {
                                Text("Project")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                Spacer()

                                Picker("Select Project", selection: $selectedProject)
                                {
                                    Text("No Project").tag(nil as Project?)

                                    ForEach(projects)
                                    {
                                        project in

                                        Text(project.title.isEmpty ? "Untitled Project" : project.title)
                                            .tag(project as Project?)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.blue)
                            }
                        }

                        // Task Name Card
                        ModernFormCard
                        {
                            VStack(alignment: .leading, spacing: 8)
                            {
                                Text("Task Name")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                TextField("Enter task name", text: $task.taskName)
                                    .textFieldStyle(.plain)
                                    .font(.body)
                            }
                        }

                        // Comment Card
                        ModernFormCard
                        {
                            VStack(alignment: .leading, spacing: 8)
                            {
                                Text("Comment")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                TextEditor(text: $task.taskComment)
                                    .frame(minHeight: 80)
                                    .scrollContentBackground(.hidden)
                                    .font(.body)
                            }
                        }

                        // Task Details Card
                        ModernFormCard
                        {
                            VStack(spacing: 12)
                            {
                                // Task Type
                                HStack
                                {
                                    Text("Type")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)

                                    Spacer()

                                    Picker("Type", selection: $selectedTaskType)
                                    {
                                        ForEach(TaskTypeEnum.allCases)
                                        {
                                            taskType in
                                            
                                            Text(taskType.title).tag(taskType.title)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.blue)
                                }

                                Divider()

                                // Task Status
                                HStack
                                {
                                    Text("Status")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)

                                    Spacer()

                                    Picker("Status", selection: $selectedTaskStatus)
                                    {
                                        ForEach(TaskStatusEnum.allCases)
                                        {
                                            taskStatus in
                                            
                                            Text(taskStatus.title).tag(taskStatus.title)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.blue)
                                }

                                Divider()

                                // Task Priority
                                HStack
                                {
                                    Text("Priority")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)

                                    Spacer()

                                    Picker("Priority", selection: $selectedTaskPriority)
                                    {
                                        ForEach(TaskPriorityEnum.allCases)
                                        {
                                            taskPriority in
                                            
                                            Text(taskPriority.title).tag(taskPriority.title)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.blue)
                                }

                                Divider()

                                // Assigned User
                                HStack
                                {
                                    Text("Assigned To")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)

                                    Spacer()

                                    Picker("User", selection: $selectedUser)
                                    {
                                        Text("Unassigned").tag(nil as User?)

                                        ForEach(users)
                                        {
                                            user in
                                            
                                            Text(user.fullName())
                                                .tag(user as User?)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.blue)
                                }
                            }
                        }

                        // Save Button
                        Button(action: {
                            saveTask()
                            dismiss()
                        })
                        {
                            Text("Save Task")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            validateFields() ?
                                                LinearGradient(
                                                    colors: [.orange, .red],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ) :
                                                LinearGradient(
                                                    colors: [.gray.opacity(0.5), .gray.opacity(0.5)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                        )
                                        .shadow(color: validateFields() ? .orange.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                                )
                        }
                        .disabled(!validateFields())
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .toolbar
        {
            toolbarLeadingContent
            toolbarTrailingContent
        }
        .platformNavigationBar()
        .onDisappear(perform: validateTask)
    }

    // MARK: - Toolbar Components

    @ToolbarContentBuilder
    private var toolbarLeadingContent: some ToolbarContent
    {
        ToolbarItem(placement: .platformLeading)
        {
            navigationMenu
        }
    }

    @ToolbarContentBuilder
    private var toolbarTrailingContent: some ToolbarContent
    {
        ToolbarItem(placement: .platformCancellation)
        {
            Button("Cancel")
            {
                validateTask() // Clean up unsaved tasks before dismissing
                
                #if os(macOS)
                // On macOS with NavigationSplitView
                if let detailSelection = detailSelection {
                    // Navigate back to the appropriate list view based on context
                    switch sourceContext {
                    case .projectTasksList:
                        // Return to project tasks view
                        if let project = task.project {
                            detailSelection.wrappedValue = .projectTasks(project)
                        } else {
                            detailSelection.wrappedValue = nil
                        }
                    case .userTasksList:
                        // Return to user tasks view
                        if let user = task.assignedUser {
                            detailSelection.wrappedValue = .userTasks(user)
                        } else {
                            detailSelection.wrappedValue = nil
                        }
                    case .taskList:
                        // For general task list, clear selection
                        detailSelection.wrappedValue = nil
                    }
                } else {
                    dismiss()
                }
                #else
                dismiss()
                #endif
            }
            .foregroundStyle(AppGradients.taskGradient)
        }
    }

    // MARK: - Helper Views

    private var navigationMenu: some View
    {
        Menu
        {
            Button
            {
                navigateBackOneLevel()
            } label: {
                switch sourceContext
                {
                    case .taskList:
                        Label("Back To Task List", systemImage: "list.bullet.clipboard")
                    case .userTasksList:
                        Label("Back To Assigned Tasks", systemImage: "person.crop.circle.badge.checkmark")
                    case .projectTasksList:
                        Label("Back To Project Tasks", systemImage: "folder.badge.gearshape")
                }
            }

            Button
            {
                navigateToMainMenu()
            } label: {
                Label("Back To Main Menu", systemImage: "house.fill")
            }
        } label: {
            HStack(spacing: 4)
            {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .foregroundStyle(AppGradients.taskGradient)
        }
    }

    // MARK: - Navigation Actions

    private func navigateBackOneLevel()
    {
        validateTask() // Clean up unsaved tasks before navigating
        #if os(macOS)
        // On macOS with NavigationSplitView
        if let detailSelection = detailSelection {
            // Navigate back to the appropriate list view based on context
            switch sourceContext {
            case .projectTasksList:
                // Return to project tasks view
                if let project = task.project {
                    detailSelection.wrappedValue = .projectTasks(project)
                } else {
                    detailSelection.wrappedValue = nil
                }
            case .userTasksList:
                // Return to user tasks view
                if let user = task.assignedUser {
                    detailSelection.wrappedValue = .userTasks(user)
                } else {
                    detailSelection.wrappedValue = nil
                }
            case .taskList:
                // For general task list, clear selection
                detailSelection.wrappedValue = nil
            }
        } else {
            if !path.isEmpty {
                path.removeLast()
            }
            dismiss()
        }
        #else
        if !path.isEmpty {
            path.removeLast()
        }
        dismiss()
        #endif
    }

    private func navigateToMainMenu()
    {
        validateTask() // Clean up unsaved tasks before navigating
        #if os(macOS)
        // On macOS with NavigationSplitView, clear the detail selection
        if let detailSelection = detailSelection {
            detailSelection.wrappedValue = nil
        } else {
            path.removeAll()
            if let onDismissToMain = onDismissToMain {
                onDismissToMain()
            } else {
                dismiss()
            }
        }
        #else
        path.removeAll()
        if let onDismissToMain = onDismissToMain {
            onDismissToMain()
        } else {
            dismiss()
        }
        #endif
    }
}
