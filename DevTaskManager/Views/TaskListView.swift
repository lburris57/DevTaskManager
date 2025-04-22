//
//  TaskListView.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/20/25.
//
import SwiftData
import SwiftUI
import Inject

struct TaskListView: View
{
    @Environment(\.modelContext) var modelContext
    
    @ObserveInjection var inject

    @State private var path = NavigationPath()
    
    @Query(sort: \Task.taskName) var tasks: [Task]
    
    @Query(sort: \User.lastName) var users: [User]
    
    @Query(sort: \Role.roleName) var roles: [Role]

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

                                VStack(alignment: .leading, spacing: 3)
                                {
                                    NavigationLink(value: task)
                                    {
                                        VStack
                                        {
                                            HStack
                                            {
                                                Text("Task Name:").bold()
                                                Spacer()
                                                Text(task.taskName)
                                            }
                                            
                                            HStack
                                            {
                                                Text("Task Type:").bold()
                                                Spacer()
                                                Text(task.taskType)
                                            }
                                            
                                            HStack
                                            {
                                                Text("Task Priority:").bold()
                                                Spacer()
                                                Text(task.taskPriority)
                                            }
                                            
                                            HStack
                                            {
                                                Text("Date Created:").bold()
                                                Spacer()
                                                Text(task.dateCreated.formatted())
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .listStyle(.plain)
                        .navigationDestination(for: Task.self)
                        {
                            task in
                            
                            //  Send the selected task to the TaskDetailsView
                            //  along with the navigation path array
                            TaskDetailView(task: task, path: $path)
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
                ToolbarItem(placement: .topBarTrailing)
                {
                    //  Save the skeleton user to the database and
                    //  add it to the NavigationPath array
                    Button(action:
                    {
                        let task = Task(taskName: Constants.EMPTY_STRING)

                        modelContext.insert(task)
                        try? modelContext.save()
                        
                        path.append(task)
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
        .enableInjection()
    }
}
