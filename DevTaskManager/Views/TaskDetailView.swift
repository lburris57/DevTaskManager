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
    var onDismissToMain: (() -> Void)? = nil
    
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
    init(task: Task, path: Binding<[AppNavigationDestination]>, onDismissToMain: (() -> Void)? = nil) {
        self._task = Bindable(wrappedValue: task)
        self._path = path
        self.onDismissToMain = onDismissToMain
        
        // Initialize state values from task
        self._selectedTaskType = State(initialValue: task.taskType)
        self._selectedTaskStatus = State(initialValue: task.taskStatus)
        self._selectedTaskPriority = State(initialValue: task.taskPriority)
        self._selectedProject = State(initialValue: task.project)
        self._selectedUser = State(initialValue: task.assignedUser)
        self._isNewTask = State(initialValue: task.taskName == Constants.EMPTY_STRING)
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
        if isNewTask {
            modelContext.insert(task)
        }
        
        try? modelContext.save()
    }
    
    var body: some View
    {
        VStack(spacing: 15)
        {
                // Project section
                HStack
                {
                    Text("Project:")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.leading, 15)
                    
                    Spacer()
                    
                    Picker(Constants.EMPTY_STRING, selection: $selectedProject)
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
                    .padding(.trailing, 15)
                }
            
                FloatingPromptTextField(text: $task.taskName, prompt: Text("Task Name:")
                .foregroundStyle(colorScheme == .dark ? .gray : .blue).fontWeight(.bold))
                .floatingPromptScale(1.0)
                .background(colorScheme == .dark ? .gray.opacity(0.2) : .gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.leading, 15)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Comment:")
                        .foregroundColor(colorScheme == .dark ? .gray : .blue)
                        .fontWeight(.bold)
                        .padding(.leading, 15)
                    
                    TextEditor(text: $task.taskComment)
                        .frame(minHeight: 40, maxHeight: 160) // ~8 lines at 20px per line
                        .scrollContentBackground(.hidden)
                        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 15)
                }
                
                VStack(alignment: .leading, spacing: 8)
                {
                    HStack
                    {
                        Text("Task Type:")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.leading, 15)
                        
                        Spacer()
                        
                        Picker(Constants.EMPTY_STRING, selection: $selectedTaskType)
                        {
                            ForEach(TaskTypeEnum.allCases)
                            {
                                taskType in
                                
                                Text(taskType.title).tag(taskType.title)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.trailing, 15)
                    }
                    
                    HStack
                    {
                        Text("Task Status:")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.leading, 15)
                        
                        Spacer()
                        
                        Picker(Constants.EMPTY_STRING, selection: $selectedTaskStatus)
                        {
                            ForEach(TaskStatusEnum.allCases)
                            {
                                taskStatus in
                                
                                Text(taskStatus.title).tag(taskStatus.title)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.trailing, 15)
                    }
                    
                    HStack
                    {
                        Text("Task Priority:")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.leading, 15)
                        
                        Spacer()
                        
                        Picker(Constants.EMPTY_STRING, selection: $selectedTaskPriority)
                        {
                            ForEach(TaskPriorityEnum.allCases)
                            {
                                taskPriority in
                                
                                Text(taskPriority.title).tag(taskPriority.title)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.trailing, 15)
                    }
                    
                    // Assigned User Picker
                    HStack
                    {
                        Text("Assigned User:")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.leading, 15)
                        
                        Spacer()
                        
                        Picker(Constants.EMPTY_STRING, selection: $selectedUser)
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
                        .padding(.trailing, 15)
                    }
                }
                
                Button("Save Task")
                {
                    saveTask()
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .disabled(!validateFields())
                .padding(10)
                .background(Color.blue).opacity(!validateFields() ? 0.6 : 1)
                .foregroundColor(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                .shadow(color: .black, radius: 2.0, x: 2.0, y: 2.0)
                
                Spacer()
            }
            .padding()
            .toolbar {
                toolbarLeadingContent
                toolbarTrailingContent
            }
            .padding(.horizontal)
            .onDisappear(perform: validateTask)
            .navigationTitle(validateFields() ? "Edit Task" : "Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Toolbar Components
    
    @ToolbarContentBuilder
    private var toolbarLeadingContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            navigationMenu
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarTrailingContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Cancel") {
                dismiss()
            }
        }
    }
    
    // MARK: - Helper Views
    
    private var navigationMenu: some View {
        Menu {
            Button {
                navigateBackOneLevel()
            } label: {
                Label("Back To Assigned Tasks", systemImage: "list.bullet.clipboard")
            }
            
            Button {
                navigateToMainMenu()
            } label: {
                Label("Back To Main Menu", systemImage: "house.fill")
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
    
    // MARK: - Navigation Actions
    
    private func navigateBackOneLevel() {
        if !path.isEmpty {
            path.removeLast()
        }
        dismiss()
    }
    
    private func navigateToMainMenu() {
        path.removeAll()
        if let onDismissToMain = onDismissToMain {
            onDismissToMain()
        } else {
            dismiss()
        }
    }
}
