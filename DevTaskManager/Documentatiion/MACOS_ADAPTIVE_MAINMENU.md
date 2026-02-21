# macOS-Adaptive MainMenuView Implementation

## Overview

This guide shows how to create a MainMenuView that provides:
- **iOS/iPadOS**: Beautiful card-based menu (current design)
- **macOS**: Native 3-column sidebar layout

## Complete Implementation

```swift
//
//  MainMenuView.swift
//  DevTaskManager
//
//  Cross-platform main menu with adaptive layouts
//
import SwiftData
import SwiftUI

struct MainMenuView: View
{
    @Environment(\.modelContext) var modelContext

    @State private var showSuccessToast = false
    @State private var selectedView: MenuDestination?

    // Menu destinations
    enum MenuDestination: Hashable, Identifiable
    {
        case dashboard
        case projectList
        case userList
        case taskList

        var id: Self { self }
    }

    var body: some View
    {
        #if os(macOS)
        macOSLayout
        #else
        iOSLayout
        #endif
    }
    
    // MARK: - macOS Layout (Native Sidebar)
    
    @ViewBuilder
    private var macOSLayout: some View
    {
        NavigationSplitView
        {
            // Sidebar (Column 1)
            List(selection: $selectedView)
            {
                Section("Analytics")
                {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                        .tag(MenuDestination.dashboard)
                }
                
                Section("Management")
                {
                    Label("Projects", systemImage: "folder.fill")
                        .tag(MenuDestination.projectList)
                    
                    Label("Users", systemImage: "person.3.fill")
                        .tag(MenuDestination.userList)
                    
                    Label("Tasks", systemImage: "checklist")
                        .tag(MenuDestination.taskList)
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
            .navigationTitle("DevTaskManager")
            .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar) {
                        Label("Toggle Sidebar", systemImage: "sidebar.left")
                    }
                }
            }
        } detail: {
            // Detail view (Columns 2 & 3)
            if let destination = selectedView
            {
                destinationView(for: destination)
                    .frame(minWidth: 600, minHeight: 400)
            }
            else
            {
                // Welcome/empty state
                welcomeView
            }
        }
        .successToast(
            isShowing: $showSuccessToast,
            message: "Sample data loaded successfully"
        )
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
                    .platformIgnoreSafeArea()

                VStack(spacing: 24)
                {
                    // App Header
                    headerView
                        .padding(.top, 40)
                        .padding(.bottom, 20)

                    // Menu Cards
                    ScrollView
                    {
                        VStack(spacing: 16)
                        {
                            menuCards
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer()
                }
            }
            .fullScreenCover(item: $selectedView)
            { destination in
                destinationView(for: destination)
            }
        }
        .successToast(
            isShowing: $showSuccessToast,
            message: "Sample data loaded successfully"
        )
    }
    
    // MARK: - Shared Components
    
    @ViewBuilder
    private var headerView: some View
    {
        VStack(spacing: 8)
        {
            Image(systemName: "checklist.checked")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("DevTaskManager")
                .font(.system(size: 32, weight: .bold, design: .rounded))

            Text("Manage your projects efficiently")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private var welcomeView: some View
    {
        VStack(spacing: 20)
        {
            Image(systemName: "checklist.checked")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Welcome to DevTaskManager")
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
        ) {
            selectedView = .dashboard
        }

        // Projects Card
        MenuCard(
            icon: "folder.fill",
            title: "Projects",
            subtitle: "Manage your projects",
            gradientColors: [.blue, .cyan]
        ) {
            selectedView = .projectList
        }

        // Users Card
        MenuCard(
            icon: "person.3.fill",
            title: "Users",
            subtitle: "Team members",
            gradientColors: [.purple, .pink]
        ) {
            selectedView = .userList
        }

        // Tasks Card
        MenuCard(
            icon: "checklist",
            title: "Tasks",
            subtitle: "Track your work",
            gradientColors: [.orange, .red]
        ) {
            selectedView = .taskList
        }

        #if DEBUG
        // Developer Tools Card
        MenuCard(
            icon: "hammer.fill",
            title: "Developer Tools",
            subtitle: "Load sample data",
            gradientColors: [.green, .mint]
        ) {
            loadSampleData()
        }
        #endif
    }
    
    // MARK: - Navigation
    
    @ViewBuilder
    private func destinationView(for destination: MenuDestination) -> some View
    {
        switch destination
        {
        case .dashboard:
            // Replace with your DashboardView when ready
            Text("Dashboard")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.systemBackground)
            
        case .projectList:
            ProjectListView()
            
        case .userList:
            UserListView()
            
        case .taskList:
            TaskListView()
        }
    }
    
    // MARK: - Actions
    
    private func loadSampleData()
    {
        SampleData.createSampleData(in: modelContext)
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

// MARK: - Menu Card Component

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
        Button(action: action)
        {
            HStack(spacing: 16)
            {
                // Icon
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
                        .shadow(
                            color: gradientColors.first?.opacity(0.3) ?? .clear,
                            radius: 8,
                            x: 0,
                            y: 4
                        )

                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                }

                // Text
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
                    .font(.body.weight(.semibold))
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
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                    action()
                }
        )
        #else
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
        #endif
    }
}

// MARK: - Previews

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
```

## Key Features

### macOS Layout
- **3-column NavigationSplitView**
- Collapsible sidebar with toggle button
- Minimum window size enforcement
- Native macOS sidebar styling
- Section headers for organization

### iOS Layout
- Beautiful card-based menu
- Full-screen navigation
- Gradient backgrounds
- Touch-optimized interactions

### Shared
- Same MenuDestination enum
- Unified navigation logic
- Consistent data loading
- Toast notifications

## Window Configuration

Add to your App file for optimal macOS experience:

```swift
@main
struct DevTaskManagerApp: App {
    // ... model container ...
    
    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        .defaultSize(width: 1200, height: 800)
        .windowStyle(.automatic)
        .windowToolbarStyle(.unified)
        .commands {
            // Add menu bar commands here
        }
        #endif
    }
}
```

## Testing

1. **iOS**: Tap cards → Full screen views
2. **macOS**: Click sidebar → Split view layout
3. **Sidebar**: Click toggle button to show/hide
4. **Resize**: Window resizes gracefully

## Benefits

✅ Native experience on each platform
✅ Single codebase
✅ Minimal code duplication
✅ Easy to maintain
✅ Platform-appropriate interactions

---

*macOS-Adaptive MainMenuView Guide*
