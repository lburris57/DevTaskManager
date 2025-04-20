//
//  UserListView.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/19/25.
//
import SwiftData
import SwiftUI
import Inject

struct UserListView: View
{
    @Environment(\.modelContext) var modelContext
    
    @ObserveInjection var inject

    @State private var path = NavigationPath()
    
    @Query(sort: \User.lastName) var users: [User]
    
    @Query(sort: \Role.roleName) var roles: [Role]

    var body: some View
    {
        NavigationStack(path: $path)
        {
            VStack
            {
                if !users.isEmpty
                {
                    VStack
                    {
                        List
                        {
                            //  Display all the users in a navigation link
                            ForEach(users)
                            {
                                user in

                                VStack(alignment: .leading, spacing: 3)
                                {
                                    NavigationLink(value: user)
                                    {
                                        VStack
                                        {
                                            HStack
                                            {
                                                Text("User:").bold()
                                                Spacer()
                                                Text(user.firstName + " " + user.lastName)
                                            }
                                            
                                            HStack
                                            {
                                                Text("Role:").bold()
                                                Spacer()
                                                Text(user.roles.map(\.self).first?.roleName ?? roles[0].roleName)
                                            }
                                            
                                            HStack
                                            {
                                                Text("Date Created:").bold()
                                                Spacer()
                                                Text(user.dateCreated.formatted())
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .listStyle(.plain)
                        .navigationDestination(for: User.self)
                        {
                            user in
                            
                            //  Send the selected project to the ProjectDetailsView
                            //  along with the navigation path array
                            UserDetailView(user: user, path: $path)
                        }
                    }
                }
                else
                {
                    //  No users were found
                    ContentUnavailableView
                    {
                        Label("No users were found for display.", systemImage: "calendar.badge.clock")
                    }
                    description:
                    {
                        Text("\nPlease click the 'Add User' button to create your first user record.")
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
                        let user = User(firstName: Constants.EMPTY_STRING,
                                        lastName: Constants.EMPTY_STRING)

                        modelContext.insert(user)
                        try? modelContext.save()
                        
                        path.append(user)
                    },
                    label:
                    {
                        HStack
                        {
                            Text("Add User").font(.body)
                            Image(systemName: "plus")
                        }
                    })
                }
            }.navigationTitle("User List").navigationBarTitleDisplayMode(.inline)
        }
        .enableInjection()
    }
}

#Preview
{
    UserListView()
}
