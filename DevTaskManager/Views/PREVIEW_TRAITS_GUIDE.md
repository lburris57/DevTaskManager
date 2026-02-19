# SwiftUI Preview Traits Guide

## Overview
All views in DevTaskManager now use modern SwiftUI preview traits with reusable preview modifiers for consistent sample data across all previews.

## 🎨 Preview Modifiers

### `SampleDataPreviewModifier`
Provides a fully populated model container with sample data:
- ✅ 6 diverse projects
- ✅ 5 users with different roles
- ✅ 20+ tasks with various statuses
- ✅ 4 roles with permissions

**Usage:**
```swift
#Preview("With Sample Data", traits: .modifier(SampleDataPreviewModifier())) {
    ProjectListView()
}
```

### `EmptyDataPreviewModifier`
Provides an empty model container with no data - perfect for testing empty states.

**Usage:**
```swift
#Preview("Empty State", traits: .modifier(EmptyDataPreviewModifier())) {
    ProjectListView()
}
```

## 📱 Views with Preview Traits

### ProjectListView
- **"With Sample Data"** - Shows all 6 sample projects
- **"Empty State"** - Shows the empty state message

### UserListView
- **"With Sample Data"** - Shows all 5 sample users
- **"Empty State"** - Shows the empty state message

### TaskListView
- **"With Sample Data"** - Shows all sample tasks
- **"Empty State"** - Shows the empty state message

### MainMenuView
- **"With Sample Data"** - Shows main menu with sample data loaded

## 🎯 Benefits of Preview Traits

### 1. **Consistent Sample Data**
All previews use the same sample data source, ensuring consistency across the app.

### 2. **Multiple Preview Variants**
Easily test different states (populated vs empty) in the same preview canvas.

### 3. **Shared Context**
Preview modifiers use `makeSharedContext()` which creates the model container once and shares it across all preview instances.

### 4. **Easier to Maintain**
Changes to sample data automatically reflect in all previews.

### 5. **Better Performance**
Shared context means previews load faster and use less memory.

## 📝 Adding Preview Traits to New Views

When creating a new view, use this pattern:

```swift
#Preview("With Sample Data", traits: .modifier(SampleDataPreviewModifier())) {
    YourNewView()
}

#Preview("Empty State", traits: .modifier(EmptyDataPreviewModifier())) {
    YourNewView()
}
```

## 🔧 Advanced Usage

### Testing Different Device Sizes
Combine preview traits with other modifiers:

```swift
#Preview("iPhone 15 Pro", traits: .fixedLayout(width: 393, height: 852)) {
    ProjectListView()
}
    .modifier(SampleDataPreviewModifier())
```

### Testing Dark Mode
```swift
#Preview("Dark Mode", traits: .modifier(SampleDataPreviewModifier())) {
    ProjectListView()
        .preferredColorScheme(.dark)
}
```

### Testing Landscape
```swift
#Preview("Landscape", traits: .landscapeLeft) {
    ProjectListView()
}
    .modifier(SampleDataPreviewModifier())
```

### Multiple Variants in One Preview
```swift
#Preview {
    VStack {
        // With data
        ProjectListView()
            .modifier(SampleDataPreviewModifier())
        
        Divider()
        
        // Empty state
        ProjectListView()
            .modifier(EmptyDataPreviewModifier())
    }
}
```

## 🎨 Creating Custom Preview Modifiers

You can create specialized preview modifiers for specific scenarios:

```swift
/// Preview modifier with only one project
struct SingleProjectPreviewModifier: PreviewModifier {
    
    static func makeSharedContext() async throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Project.self, Task.self, User.self, Role.self,
            configurations: config
        )
        
        await MainActor.run {
            let project = Project(
                title: "Test Project",
                descriptionText: "A test project for previews"
            )
            container.mainContext.insert(project)
            try? container.mainContext.save()
        }
        
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
    }
}
```

## 📊 Sample Data Contents

The `SampleDataPreviewModifier` provides:

### Projects (6 total)
1. **E-Commerce Platform** - 5 tasks, 45 days old
2. **Mobile Banking App** - 3 tasks, 30 days old
3. **Task Management System** - 6 tasks, 20 days old
4. **Social Media Dashboard** - 4 tasks, 15 days old
5. **Healthcare Portal** - 2 tasks, 5 days old
6. **Fitness Tracker App** - 0 tasks, 2 days old (empty project)

### Users (5 total)
- Sarah Johnson (Admin)
- Michael Chen (Developer)
- Emily Rodriguez (Developer)
- James Williams (Validator)
- Olivia Martinez (Business Analyst)

### Tasks (20+ total)
- Various statuses: Unassigned, In Progress, Completed
- Various priorities: High, Medium, Low
- Various types: Development, Testing, Design, Documentation
- Realistic dates and assignments

### Roles (4 total)
- Admin (full permissions)
- Developer (task management)
- Validator (testing and reporting)
- Business Analyst (requirements and reporting)

## 🚀 Quick Tips

1. **Use Named Previews**: Always name your previews for clarity
   ```swift
   #Preview("With Data") { ... }
   ```

2. **Test Empty States**: Always include an empty state preview
   ```swift
   #Preview("Empty State", traits: .modifier(EmptyDataPreviewModifier())) { ... }
   ```

3. **Combine Traits**: You can combine multiple traits
   ```swift
   #Preview("iPad Pro", traits: [
       .fixedLayout(width: 1024, height: 1366),
       .modifier(SampleDataPreviewModifier())
   ]) { ... }
   ```

4. **View Preview Variants**: Click the preview selector in Xcode to switch between different preview variants

## 🔗 Related Files

- `SampleDataPreviewModifier.swift` - Preview modifier definitions
- `SampleData.swift` - Sample data generation
- `ModelContainer+SampleData.swift` - Model container extensions

## ✅ Migration Complete

All main views have been migrated to use preview traits:
- ✅ ProjectListView
- ✅ UserListView
- ✅ TaskListView
- ✅ MainMenuView

Detail views (ProjectDetailView, UserDetailView, TaskDetailView) use navigation and require a binding, so they're tested through their parent list views.
