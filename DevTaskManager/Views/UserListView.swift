//
//  UserListView.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/19/25.
//
import SwiftData
import SwiftUI

struct UserListView: View
{
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var path = NavigationPath()
    @State private var showDeleteToast = false
    @State private var deletedUserName = ""
    
    @Query(sort: \User.lastName) var users: [User]
    
    @Query(sort: \Role.roleName) var roles: [Role]
    
    // Delete users
    func deleteUsers(at offsets: IndexSet)
    {
        for index in offsets
        {
            let user = users[index]
            deletedUserName = user.fullName()
            modelContext.delete(user)
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
            Log.error("Failed to delete user: \(error.localizedDescription)")
        }
    }

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
                            .onDelete(perform: deleteUsers)
                        }
                        .padding()
                        .listStyle(.plain)
                        .navigationDestination(for: User.self)
                        {
                            user in
                            
                            //  Send the selected user to the ProjectDetailsView
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
                        let user = User(firstName: Constants.EMPTY_STRING,
                                        lastName: Constants.EMPTY_STRING)

                        modelContext.insert(user)
                        try? modelContext.save()
                        
                        path.append(user)
                    },
                    label:
                    {
                        Image(systemName: "plus")
                    })
                }
            }
            .navigationTitle("User List")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .successToast(
            isShowing: $showDeleteToast,
            message: "'\(deletedUserName)' deleted"
        )
        .background(Color(UIColor.systemBackground))
        .ignoresSafeArea(.all, edges: .top)
    }
}

#Preview
{
    UserListView()
}

