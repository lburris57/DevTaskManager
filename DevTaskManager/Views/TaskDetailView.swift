//
//  TaskDetailView.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/20/25.
//
import FloatingPromptTextField
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
    init(task: Task, path: Binding<[AppNavigationDestination]>, onDismissToMain: (() -> Void)? = nil, sourceContext: TaskDetailSourceContext = .taskList)
    {
        _task = Bindable(wrappedValue: task)
        _path = path
        self.onDismissToMain = onDismissToMain
        self.sourceContext = sourceContext

        // Initialize state values from task
        _selectedTaskType = State(initialValue: task.taskType)
        _selectedTaskStatus = State(initialValue: task.taskStatus)
        _selectedTaskPriority = State(initialValue: task.taskPriority)
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

    //  Clean up if needed (no-op now since task isn't inserted until saved)
    func validateTask()
    {
        // Task is only inserted when saved, so no cleanup needed
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
        .toolbarBackground(.visible, for: .navigationBar)
        .onDisappear(perform: validateTask)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Toolbar Components

    @ToolbarContentBuilder
    private var toolbarLeadingContent: some ToolbarContent
    {
        ToolbarItem(placement: .topBarLeading)
        {
            navigationMenu
        }
    }

    @ToolbarContentBuilder
    private var toolbarTrailingContent: some ToolbarContent
    {
        ToolbarItem(placement: .topBarTrailing)
        {
            Button("Cancel")
            {
                dismiss()
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
        if !path.isEmpty
        {
            path.removeLast()
        }
    }

    private func navigateToMainMenu()
    {
        path.removeAll()
        if let onDismissToMain = onDismissToMain
        {
            onDismissToMain()
        }
        else
        {
            dismiss()
        }
    }
}
