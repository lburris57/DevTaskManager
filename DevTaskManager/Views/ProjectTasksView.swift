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
    @Binding var path: NavigationPath
    
    @State private var showDeleteToast = false
    @State private var deletedTaskName = ""
    
    // Delete tasks from this project
    func deleteTasks(at offsets: IndexSet)
    {
        for index in offsets
        {
            let task = project.tasks[index]
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
    
    // Create new task for this project
    func createNewTask()
    {
        let task = Task(
            taskName: Constants.EMPTY_STRING,
            project: project
        )
        modelContext.insert(task)
        
        do
        {
            try modelContext.save()
            // Navigate to task detail
            path.append(task)
        }
        catch
        {
            Log.error("Failed to create task: \(error.localizedDescription)")
        }
    }
    
    var body: some View
    {
        VStack
        {
            if !project.tasks.isEmpty
            {
                List
                {
                    ForEach(project.tasks.sorted(by: { $0.dateCreated > $1.dateCreated }))
                    {
                        task in
                        
                        NavigationLink(value: task)
                        {
                            VStack(alignment: .leading, spacing: 8)
                            {
                                // Task Name
                                Text(task.taskName.isEmpty ? "Untitled Task" : task.taskName)
                                    .font(.headline)
                                
                                // Task Details
                                HStack(spacing: 12) {
                                    Label(task.taskType, systemImage: "hammer.fill")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    Label(task.taskPriority, systemImage: priorityIcon(for: task.taskPriority))
                                        .font(.caption)
                                        .foregroundStyle(priorityColor(for: task.taskPriority))
                                    
                                    Label(task.taskStatus, systemImage: statusIcon(for: task.taskStatus))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
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
                .listStyle(.plain)
                .navigationDestination(for: Task.self)
                {
                    task in
                    TaskDetailView(task: task, path: $path)
                }
            }
            else
            {
                // No tasks
                ContentUnavailableView
                {
                    Label("No tasks yet", systemImage: "checkmark.circle.badge.plus")
                }
                description:
                {
                    Text("Add tasks to \(project.title.isEmpty ? "this project" : project.title)")
                }
                actions:
                {
                    Button("Add Task")
                    {
                        createNewTask()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .navigationTitle(project.title.isEmpty ? "Untitled Project" : project.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar
        {
            ToolbarItem(placement: .topBarTrailing)
            {
                Menu
                {
                    // Edit project button
                    Button(action: {
                        path.append(project)
                    })
                    {
                        Label("Edit Project", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    // Add task button
                    Button(action: createNewTask)
                    {
                        Label("Add Task", systemImage: "plus")
                    }
                }
                label:
                {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .successToast(
            isShowing: $showDeleteToast,
            message: "'\(deletedTaskName)' deleted"
        )
    }
    
    // MARK: - Helper Functions
    
    private func priorityIcon(for priority: String) -> String {
        switch priority.lowercased() {
        case "high":
            return "exclamationmark.triangle.fill"
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
    
    private func statusIcon(for status: String) -> Color {
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
}
