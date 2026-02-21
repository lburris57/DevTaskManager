# DashboardView Documentation

## Overview
`DashboardView` provides a comprehensive analytics and overview screen for the DevTaskManager application. It displays key metrics, task statistics, priority breakdowns, recent activity, and project progress in a visually appealing, data-driven interface.

## File Information
- **File**: `DashboardView.swift`
- **Created**: February 20, 2026
- **Platform**: iOS
- **Framework**: SwiftUI
- **Dependencies**: SwiftData

## Features

### 📊 Quick Statistics
- **Total Tasks**: Count of all tasks in the system
- **Total Projects**: Count of all projects
- **Total Users**: Count of all team members
- Displayed in attractive stat cards with gradient icons

### 📈 Task Status Breakdown
- Visual breakdown of tasks by status with progress bars
- Shows count and percentage for each status:
  - Unassigned
  - In Progress
  - Completed
  - Deferred
- Color-coded progress indicators

### ⚡ Priority Analysis
- Task distribution by priority level
- Shows count and percentage for:
  - High priority (red)
  - Medium priority (orange)
  - Low priority (green)
  - Enhancement (blue)
- Progress bars for visual representation

### 🕐 Recent Activity
- Lists the 5 most recently created tasks
- Shows task name, project, priority, and status
- Tappable to navigate to task details
- Empty state message when no tasks exist

### 📁 Project Progress
- Displays completion progress for up to 5 projects
- Shows:
  - Project name
  - Completion percentage
  - Tasks completed vs total
  - Visual progress bar
  - "Complete" badge for 100% completion
- Tappable to navigate to project details

## Architecture

### View Structure
```
DashboardView (NavigationStack)
└── ZStack
    ├── Background (System + Gradient)
    └── VStack (spacing: 0)
        ├── ModernHeaderView
        └── ScrollView
            └── VStack (sections)
                ├── Quick Stats Section
                ├── Task Status Section
                ├── Priority Breakdown Section
                ├── Recent Activity Section
                └── Project Progress Section
```

## Component Breakdown

### Main Components

#### 1. StatCard
A reusable component displaying a single statistic.

**Props:**
- `icon`: SF Symbol name
- `title`: Stat description
- `value`: Numeric value to display
- `gradientColors`: Array of 2 colors for gradient

**Design:**
- Circular gradient icon
- Large value text (24pt, bold, rounded)
- Subtitle label
- Shadow effect

#### 2. DashboardCard
A container for dashboard sections with title and icon.

**Props:**
- `title`: Section title
- `icon`: SF Symbol for section
- `content`: View builder for card content

**Design:**
- Rounded rectangle (16pt radius)
- White background with shadow
- Consistent padding (16pt)

#### 3. StatusRow / PriorityRow
Progress bar rows showing distribution metrics.

**Features:**
- Icon with color coding
- Count and percentage
- Animated progress bar
- Color-coordinated design

#### 4. RecentTaskRow
Individual task item in recent activity list.

**Features:**
- Priority icon (left)
- Task name
- Project label (if assigned)
- Status badge
- Chevron navigation indicator

#### 5. ProjectProgressRow
Individual project progress item.

**Features:**
- Folder icon
- Project name
- Completion ratio (e.g., "3/5")
- Gradient progress bar
- Status indicators (complete/remaining)
- Secondary background color

## Data Queries

The view uses SwiftData queries to fetch:

```swift
@Query var tasks: [Task]
@Query var projects: [Project]
@Query var users: [User]
```

All data is reactive - the dashboard automatically updates when data changes.

## Navigation

The dashboard supports navigation to:
- **Task Details** - Tap any task in recent activity
- **Project Details** - Tap any project in progress section

Uses the app's shared navigation system (`AppNavigationDestination`).

## Helper Functions

### tasksByStatus(_ status: TaskStatusEnum) -> [Task]
Filters tasks by a specific status.

### tasksByPriority(_ priority: TaskPriorityEnum) -> [Task]
Filters tasks by a specific priority.

### recentTasks -> [Task]
Returns tasks sorted by creation date (newest first).

### completionPercentage(for project: Project) -> Double
Calculates the completion percentage for a project (0.0 to 1.0).

## Color Scheme

### Status Colors
- **Unassigned**: Orange (#FF9500)
- **In Progress**: Blue (#007AFF)
- **Completed**: Green (#34C759)
- **Deferred**: Gray (#8E8E93)

### Priority Colors
- **High**: Red (#FF3B30)
- **Medium**: Orange (#FF9500)
- **Low**: Green (#34C759)
- **Enhancement**: Blue (#007AFF)

### Quick Stats Gradients
- **Tasks**: Orange → Red
- **Projects**: Blue → Cyan
- **Users**: Purple → Pink

## Empty States

The dashboard handles empty data gracefully:

- **No Tasks**: Shows "No tasks yet" message
- **No Projects**: Shows "No projects yet" message
- Empty states display in dashboard cards with centered text

## Integration with MainMenuView

To add the Dashboard to your main menu, update `MainMenuView.swift`:

### 1. Add MenuDestination Case

```swift
enum MenuDestination: Identifiable {
    case projectList
    case userList
    case taskList
    case dashboard  // Add this
    
    var id: String {
        switch self {
        case .projectList: return "projects"
        case .userList: return "users"
        case .taskList: return "tasks"
        case .dashboard: return "dashboard"  // Add this
        }
    }
}
```

### 2. Add Dashboard Card

Add this card to the VStack in the body, ideally as the first card:

```swift
// Dashboard Card (add as first item)
MenuCard(
    icon: "chart.bar.fill",
    title: "Dashboard",
    subtitle: "Overview & analytics",
    gradientColors: [.blue, .purple]
) {
    selectedView = .dashboard
}
```

### 3. Add Navigation Case

Update the `fullScreenCover` switch statement:

```swift
.fullScreenCover(item: $selectedView) { destination in
    switch destination {
    case .dashboard:
        DashboardView()  // Add this case
    case .projectList:
        ProjectListView()
    case .userList:
        UserListView()
    case .taskList:
        TaskListView()
    }
}
```

## Preview Configuration

The view includes two preview variants:

```swift
#Preview("With Sample Data", traits: .modifier(SampleDataPreviewModifier())) {
    DashboardView()
}

#Preview("Empty State", traits: .modifier(EmptyDataPreviewModifier())) {
    DashboardView()
}
```

## Performance Considerations

### Optimizations
1. **SwiftData Queries**: Automatic change tracking and updates
2. **Computed Properties**: Efficient filtering and sorting
3. **Lazy Evaluation**: Only computes when needed
4. **Limited Lists**: Shows only top 5 items in sections
5. **Lightweight Components**: Minimal view hierarchy

### Best Practices
- Uses `@Query` for reactive data
- Implements prefix(5) to limit displayed items
- Reusable component architecture
- Efficient percentage calculations with guard statements

## Accessibility

### Current Support
- ✅ Dynamic Type support (system fonts)
- ✅ Semantic colors
- ✅ Clear visual hierarchy
- ✅ High contrast text and icons
- ✅ Sufficient touch targets

### Potential Improvements
- ⚠️ Add accessibility labels to progress bars
- ⚠️ Provide accessibility hints for tappable items
- ⚠️ Consider VoiceOver announcements for percentages
- ⚠️ Add accessibility traits for interactive elements

## Future Enhancements

### Potential Features
1. **Date Range Filters** - View stats for specific time periods
2. **Charts** - Visual charts (pie, bar, line) using Swift Charts
3. **Trend Analysis** - Task completion trends over time
4. **Team Leaderboard** - Most productive users
5. **Export Reports** - PDF or CSV export of dashboard data
6. **Customizable Widgets** - Let users choose which sections to display
7. **Comparison View** - Compare current period to previous
8. **Goal Tracking** - Set and track completion goals
9. **Alerts** - Notifications for overdue tasks or stuck projects
10. **Time Tracking** - Show time spent on tasks

### Quick Wins
- Add pull-to-refresh
- Animate progress bars on appear
- Add haptic feedback on interactions
- Show task type distribution
- Display user assignment statistics

## Testing Checklist

### Manual Testing
- [ ] Dashboard displays correct task count
- [ ] Dashboard displays correct project count
- [ ] Dashboard displays correct user count
- [ ] Status breakdown shows accurate percentages
- [ ] Priority breakdown shows accurate percentages
- [ ] Recent tasks appear in chronological order (newest first)
- [ ] Project progress bars show correct completion percentage
- [ ] Tapping a recent task navigates to task detail
- [ ] Tapping a project navigates to project detail
- [ ] Empty states display when no data exists
- [ ] Progress bars animate smoothly
- [ ] All colors match design system
- [ ] Back button returns to main menu

## Version History

| Date | Change | Author |
|------|--------|--------|
| February 20, 2026 | Initial implementation | AI Assistant |

---

**Note**: This dashboard provides real-time insights into your task management workflow. It automatically updates as data changes, giving you an instant overview of your team's progress and workload distribution.
