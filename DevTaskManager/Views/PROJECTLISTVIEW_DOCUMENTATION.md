# ProjectListView Documentation

## Overview
`ProjectListView` is the main interface for viewing, searching, sorting, and managing projects in the DevTaskManager application. It provides a comprehensive list view with search, sort, and navigation capabilities to project details and tasks.

## File Information
- **File**: `ProjectListView.swift`
- **Created**: April 12, 2025
- **Platform**: iOS
- **Framework**: SwiftUI
- **Dependencies**: SwiftData

## Architecture

### View Structure
```
ProjectListView (NavigationStack)
└── ZStack
    ├── Background Color (System Background)
    ├── AppGradients.mainBackground
    └── VStack
        ├── ModernHeaderView
        ├── Search Bar (HStack)
        ├── ScrollView (if projects exist)
        │   └── LazyVStack
        │       └── ForEach(filteredProjects)
        │           └── NavigationLink → ProjectDetail
        │               └── ModernListRow
        │                   └── ProjectRowView
        └── EmptyStateCard (if no projects)
```

### Navigation Destinations
- **ProjectDetailView**: Edit or create project details
- **ProjectTasksView**: View tasks associated with a project
- **TaskDetailView**: View/edit individual tasks
- **UserDetailView**: View/edit user information
- **UserTasksView**: View tasks assigned to a user

## Main Components

### Properties

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `modelContext` | `ModelContext` | `@Environment` | SwiftData context for data operations |
| `dismiss` | `DismissAction` | `@Environment` | Action to dismiss the view |
| `path` | `[AppNavigationDestination]` | `@State` | Navigation path for type-safe navigation |
| `hasLoadedRoles` | `Bool` | `@State` | Tracks whether roles have been loaded |
| `searchText` | `String` | `@State` | Current search query text |
| `sortOrder` | `SortOrder` | `@State` | Current sort order selection |
| `showDeleteToast` | `Bool` | `@State` | Controls toast notification visibility |
| `deletedProjectName` | `String` | `@State` | Name of deleted project for toast message |
| `projects` | `[Project]` | `@Query` | All projects from SwiftData |

### Sort Order Enum

```swift
enum SortOrder: String, CaseIterable {
    case titleAscending = "Title A-Z"
    case titleDescending = "Title Z-A"
    case dateNewest = "Newest First"
    case dateOldest = "Oldest First"
}
```

**Purpose**: Defines available sorting options for the project list.

**Features**:
- Conforms to `String` and `CaseIterable`
- Raw values provide user-facing labels
- Easy to extend with new sort options

## Core Functionality

### 1. Search & Filter

#### `filteredProjects` Computed Property
```swift
var filteredProjects: [Project]
```

**Algorithm**:
1. Check if search text is empty
2. If empty: use all projects
3. If not empty: filter by case-insensitive title match
4. Apply selected sort order
5. Return sorted and filtered results

**Search Behavior**:
- Real-time filtering as user types
- Case-insensitive matching
- Only searches project titles
- Clear button appears when search is active

**Sort Options**:
| Option | Order | Field |
|--------|-------|-------|
| Title A-Z | Ascending | `project.title` |
| Title Z-A | Descending | `project.title` |
| Newest First | Descending | `project.dateCreated` |
| Oldest First | Ascending | `project.dateCreated` |

### 2. Role Management

#### `saveRoles()` Method
```swift
func saveRoles()
```

**Purpose**: Ensures default roles exist in the database on first launch.

**Behavior**:
1. Checks `hasLoadedRoles` flag to prevent duplicate loading
2. Fetches existing roles from database
3. If roles exist, sets flag and returns
4. If no roles exist, loads default roles via `Role.loadRoles()`
5. Sets `lastUpdated` date for each role
6. Inserts roles into model context
7. Saves context and sets flag

**Called**: On view appearance via `.onAppear()`

**Default Roles**:
- Administrator
- Developer
- Business Analyst
- Validator

### 3. Project Creation

#### `createNewProject()` Method
```swift
func createNewProject()
```

**Purpose**: Initiates creation of a new project.

**Behavior**:
1. Creates new `Project` instance with empty strings
2. Does NOT insert into model context (deferred to detail view)
3. Appends `.projectDetail(project)` to navigation path
4. Navigates to `ProjectDetailView`

**Design Decision**: The project is not saved to the database until the user explicitly saves it in the detail view. This prevents orphaned empty projects.

### 4. Project Deletion

#### `deleteProjects(at:)` Method
```swift
func deleteProjects(at offsets: IndexSet)
```

**Purpose**: Deletes selected projects from the database.

**Parameters**:
- `offsets`: IndexSet of projects to delete in filtered list

**Behavior**:
1. Iterates through offset indices
2. Gets project from `filteredProjects` array
3. Stores project name for toast message
4. Deletes project from model context
5. Saves context
6. Shows success toast with animation

**Error Handling**: Logs errors but doesn't interrupt flow

**Cascade Behavior**: SwiftData relationships determine cascade deletion

## User Interface

### Header Section
- **Component**: `ModernHeaderView`
- **Icon**: "folder.fill"
- **Title**: "Projects"
- **Subtitle**: Dynamic count (e.g., "5 total")
- **Gradient**: Blue to Cyan

### Search Bar
**Layout**: HStack with:
- Magnifying glass icon (leading)
- TextField with placeholder "Search projects"
- Clear button (trailing, conditional)

**Styling**:
- 12pt padding
- White background (system background)
- 12pt corner radius
- Subtle shadow

### Project List
**When projects exist**:
- ScrollView with LazyVStack
- 8pt spacing between items
- Each item wrapped in `ModernListRow`
- NavigationLink to ProjectDetailView
- Context menu with delete option

**When no projects**:
- `EmptyStateCard` component
- Icon: "folder.badge.plus"
- Title: "No Projects Yet"
- Message: "Create your first project to start organizing tasks"
- Button: "Add Project" → triggers `createNewProject()`

### ProjectRowView Component

Displays individual project information in the list.

**Content**:
1. **Header**: Project title
2. **Description**: Truncated description text
3. **Metadata Row**:
   - Date created
   - Task count badge
4. **Tasks Button**: Navigate to ProjectTasksView (if tasks exist)
5. **Empty Tasks**: Gray indicator (if no tasks)

**Navigation Options**:
- Tap card: Edit project (ProjectDetailView)
- Tap tasks button: View tasks (ProjectTasksView)

## Navigation Architecture

### Navigation Path
```swift
@State private var path: [AppNavigationDestination] = []
```

**Type**: Type-safe array of `AppNavigationDestination` enum cases

**Destinations Handled**:
```swift
.navigationDestination(for: AppNavigationDestination.self) { destination in
    switch destination {
    case .projectTasks(let project):
        ProjectTasksView(project: project, path: $path)
    case .projectDetail(let project):
        ProjectDetailView(project: project, path: $path, onDismissToMain: { dismiss() })
    case .taskDetail(let task, let context):
        TaskDetailView(task: task, path: $path, onDismissToMain: { dismiss() }, sourceContext: context)
    case .userDetail(let user):
        UserDetailView(user: user, path: $path)
    case .userTasks(let user):
        UserTasksView(user: user, path: $path)
    }
}
```

**Navigation Flow**:
```
ProjectListView
├── ProjectDetailView (tap card or "Add Project")
├── ProjectTasksView (tap "View Tasks" button)
│   ├── TaskDetailView (from tasks list)
│   └── ProjectDetailView (tap "Edit Project" menu)
└── [Indirect via nested navigation]
    ├── UserDetailView
    └── UserTasksView
```

## Toolbar

### Leading Item: Back Button
```swift
Button(action: { dismiss() }) {
    HStack(spacing: 4) {
        Image(systemName: "chevron.left")
        Text("Back")
    }
    .foregroundStyle(AppGradients.projectGradient)
}
```

**Behavior**: Dismisses view and returns to MainMenuView

### Trailing Items

#### 1. Sort Menu
- **Icon**: "arrow.up.arrow.down"
- **Style**: Menu with picker
- **Options**: All SortOrder cases
- **Gradient**: projectGradient

#### 2. Add Button
- **Icon**: "plus.circle.fill"
- **Action**: `createNewProject()`
- **Style**: Title3 font
- **Gradient**: projectGradient

## Design Patterns

### 1. **MVVM-Adjacent Pattern**
- View handles UI and user interaction
- Computed properties for derived state
- SwiftData handles data persistence

### 2. **Declarative UI**
- SwiftUI's declarative syntax
- Reactive updates via `@Query`
- State-driven rendering

### 3. **Type-Safe Navigation**
- `AppNavigationDestination` enum
- Compile-time safety
- Explicit navigation paths

### 4. **Lazy Loading**
- `LazyVStack` for performance
- Only renders visible items
- Efficient for large lists

### 5. **Separation of Concerns**
- ProjectRowView handles row display
- ModernListRow provides styling
- ProjectListView manages list logic

## Performance Optimizations

### 1. **Lazy Rendering**
```swift
LazyVStack(spacing: 8) {
    ForEach(filteredProjects) { project in
        // Row content
    }
}
```
Only renders visible projects

### 2. **Computed Properties**
`filteredProjects` only recomputes when dependencies change

### 3. **Efficient Queries**
SwiftData `@Query` automatically updates

### 4. **Minimal State**
Only essential state variables

### 5. **Button Style**
`.buttonStyle(.plain)` prevents default button animations

## Accessibility

### Current Support
- ✅ Dynamic Type (system fonts)
- ✅ VoiceOver compatible navigation
- ✅ Standard SwiftUI accessibility
- ✅ Clear visual hierarchy
- ✅ Sufficient contrast

### Potential Improvements
```swift
// Search field
.accessibilityLabel("Search projects")
.accessibilityHint("Enter text to filter projects")

// Sort button
.accessibilityLabel("Sort projects")
.accessibilityHint("Choose sorting order")

// Project cards
.accessibilityLabel("\(project.title)")
.accessibilityHint("Double tap to edit project")
.accessibilityAddTraits(.isButton)
```

## Error Handling

### Save Failures
```swift
catch {
    Log.error("Failed to save roles: \(error.localizedDescription)")
}
```
Logs to console, doesn't block UI

### Delete Failures
```swift
catch {
    Log.error("Failed to delete project: \(error.localizedDescription)")
}
```
Logs error, toast still shows

### Missing Data
Empty states handle:
- No projects
- No search results
- No tasks for a project

## Toast Notifications

### Delete Success Toast
```swift
.successToast(
    isShowing: $showDeleteToast,
    message: "'\(deletedProjectName)' deleted"
)
```

**Behavior**:
- Appears after successful deletion
- Shows project name
- Auto-dismisses after 3 seconds
- Animated appearance

## Testing

### Preview Configuration
```swift
#Preview("With Sample Data", traits: .modifier(SampleDataPreviewModifier())) {
    ProjectListView()
}

#Preview("Empty State", traits: .modifier(EmptyDataPreviewModifier())) {
    ProjectListView()
}
```

**Scenarios**:
1. **With Sample Data**: Full project list
2. **Empty State**: No projects

### Manual Test Checklist
- [ ] View displays list of projects
- [ ] Search filters projects correctly
- [ ] Clear button appears and works
- [ ] Sort menu changes order
- [ ] Add button creates new project
- [ ] Tapping project card navigates to detail
- [ ] Delete via context menu works
- [ ] Toast appears after deletion
- [ ] Empty state shows when no projects
- [ ] Back button returns to main menu
- [ ] Navigation path maintains state
- [ ] Search + sort work together
- [ ] Roles load on first launch

## Integration Points

### Dependencies
1. **SwiftData Models**: Project, Task, User, Role
2. **Navigation**: AppNavigationDestination enum
3. **UI Components**: ModernHeaderView, ModernListRow, EmptyStateCard
4. **Utilities**: Log, Constants, AppGradients
5. **Child Views**: ProjectDetailView, ProjectTasksView, ProjectRowView

### Data Flow
```
SwiftData Store
    ↓ @Query
ProjectListView
    ↓ filteredProjects
LazyVStack → ForEach
    ↓
ProjectRowView
```

## Best Practices Demonstrated

1. ✅ **SwiftData Integration**: Proper use of @Query and ModelContext
2. ✅ **Type-Safe Navigation**: Custom enum for navigation
3. ✅ **Lazy Loading**: LazyVStack for performance
4. ✅ **Search & Sort**: Real-time filtering and sorting
5. ✅ **Empty States**: Meaningful empty state UI
6. ✅ **Error Logging**: Proper error handling with Log
7. ✅ **Deferred Insertion**: New projects not saved until user confirms
8. ✅ **Toast Feedback**: User feedback on actions
9. ✅ **Modern UI**: Gradients, shadows, rounded corners
10. ✅ **Preview Support**: Multiple preview configurations

## Future Enhancements

### Potential Features
1. **Bulk Actions**: Select multiple projects for deletion
2. **Project Templates**: Quick start with pre-configured projects
3. **Favorites**: Star/favorite important projects
4. **Project Status**: Active, archived, completed states
5. **Color Coding**: Custom colors per project
6. **Export**: Export project data
7. **Sharing**: Share project with team
8. **Advanced Search**: Search in descriptions, tags
9. **Grid View**: Alternative layout option
10. **Quick Actions**: Swipe actions for common tasks

### Code Improvements
1. **Extract Search Logic**: Separate search/filter service
2. **Pagination**: Load projects in chunks for large datasets
3. **Caching**: Cache filtered results
4. **Debounced Search**: Reduce search computations
5. **Analytics**: Track search patterns, popular sorts

## Common Issues & Solutions

### Issue: Projects not updating
**Solution**: Ensure SwiftData context is properly configured in app entry

### Issue: Search not working
**Solution**: Verify `filteredProjects` computed property logic

### Issue: Navigation broken
**Solution**: Check `AppNavigationDestination` enum and `.navigationDestination` switch cases match

### Issue: Roles loading every time
**Solution**: `hasLoadedRoles` flag prevents duplicate loading

## Related Documentation
- [NAVIGATION_REFACTOR_SUMMARY.md](./Documentation/NAVIGATION_REFACTOR_SUMMARY.md) - Navigation architecture
- [TOAST_IMPLEMENTATION_SUMMARY.md](./Documentation/TOAST_IMPLEMENTATION_SUMMARY.md) - Toast system
- [MAINMENUVIEW_DOCUMENTATION.md](./MAINMENUVIEW_DOCUMENTATION.md) - Main menu
- [PROJECT_NAVIGATION_ENHANCEMENT.md](./Documentation/PROJECT_NAVIGATION_ENHANCEMENT.md) - Navigation improvements

## Version History

| Date | Change | Author |
|------|--------|--------|
| April 12, 2025 | Initial implementation | Larry Burris |
| February 19, 2026 | Navigation refactor | AI Assistant |
| February 20, 2026 | Documentation created | AI Assistant |

---

**Note**: Keep this documentation synchronized with code changes. Update when adding new features or modifying existing behavior.
