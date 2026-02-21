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

    // Optional binding for macOS NavigationSplitView detail column
    var detailSelection: Binding<AppNavigationDestination?>?
    
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

    // Computed property for active filter badges
    private var activeFilterBadges: [FilterBadgesContainer.FilterBadge]
    {
        var badges: [FilterBadgesContainer.FilterBadge] = []

        // Add badge for role filters (not sort options)
        switch sortOrder
        {
            case .roleAdministrator:
                badges.append(.init(
                    text: "Role: Administrator",
                    icon: "person.badge.key",
                    onClear: { sortOrder = .nameAscending }
                ))
            case .roleDeveloper:
                badges.append(.init(
                    text: "Role: Developer",
                    icon: "person.badge.key",
                    onClear: { sortOrder = .nameAscending }
                ))
            case .roleBusinessAnalyst:
                badges.append(.init(
                    text: "Role: Business Analyst",
                    icon: "person.badge.key",
                    onClear: { sortOrder = .nameAscending }
                ))
            case .roleValidator:
                badges.append(.init(
                    text: "Role: Validator",
                    icon: "person.badge.key",
                    onClear: { sortOrder = .nameAscending }
                ))
            default:
                break // No badge for sort-only options
        }

        return badges
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
            withAnimation
            {
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
        #if os(macOS)
        // macOS: Plain view without NavigationStack (participates in NavigationSplitView)
        userListContent
        #else
        // iOS: Wrapped in NavigationStack for full-screen presentation
        NavigationStack(path: $path)
        {
            userListContent
                .navigationBarBackButtonHidden(true)
                .toolbar
                {
                    ToolbarItem(placement: .navigationBarLeading)
                    {
                        Button(action: {
                            dismiss()
                        })
                        {
                            HStack(spacing: 4)
                            {
                                Image(systemName: "chevron.left")
                                    .font(.body.weight(.semibold))
                                Text("Back")
                                    .font(.body)
                            }
                            .foregroundStyle(AppGradients.userGradient)
                        }
                    }

                    toolbarContent
                }
                .platformNavigationBar()
                .navigationDestination(for: AppNavigationDestination.self)
                { destination in
                    switch destination
                    {
                    case let .userDetail(user):
                        UserDetailView(user: user, path: $path)
                    case let .userTasks(user):
                        UserTasksView(user: user, onDismissToMain: { dismiss() }, path: $path)
                    case let .taskDetail(task, context):
                        TaskDetailView(task: task, path: $path, onDismissToMain: { dismiss() }, sourceContext: context)
                    case let .projectDetail(project):
                        ProjectDetailView(project: project, path: $path, onDismissToMain: { dismiss() })
                    case let .projectTasks(project):
                        ProjectTasksView(project: project, path: $path)
                    }
                }
        }
        .successToast(
            isShowing: $showDeleteToast,
            message: "'\(deletedUserName)' deleted"
        )
        #endif
    }
    
    // MARK: - User List Content
    
    @ViewBuilder
    private var userListContent: some View
    {
        ZStack
        {
            // Solid background to prevent content showing through
            Color.systemBackground
                .platformIgnoreSafeArea()

            // Modern gradient background overlay
            AppGradients.mainBackground
                .platformIgnoreSafeArea()

            VStack(spacing: 0)
            {
                // Modern header
                ModernHeaderView(
                    icon: "person.3.fill",
                    title: "Users",
                    subtitle: "\(sortedUsers.count) team members",
                    gradientColors: [.purple, .pink]
                )

                // Filter badges - shows active role filters
                FilterBadgesContainer(badges: activeFilterBadges)

                if !users.isEmpty
                {
                    ScrollView
                    {
                        LazyVStack(spacing: 8)
                        {
                            ForEach(sortedUsers)
                            {
                                user in
                                
                                ModernListRow
                                {
                                    userRow(for: user)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                else
                {
                    Spacer()
                    EmptyStateCard(
                        icon: "person.badge.plus",
                        title: "No Users Yet",
                        message: "Add team members to start assigning tasks and collaborating"
                    )
                    Spacer()
                }
            }
        }
        #if os(macOS)
        .toolbar
        {
            toolbarContent
        }
        .navigationDestination(for: AppNavigationDestination.self)
        { destination in
            switch destination
            {
            case let .userDetail(user):
                UserDetailView(user: user, path: $path)
            case let .userTasks(user):
                UserTasksView(user: user, onDismissToMain: { dismiss() }, path: $path)
            case let .taskDetail(task, context):
                TaskDetailView(task: task, path: $path, onDismissToMain: { dismiss() }, sourceContext: context)
            case let .projectDetail(project):
                ProjectDetailView(project: project, path: $path, onDismissToMain: { dismiss() })
            case let .projectTasks(project):
                ProjectTasksView(project: project, path: $path)
            }
        }
        .successToast(
            isShowing: $showDeleteToast,
            message: "'\(deletedUserName)' deleted"
        )
        #endif
    }

    // MARK: - View Components

    private func userRow(for user: User) -> some View
    {
        VStack(alignment: .leading, spacing: 8)
        {
            // User info section with edit navigation
            #if os(macOS)
            Button(action: {
                if let detailSelection = detailSelection {
                    detailSelection.wrappedValue = .userDetail(user)
                } else {
                    path.append(.userDetail(user))
                }
            }) {
                userInfoView(for: user)
            }
            .buttonStyle(.plain)
            #else
            NavigationLink(value: AppNavigationDestination.userDetail(user))
            {
                userInfoView(for: user)
            }
            .buttonStyle(.plain)
            #endif

            // Assigned tasks section - separate navigation
            assignedTasksButton(for: user)
        }
    }

    private func userInfoView(for user: User) -> some View
    {
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
    private func assignedTasksButton(for user: User) -> some View
    {
        if user.tasks.count > 0
        {
            #if os(macOS)
            Button(action: {
                if let detailSelection = detailSelection {
                    detailSelection.wrappedValue = .userTasks(user)
                } else {
                    path.append(.userTasks(user))
                }
            }) {
                HStack
                {
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
            #else
            NavigationLink(value: AppNavigationDestination.userTasks(user))
            {
                HStack
                {
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
            #endif
        }
        else
        {
            HStack
            {
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

    private var emptyStateView: some View
    {
        ContentUnavailableView
        {
            Label("No users were found for display.", systemImage: "calendar.badge.clock")
        }
        description:
        {
            Text("\nPlease click the 'Add User' button to create your first user record.")
        }
    }

    private var toolbarContent: some ToolbarContent
    {
        #if canImport(UIKit)
            ToolbarItemGroup(placement: .topBarTrailing)
            {
                // Only show sort/filter menu when there are users
                if !users.isEmpty
                {
                    Menu
                    {
                        // User Name submenu
                        Menu("User Name")
                        {
                            Button(action: { sortOrder = .nameAscending })
                            {
                                if sortOrder == .nameAscending
                                {
                                    Label("A-Z", systemImage: "checkmark")
                                }
                                else
                                {
                                    Text("A-Z")
                                }
                            }

                            Button(action: { sortOrder = .nameDescending })
                            {
                                if sortOrder == .nameDescending
                                {
                                    Label("Z-A", systemImage: "checkmark")
                                }
                                else
                                {
                                    Text("Z-A")
                                }
                            }
                        }

                        // Role submenu
                        Menu("Role")
                        {
                            Button(action: { sortOrder = .roleAdministrator })
                            {
                                if sortOrder == .roleAdministrator
                                {
                                    Label("Administrator", systemImage: "checkmark")
                                }
                                else
                                {
                                    Text("Administrator")
                                }
                            }

                            Button(action: { sortOrder = .roleDeveloper })
                            {
                                if sortOrder == .roleDeveloper
                                {
                                    Label("Developer", systemImage: "checkmark")
                                }
                                else
                                {
                                    Text("Developer")
                                }
                            }

                            Button(action: { sortOrder = .roleBusinessAnalyst })
                            {
                                if sortOrder == .roleBusinessAnalyst
                                {
                                    Label("Business Analyst", systemImage: "checkmark")
                                }
                                else
                                {
                                    Text("Business Analyst")
                                }
                            }

                            Button(action: { sortOrder = .roleValidator })
                            {
                                if sortOrder == .roleValidator
                                {
                                    Label("Validator", systemImage: "checkmark")
                                }
                                else
                                {
                                    Text("Validator")
                                }
                            }
                        }

                        // Date Created submenu
                        Menu("Date Created")
                        {
                            Button(action: { sortOrder = .dateNewest })
                            {
                                if sortOrder == .dateNewest
                                {
                                    Label("Newest First", systemImage: "checkmark")
                                }
                                else
                                {
                                    Text("Newest First")
                                }
                            }

                            Button(action: { sortOrder = .dateOldest })
                            {
                                if sortOrder == .dateOldest
                                {
                                    Label("Oldest First", systemImage: "checkmark")
                                }
                                else
                                {
                                    Text("Oldest First")
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundStyle(AppGradients.userGradient)
                    }
                }

                Button(action:
                    {
                        let user = User(firstName: Constants.EMPTY_STRING,
                                        lastName: Constants.EMPTY_STRING)

                        // Don't insert or save yet - let the detail view handle it
                        path.append(.userDetail(user))
                    })
                {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppGradients.userGradient)
                }
            }
        #elseif canImport(AppKit)
            ToolbarItemGroup(placement: .automatic)
            {
                // Only show sort/filter menu when there are users
                if !users.isEmpty
                {
                    Menu
                    {
                        // User Name submenu
                        Menu("User Name")
                        {
                            Button(action: { sortOrder = .nameAscending })
                            {
                                if sortOrder == .nameAscending
                                {
                                    Label("A-Z", systemImage: "checkmark")
                                }
                                else
                                {
                                    Text("A-Z")
                                }
                            }

                            Button(action: { sortOrder = .nameDescending })
                            {
                                if sortOrder == .nameDescending
                                {
                                    Label("Z-A", systemImage: "checkmark")
                                }
                                else
                                {
                                    Text("Z-A")
                                }
                            }
                        }

                        // Role submenu
                        Menu("Role")
                        {
                            Button(action: { sortOrder = .roleAdministrator })
                            {
                                if sortOrder == .roleAdministrator
                                {
                                    Label("Administrator", systemImage: "checkmark")
                                }
                                else
                                {
                                    Text("Administrator")
                                }
                            }

                            Button(action: { sortOrder = .roleDeveloper })
                            {
                                if sortOrder == .roleDeveloper
                                {
                                    Label("Developer", systemImage: "checkmark")
                                }
                                else
                                {
                                    Text("Developer")
                                }
                            }

                            Button(action: { sortOrder = .roleBusinessAnalyst })
                            {
                                if sortOrder == .roleBusinessAnalyst
                                {
                                    Label("Business Analyst", systemImage: "checkmark")
                                }
                                else
                                {
                                    Text("Business Analyst")
                                }
                            }

                            Button(action: { sortOrder = .roleValidator })
                            {
                                if sortOrder == .roleValidator
                                {
                                    Label("Validator", systemImage: "checkmark")
                                }
                                else
                                {
                                    Text("Validator")
                                }
                            }
                        }

                        // Date Created submenu
                        Menu("Date Created")
                        {
                            Button(action: { sortOrder = .dateNewest })
                            {
                                if sortOrder == .dateNewest
                                {
                                    Label("Newest First", systemImage: "checkmark")
                                }
                                else
                                {
                                    Text("Newest First")
                                }
                            }

                            Button(action: { sortOrder = .dateOldest })
                            {
                                if sortOrder == .dateOldest
                                {
                                    Label("Oldest First", systemImage: "checkmark")
                                }
                                else
                                {
                                    Text("Oldest First")
                                }
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }

                Button(action:
                    {
                        let user = User(firstName: Constants.EMPTY_STRING,
                                        lastName: Constants.EMPTY_STRING)

                        // Don't insert or save yet - let the detail view handle it
                        if let detailSelection = detailSelection {
                            detailSelection.wrappedValue = .userDetail(user)
                        } else {
                            path.append(.userDetail(user))
                        }
                    })
                {
                    Label("Add User", systemImage: "plus.circle.fill")
                }
            }
        #endif
    }
}

#Preview
{
    UserListView()
}
