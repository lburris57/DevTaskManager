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
    @Environment(\.dismiss) var dismiss

    // Optional binding for macOS NavigationSplitView detail column
    var detailSelection: Binding<AppNavigationDestination?>?
    
    @State private var path: [AppNavigationDestination] = []
    @State private var hasLoadedRoles = false
    @State private var searchText = ""
    @State private var sortOrder = SortOrder.titleAscending
    @State private var showDeleteToast = false
    @State private var deletedProjectName = ""

    // Filter states (for future filtering)
    @State private var selectedStatus: String? = nil

    @Query var projects: [Project]

    // Sort order options
    enum SortOrder: String, CaseIterable
    {
        case titleAscending = "Title A-Z"
        case titleDescending = "Title Z-A"
        case dateNewest = "Newest First"
        case dateOldest = "Oldest First"
    }

    // Computed property for active filter badges
    private var activeFilterBadges: [FilterBadgesContainer.FilterBadge]
    {
        var badges: [FilterBadgesContainer.FilterBadge] = []

        // Add badge for status filter if active
        if let status = selectedStatus
        {
            badges.append(.init(
                text: "Status: \(status)",
                icon: "checkmark.circle",
                onClear: { selectedStatus = nil }
            ))
        }

        return badges
    }

    // Filtered and sorted projects
    var filteredProjects: [Project]
    {
        var filtered: [Project]

        // Apply search filter
        if searchText.isEmpty
        {
            filtered = projects
        }
        else
        {
            filtered = projects.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }

        // Apply status filter if selected (example - customize based on your needs)
        if let status = selectedStatus
        {
            // Example: You could filter by completion percentage, task count, etc.
            // For now, this is a placeholder for when you add actual status filtering
            // filtered = filtered.filter { /* your filter logic */ }
        }

        // Apply sorting
        switch sortOrder
        {
        case .titleAscending:
            return filtered.sorted { $0.title < $1.title }
        case .titleDescending:
            return filtered.sorted { $0.title > $1.title }
        case .dateNewest:
            return filtered.sorted { $0.dateCreated > $1.dateCreated }
        case .dateOldest:
            return filtered.sorted { $0.dateCreated < $1.dateCreated }
        }
    }

    // Save roles to the database (only once)
    func saveRoles()
    {
        // Only load roles once
        guard !hasLoadedRoles else { return }

        let descriptor = FetchDescriptor<Role>()
        let existingRoles = (try? modelContext.fetch(descriptor)) ?? []

        guard existingRoles.isEmpty
        else
        {
            hasLoadedRoles = true
            return
        }

        let roles = Role.loadRoles()

        Log.info("The permissions for validators are: \(roles[3].permissions)")

        for role in roles
        {
            role.lastUpdated = Date()
            modelContext.insert(role)
        }

        do
        {
            try modelContext.save()
            hasLoadedRoles = true
        }
        catch
        {
            Log.error("Failed to save roles: \(error.localizedDescription)")
        }
    }

    // Create a new project
    func createNewProject()
    {
        let project = Project(title: Constants.EMPTY_STRING,
                              descriptionText: Constants.EMPTY_STRING)

        // Don't insert or save yet - let the detail view handle it
        #if os(macOS)
        if let detailSelection = detailSelection {
            detailSelection.wrappedValue = .projectDetail(project)
        } else {
            path.append(.projectDetail(project))
        }
        #else
        path.append(.projectDetail(project))
        #endif
    }

    // Delete projects
    func deleteProjects(at offsets: IndexSet)
    {
        for index in offsets
        {
            let project = filteredProjects[index]
            deletedProjectName = project.title.isEmpty ? "Untitled Project" : project.title
            modelContext.delete(project)
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
            Log.error("Failed to delete project: \(error.localizedDescription)")
        }
    }
    
    // Helper function to create project list row
    @ViewBuilder
    private func projectListRow(for project: Project) -> some View
    {
        #if os(macOS)
        // macOS: Use button with selection binding for NavigationSplitView
        Button(action: {
            if let detailSelection = detailSelection {
                detailSelection.wrappedValue = .projectDetail(project)
            } else {
                path.append(.projectDetail(project))
            }
        }) {
            ModernListRow
            {
                ProjectRowView(project: project, path: $path, detailSelection: detailSelection)
            }
        }
        .buttonStyle(.plain)
        .contextMenu
        {
            Button(role: .destructive)
            {
                if let index = filteredProjects.firstIndex(where: { $0.id == project.id })
                {
                    deleteProjects(at: IndexSet(integer: index))
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .id(project.projectId)
        #else
        // iOS: Use NavigationLink for full-screen presentation
        NavigationLink(value: AppNavigationDestination.projectDetail(project))
        {
            ModernListRow
            {
                ProjectRowView(project: project, path: $path, detailSelection: nil)
            }
        }
        .buttonStyle(.plain)
        .contextMenu
        {
            Button(role: .destructive)
            {
                if let index = filteredProjects.firstIndex(where: { $0.id == project.id })
                {
                    deleteProjects(at: IndexSet(integer: index))
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .id(project.projectId)
        #endif
    }

    var body: some View
    {
        #if os(macOS)
        // macOS: Plain view without NavigationStack (participates in NavigationSplitView)
        projectListContent
        #else
        // iOS: Wrapped in NavigationStack for full-screen presentation
        NavigationStack(path: $path)
        {
            projectListContent
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
                            .foregroundStyle(AppGradients.projectGradient)
                        }
                    }

                    ToolbarItemGroup(placement: .primaryAction)
                    {
                        // Only show sort menu when there are projects
                        if !projects.isEmpty
                        {
                            Menu
                            {
                                Picker("Sort by", selection: $sortOrder)
                                {
                                    ForEach(SortOrder.allCases, id: \.self)
                                    {
                                        order in
                                        Text(order.rawValue).tag(order)
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
                                    .foregroundStyle(AppGradients.projectGradient)
                            }
                        }

                        Button(action: createNewProject)
                        {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(AppGradients.projectGradient)
                        }
                    }
                }
                .platformNavigationBar()
                .navigationDestination(for: AppNavigationDestination.self)
                {
                    destination in
                    
                    switch destination
                    {
                        case let .projectTasks(project):
                            ProjectTasksView(project: project, path: $path)
                        case let .projectDetail(project):
                            ProjectDetailView(project: project, path: $path, onDismissToMain: { dismiss() }, detailSelection: detailSelection)
                        case let .taskDetail(task, context):
                            TaskDetailView(task: task, path: $path, onDismissToMain: { dismiss() }, sourceContext: context)
                        case let .userDetail(user):
                            UserDetailView(user: user, path: $path)
                        case let .userTasks(user):
                            UserTasksView(user: user, path: $path)
                    }
                }
        }
        .successToast(
            isShowing: $showDeleteToast,
            message: "'\(deletedProjectName)' deleted"
        )
        #endif
    }
    
    // MARK: - Project List Content
    
    @ViewBuilder
    private var projectListContent: some View
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
                        icon: "folder.fill",
                        title: "Projects",
                        subtitle: "\(filteredProjects.count) total",
                        gradientColors: [.blue, .cyan]
                    )

                    // Filter badges - shows active filters
                    FilterBadgesContainer(badges: activeFilterBadges)

                    // Modern search bar
                    HStack
                    {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search projects", text: $searchText)
                            .textFieldStyle(.plain)

                        if !searchText.isEmpty
                        {
                            Button(action: { searchText = "" })
                            {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.systemBackground)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                    if !projects.isEmpty
                    {
                        ScrollView
                        {
                            LazyVStack(spacing: 8)
                            {
                                ForEach(filteredProjects)
                                { project in
                                    projectListRow(for: project)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    else
                    {
                        Spacer()
                        EmptyStateCard(
                            icon: "folder.badge.plus",
                            title: "No Projects Yet",
                            message: "Create your first project to get started organizing your work",
                            buttonTitle: "Add Project",
                            buttonAction: createNewProject
                        )
                        Spacer()
                    }
                }
            }
        #if os(macOS)
        .toolbar
        {
            ToolbarItemGroup(placement: .primaryAction)
            {
                // Only show sort menu when there are projects
                if !projects.isEmpty
                {
                    Menu
                    {
                        Picker("Sort by", selection: $sortOrder)
                        {
                            ForEach(SortOrder.allCases, id: \.self)
                            {
                                order in
                                Text(order.rawValue).tag(order)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }

                Button(action: createNewProject)
                {
                    Label("Add Project", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationDestination(for: AppNavigationDestination.self)
        {
            destination in
            
            switch destination
            {
                case let .projectTasks(project):
                    ProjectTasksView(project: project, path: $path)
                case let .projectDetail(project):
                    ProjectDetailView(project: project, path: $path, onDismissToMain: {}, detailSelection: detailSelection)
                case let .taskDetail(task, context):
                    TaskDetailView(task: task, path: $path, onDismissToMain: {}, sourceContext: context)
                case let .userDetail(user):
                    UserDetailView(user: user, path: $path)
                case let .userTasks(user):
                    UserTasksView(user: user, path: $path)
            }
        }
        .successToast(
            isShowing: $showDeleteToast,
            message: "'\(deletedProjectName)' deleted"
        )
        .onAppear(perform: saveRoles)
        #endif
    }
}

// MARK: - Project Row View

struct ProjectRowView: View
{
    let project: Project
    @Binding var path: [AppNavigationDestination]
    var detailSelection: Binding<AppNavigationDestination?>?

    var body: some View
    {
        #if os(macOS)
        // macOS: Use button for project tasks navigation
        Button(action: {
            if let detailSelection = detailSelection {
                detailSelection.wrappedValue = .projectTasks(project)
            } else {
                path.append(.projectTasks(project))
            }
        }) {
            projectRowContent
        }
        .accessibilityLabel("Project: \(project.title.isEmpty ? "Untitled" : project.title)")
        .accessibilityHint("Tap to view tasks. Tap edit button to edit project.")
        #else
        // iOS: Use NavigationLink
        NavigationLink(value: AppNavigationDestination.projectTasks(project))
        {
            projectRowContent
        }
        .accessibilityLabel("Project: \(project.title.isEmpty ? "Untitled" : project.title)")
        .accessibilityHint("Tap to view tasks. Tap edit button to edit project.")
        #endif
    }
    
    @ViewBuilder
    private var projectRowContent: some View
    {
        VStack(alignment: .leading, spacing: 8)
        {
            HStack
            {
                Text(project.title.isEmpty ? "Untitled Project" : project.title)
                    .font(.headline)

                Spacer()

                Button(action: {
                    #if os(macOS)
                    if let detailSelection = detailSelection {
                        detailSelection.wrappedValue = .projectDetail(project)
                    } else {
                        path.append(.projectDetail(project))
                    }
                    #else
                    path.append(.projectDetail(project))
                    #endif
                })
                {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }

            if !project.descriptionText.isEmpty
            {
                Text(project.descriptionText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack
            {
                Label(project.dateCreated.formatted(date: .abbreviated, time: .omitted),
                      systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if !project.tasks.isEmpty
                {
                    Label("\(project.tasks.count)", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview("With Sample Data", traits: .modifier(SampleDataPreviewModifier()))
{
    ProjectListView()
}

#Preview("Empty State", traits: .modifier(EmptyDataPreviewModifier()))
{
    ProjectListView()
}
