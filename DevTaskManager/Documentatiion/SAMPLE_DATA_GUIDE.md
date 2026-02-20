# How to Access Sample Data

## Overview
The `SampleData.swift` file provides rich sample data for your DevTaskManager app including 6 projects, 5 users with roles, and multiple tasks.

## 📱 Method 1: Using the App (NEW!)

I've added a "Load Sample Data" button to your MainMenuView:

1. **Run your app** (Cmd+R)
2. On the **Main Menu**, you'll see a new "Development Tools" section at the bottom
3. Tap **"Load Sample Data"**
4. Navigate to **Project List** to see all the sample projects!

**Note:** This button only appears in DEBUG builds, so it won't show in production.

## 🎨 Method 2: Using Xcode Previews (Already Set Up!)

Your `ProjectListView` already has sample data in its preview:

1. Open **ProjectListView.swift** in Xcode
2. Open the Canvas (Cmd+Option+Return)
3. Click "Resume" if the preview isn't running
4. You'll see all 6 sample projects with tasks!

The preview code at the bottom of the file automatically loads sample data:
```swift
#Preview
{
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Project.self, Task.self, User.self, Role.self, configurations: config)
    
    SampleData.createSampleData(in: container.mainContext)
    
    return ProjectListView()
        .modelContainer(container)
}
```

## 🧪 Method 3: Using in Tests

```swift
import Testing
import SwiftData

@Test("Sample data creates projects")
func testSampleData() async throws {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
        for: Project.self, Task.self, User.self, Role.self,
        configurations: config
    )
    
    await MainActor.run {
        SampleData.createSampleData(in: container.mainContext)
    }
    
    // Test your data
    let projects = try await MainActor.run {
        try container.mainContext.fetch(FetchDescriptor<Project>())
    }
    
    #expect(projects.count == 6)
}
```

## 🔄 Method 4: Load on App Launch (Development Only)

Add this to your `DevTaskManagerApp.swift`:

```swift
import SwiftUI
import SwiftData

@main
struct DevTaskManagerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Project.self,
            Task.self,
            User.self,
            Role.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            #if DEBUG
            // Uncomment to load sample data on every app launch
            // SampleData.createSampleData(in: container.mainContext)
            #endif
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \\(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

## 📊 What Sample Data Contains

### 6 Projects:
1. **E-Commerce Platform** - 5 tasks (shopping cart, payments, testing)
2. **Mobile Banking App** - 3 tasks (biometric auth, dashboard, security)
3. **Task Management System** - 6 tasks (Kanban board, collaboration, time tracking)
4. **Social Media Dashboard** - 4 tasks (scheduling, analytics, design)
5. **Healthcare Portal** - 2 tasks (authentication, appointment scheduling)
6. **Fitness Tracker App** - 0 tasks (empty project for testing)

### 5 Users with Different Roles:
- **Sarah Johnson** - Admin
- **Michael Chen** - Developer
- **Emily Rodriguez** - Developer
- **James Williams** - Validator
- **Olivia Martinez** - Business Analyst

### Task Variety:
- ✅ Different statuses (Unassigned, In Progress, Completed)
- 🎯 Different priorities (High, Medium, Low)
- 🔧 Different types (Development, Testing, Design, Documentation)
- 👥 Various user assignments
- 📅 Realistic dates (projects from 45 days ago to 2 days ago)

## 🎯 Recommended Approach

**For Development:**
Use the "Load Sample Data" button I added to MainMenuView. This lets you:
- Load data whenever you want
- Test with fresh sample data
- Keep your database clean otherwise

**For Previews:**
Sample data is already loaded automatically - just open the Canvas!

**For Testing:**
Use Method 3 to create isolated test data in memory.

## 🗑️ Clearing Sample Data

To clear all data and start fresh:

1. Delete the app from your simulator/device
2. Reinstall and run again

Or add a "Clear All Data" button (development only):

```swift
#if DEBUG
Button("Clear All Data", role: .destructive) {
    do {
        try modelContext.delete(model: Project.self)
        try modelContext.delete(model: Task.self)
        try modelContext.delete(model: User.self)
        try modelContext.delete(model: Role.self)
        try modelContext.save()
    } catch {
        Log.error("Failed to clear data: \\(error)")
    }
}
#endif
```

## 🚀 Quick Start

1. **Run the app** (Cmd+R)
2. **Tap "Load Sample Data"** in the Main Menu
3. **Navigate to Project List**
4. **See your data!** Browse projects, users, and tasks

That's it! You now have a fully populated app to test all your features.
