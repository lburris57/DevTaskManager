# macOS Keyboard Shortcuts & Menu Bar Support

## Overview

Add native macOS keyboard shortcuts and menu bar commands to your DevTaskManager app.

## Keyboard Shortcuts Implementation

### Step 1: Add Keyboard Shortcuts to Views

Update your MainMenuView to support keyboard shortcuts:

```swift
var body: some View {
    #if os(macOS)
    macOSLayout
        .onAppear {
            setupKeyboardShortcuts()
        }
    #else
    iOSLayout
    #endif
}

#if os(macOS)
private func setupKeyboardShortcuts() {
    // Shortcuts are handled via menu bar commands
}
#endif
```

### Step 2: Add Menu Bar Commands

Update your App file:

```swift
@main
struct DevTaskManagerApp: App {
    let sharedModelContainer: ModelContainer = { /* ... */ }()
    
    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        .defaultSize(width: 1200, height: 800)
        .commands {
            // File Menu
            CommandGroup(replacing: .newItem) {
                Button("New Task") {
                    // Trigger new task creation
                    NotificationCenter.default.post(
                        name: .createNewTask,
                        object: nil
                    )
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("New Project") {
                    NotificationCenter.default.post(
                        name: .createNewProject,
                        object: nil
                    )
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
                
                Button("New User") {
                    NotificationCenter.default.post(
                        name: .createNewUser,
                        object: nil
                    )
                }
                .keyboardShortcut("n", modifiers: [.command, .option])
                
                Divider()
                
                Button("Close Window") {
                    NSApp.keyWindow?.close()
                }
                .keyboardShortcut("w", modifiers: .command)
            }
            
            // View Menu
            CommandGroup(after: .sidebar) {
                Button("Dashboard") {
                    NotificationCenter.default.post(
                        name: .showDashboard,
                        object: nil
                    )
                }
                .keyboardShortcut("1", modifiers: .command)
                
                Button("Projects") {
                    NotificationCenter.default.post(
                        name: .showProjects,
                        object: nil
                    )
                }
                .keyboardShortcut("2", modifiers: .command)
                
                Button("Users") {
                    NotificationCenter.default.post(
                        name: .showUsers,
                        object: nil
                    )
                }
                .keyboardShortcut("3", modifiers: .command)
                
                Button("Tasks") {
                    NotificationCenter.default.post(
                        name: .showTasks,
                        object: nil
                    )
                }
                .keyboardShortcut("4", modifiers: .command)
                
                Divider()
                
                Button("Refresh") {
                    NotificationCenter.default.post(
                        name: .refreshData,
                        object: nil
                    )
                }
                .keyboardShortcut("r", modifiers: .command)
            }
            
            // Edit Menu
            CommandGroup(after: .pasteboard) {
                Button("Find...") {
                    NotificationCenter.default.post(
                        name: .showSearch,
                        object: nil
                    )
                }
                .keyboardShortcut("f", modifiers: .command)
            }
            
            // Help Menu
            CommandGroup(replacing: .help) {
                Button("DevTaskManager Help") {
                    if let url = URL(string: "https://your-help-url.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .keyboardShortcut("?", modifiers: .command)
            }
        }
        #endif
    }
}
```

## Notification Names Extension

Create a new file `NotificationNames.swift`:

```swift
//
//  NotificationNames.swift
//  DevTaskManager
//
//  Notification names for app-wide events
//
import Foundation

extension Notification.Name {
    // Creation
    static let createNewTask = Notification.Name("createNewTask")
    static let createNewProject = Notification.Name("createNewProject")
    static let createNewUser = Notification.Name("createNewUser")
    
    // Navigation
    static let showDashboard = Notification.Name("showDashboard")
    static let showProjects = Notification.Name("showProjects")
    static let showUsers = Notification.Name("showUsers")
    static let showTasks = Notification.Name("showTasks")
    
    // Actions
    static let refreshData = Notification.Name("refreshData")
    static let showSearch = Notification.Name("showSearch")
}
```

## Handle Notifications in MainMenuView

```swift
struct MainMenuView: View {
    @Environment(\.modelContext) var modelContext
    @State private var selectedView: MenuDestination?
    
    var body: some View {
        // ... your layout ...
        .onReceive(NotificationCenter.default.publisher(for: .showDashboard)) { _ in
            selectedView = .dashboard
        }
        .onReceive(NotificationCenter.default.publisher(for: .showProjects)) { _ in
            selectedView = .projectList
        }
        .onReceive(NotificationCenter.default.publisher(for: .showUsers)) { _ in
            selectedView = .userList
        }
        .onReceive(NotificationCenter.default.publisher(for: .showTasks)) { _ in
            selectedView = .taskList
        }
    }
}
```

## Complete Keyboard Shortcuts Reference

### File Menu
| Shortcut | Action | Description |
|----------|--------|-------------|
| ⌘N | New Task | Create a new task |
| ⇧⌘N | New Project | Create a new project |
| ⌥⌘N | New User | Create a new user |
| ⌘W | Close Window | Close current window |
| ⌘Q | Quit | Quit application |

### Edit Menu
| Shortcut | Action | Description |
|----------|--------|-------------|
| ⌘Z | Undo | Undo last action |
| ⇧⌘Z | Redo | Redo last action |
| ⌘X | Cut | Cut selection |
| ⌘C | Copy | Copy selection |
| ⌘V | Paste | Paste clipboard |
| ⌘A | Select All | Select all items |
| ⌘F | Find | Show search |

### View Menu
| Shortcut | Action | Description |
|----------|--------|-------------|
| ⌘1 | Dashboard | Show dashboard |
| ⌘2 | Projects | Show projects |
| ⌘3 | Users | Show users |
| ⌘4 | Tasks | Show tasks |
| ⌘R | Refresh | Refresh current view |
| ⌘⌃F | Toggle Fullscreen | Enter/exit fullscreen |

### Window Menu
| Shortcut | Action | Description |
|----------|--------|-------------|
| ⌘M | Minimize | Minimize window |
| ⌘` | Next Window | Cycle through windows |

### Help Menu
| Shortcut | Action | Description |
|----------|--------|-------------|
| ⌘? | Help | Show help |

## Advanced: Context Menu Shortcuts

Add keyboard shortcuts to list items:

```swift
.contextMenu {
    Button(action: { /* edit */ }) {
        Text("Edit")
    }
    .keyboardShortcut(.return, modifiers: .command)
    
    Button(action: { /* duplicate */ }) {
        Text("Duplicate")
    }
    .keyboardShortcut("d", modifiers: .command)
    
    Divider()
    
    Button(role: .destructive, action: { /* delete */ }) {
        Text("Delete")
    }
    .keyboardShortcut(.delete, modifiers: .command)
}
```

## Touch Bar Support (Optional)

For MacBook Pro with Touch Bar:

```swift
#if os(macOS)
.touchBar {
    Button("New Task") {
        // Create task
    }
    
    Button("Refresh") {
        // Refresh
    }
    
    Spacer()
    
    Button("Dashboard") {
        selectedView = .dashboard
    }
    
    Button("Projects") {
        selectedView = .projectList
    }
}
#endif
```

## Menu Bar Validation

Enable/disable menu items based on context:

```swift
CommandGroup(replacing: .newItem) {
    Button("New Task") {
        // ...
    }
    .keyboardShortcut("n", modifiers: .command)
    .disabled(/* condition */)  // Disable when appropriate
}
```

## Testing Shortcuts

### Manual Testing
1. Build and run macOS target
2. Try each keyboard shortcut
3. Verify correct action occurs
4. Check menu items show shortcuts
5. Test with different windows

### Automated Testing
```swift
@Test
func testKeyboardShortcuts() async throws {
    // Test shortcut registration
    // Verify notifications are sent
    // Check view navigation
}
```

## Best Practices

### Do:
✅ Use standard macOS shortcuts when possible
✅ Show shortcuts in menu items
✅ Group related commands logically
✅ Provide keyboard alternatives for all mouse actions
✅ Test shortcuts don't conflict

### Don't:
❌ Override system shortcuts (⌘Q, ⌘W, etc.)
❌ Create confusing shortcut combinations
❌ Forget to update help documentation
❌ Make shortcuts platform-specific in shared code

## Accessibility

Keyboard shortcuts improve accessibility:
- ✅ Faster navigation for power users
- ✅ Alternative to mouse for those who can't use one
- ✅ Consistent with macOS standards
- ✅ VoiceOver announces shortcuts

## Summary

With keyboard shortcuts and menu bar support:
- ⌘N - Quick task creation
- ⌘1-4 - Fast navigation
- ⌘F - Search anywhere
- ⌘R - Refresh data
- ⌘W - Close windows
- Native macOS experience

Your app now feels like a true Mac application! 🎉

---

*macOS Keyboard Shortcuts & Menu Bar Guide*
