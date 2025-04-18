//
//  ProjectListView.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import SwiftData
import SwiftUI

struct ProjectListView: View
{
    @Environment(\.modelContext) var modelContext

    @State private var path = NavigationPath()
    
    @Query(sort: \Project.title) var projects: [Project]
    
    //  Save roles to the database.
    func saveRoles()
    {
        let roles = Role.loadRoles()
        
        Log.info("The permissions for validators are: \(roles[3].permissions)")
        
        for role in roles
        {
            role.lastUpdated = Date()
            
            modelContext.insert(role)
        }
    }

    var body: some View
    {
        NavigationStack(path: $path)
        {
            VStack
            {
                if !projects.isEmpty
                {
                    VStack
                    {
                        List
                        {
                            //  Display all the projects in a navigation link
                            ForEach(projects)
                            {
                                project in

                                VStack(alignment: .leading, spacing: 3)
                                {
                                    NavigationLink(value: project)
                                    {
                                        VStack
                                        {
                                            HStack
                                            {
                                                Text("Project Title:").bold()
                                                Spacer()
                                                Text(project.title)
                                            }
                                            
                                            HStack
                                            {
                                                Text("Date Created:").bold()
                                                Spacer()
                                                Text(project.dateCreated.formatted())
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .listStyle(.plain)
                        .navigationDestination(for: Project.self)
                        {
                            project in
                            
                            //  Send the selected project to the ProjectDetailsView
                            //  along with the navigation path array
                            ProjectDetailsView(project: project, path: $path)
                        }
                    }
                }
                else
                {
                    //  No projects were found
                    ContentUnavailableView
                    {
                        Label("No projects were found for display.", systemImage: "calendar.badge.clock")
                    }
                    description:
                    {
                        Text("\nPlease click the 'Add Project' button to create your first project.")
                    }
                }
            }
            .onAppear(perform: saveRoles)
            .toolbar
            {
                ToolbarItem(placement: .topBarTrailing)
                {
                    //  Save the skeleton project to the database and
                    //  add it to the NavigationPath array
                    Button(action:
                    {
                        let project = Project(title: Constants.EMPTY_STRING,
                                              descriptionText: Constants.EMPTY_STRING)

                        modelContext.insert(project)
                        
                        path.append(project)
                    },
                    label:
                    {
                        HStack
                        {
                            Text("Add Project").font(.body)
                            Image(systemName: "plus")
                        }
                    })
                }
            }.navigationTitle("Project List").navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview
{
    ProjectListView()
}
