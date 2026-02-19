# Project-Task Relationship Fix

## Problem
Tasks were not showing up as related to their projects in the UI. The task count badge was always showing 0 tasks even though sample data was creating tasks.

## Root Cause
The `Project` and `Task` models didn't have a proper **bidirectional relationship** configured in SwiftData. While tasks were being added to project arrays in code, SwiftData wasn't persisting this relationship correctly because it lacked the inverse relationship definition.

## Solution

### 1. Updated Project Model (`Project.swift`)

**Before:**
```swift
var tasks: [Task] = []
```

**After:**
```swift
@Relationship(deleteRule: .cascade, inverse: \Task.project)
var tasks: [Task] = []
```

**Changes:**
- ✅ Added `@Relationship` attribute
- ✅ Specified `deleteRule: .cascade` - when a project is deleted, all its tasks are deleted
- ✅ Defined `inverse: \Task.project` - establishes bidirectional relationship

### 2. Updated Task Model (`Task.swift`)

**Before:**
```swift
@Model
class Task {
    // ... properties
    // No reference to Project
}
```

**After:**
```swift
@Model
class Task {
    // ... properties
    var project: Project?
    // ...
}
```

**Changes:**
- ✅ Added `project: Project?` property to Task
- ✅ Updated `init()` to include `project` parameter
- ✅ This completes the bidirectional relationship

## How SwiftData Relationships Work

### Bidirectional Relationships
For SwiftData to properly manage relationships between models, you need:

1. **Forward Relationship** (Project → Tasks)
   - The `@Relationship` attribute on the `tasks` array
   - Defines how to handle deletions (`deleteRule: .cascade`)
   - Points to the inverse property (`inverse: \Task.project`)

2. **Inverse Relationship** (Task → Project)
   - The `project: Project?` property on Task
   - Allows SwiftData to maintain both sides of the relationship
   - Automatically updated when tasks are added to a project

### Delete Rules

The `deleteRule: .cascade` means:
- When you delete a **Project**, all its **Tasks** are automatically deleted
- This prevents orphaned tasks in the database
- Maintains referential integrity

## What Now Works

### Task Count Badge
```swift
if !project.tasks.isEmpty {
    Label("\(project.tasks.count)", systemImage: "checkmark.circle")
}
```
This now correctly shows the number of tasks for each project!

### Sample Data
When you load sample data:
- E-Commerce Platform: **5 tasks**
- Mobile Banking App: **3 tasks**
- Task Management System: **6 tasks**
- Social Media Dashboard: **4 tasks**
- Healthcare Portal: **2 tasks**
- Fitness Tracker App: **0 tasks** (empty state testing)

### Navigation
When you tap a project, you can now see all its tasks and navigate between them properly.

## Database Schema Change

⚠️ **Important:** This is a schema change! You'll need to:

1. **Delete the app** from your simulator/device
2. **Reinstall** to create a fresh database with the new schema
3. **Load sample data** again using the "Load Sample Data" button

Or in the simulator:
```
Device → Erase All Content and Settings
```

## Testing

After reinstalling:

1. **Run the app**
2. **Tap "Load Sample Data"** in Main Menu
3. **Go to Project List**
4. **You should now see task counts!**
   - E-Commerce Platform: 🔵 5
   - Mobile Banking App: 🔵 3
   - Task Management System: 🔵 6
   - etc.

## Other Relationships in the App

The app has several other bidirectional relationships that were already correctly configured:

### Task ↔ TaskItem
```swift
// In Task
@Relationship(deleteRule: .cascade, inverse: \TaskItem.parentTask)
var taskItems: [TaskItem] = []

// In TaskItem
var parentTask: Task?
```

### Task ↔ User
```swift
// In Task
var assignedUser: User?

// In User
@Relationship(deleteRule: .cascade, inverse: \Task.assignedUser)
var tasks: [Task] = []
```

## Best Practices for SwiftData Relationships

When creating relationships in SwiftData:

1. **Always use bidirectional relationships**
   ```swift
   // Parent side
   @Relationship(deleteRule: .cascade, inverse: \Child.parent)
   var children: [Child] = []
   
   // Child side
   var parent: Parent?
   ```

2. **Choose appropriate delete rules**
   - `.cascade` - Delete children when parent is deleted
   - `.nullify` - Set child's parent to nil when parent is deleted
   - `.deny` - Prevent deletion if children exist

3. **Update init() methods**
   - Include all relationship properties in initializers
   - Provide default values (usually `nil` or `[]`)

4. **Test relationships**
   - Verify data persists correctly
   - Test delete cascades
   - Check bidirectional updates

## Summary

✅ **Project model** now has `@Relationship` on `tasks` array
✅ **Task model** now has `project: Project?` property  
✅ **Bidirectional relationship** properly configured
✅ **Task counts** now display correctly in UI
✅ **Sample data** relationships work as expected

The relationship between Projects and Tasks is now properly persisted in SwiftData, and the UI correctly reflects the number of tasks in each project! 🎉
