# UserListView Documentation

## Overview
`UserListView` provides a comprehensive interface for managing team members in the DevTaskManager application. It offers user viewing, role-based filtering, sorting options, and navigation to user details and assigned tasks.

## File Information
- **File**: `UserListView.swift`
- **Created**: April 19, 2025 (estimated)
- **Platform**: iOS
- **Framework**: SwiftUI
- **Dependencies**: SwiftData

## Architecture

### View Structure
```
UserListView (NavigationStack)
└── ZStack
    ├── Background Color (System Background)
    ├── AppGradients.mainBackground
    └── VStack
        ├── ModernHeaderView
        ├── ScrollView (if users exist)
        │   └── LazyVStack
        │       └── ForEach(sortedUsers)
        │           └── ModernListRow
        │               └── User Row Content
        │                   ├── User Info (NavigationLink)
        │                   └── Assigned Tasks Button
        └── EmptyStateCard (if no users)
```

## Main Components

### Properties

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `modelContext` | `ModelContext` | `@Environment` | SwiftData context for data operations |
| `dismiss` | `DismissAction` | `@Environment` | Action to dismiss the view |
| `path` | `[AppNavigationDestination]` | `@State` | Navigation path for type-safe navigation |
| `showDeleteToast` | `Bool` | `@State` | Controls toast notification visibility |
| `deletedUserName` | `String` | `@State` | Name of deleted user for toast message |
| `sortOrder` | `SortOrder` | `@State` | Current sort/filter selection |
| `users` | `[User]` | `@Query` | All users sorted by last name |
| `roles` | `[Role]` | `@Query` | All roles sorted by role name |

### Sort Order Enum

```swift
enum SortOrder: String, CaseIterable {
    // Name sorting
    case nameAscending = "Name A-Z"
    case nameDescending = "Name Z-A"
    
    // Role filters
    case roleAdministrator = "Administrator"
    case roleDeveloper = "Developer"
    case roleBusinessAnalyst = "Business Analyst"
    case roleValidator = "Validator"
    
    // Date sorting
    case dateNewest = "Newest First"
    case dateOldest = "Oldest First"
}
```

**Total Options**: 10 sort and filter combinations

## Core Functionality

### 1. Sort & Filter

#### `sortedUsers` Computed Property
```swift
private var sortedUsers: [User]
```

**Algorithm**:
Based on selected `sortOrder`, returns:

**Name Sorting (2)**:
| Option | Field | Order | Secondary Sort |
|--------|-------|-------|----------------|
| Name A-Z | `user.fullName()` | Ascending | N/A |
| Name Z-A | `user.fullName()` | Descending | N/A |

**Role Filtering (4)**:
| Option | Filter | Sort After Filter |
|--------|--------|-------------------|
| Administrator | `user.roles.contains("Administrator")` | fullName() A-Z |
| Developer | `user.roles.contains("Developer")` | fullName() A-Z |
| Business Analyst | `user.roles.contains("Business Analyst")` | fullName() A-Z |
| Validator | `user.roles.contains("Validator")` | fullName() A-Z |

**Date Sorting (2)**:
| Option | Field | Order |
|--------|-------|-------|
| Newest First | `user.dateCreated` | Descending |
| Oldest First | `user.dateCreated` | Ascending |

**Role Filter Logic**:
```swift
return users.filter { $0.roles.contains(where: { $0.roleName == "Administrator" }) }
             .sorted { $0.fullName() < $1.fullName() }
```

### 2. User Deletion

#### `deleteUsers(at:)` Method
```swift
func deleteUsers(at offsets: IndexSet)
```

**Purpose**: Deletes selected users from the database.

**Parameters**:
- `offsets`: IndexSet of users to delete in sorted list

**Behavior**:
1. Iterates through offset indices
2. Gets user from `sortedUsers` array
3. Stores user's full name for toast message
4. Deletes user from model context
5. Saves context with error handling
6. Shows success toast with animation

**Cascade Behavior**:
- User's assigned tasks may be affected
- SwiftData relationships handle cascading

**Error Handling**: Logs errors via `Log.error()`

## User Interface

### Header Section
- **Component**: `ModernHeaderView`
- **Icon**: "person.3.fill"
- **Title**: "Users"
- **Subtitle**: Dynamic count (e.g., "5 team members")
- **Gradient**: Purple to Pink

### User Row Structure

Each user row is split into two interactive sections:

#### 1. User Info Section (NavigationLink)
```swift
NavigationLink(value: AppNavigationDestination.userDetail(user)) {
    userInfoView(for: user)
}
```

**Displays**:
```
┌────────────────────────────┐
│ User: [First] [Last]       │
│ Role: [Primary Role]       │
│ Date Created: [Date]       │
└────────────────────────────┘
```

**Interaction**: Tap to edit user details

#### 2. Assigned Tasks Section

Conditional based on task count:

**If tasks > 0**:
```swift
NavigationLink(value: AppNavigationDestination.userTasks(user)) {
    HStack {
        Image(systemName: "list.bullet.clipboard").green
        Text("View X Assigned Task(s)").green
        Spacer()
        Image(systemName: "chevron.right").green
    }
    .background(Color.green.opacity(0.1))
}
```

**If tasks == 0**:
```swift
HStack {
    Image(systemName: "checkmark.circle").secondary
    Text("No tasks assigned").secondary
}
```

### User Info View

#### `userInfoView(for:)` Method
```swift
private func userInfoView(for user: User) -> some View
```

**Layout**: VStack with 3 HStacks:

1. **User Label & Name**
   - Left: "User:" (bold)
   - Right: Full name

2. **Role Label & Value**
   - Left: "Role:" (bold)
   - Right: Primary role or default role

3. **Date Created Label & Value**
   - Left: "Date Created:" (bold)
   - Right: Formatted date

**Role Logic**:
```swift
Text(user.roles.map(\.self).first?.roleName ?? roles[0].roleName)
```
- Gets first role from user's roles array
- Falls back to first role in roles query if none assigned

### Assigned Tasks Button

#### `assignedTasksButton(for:)` Method
```swift
@ViewBuilder
private func assignedTasksButton(for user: User) -> some View
```

**Conditional Rendering**:
- Shows green button if `user.tasks.count > 0`
- Shows gray "No tasks assigned" if count == 0

**Features**:
- Task count badge
- Proper pluralization ("1 Task" vs "2 Tasks")
- Green color scheme for active tasks
- NavigationLink to UserTasksView

### Empty State
When no users exist:
- Icon: "person.badge.plus"
- Title: "No Users Yet"
- Message: "Add team members to start assigning tasks and collaborating"

### Empty State View (Deprecated)

```swift
private var emptyStateView: some View {
    ContentUnavailableView {
        Label("No users were found for display.", systemImage: "calendar.badge.clock")
    } description: {
        Text("\nPlease click the 'Add User' button to create your first user record.")
    }
}
```

**Note**: Currently not used; replaced by `EmptyStateCard` component

## Navigation Architecture

### Navigation Path
```swift
@State private var path: [AppNavigationDestination] = []
```

### Destination Handler
```swift
.navigationDestination(for: AppNavigationDestination.self) { destination in
    switch destination {
    case .userDetail(let user):
        UserDetailView(user: user, path: $path)
    case .userTasks(let user):
        UserTasksView(user: user, onDismissToMain: { dismiss() }, path: $path)
    case .taskDetail(let task, let context):
        TaskDetailView(task: task, path: $path, onDismissToMain: { dismiss() }, sourceContext: context)
    case .projectDetail(let project):
        ProjectDetailView(project: project, path: $path, onDismissToMain: { dismiss() })
    case .projectTasks(let project):
        ProjectTasksView(project: project, path: $path)
    }
}
```

**Navigation Flow**:
```
UserListView
├── UserDetailView (tap user info area)
│   └── Back to UserListView
├── UserTasksView (tap "View Assigned Tasks")
│   ├── TaskDetailView (tap task)
│   │   └── Context: .userTasksList
│   │   └── Back button: "Back To Assigned Tasks"
│   └── UserDetailView (from menu)
└── [Indirect via nested navigation]
    ├── ProjectDetailView
    └── ProjectTasksView
```

## Toolbar

### Leading: Back Button
```swift
Button(action: { dismiss() }) {
    HStack(spacing: 4) {
        Image(systemName: "chevron.left")
        Text("Back")
    }
    .foregroundStyle(AppGradients.userGradient)
}
```

**Returns to**: MainMenuView

### Trailing: Sort Menu & Add Button

#### Sort/Filter Menu
```swift
Menu {
    // User Name submenu
    Menu("User Name") {
        Button("A-Z") { sortOrder = .nameAscending }
        Button("Z-A") { sortOrder = .nameDescending }
    }
    
    // Role submenu
    Menu("Role") {
        Button("Administrator") { sortOrder = .roleAdministrator }
        Button("Developer") { sortOrder = .roleDeveloper }
        Button("Business Analyst") { sortOrder = .roleBusinessAnalyst }
        Button("Validator") { sortOrder = .roleValidator }
    }
    
    // Date Created submenu
    Menu("Date Created") {
        Button("Newest First") { sortOrder = .dateNewest }
        Button("Oldest First") { sortOrder = .dateOldest }
    }
} label: {
    Image(systemName: "arrow.up.arrow.down")
}
```

**Features**:
- Checkmarks indicate active selection
- Organized into logical submenus
- Icon: arrow.up.arrow.down

#### Add User Button
```swift
Button(action: {
    let user = User(firstName: Constants.EMPTY_STRING,
                    lastName: Constants.EMPTY_STRING)
    path.append(.userDetail(user))
}) {
    Image(systemName: "plus.circle.fill")
}
```

**Creates**: New empty user
**Navigates**: To UserDetailView
**Note**: User not inserted until saved in detail view

## Design Patterns

### 1. **Split Row Navigation**
Innovative pattern where one row has two separate navigation targets:
- Tap user info → Edit user
- Tap tasks button → View tasks

### 2. **Type-Safe Navigation**
Using `AppNavigationDestination` enum for compile-time safety

### 3. **Conditional UI**
Different task button states based on task count

### 4. **Deferred Insertion**
New users not saved until confirmed in detail view

### 5. **Role Fallback**
Graceful handling of users without assigned roles

## Performance Considerations

### Optimizations
1. **Lazy Loading**: LazyVStack renders only visible rows
2. **Computed Property**: `sortedUsers` only recalculates on changes
3. **Efficient Queries**: SwiftData `@Query` with sort descriptors
4. **State Minimization**: Only essential state variables

### Memory Usage
- Minimal state (5 state variables)
- No heavy resources (SF Symbols only)
- Efficient role lookups

## Accessibility

### Current Support
- ✅ Dynamic Type support
- ✅ Standard SwiftUI accessibility
- ✅ Clear visual hierarchy
- ✅ Sufficient touch targets

### Recommended Enhancements
```swift
// User row
.accessibilityLabel("User: \(user.fullName()), Role: \(userRole)")
.accessibilityHint("Double tap to edit user details")

// Tasks button
.accessibilityLabel("\(user.tasks.count) assigned tasks")
.accessibilityHint("Double tap to view assigned tasks")

// Add button
.accessibilityLabel("Add new user")
.accessibilityHint("Creates a new team member")
```

## Testing

### Preview Configuration
```swift
#Preview {
    UserListView()
}
```

### Manual Test Checklist
- [ ] Users list displays correctly
- [ ] Sort by name A-Z works
- [ ] Sort by name Z-A works
- [ ] Filter by Administrator works
- [ ] Filter by Developer works
- [ ] Filter by Business Analyst works
- [ ] Filter by Validator works
- [ ] Sort by date works (newest/oldest)
- [ ] User with no role shows default role
- [ ] Tap user info navigates to detail
- [ ] Tap tasks button navigates to tasks
- [ ] Tasks button shows correct count
- [ ] "No tasks assigned" shows for 0 tasks
- [ ] Singular "Task" for count of 1
- [ ] Plural "Tasks" for count > 1
- [ ] Add button creates new user
- [ ] Delete via context menu works (if implemented)
- [ ] Toast shows after deletion
- [ ] Empty state appears when no users
- [ ] Back button returns to main menu

## Integration Points

### Dependencies
1. **SwiftData Models**: User, Role, Task, Project
2. **Navigation**: AppNavigationDestination
3. **UI Components**: ModernHeaderView, ModernListRow, EmptyStateCard
4. **Utilities**: Log, Constants, AppGradients
5. **Child Views**: UserDetailView, UserTasksView

### Data Flow
```
SwiftData Store
    ↓ @Query (sorted by lastName)
UserListView
    ↓ sortedUsers (computed)
    ↓ Sort/Filter
LazyVStack → ForEach
    ↓
User Row Components
```

## Best Practices Demonstrated

1. ✅ **Split Navigation**: One row, two navigation targets
2. ✅ **Type-Safe Navigation**: Context-aware navigation
3. ✅ **Conditional UI**: Task button adapts to state
4. ✅ **Role Fallback**: Handles missing roles gracefully
5. ✅ **Deferred Insertion**: Users not saved until confirmed
6. ✅ **Error Handling**: Proper logging
7. ✅ **Toast Feedback**: User feedback on deletion
8. ✅ **Empty States**: Meaningful empty state
9. ✅ **Pluralization**: Correct grammar for counts
10. ✅ **Clean Architecture**: Separated view components

## Common Issues & Solutions

### Issue: Role not displaying
**Solution**: Check user has assigned roles, fallback to `roles[0]`

### Issue: Task count incorrect
**Solution**: Verify SwiftData relationship properly configured

### Issue: Navigation to tasks not working
**Solution**: Check `AppNavigationDestination.userTasks` case exists

### Issue: Delete not working
**Solution**: Ensure `deleteUsers(at:)` is implemented in context menu

## Future Enhancements

### Potential Features
1. **User Search**: Search by name, role, or email
2. **Bulk Actions**: Select multiple users
3. **User Status**: Active, inactive, on leave
4. **Profile Pictures**: Avatar support
5. **Team Organization**: Group users by team
6. **Permissions Management**: Detailed permission editing
7. **User Statistics**: Tasks completed, in progress
8. **Contact Information**: Email, phone, etc.
9. **Department/Location**: Organizational info
10. **Recent Activity**: Last login, last task update

### Code Improvements
1. **Extract User Row**: Separate UserRowView component
2. **Search Integration**: Add search bar
3. **Role Badge**: Visual role indicators
4. **Status Indicator**: Online/offline status
5. **Sorting Persistence**: Remember user's sort preference

## Related Documentation
- [TASK_CONTEXT_FIX_SUMMARY.md](./Documentation/TASK_CONTEXT_FIX_SUMMARY.md) - Context navigation fix
- [NAVIGATION_REFACTOR_SUMMARY.md](./Documentation/NAVIGATION_REFACTOR_SUMMARY.md) - Navigation architecture
- [MAINMENUVIEW_DOCUMENTATION.md](./MAINMENUVIEW_DOCUMENTATION.md) - Main menu

## Version History

| Date | Change | Author |
|------|--------|--------|
| April 19, 2025 | Initial implementation | Larry Burris |
| February 19, 2026 | Navigation refactor | AI Assistant |
| February 19, 2026 | Context-aware task navigation | AI Assistant |
| February 20, 2026 | Documentation created | AI Assistant |

---

**Note**: This view demonstrates an innovative split-navigation pattern where a single row has two distinct navigation targets, providing efficient access to both user details and assigned tasks.
