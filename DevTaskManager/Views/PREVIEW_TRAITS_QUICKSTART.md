# Quick Start: Using Preview Traits

## 🚀 See Your New Previews in Action

### Step 1: Open a View File
Open any of these files in Xcode:
- `ProjectListView.swift`
- `UserListView.swift`
- `TaskListView.swift`
- `MainMenuView.swift`

### Step 2: Open the Canvas
- Press **Cmd + Option + Return**, or
- Click **Editor → Canvas** in the menu

### Step 3: See Multiple Preview Variants
At the bottom of the Canvas, you'll see a preview selector with options like:
- **"With Sample Data"** - Shows the view populated with realistic data
- **"Empty State"** - Shows what users see when there's no data

### Step 4: Switch Between Variants
Click on different variants in the preview selector to instantly switch views!

## 🎯 What You'll See

### ProjectListView
**With Sample Data:**
```
📱 Project List
┌─────────────────────────────────┐
│ E-Commerce Platform             │
│ A comprehensive online shop...  │
│ 📅 Jan 3 • ✓ 5 tasks           │
├─────────────────────────────────┤
│ Mobile Banking App              │
│ Secure mobile banking app...    │
│ 📅 Jan 18 • ✓ 3 tasks          │
├─────────────────────────────────┤
│ Task Management System          │
│ Collaborative task manager...   │
│ 📅 Jan 28 • ✓ 6 tasks          │
└─────────────────────────────────┘
```

**Empty State:**
```
📱 Project List
┌─────────────────────────────────┐
│                                 │
│       📁                        │
│   No projects yet               │
│                                 │
│   Create your first project     │
│   to get started                │
│                                 │
│   [  Add Project  ]             │
│                                 │
└─────────────────────────────────┘
```

### UserListView
**With Sample Data:**
```
📱 User List
┌─────────────────────────────────┐
│ Sarah Johnson                   │
│ Role: Admin                     │
│ Created: Dec 18, 2025          │
├─────────────────────────────────┤
│ Michael Chen                    │
│ Role: Developer                 │
│ Created: Jan 2, 2026           │
├─────────────────────────────────┤
│ Emily Rodriguez                 │
│ Role: Developer                 │
│ Created: Jan 17, 2026          │
└─────────────────────────────────┘
```

### TaskListView
**With Sample Data:**
```
📱 Task List
┌─────────────────────────────────┐
│ Implement Shopping Cart         │
│ Development • High Priority     │
│ Status: In Progress            │
├─────────────────────────────────┤
│ Payment Gateway Integration     │
│ Development • High Priority     │
│ Status: Completed ✓            │
├─────────────────────────────────┤
│ Product Search Optimization     │
│ Development • Medium Priority   │
│ Status: Unassigned             │
└─────────────────────────────────┘
```

## 💡 Pro Tips

### Pin Multiple Previews
1. Click the pin icon 📌 in a preview
2. Open another preview variant
3. See both side-by-side for comparison

### Test Dark Mode
Add to your preview:
```swift
#Preview("Dark Mode", traits: .modifier(SampleDataPreviewModifier())) {
    ProjectListView()
        .preferredColorScheme(.dark)
}
```

### Test Different Devices
```swift
#Preview("iPhone", traits: .fixedLayout(width: 393, height: 852)) {
    ProjectListView()
}
    .modifier(SampleDataPreviewModifier())

#Preview("iPad", traits: .fixedLayout(width: 1024, height: 1366)) {
    ProjectListView()
}
    .modifier(SampleDataPreviewModifier())
```

### Refresh Previews
If a preview gets stuck:
- Press **Cmd + Option + P**, or
- Click **Try Again** in the Canvas

## 🎨 Customize Sample Data

Want different sample data? Edit `SampleData.swift`:
- Add more projects
- Change user names
- Modify task details
- All previews update automatically!

## 📝 Add Previews to Your Views

When creating new views:

```swift
import SwiftUI
import SwiftData

struct MyNewView: View {
    @Query var items: [MyModel]
    
    var body: some View {
        List(items) { item in
            Text(item.name)
        }
    }
}

// Add these preview variants
#Preview("With Sample Data", traits: .modifier(SampleDataPreviewModifier())) {
    MyNewView()
}

#Preview("Empty State", traits: .modifier(EmptyDataPreviewModifier())) {
    MyNewView()
}
```

## ✅ Checklist

- [ ] Open any list view file
- [ ] Open Canvas (Cmd + Option + Return)
- [ ] See multiple preview variants
- [ ] Click "With Sample Data" to see populated view
- [ ] Click "Empty State" to see empty UI
- [ ] Pin both previews to compare side-by-side

## 🎉 You're All Set!

Your preview system is now fully configured with:
- ✨ Modern SwiftUI preview traits
- 📊 Rich sample data
- 🔄 Multiple test scenarios
- ⚡ Shared context for better performance

Happy previewing! 🚀

---

**Need Help?**
- See `PREVIEW_TRAITS_GUIDE.md` for detailed documentation
- See `SAMPLE_DATA_GUIDE.md` for sample data info
- See `PREVIEW_TRAITS_SUMMARY.md` for implementation details
