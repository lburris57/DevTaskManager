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

    @State private var path: [AppNavigationDestination] = []
    @State private var hasLoadedRoles = false
    @State private var searchText = ""
    @State private var sortOrder = SortOrder.titleAscending
    @State private var showDeleteToast = false
    @State private var deletedProjectName = ""

    @Query var projects: [Project]

    // Sort order options
    enum SortOrder: String, CaseIterable
    {
        case titleAscending = "Title A-Z"
        case titleDescending = "Title Z-A"
        case dateNewest = "Newest First"
        case dateOldest = "Oldest First"
    }

    // Filtered and sorted projects
    var filteredProjects: [Project]
    {
        let filtered: [Project]

        if searchText.isEmpty
        {
            filtered = projects
        }
        else
        {
            filtered = projects.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
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
        modelContext.insert(project)

        do
        {
            try modelContext.save()
            path.append(.projectDetail(project))
        }
        catch
        {
            Log.error("Failed to create project: \(error.localizedDescription)")
        }
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

    var body: some View
    {
        NavigationStack(path: $path)
        {
            VStack(spacing: 0)
            {
                // Search bar at the top
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search projects", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)
                
                if !projects.isEmpty
                {
                    List
                    {
                        // Display all the projects in a navigation link
                        ForEach(filteredProjects)
                        {
                            project in

                            ProjectRowView(project: project, path: $path)
                        }
                        .onDelete(perform: deleteProjects)
                    }
                    .listStyle(.plain)
                }
                else
                {
                    // No projects were found
                    ContentUnavailableView
                    {
                        Label("No projects yet", systemImage: "folder.badge.plus")
                    } description: {
                        Text("Create your first project to get started")
                    } actions: {
                        Button("Add Project")
                        {
                            createNewProject()
                        }
                        .buttonStyle(.borderedProminent)
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
                
                ToolbarItemGroup(placement: .topBarTrailing)
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
                    }
                    
                    Button(action: createNewProject)
                    {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Project List")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(for: AppNavigationDestination.self) { destination in
                switch destination {
                case .projectTasks(let project):
                    ProjectTasksView(project: project, path: $path)
                case .projectDetail(let project):
                    ProjectDetailView(project: project, path: $path)
                case .taskDetail(let task):
                    TaskDetailView(task: task, path: $path)
                case .userDetail(let user):
                    UserDetailView(user: user, path: $path)
                case .userTasks(let user):
                    UserTasksView(user: user, path: $path)
                }
            }
            .onAppear(perform: saveRoles)
        }
        .successToast(
            isShowing: $showDeleteToast,
            message: "'\(deletedProjectName)' deleted"
        )
        .background(Color(UIColor.systemBackground))
        .ignoresSafeArea(.all, edges: .top)
    }
}

// MARK: - Project Row View

struct ProjectRowView: View
{
    let project: Project
    @Binding var path: [AppNavigationDestination]

    var body: some View
    {
        NavigationLink(value: AppNavigationDestination.projectTasks(project)) {
            VStack(alignment: .leading, spacing: 8)
            {
                HStack {
                    Text(project.title.isEmpty ? "Untitled Project" : project.title)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        path.append(.projectDetail(project))
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
        .accessibilityLabel("Project: \(project.title.isEmpty ? "Untitled" : project.title)")
        .accessibilityHint("Tap to view tasks. Tap edit button to edit project.")
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
