//
//  TaskDetailView.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/20/25.
//
import FloatingPromptTextField
import SwiftData
import SwiftUI
import Inject

struct TaskDetailView: View
{
    //  This is the task sent from the list view
    @Bindable var task: Task
    
    //  This is the navigation path sent from the list view
    @Binding var path: NavigationPath
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedRole = Constants.EMPTY_STRING
    @State private var selectedTaskType = Constants.EMPTY_STRING
    @State private var selectedTaskStatus = Constants.EMPTY_STRING
    @State private var selectedTaskPriority = Constants.EMPTY_STRING
    
    @ObserveInjection var inject

    //  Populate values from passed in Task
    func populateInitialSelectedValues()
    {
        selectedTaskType = task.taskType
        selectedTaskStatus = task.taskStatus
        selectedTaskPriority = task.taskPriority
    }
    
    //  Check whether to enable/disable Save button
    func validateFields() -> Bool
    {
        if  task.taskName == Constants.EMPTY_STRING
        {
            return false
        }

        return true
    }
    
    //  Delete the skeleton task from the database if not edited
    func validateTask()
    {
        if  task.taskName == Constants.EMPTY_STRING
        {
            withAnimation
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
        task.lastUpdated = Date()
        
        modelContext.insert(task)
        try? modelContext.save()
    }
    
    var body: some View
    {
        NavigationView
        {
            VStack(spacing: 15)
            {
                FloatingPromptTextField(text: $task.taskName, prompt: Text("Task Name:")
                .foregroundStyle(colorScheme == .dark ? .gray : .blue).fontWeight(.bold))
                .floatingPromptScale(1.0)
                .background(colorScheme == .dark ? .gray.opacity(0.2) : .gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.leading, 15)
                
                FloatingPromptTextField(text: $task.taskComment, prompt: Text("Comment:")
                .foregroundStyle(colorScheme == .dark ? .gray : .blue).fontWeight(.bold))
                .floatingPromptScale(1.0)
                .background(colorScheme == .dark ? .gray.opacity(0.2) : .gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.leading, 15)
                
                VStack(alignment: .leading, spacing: 15)
                {
                    HStack
                    {
                        FloatingPromptTextField(text: $selectedTaskType, prompt: Text("Task Type:")
                            .foregroundStyle(colorScheme == .dark ? .gray : .blue).fontWeight(.bold))
                        .floatingPromptScale(1.0)
                        .background(colorScheme == .dark ? .gray.opacity(0.2) : .gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.leading, 15)
                        
                        Picker(Constants.EMPTY_STRING, selection: $selectedTaskType)
                        {
                            ForEach(TaskTypeEnum.allCases)
                            {
                                taskType in
                                
                                Text(taskType.title).tag(taskType.title)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                    
                    HStack
                    {
                        FloatingPromptTextField(text: $selectedTaskStatus, prompt: Text("Task Status:")
                            .foregroundStyle(colorScheme == .dark ? .gray : .blue).fontWeight(.bold))
                        .floatingPromptScale(1.0)
                        .background(colorScheme == .dark ? .gray.opacity(0.2) : .gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.leading, 15)
                        
                        Picker(Constants.EMPTY_STRING, selection: $selectedTaskStatus)
                        {
                            ForEach(TaskStatusEnum.allCases)
                            {
                                taskStatus in
                                
                                Text(taskStatus.title).tag(taskStatus.title)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                    
                    HStack
                    {
                        FloatingPromptTextField(text: $selectedTaskPriority, prompt: Text("Task Priority:")
                            .foregroundStyle(colorScheme == .dark ? .gray : .blue).fontWeight(.bold))
                        .floatingPromptScale(1.0)
                        .background(colorScheme == .dark ? .gray.opacity(0.2) : .gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.leading, 15)
                        
                        Picker(Constants.EMPTY_STRING, selection: $selectedTaskPriority)
                        {
                            ForEach(TaskPriorityEnum.allCases)
                            {
                                taskPriority in
                                
                                Text(taskPriority.title).tag(taskPriority.title)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
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
                
                }.padding()
            }
            .navigationBarItems(trailing: Button("Cancel")
            {
                dismiss()
            })
            .padding(.horizontal)
            .onAppear(perform: populateInitialSelectedValues)
            .onDisappear(perform: validateTask)
            .navigationTitle(validateFields() ? "Edit Task" : "Add Task").navigationBarTitleDisplayMode(.inline)
            .enableInjection()
        }
}
