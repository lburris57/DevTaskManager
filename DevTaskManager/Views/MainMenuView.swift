//
//  MainMenuView.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/20/25.
//  Updated for macOS support on 2/20/26
//
import SwiftData
import SwiftUI

struct MainMenuView: View
{
    @Environment(\.modelContext) var modelContext
    @State private var showSuccessToast = false
    @State private var selectedView: MenuDestination?
    @State private var selectedDetailItem: AppNavigationDestination?

    enum MenuDestination: Hashable, Identifiable
    {
        case dashboard
        case projectList
        case userList
        case taskList
        case reports

        var id: Self { self }
    }

    var body: some View
    {
        #if os(macOS)
            macOSLayout
                .onAppear {
                    // Set dashboard as default view on macOS if nothing is selected
                    if selectedView == nil {
                        selectedView = .dashboard
                    }
                }
        #else
            iOSLayout
        #endif
    }

    // MARK: - macOS Layout (Two or Three-Column Navigation)

    @ViewBuilder
    private var macOSLayout: some View
    {
        // Check if the selected view needs three columns (list views) or two columns (dashboard/reports)
        if selectedView == .dashboard || selectedView == .reports {
            // Two-column layout for Dashboard and Reports
            twoColumnLayout
        } else {
            // Three-column layout for list views (Projects, Users, Tasks)
            threeColumnLayout
        }
    }
    
    // MARK: - Two-Column Layout (Dashboard & Reports)
    
    @ViewBuilder
    private var twoColumnLayout: some View
    {
        NavigationSplitView
        {
            // Sidebar (Column 1)
            sidebarContent
        } detail: {
            // Content view (Column 2) - Full width for Dashboard/Reports
            if let destination = selectedView
            {
                destinationView(for: destination)
                    .navigationSplitViewColumnWidth(min: 600, ideal: 900)
            }
            else
            {
                // Placeholder for when no section is selected
                ContentUnavailableView(
                    "No Selection",
                    systemImage: "sidebar.left",
                    description: Text("Select a section from the sidebar")
                )
                .navigationSplitViewColumnWidth(min: 600, ideal: 900)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .successToast(
            isShowing: $showSuccessToast,
            message: "Sample data loaded successfully! 🎉"
        )
    }
    
    // MARK: - Three-Column Layout (Projects, Users, Tasks)
    
    @ViewBuilder
    private var threeColumnLayout: some View
    {
        NavigationSplitView
        {
            // Sidebar (Column 1)
            sidebarContent
        } content: {
            // Content/List view (Column 2)
            if let destination = selectedView
            {
                destinationView(for: destination)
                    .navigationSplitViewColumnWidth(min: 300, ideal: 400, max: 500)
            }
            else
            {
                // Placeholder for when no section is selected
                ContentUnavailableView(
                    "No Selection",
                    systemImage: "sidebar.left",
                    description: Text("Select a section from the sidebar")
                )
                .navigationSplitViewColumnWidth(min: 300, ideal: 400, max: 500)
            }
        } detail: {
            // Detail view (Column 3) - Shows when an item is selected from the list
            if let detailItem = selectedDetailItem {
                detailViewForNavigation(detailItem)
                    .navigationSplitViewColumnWidth(min: 400, ideal: 600)
            } else {
                ContentUnavailableView(
                    "No Item Selected",
                    systemImage: "doc.text.image",
                    description: Text("Select an item from the list to view details")
                )
                .navigationSplitViewColumnWidth(min: 400, ideal: 600)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .successToast(
            isShowing: $showSuccessToast,
            message: "Sample data loaded successfully! 🎉"
        )
    }
    
    // MARK: - Shared Sidebar Content
    
    @ViewBuilder
    private var sidebarContent: some View
    {
        List(selection: $selectedView)
        {
            Section("Analytics")
            {
                NavigationLink(value: MenuDestination.dashboard)
                {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }

                NavigationLink(value: MenuDestination.reports)
                {
                    Label("Reports", systemImage: "chart.bar.doc.horizontal.fill")
                }
            }

            Section("Management")
            {
                NavigationLink(value: MenuDestination.projectList)
                {
                    Label("Projects", systemImage: "folder.fill")
                }

                NavigationLink(value: MenuDestination.userList)
                {
                    Label("Users", systemImage: "person.3.fill")
                }

                NavigationLink(value: MenuDestination.taskList)
                {
                    Label("Tasks", systemImage: "checklist")
                }
            }

            #if DEBUG
                Section("Development")
                {
                    Button(action: loadSampleData)
                    {
                        Label("Load Sample Data", systemImage: "hammer.fill")
                    }
                }
            #endif
        }
        .listStyle(.sidebar)
        .navigationTitle("Dev Task Manager")
        .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
        .toolbar
        {
            ToolbarItem(placement: .navigation)
            {
                #if os(macOS)
                Button(action: toggleSidebar)
                {
                    Label("Toggle Sidebar", systemImage: "sidebar.left")
                }
                #endif
            }
        }
        .onChange(of: selectedView) { oldValue, newValue in
            // Clear the detail selection when switching menu sections
            if oldValue != newValue {
                selectedDetailItem = nil
            }
        }
    }

    // MARK: - iOS Layout (Card Menu)

    @ViewBuilder
    private var iOSLayout: some View
    {
        NavigationStack
        {
            ZStack
            {
                // Background gradient
                AppGradients.mainBackground
                    .ignoresSafeArea()

                VStack(spacing: 0)
                {
                    // Header section with app title and subtitle
                    headerView
                        .padding(.vertical, 20)

                    // Main menu cards
                    ScrollView
                    {
                        VStack(spacing: 16)
                        {
                            menuCards
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }

                    Spacer()
                }
            }
            #if canImport(UIKit)
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedView)
            { destination in
                destinationView(for: destination)
            }
            #elseif canImport(AppKit)
            .sheet(item: $selectedView)
            { destination in
                destinationView(for: destination)
            }
            #endif
            .successToast(
                isShowing: $showSuccessToast,
                message: "Sample data loaded successfully! 🎉"
            )
        }
    }

    // MARK: - Shared Components

    @ViewBuilder
    private var headerView: some View
    {
        VStack(spacing: 8)
        {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.top, 20)

            Text("Dev Task Manager")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)

            Text("Organize your development workflow")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 10)
        }
    }

    @ViewBuilder
    private var welcomeView: some View
    {
        VStack(spacing: 20)
        {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Welcome to Dev Task Manager")
                .font(.largeTitle.bold())

            Text("Select a section from the sidebar to begin")
                .font(.title3)
                .foregroundStyle(.secondary)

            #if DEBUG
                Button("Load Sample Data", action: loadSampleData)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private var menuCards: some View
    {
        // Dashboard Card
        MenuCard(
            icon: "chart.bar.fill",
            title: "Dashboard",
            subtitle: "Overview & analytics",
            gradientColors: [.blue, .purple]
        )
        {
            selectedView = .dashboard
        }

        // Projects Card
        MenuCard(
            icon: "folder.fill",
            title: "Projects",
            subtitle: "Manage your projects",
            gradientColors: [.blue, .cyan],
            action: { selectedView = .projectList }
        )

        // Users Card
        MenuCard(
            icon: "person.3.fill",
            title: "Users",
            subtitle: "Manage team members",
            gradientColors: [.purple, .pink],
            action: { selectedView = .userList }
        )

        // Tasks Card
        MenuCard(
            icon: "checklist",
            title: "Tasks",
            subtitle: "View all tasks",
            gradientColors: [.orange, .red],
            action: { selectedView = .taskList }
        )

        // Reports Card
        MenuCard(
            icon: "chart.bar.doc.horizontal.fill",
            title: "Reports",
            subtitle: "View project analytics",
            gradientColors: [.indigo, .purple],
            action: { selectedView = .reports }
        )

        #if DEBUG
            // Developer Tools Card (Debug only)
            MenuCard(
                icon: "hammer.fill",
                title: "Developer Tools",
                subtitle: "Load sample data",
                gradientColors: [.green, .mint],
                action: loadSampleData
            )
        #endif
    }

    // MARK: - Navigation

    @ViewBuilder
    private func destinationView(for destination: MenuDestination) -> some View
    {
        switch destination
        {
        case .dashboard:
            DashboardView()
        case .projectList:
            #if os(macOS)
            ProjectListView(detailSelection: $selectedDetailItem)
            #else
            ProjectListView()
            #endif
        case .userList:
            #if os(macOS)
            UserListView(detailSelection: $selectedDetailItem)
            #else
            UserListView()
            #endif
        case .taskList:
            #if os(macOS)
            TaskListView(detailSelection: $selectedDetailItem)
            #else
            TaskListView()
            #endif
        case .reports:
            SimpleReportsView()
        }
    }
    
    @ViewBuilder
    private func detailViewForNavigation(_ destination: AppNavigationDestination) -> some View
    {
        switch destination
        {
        case let .taskDetail(task, context):
            TaskDetailView(task: task, path: .constant([]), onDismissToMain: {}, sourceContext: context)
        case let .projectDetail(project):
            ProjectDetailView(project: project, path: .constant([]), onDismissToMain: {})
        case let .userDetail(user):
            UserDetailView(user: user, path: .constant([]))
        case let .projectTasks(project):
            ProjectTasksView(project: project, path: .constant([]))
        case let .userTasks(user):
            UserTasksView(user: user, path: .constant([]))
        }
    }

    // MARK: - Actions

    // Load sample data with visual feedback
    private func loadSampleData()
    {
        SampleData.createSampleData(in: modelContext)

        // Show success toast (auto-dismisses after 3 seconds)
        withAnimation
        {
            showSuccessToast = true
        }
    }

    #if os(macOS)
        private func toggleSidebar()
        {
            NSApp.keyWindow?.firstResponder?.tryToPerform(
                #selector(NSSplitViewController.toggleSidebar(_:)),
                with: nil
            )
        }
    #endif
}

// MARK: - MenuCard Component

struct MenuCard: View
{
    let icon: String
    let title: String
    let subtitle: String
    let gradientColors: [Color]
    let action: () -> Void

    @State private var isPressed = false
    @State private var isHovering = false

    var body: some View
    {
        #if DEBUG
        let _ = print("🎯 Platform check:")
        #if os(macOS)
        let _ = print("✅ os(macOS) = true - Using macOSLayout")
        #else
        let _ = print("❌ os(macOS) = false - Using iOSLayout")
        #endif
        #endif

        return Button(action: action)
        {
            HStack(spacing: 16)
            {
                // Icon with gradient background
                ZStack
                {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: gradientColors.first?.opacity(0.3) ?? .clear, radius: 8, x: 0, y: 4)

                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                }

                // Title and subtitle
                VStack(alignment: .leading, spacing: 4)
                {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.systemBackground)
                    .shadow(color: .black.opacity(isHovering ? 0.12 : 0.08), radius: 10, x: 0, y: 4)
            )
            .scaleEffect(isPressed || isHovering ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        #if os(iOS)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged
                    { _ in
                        withAnimation(.easeInOut(duration: 0.1))
                        {
                            isPressed = true
                        }
                    }
                    .onEnded
                    { _ in
                        withAnimation(.easeInOut(duration: 0.1))
                        {
                            isPressed = false
                        }
                    }
            )
        #else
                .onHover
                { hovering in
                    withAnimation(.easeInOut(duration: 0.15))
                    {
                        isHovering = hovering
                    }
                }
        #endif
    }
}

#Preview("iOS", traits: .modifier(SampleDataPreviewModifier()))
{
    MainMenuView()
}

#if os(macOS)
    #Preview("macOS", traits: .modifier(SampleDataPreviewModifier()))
    {
        MainMenuView()
            .frame(width: 1200, height: 800)
    }
#endif
