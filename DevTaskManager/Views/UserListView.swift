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

    @State private var path: [AppNavigationDestination] = []
    @State private var showDeleteToast = false
    @State private var deletedUserName = ""
    @State private var sortOrder = SortOrder.nameAscending
    
    @Query(sort: \User.lastName) var users: [User]
    
    @Query(sort: \Role.roleName) var roles: [Role]
    
    // Sort order options
    enum SortOrder: String, CaseIterable
    {
        case nameAscending = "Name A-Z"
        case nameDescending = "Name Z-A"
        
        // Role options
        case roleAdministrator = "Administrator"
        case roleDeveloper = "Developer"
        case roleBusinessAnalyst = "Business Analyst"
        case roleValidator = "Validator"
        
        // Date Created options
        case dateNewest = "Newest First"
        case dateOldest = "Oldest First"
    }
    
    // Computed property for sorted users
    private var sortedUsers: [User]
    {
        switch sortOrder
        {
        case .nameAscending:
            return users.sorted { $0.fullName() < $1.fullName() }
        case .nameDescending:
            return users.sorted { $0.fullName() > $1.fullName() }
            
        // Role filtering and sorting
        case .roleAdministrator:
            return users.filter { $0.roles.contains(where: { $0.roleName == "Administrator" }) }.sorted { $0.fullName() < $1.fullName() }
        case .roleDeveloper:
            return users.filter { $0.roles.contains(where: { $0.roleName == "Developer" }) }.sorted { $0.fullName() < $1.fullName() }
        case .roleBusinessAnalyst:
            return users.filter { $0.roles.contains(where: { $0.roleName == "Business Analyst" }) }.sorted { $0.fullName() < $1.fullName() }
        case .roleValidator:
            return users.filter { $0.roles.contains(where: { $0.roleName == "Validator" }) }.sorted { $0.fullName() < $1.fullName() }
            
        // Date Created sorting
        case .dateNewest:
            return users.sorted { $0.dateCreated > $1.dateCreated }
        case .dateOldest:
            return users.sorted { $0.dateCreated < $1.dateCreated }
        }
    }
    
    // Delete users
    func deleteUsers(at offsets: IndexSet)
    {
        for index in offsets
        {
            let user = sortedUsers[index]
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
                    userListContent
                }
                else
                {
                    emptyStateView
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
                
                toolbarContent
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
    
    // MARK: - View Components
    
    private var userListContent: some View {
        VStack
        {
            List
            {
                ForEach(sortedUsers)
                {
                    user in
                    userRow(for: user)
                }
                .onDelete(perform: deleteUsers)
            }
            .padding()
            .listStyle(.plain)
            .navigationDestination(for: AppNavigationDestination.self) { destination in
                switch destination {
                case .userDetail(let user):
                    UserDetailView(user: user, path: $path)
                case .userTasks(let user):
                    UserTasksView(user: user, onDismissToMain: { dismiss() }, path: $path)
                case .taskDetail(let task):
                    TaskDetailView(task: task, path: $path, onDismissToMain: { dismiss() })
                case .projectDetail(let project):
                    ProjectDetailView(project: project, path: $path, onDismissToMain: { dismiss() })
                case .projectTasks(let project):
                    ProjectTasksView(project: project, path: $path)
                }
            }
        }
    }
    
    private func userRow(for user: User) -> some View {
        VStack(alignment: .leading, spacing: 8)
        {
            // User info section with edit navigation
            NavigationLink(value: AppNavigationDestination.userDetail(user))
            {
                userInfoView(for: user)
            }
            .buttonStyle(.plain)
            
            // Assigned tasks section - separate navigation
            assignedTasksButton(for: user)
        }
    }
    
    private func userInfoView(for user: User) -> some View {
        VStack(alignment: .leading, spacing: 5)
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
    
    @ViewBuilder
    private func assignedTasksButton(for user: User) -> some View {
        if user.tasks.count > 0 {
            NavigationLink(value: AppNavigationDestination.userTasks(user)) {
                HStack {
                    Image(systemName: "list.bullet.clipboard")
                        .foregroundStyle(.green)
                    Text("View \(user.tasks.count) Assigned Task\(user.tasks.count == 1 ? "" : "s")")
                        .foregroundStyle(.green)
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        } else {
            HStack {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(.secondary)
                Text("No tasks assigned")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView
        {
            Label("No users were found for display.", systemImage: "calendar.badge.clock")
        }
        description:
        {
            Text("\nPlease click the 'Add User' button to create your first user record.")
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing)
        {
            Menu
            {
                // User Name submenu
                Menu("User Name")
                {
                    Button(action: { sortOrder = .nameAscending })
                    {
                        Label("A-Z", systemImage: sortOrder == .nameAscending ? "checkmark" : "")
                    }
                    
                    Button(action: { sortOrder = .nameDescending })
                    {
                        Label("Z-A", systemImage: sortOrder == .nameDescending ? "checkmark" : "")
                    }
                }
                
                // Role submenu
                Menu("Role")
                {
                    Button(action: { sortOrder = .roleAdministrator })
                    {
                        Label("Administrator", systemImage: sortOrder == .roleAdministrator ? "checkmark" : "")
                    }
                    
                    Button(action: { sortOrder = .roleDeveloper })
                    {
                        Label("Developer", systemImage: sortOrder == .roleDeveloper ? "checkmark" : "")
                    }
                    
                    Button(action: { sortOrder = .roleBusinessAnalyst })
                    {
                        Label("Business Analyst", systemImage: sortOrder == .roleBusinessAnalyst ? "checkmark" : "")
                    }
                    
                    Button(action: { sortOrder = .roleValidator })
                    {
                        Label("Validator", systemImage: sortOrder == .roleValidator ? "checkmark" : "")
                    }
                }
                
                // Date Created submenu
                Menu("Date Created")
                {
                    Button(action: { sortOrder = .dateNewest })
                    {
                        Label("Newest First", systemImage: sortOrder == .dateNewest ? "checkmark" : "")
                    }
                    
                    Button(action: { sortOrder = .dateOldest })
                    {
                        Label("Oldest First", systemImage: sortOrder == .dateOldest ? "checkmark" : "")
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
            }
            
            Button(action:
            {
                let user = User(firstName: Constants.EMPTY_STRING,
                                lastName: Constants.EMPTY_STRING)

                // Don't insert or save yet - let the detail view handle it
                path.append(.userDetail(user))
            })
            {
                Image(systemName: "plus")
            }
        }
    }
}

#Preview
{
    UserListView()
}

