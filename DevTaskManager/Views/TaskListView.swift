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
    
    @Query(sort: \Task.taskName) var tasks: [Task]
    
    @Query(sort: \User.lastName) var users: [User]
    
    @Query(sort: \Role.roleName) var roles: [Role]
    
    // Delete tasks
    func deleteTasks(at offsets: IndexSet)
    {
        for index in offsets
        {
            let task = tasks[index]
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
            VStack
            {
                if !tasks.isEmpty
                {
                    VStack(spacing: 15)
                    {
                        List
                        {
                            //  Display all the tasks in a navigation link
                            ForEach(tasks)
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
                        .padding()
                        .listStyle(.plain)
                        .navigationDestination(for: AppNavigationDestination.self) { destination in
                            switch destination {
                            case .taskDetail(let task):
                                TaskDetailView(task: task, path: $path)
                            case .projectDetail(let project):
                                ProjectDetailView(project: project, path: $path)
                            case .projectTasks(let project):
                                ProjectTasksView(project: project, path: $path)
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
                
                ToolbarItem(placement: .topBarTrailing)
                {
                    //  Save the skeleton user to the database and
                    //  add it to the NavigationPath array
                    Button(action:
                    {
                        let task = Task(taskName: Constants.EMPTY_STRING)

                        modelContext.insert(task)
                        try? modelContext.save()
                        
                        path.append(.taskDetail(task))
                    },
                    label:
                    {
                        HStack
                        {
                            Text("Add Task").font(.body)
                            Image(systemName: "plus")
                        }
                    })
                }
            }.navigationTitle("Task List").navigationBarTitleDisplayMode(.inline)
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
}

#Preview("With Sample Data", traits: .modifier(SampleDataPreviewModifier())) {
    TaskListView()
}

#Preview("Empty State", traits: .modifier(EmptyDataPreviewModifier())) {
    TaskListView()
}
