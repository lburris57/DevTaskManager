# TaskListView Documentation

## Overview
`TaskListView` provides a comprehensive interface for viewing, searching, sorting, and filtering all tasks across all projects in the DevTaskManager application. It offers extensive filtering options by task type, priority, status, and project, along with real-time search capabilities.

## File Information
- **File**: `TaskListView.swift`
- **Created**: April 20, 2025
- **Platform**: iOS
- **Framework**: SwiftUI
- **Dependencies**: SwiftData

## Architecture

### View Structure
```
TaskListView (NavigationStack)
└── ZStack
    ├── Background Color (System Background)
    ├── AppGradients.mainBackground
    └── VStack
        ├── ModernHeaderView
        ├── Search Bar (HStack)
        ├── ScrollView (if tasks exist)
        │   └── LazyVStack
        │       └── ForEach(sortedTasks)
        │           └── NavigationLink → TaskDetail
        │               └── ModernListRow
        │                   └── Task Row Content
        └── EmptyStateCard (if no tasks)
```

## Main Components

### Properties

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `modelContext` | `ModelContext` | `@Environment` | SwiftData context for data operations |
| `dismiss` | `DismissAction` | `@Environment` | Action to dismiss the view |
| `path` | `[AppNavigationDestination]` | `@State` | Navigation path for type-safe navigation |
| `showDeleteToast` | `Bool` | `@State` | Controls toast notification visibility |
| `deletedTaskName` | `String` | `@State` | Name of deleted task for toast message |
| `sortOrder` | `SortOrder` | `@State` | Current sort/filter selection |
| `searchText` | `String` | `@State` | Current search query text |
| `tasks` | `[Task]` | `@Query` | All tasks from SwiftData |
| `users` | `[User]` | `@Query` | All users (for display) |
| `roles` | `[Role]` | `@Query` | All roles (for reference) |

### Sort Order Enum

```swift
enum SortOrder: String, CaseIterable {
    // Name sorting
    case taskNameAscending = "Task Name A-Z"
    case taskNameDescending = "Task Name Z-A"
    
    // Project sorting
    case projectAscending = "Project A-Z"
    case projectDescending = "Project Z-A"
    case projectNewest = "Project Newest First"
    case projectOldest = "Project Oldest First"
    
    // Task Type filters
    case taskTypeDevelopment = "Development"
    case taskTypeRequirements = "Requirements"
    case taskTypeDesign = "Design"
    case taskTypeUseCases = "Use Cases"
    case taskTypeTesting = "Testing"
    case taskTypeDocumentation = "Documentation"
    case taskTypeDatabase = "Database"
    case taskTypeDefectCorrection = "Defect Correction"
    
    // Priority filters
    case priorityHigh = "High"
    case priorityMedium = "Medium"
    case priorityLow = "Low"
    case priorityEnhancement = "Enhancement"
    
    // Status filters
    case statusUnassigned = "Unassigned"
    case statusInProgress = "In Progress"
    case statusCompleted = "Completed"
    case statusDeferred = "Deferred"
    
    // Date sorting
    case dateNewest = "Newest First"
    case dateOldest = "Oldest First"
}
```

**Total Options**: 28 different sort and filter combinations

## Core Functionality

### 1. Search & Filter

#### `sortedTasks` Computed Property
```swift
private var sortedTasks: [Task]
```

**Algorithm**:
1. **Search Filtering**:
   - If search text is empty: use all tasks
   - Otherwise filter by matching:
     - Task name (case-insensitive)
     - Task comment (case-insensitive)
     - Project title (case-insensitive)

2. **Sort/Filter Application**:
   - Apply selected sort order or filter
   - Return sorted/filtered results

**Search Fields**:
- ✅ Task name
- ✅ Task comment/description
- ✅ Associated project title

**Sort Options (6)**:
| Option | Field | Order |
|--------|-------|-------|
| Task Name A-Z | `task.taskName` | Ascending |
| Task Name Z-A | `task.taskName` | Descending |
| Project A-Z | `task.project.title` | Ascending |
| Project Z-A | `task.project.title` | Descending |
| Project Newest | `task.project.dateCreated` | Descending |
| Project Oldest | `task.project.dateCreated` | Ascending |
| Newest First | `task.dateCreated` | Descending |
| Oldest First | `task.dateCreated` | Ascending |

**Filter Options (16)**:
- **By Task Type** (8): Development, Requirements, Design, Use Cases, Testing, Documentation, Database, Defect Correction
- **By Priority** (4): High, Medium, Low, Enhancement
- **By Status** (4): Unassigned, In Progress, Completed, Deferred

**Filter Behavior**:
- Filters are exclusive (only show matching tasks)
- Filtered results are then sorted by task name A-Z
- Multiple filters cannot be active simultaneously

### 2. Task Deletion

#### `deleteTasks(at:)` Method
```swift
func deleteTasks(at offsets: IndexSet)
```

**Purpose**: Deletes selected tasks from the database.

**Parameters**:
- `offsets`: IndexSet of tasks to delete in sorted/filtered list

**Behavior**:
1. Iterates through offset indices
2. Gets task from `sortedTasks` array
3. Stores task name for toast message (or "Untitled Task")
4. Deletes task from model context
5. Saves context with error handling
6. Shows success toast with animation

**Error Handling**: Logs errors via `Log.error()`

### 3. Helper Functions

#### `priorityValue(for:)` Method
```swift
private func priorityValue(for priority: String) -> Int
```

**Purpose**: Converts priority strings to numeric values for sorting.

**Returns**:
| Priority | Value |
|----------|-------|
| High | 3 |
| Medium | 2 |
| Low | 1 |
| Other | 0 |

**Note**: Currently unused in implementation but available for future priority-based sorting.

## User Interface

### Header Section
- **Component**: `ModernHeaderView`
- **Icon**: "checklist"
- **Title**: "Tasks"
- **Subtitle**: Dynamic count (e.g., "12 total")
- **Gradient**: Orange to Red

### Search Bar
**Layout**: HStack with:
- Magnifying glass icon
- TextField: "Search tasks"
- Clear button (conditional)

**Styling**:
- 12pt padding
- System background color
- 12pt corner radius
- Subtle shadow

### Task Row Content

Displays comprehensive task information extracted into helper methods for compiler performance.

**Structure**:
```swift
@ViewBuilder
private func taskRowContent(for task: Task) -> some View {
    VStack {
        // Project badge (if associated)
        // Task name with priority icon
        // Assigned user info (if assigned)
        // Task type and status
        // Date created
    }
}
```

**Content Sections**:

#### 1. Project Badge (Optional)
```swift
if let project = task.project {
    HStack {
        Image(systemName: "folder.fill").blue
        Text(project.title)
    }
}
```

#### 2. Task Name with Priority
```swift
HStack(spacing: 8) {
    Image(systemName: priorityIcon(for: task.taskPriority))
        .foregroundStyle(priorityColor(for: task.taskPriority))
    Text(task.taskName.isEmpty ? "Untitled Task" : task.taskName)
}
```

#### 3. Assigned User (Optional)
```swift
if let assignedUser = task.assignedUser {
    assignedUserRow(for: task, user: assignedUser)
}
```

Shows:
- User full name
- Date assigned (if available)
- Green color coding

#### 4. Task Type and Status
```swift
HStack(spacing: 12) {
    Label(task.taskType, systemImage: "hammer.fill")
    Spacer()
    Label(task.taskStatus, systemImage: statusIcon(for: task.taskStatus))
        .foregroundStyle(statusColor(for: task.taskStatus))
}
```

#### 5. Date Created
Calendar icon with formatted date

### Context Menu
Each task has a context menu with:
- **Delete** (destructive action)
- Red color and trash icon

### Empty State
When no tasks exist:
- Icon: "checklist.unchecked"
- Title: "No Tasks Yet"
- Message: "Create your first task to start tracking your work"
- Button: "Add Task" → creates new task

## Navigation Architecture

### Navigation Path
```swift
@State private var path: [AppNavigationDestination] = []
```

### Destination Handler
```swift
@ViewBuilder
private func destinationView(for destination: AppNavigationDestination) -> some View {
    switch destination {
    case .taskDetail(let task, let context):
        TaskDetailView(task: task, path: $path, onDismissToMain: { dismiss() }, sourceContext: context)
    case .projectDetail(let project):
        ProjectDetailView(project: project, path: $path, onDismissToMain: { dismiss() })
    case .userDetail(let user):
        UserDetailView(user: user, path: $path)
    case .projectTasks(let project):
        ProjectTasksView(project: project, path: $path)
    case .userTasks(let user):
        UserTasksView(user: user, path: $path)
    }
}
```

**Navigation Flow**:
```
TaskListView
├── TaskDetailView (tap task or "Add Task")
│   ├── Context: .taskList
│   └── Proper back button: "Back To Task List"
├── ProjectDetailView (indirect via TaskDetail)
├── UserDetailView (indirect via TaskDetail)
├── ProjectTasksView (indirect)
└── UserTasksView (indirect)
```

## Helper Functions

### Priority Icon
```swift
private func priorityIcon(for priority: String) -> String
```

| Priority | Icon |
|----------|------|
| High | exclamationmark.circle.fill |
| Medium | exclamationmark.circle.fill |
| Low | minus.circle.fill |
| Other | circle.fill |

### Priority Color
```swift
private func priorityColor(for priority: String) -> Color
```

| Priority | Color |
|----------|-------|
| High | Red |
| Medium | Orange |
| Low | Green |
| Other | Gray |

### Status Icon
```swift
private func statusIcon(for status: String) -> String
```

| Status | Icon |
|--------|------|
| Completed | checkmark.circle.fill |
| In Progress | clock.fill |
| Unassigned | circle.dashed |
| Other | circle |

### Status Color
```swift
private func statusColor(for status: String) -> Color
```

| Status | Color |
|--------|-------|
| Unassigned | Orange (80% opacity) |
| Completed | Green |
| In Progress | Blue (70% opacity) |
| Other | Secondary |

## Toolbar

### Leading: Back Button
```swift
Button(action: { dismiss() }) {
    HStack(spacing: 4) {
        Image(systemName: "chevron.left")
        Text("Back")
    }
    .foregroundStyle(AppGradients.taskGradient)
}
```

### Trailing: Sort/Filter Menu & Add Button

#### Sort/Filter Menu
```swift
Menu {
    // Sort options picker
    Picker("Sort by", selection: $sortOrder) {
        Text("Task Name A-Z").tag(SortOrder.taskNameAscending)
        // ... more options
    }
    
    Divider()
    
    // Filter by Task Type
    Menu("Filter by Task Type") {
        Button("Development") { sortOrder = .taskTypeDevelopment }
        // ... more types
    }
    
    // Filter by Priority
    Menu("Filter by Priority") { /* ... */ }
    
    // Filter by Status
    Menu("Filter by Status") { /* ... */ }
}
```

**Icon**: "arrow.up.arrow.down"
**Style**: Nested menus for organization

#### Add Button
```swift
Button(action: {
    let task = Task(taskName: Constants.EMPTY_STRING)
    path.append(.taskDetail(task, context: .taskList))
}) {
    Image(systemName: "plus.circle.fill")
}
```

**Creates**: New empty task
**Navigates**: To TaskDetailView with `.taskList` context

## Performance Optimizations

### Compiler Type-Check Fix
The view was refactored to prevent Swift compiler timeouts:

#### Before (Complex inline views)
```swift
ForEach(sortedTasks) { task in
    NavigationLink(...) {
        ModernListRow {
            VStack {
                // 70+ lines of complex nested views
            }
        }
    }
}
```

#### After (Extracted functions)
```swift
ForEach(sortedTasks) { task in
    NavigationLink(...) {
        ModernListRow {
            taskRowContent(for: task)
        }
    }
}

@ViewBuilder
private func taskRowContent(for task: Task) -> some View { /* ... */ }

@ViewBuilder
private func assignedUserRow(for task: Task, user: User) -> some View { /* ... */ }

@ViewBuilder
private func destinationView(for destination: AppNavigationDestination) -> some View { /* ... */ }
```

**Benefits**:
- ✅ Faster compilation
- ✅ Better code organization
- ✅ Easier maintenance
- ✅ No runtime performance impact

### Other Optimizations
1. **Lazy Loading**: LazyVStack only renders visible items
2. **Computed Properties**: Only recalculate when dependencies change
3. **Efficient Queries**: SwiftData automatically optimizes
4. **State Minimization**: Only essential state variables

## Design Patterns

### 1. **View Decomposition**
Complex views broken into smaller `@ViewBuilder` functions

### 2. **Type-Safe Navigation**
Context explicitly passed with navigation destination

### 3. **Search & Filter**
Real-time filtering with computed properties

### 4. **Declarative UI**
SwiftUI's reactive data flow

### 5. **Helper Functions**
Reusable icon/color mappers

## Accessibility

### Current Support
- ✅ Dynamic Type support
- ✅ System colors and contrasts
- ✅ Standard SwiftUI accessibility
- ✅ Clear visual hierarchy

### Recommended Enhancements
```swift
// Task rows
.accessibilityLabel("\(task.taskName), \(task.taskPriority) priority, \(task.taskStatus)")
.accessibilityHint("Double tap to view task details")

// Sort menu
.accessibilityLabel("Sort and filter tasks")

// Priority icons
.accessibilityLabel("\(priority) priority")
```

## Testing

### Preview Configuration
```swift
#Preview("With Sample Data", traits: .modifier(SampleDataPreviewModifier())) {
    TaskListView()
}

#Preview("Empty State", traits: .modifier(EmptyDataPreviewModifier())) {
    TaskListView()
}
```

### Manual Test Checklist
- [ ] All tasks display correctly
- [ ] Search filters tasks in real-time
- [ ] Sort by name works (A-Z, Z-A)
- [ ] Sort by project works
- [ ] Sort by date works
- [ ] Filter by task type works
- [ ] Filter by priority works
- [ ] Filter by status works
- [ ] Clear search button works
- [ ] Add task navigates correctly
- [ ] Task detail navigation works
- [ ] Context menu delete works
- [ ] Toast shows after deletion
- [ ] Empty state appears when appropriate
- [ ] Back button returns to menu
- [ ] Priority icons/colors correct
- [ ] Status icons/colors correct
- [ ] Project badges display
- [ ] Assigned user info displays

## Integration Points

### Dependencies
1. **SwiftData Models**: Task, Project, User, Role
2. **Navigation**: AppNavigationDestination, TaskDetailSourceContext
3. **UI Components**: ModernHeaderView, ModernListRow, EmptyStateCard
4. **Utilities**: Log, Constants, AppGradients
5. **Child Views**: TaskDetailView, ProjectDetailView, UserDetailView

### Data Flow
```
SwiftData Store
    ↓ @Query
TaskListView
    ↓ sortedTasks (computed)
    ↓ Search + Sort/Filter
LazyVStack → ForEach
    ↓
taskRowContent(for:)
```

## Best Practices Demonstrated

1. ✅ **Compiler Performance**: Extracted complex views into functions
2. ✅ **Type-Safe Navigation**: Context passed explicitly
3. ✅ **Comprehensive Filtering**: 28 sort/filter options
4. ✅ **Real-Time Search**: Immediate feedback
5. ✅ **Helper Functions**: Reusable icon/color mappers
6. ✅ **Empty States**: Meaningful empty state
7. ✅ **Error Handling**: Proper logging
8. ✅ **Toast Feedback**: User feedback on actions
9. ✅ **Context Menus**: Quick actions
10. ✅ **Preview Support**: Multiple configurations

## Common Issues & Solutions

### Issue: Compiler timeout on view body
**Solution**: Extract complex inline views into `@ViewBuilder` functions

### Issue: Back button shows wrong text
**Solution**: Pass explicit context (`.taskList`) when navigating

### Issue: Filters not working
**Solution**: Check `sortedTasks` computed property logic

### Issue: Search results incorrect
**Solution**: Verify all search fields included in filter

## Future Enhancements

### Potential Features
1. **Multiple Filters**: Combine filters (e.g., High priority Development tasks)
2. **Saved Filters**: Save custom filter combinations
3. **Bulk Actions**: Select multiple tasks
4. **Task Templates**: Quick create common tasks
5. **Drag to Reorder**: Manual ordering
6. **Grouping**: Group by project, status, or priority
7. **Advanced Search**: Boolean operators, date ranges
8. **Export**: CSV or PDF export
9. **Quick Edit**: Inline editing of status/priority
10. **Calendar View**: View tasks by due date

### Code Improvements
1. **Filter Service**: Extract filter logic
2. **Search Debouncing**: Reduce computation
3. **Pagination**: Load tasks in chunks
4. **Persistent Sort**: Remember user's sort preference
5. **Filter Chips**: Visual indicators for active filters

## Related Documentation
- [COMPILER_TYPE_CHECK_FIX.md](./Documentation/COMPILER_TYPE_CHECK_FIX.md) - Performance fix details
- [TASK_CONTEXT_FIX_SUMMARY.md](./Documentation/TASK_CONTEXT_FIX_SUMMARY.md) - Context navigation fix
- [NAVIGATION_REFACTOR_SUMMARY.md](./Documentation/NAVIGATION_REFACTOR_SUMMARY.md) - Navigation architecture
- [MAINMENUVIEW_DOCUMENTATION.md](./MAINMENUVIEW_DOCUMENTATION.md) - Main menu

## Version History

| Date | Change | Author |
|------|--------|--------|
| April 20, 2025 | Initial implementation | Larry Burris |
| February 19, 2026 | Context-aware navigation | AI Assistant |
| February 19, 2026 | Compiler performance fix | AI Assistant |
| February 20, 2026 | Documentation created | AI Assistant |

---

**Note**: This view demonstrates advanced SwiftUI patterns including view decomposition for compiler performance and type-safe navigation with context awareness.
