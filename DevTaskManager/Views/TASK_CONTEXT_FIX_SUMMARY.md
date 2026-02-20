# Task Detail Context Navigation Fix

## Problem
When navigating from the User Tasks view to Task Detail, the dropdown menu showed "Return To Task List" on the first navigation, but correctly showed "Return To Assigned Tasks" on subsequent navigations.

## Root Cause
The `TaskDetailView` was trying to determine its source context by examining the navigation path at runtime. However, when the view was first created, the path hadn't been fully updated yet, causing it to default to `.taskList` instead of `.userTasksList`.

## Solution
Modified the navigation architecture to pass the context explicitly as part of the navigation destination rather than inferring it from the path.

### Changes Made

#### 1. NavigationDestination.swift
- Moved `TaskDetailSourceContext` enum to this file as a top-level enum
- Modified `AppNavigationDestination.taskDetail` case to include a `context` parameter:
  ```swift
  case taskDetail(Task, context: TaskDetailSourceContext)
  ```
- Updated `hash(into:)` and `==` methods to include context in comparisons

#### 2. TaskDetailView.swift
- Removed duplicate `TaskDetailSourceContext` enum definition (now imported from NavigationDestination.swift)
- No other changes needed - the view already accepts the context parameter

#### 3. UserTasksView.swift
- Updated task navigation to pass `.userTasksList` context:
  ```swift
  NavigationLink(value: AppNavigationDestination.taskDetail(task, context: .userTasksList))
  ```

#### 4. ProjectTasksView.swift
- Updated task navigation to pass `.projectTasksList` context:
  ```swift
  NavigationLink(value: AppNavigationDestination.taskDetail(task, context: .projectTasksList))
  ```
- Updated `createNewTask()` function to include context

#### 5. TaskListView.swift
- Updated task navigation to pass `.taskList` context:
  ```swift
  NavigationLink(value: AppNavigationDestination.taskDetail(task, context: .taskList))
  ```
- Updated both toolbar "Add Task" button and empty state "Add Task" button

#### 6. UserListView.swift
- Simplified navigation destination handling to use the passed context:
  ```swift
  case .taskDetail(let task, let context):
      TaskDetailView(task: task, path: $path, onDismissToMain: { dismiss() }, sourceContext: context)
  ```
- Removed complex path-checking logic that was attempting to infer context

#### 7. ProjectListView.swift
- Updated navigation destination handling to match pattern:
  ```swift
  case .taskDetail(let task, let context):
      TaskDetailView(task: task, path: $path, onDismissToMain: { dismiss() }, sourceContext: context)
  ```

## Benefits
1. **Immediate Context Awareness**: The context is now available immediately when the view is created
2. **Explicit Over Implicit**: Context is explicitly passed rather than inferred, making the code more maintainable
3. **Consistent Behavior**: First-time and subsequent navigations now behave identically
4. **Type Safety**: The context is part of the navigation destination enum, providing compile-time safety

## Testing
To verify the fix:
1. Navigate to User List
2. Select a user with assigned tasks
3. Tap "View X Assigned Tasks"
4. Select any task
5. Open the dropdown menu in the top-left
6. Verify "Back To Assigned Tasks" is displayed (not "Back To Task List")
7. Repeat from Projects → Project Tasks → Task Detail to verify "Back To Project Tasks" appears
8. Navigate from Task List → Task Detail to verify "Back To Task List" appears

Date: February 19, 2026
