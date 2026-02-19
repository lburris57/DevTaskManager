# Toast Notification System

## Overview
A reusable toast notification component for displaying temporary feedback messages to users. Toasts automatically dismiss after a specified duration (default: 3 seconds).

## ✨ Features

- 🎯 **Auto-dismiss** - Automatically hides after 3 seconds (configurable)
- 🎨 **Multiple styles** - Success, Error, Info, and Warning variants
- ✨ **Smooth animations** - Spring-based slide-in/out transitions
- 📱 **Material design** - Uses `.ultraThinMaterial` for modern iOS look
- 🔧 **Reusable** - Simple view modifier API
- 🎭 **Customizable** - Customize icon, color, and duration

## 🚀 Quick Start

### Basic Usage

```swift
import SwiftUI

struct ContentView: View {
    @State private var showToast = false
    
    var body: some View {
        VStack {
            Button("Show Toast") {
                showToast = true
            }
        }
        .successToast(isShowing: $showToast, message: "Operation completed!")
    }
}
```

## 📋 Toast Types

### Success Toast (Green)
```swift
.successToast(isShowing: $showToast, message: "Sample data loaded!")
```
- ✅ Icon: `checkmark.circle.fill`
- 🟢 Color: Green
- **Use for:** Successful operations, confirmations

### Error Toast (Red)
```swift
.errorToast(isShowing: $showError, message: "Failed to save data")
```
- ❌ Icon: `xmark.circle.fill`
- 🔴 Color: Red
- **Use for:** Errors, failures, critical issues

### Info Toast (Blue)
```swift
.infoToast(isShowing: $showInfo, message: "New feature available")
```
- ℹ️ Icon: `info.circle.fill`
- 🔵 Color: Blue
- **Use for:** Informational messages, tips

### Warning Toast (Orange)
```swift
.warningToast(isShowing: $showWarning, message: "Low storage space")
```
- ⚠️ Icon: `exclamationmark.triangle.fill`
- 🟠 Color: Orange
- **Use for:** Warnings, cautions, non-critical issues

## 🎨 Custom Toast

For complete customization:

```swift
.toast(
    isShowing: $showToast,
    message: "Custom message",
    icon: "star.fill",
    iconColor: .purple,
    duration: 5.0  // Show for 5 seconds
)
```

## 📱 Real-World Examples

### Example 1: Data Save Confirmation
```swift
struct SaveView: View {
    @State private var showSaveSuccess = false
    
    var body: some View {
        Button("Save") {
            saveData()
            showSaveSuccess = true
        }
        .successToast(
            isShowing: $showSaveSuccess,
            message: "Changes saved successfully!"
        )
    }
}
```

### Example 2: Network Error
```swift
struct NetworkView: View {
    @State private var showError = false
    
    func fetchData() {
        // Network call fails
        showError = true
    }
    
    var body: some View {
        VStack {
            Button("Fetch Data") {
                fetchData()
            }
        }
        .errorToast(
            isShowing: $showError,
            message: "Network connection failed"
        )
    }
}
```

### Example 3: Form Validation Warning
```swift
struct FormView: View {
    @State private var showWarning = false
    @State private var email = ""
    
    func validateEmail() {
        if email.isEmpty {
            showWarning = true
        }
    }
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
            Button("Submit") {
                validateEmail()
            }
        }
        .warningToast(
            isShowing: $showWarning,
            message: "Please enter your email address"
        )
    }
}
```

### Example 4: Sample Data Loading (Like MainMenuView)
```swift
struct MainMenuView: View {
    @State private var showSuccessToast = false
    
    func loadSampleData() {
        SampleData.createSampleData(in: modelContext)
        withAnimation {
            showSuccessToast = true
        }
    }
    
    var body: some View {
        VStack {
            Button("Load Sample Data") {
                loadSampleData()
            }
        }
        .successToast(
            isShowing: $showSuccessToast,
            message: "Sample data loaded successfully! 🎉"
        )
    }
}
```

## ⚙️ Configuration

### Duration
Change how long the toast displays:

```swift
.successToast(
    isShowing: $showToast,
    message: "Quick message",
    duration: 1.5  // Show for 1.5 seconds
)
```

### Custom Icon and Color
```swift
.toast(
    isShowing: $showToast,
    message: "You earned a badge!",
    icon: "trophy.fill",
    iconColor: .yellow,
    duration: 4.0
)
```

## 🎯 Best Practices

### 1. Keep Messages Short
✅ **Good:** "Data saved"
❌ **Bad:** "Your data has been successfully saved to the database and you can now continue working"

### 2. Use Appropriate Toast Types
- **Success** - Completed actions
- **Error** - Failed operations
- **Info** - General information
- **Warning** - Cautions or validation issues

### 3. Don't Overuse
Only show toasts for meaningful feedback. Too many toasts can annoy users.

### 4. Be Specific
✅ **Good:** "Project 'E-Commerce' deleted"
❌ **Bad:** "Operation complete"

### 5. Include Emojis Sparingly
```swift
.successToast(message: "Account created! 🎉")  // Good
.successToast(message: "Done! ✅🎉🎊🥳")      // Too much
```

## 🔧 Implementation Details

### Toast Position
Toasts appear at the **top** of the screen, below the navigation bar.

### Animation
- **Entry:** Slides in from top with spring animation
- **Exit:** Slides out to top with fade
- **Timing:** `spring(response: 0.4, dampingFraction: 0.7)`

### Visual Design
- **Background:** `.ultraThinMaterial` for native iOS look
- **Shadow:** Subtle drop shadow for depth
- **Padding:** Comfortable spacing around content
- **Corner Radius:** 12pt for modern appearance

## 📱 Usage in DevTaskManager

The toast system is currently used in:

### MainMenuView
Shows success confirmation when sample data is loaded:
```swift
.successToast(
    isShowing: $showSuccessToast,
    message: "Sample data loaded successfully! 🎉"
)
```

### Potential Future Uses
- Project creation/deletion confirmation
- User account changes
- Task assignment notifications
- Data sync status
- Validation errors
- Network status changes

## 🎨 Preview Examples

The `ToastView.swift` file includes 4 interactive previews:
1. **Success Toast** - Green checkmark
2. **Error Toast** - Red X
3. **Info Toast** - Blue info icon
4. **Warning Toast** - Orange warning triangle

View these in Xcode Canvas to see the animations!

## 🔍 Code Structure

```
ToastView.swift
├── ToastView - Core toast component
├── ToastModifier - View modifier for adding toasts
├── View Extensions - Convenience methods
│   ├── toast() - Generic toast
│   ├── successToast() - Green success
│   ├── errorToast() - Red error
│   ├── infoToast() - Blue info
│   └── warningToast() - Orange warning
└── Previews - Interactive examples
```

## ✅ Advantages Over Alerts

### Toast Notifications
- ✅ Non-blocking (user can continue working)
- ✅ Auto-dismiss (no user action required)
- ✅ Subtle and unobtrusive
- ✅ Good for confirmations and quick feedback

### When to Use Alerts Instead
- ⚠️ Critical errors that require attention
- 📝 User must make a decision
- 🚨 Destructive actions (delete confirmations)
- ℹ️ Complex information that needs reading

## 🚀 Adding Toasts to New Views

1. **Add state variable:**
   ```swift
   @State private var showToast = false
   ```

2. **Trigger toast in action:**
   ```swift
   Button("Do Something") {
       performAction()
       showToast = true  // Show toast
   }
   ```

3. **Add toast modifier to view:**
   ```swift
   .successToast(isShowing: $showToast, message: "Done!")
   ```

That's it! The toast will automatically appear and dismiss after 3 seconds.

## 📚 Related Files

- `ToastView.swift` - Toast implementation
- `MainMenuView.swift` - Usage example
- All list views can benefit from toasts for delete/create operations

## 🎉 Summary

The toast notification system provides:
- ✨ Beautiful, native iOS design
- 🎯 Simple API with convenience methods
- ⚡ Automatic dismissal
- 🎨 Multiple visual styles
- 📱 Perfect for non-critical feedback

Use it throughout your app to provide quick, unobtrusive feedback to users!
