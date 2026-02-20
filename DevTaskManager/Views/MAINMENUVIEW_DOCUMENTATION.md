# MainMenuView Documentation

## Overview
`MainMenuView` is the primary entry point and navigation hub for the DevTaskManager application. It provides a modern, card-based interface for navigating to the main sections of the app: Projects, Users, and Tasks.

## File Information
- **File**: `MainMenuView.swift`
- **Created**: April 20, 2025
- **Platform**: iOS
- **Framework**: SwiftUI
- **Dependencies**: SwiftData

## Architecture

### View Structure
```
MainMenuView (NavigationStack)
└── ZStack
    ├── Background Gradient
    └── VStack
        ├── Header Section
        │   ├── App Icon
        │   ├── App Title
        │   └── Subtitle
        ├── ScrollView
        │   └── VStack (Menu Cards)
        │       ├── Projects MenuCard
        │       ├── Users MenuCard
        │       ├── Tasks MenuCard
        │       └── Developer Tools MenuCard (Debug only)
        └── Spacer
```

## Main Components

### 1. MainMenuView

The primary view that manages navigation and displays the main menu.

#### Properties

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `modelContext` | `ModelContext` | `@Environment` | SwiftData context for data operations |
| `showSuccessToast` | `Bool` | `@State` | Controls visibility of success toast notification |
| `selectedView` | `MenuDestination?` | `@State` | Tracks which view to present in full screen |

#### Navigation Enum

```swift
enum MenuDestination: Hashable, Identifiable {
    case projectList
    case userList
    case taskList
    
    var id: Self { self }
}
```

**Purpose**: Type-safe navigation destination identifier that conforms to `Hashable` and `Identifiable` for use with SwiftUI's navigation system.

#### Layout Sections

##### Header Section
- **App Icon**: 60pt checkmark.circle.fill with blue-to-purple gradient
- **Title**: "Dev Task Manager" in 32pt bold rounded font
- **Subtitle**: "Organize your development workflow" in secondary color

##### Menu Cards Section
Contains navigation cards for each main section:

1. **Projects Card**
   - Icon: `folder.fill`
   - Colors: Blue to Cyan gradient
   - Action: Navigate to ProjectListView

2. **Users Card**
   - Icon: `person.3.fill`
   - Colors: Purple to Pink gradient
   - Action: Navigate to UserListView

3. **Tasks Card**
   - Icon: `checklist`
   - Colors: Orange to Red gradient
   - Action: Navigate to TaskListView

4. **Developer Tools Card** (Debug builds only)
   - Icon: `hammer.fill`
   - Colors: Green to Mint gradient
   - Action: Load sample data

#### Methods

##### `loadSampleData()`
```swift
private func loadSampleData()
```

**Purpose**: Loads sample data into the app for testing and development purposes.

**Behavior**:
1. Calls `SampleData.createSampleData(in: modelContext)`
2. Animates the success toast to visible state
3. Toast auto-dismisses after 3 seconds (handled by toast modifier)

**Availability**: Only available in Debug builds (via `#if DEBUG`)

#### Navigation Implementation

The view uses `.fullScreenCover(item:)` for navigation:

```swift
.fullScreenCover(item: $selectedView) { destination in
    switch destination {
    case .projectList:
        ProjectListView()
    case .userList:
        UserListView()
    case .taskList:
        TaskListView()
    }
}
```

**Advantages**:
- Full-screen presentation creates independent navigation contexts
- Clean separation between menu and detail views
- Each destination manages its own NavigationStack
- No navigation stack pollution

### 2. MenuCard Component

A reusable card component for menu navigation items.

#### Properties

| Property | Type | Access | Description |
|----------|------|--------|-------------|
| `icon` | `String` | `let` | SF Symbol name for the card icon |
| `title` | `String` | `let` | Primary title text |
| `subtitle` | `String` | `let` | Secondary description text |
| `gradientColors` | `[Color]` | `let` | Array of colors for gradient (2 colors) |
| `action` | `() -> Void` | `let` | Closure executed when card is tapped |
| `isPressed` | `Bool` | `@State` | Tracks pressed state for animation |

#### Visual Design

##### Layout Structure
```
HStack
├── ZStack (Icon Container)
│   ├── RoundedRectangle (60x60, gradient background)
│   └── Image (SF Symbol icon)
├── VStack (Text Content)
│   ├── Text (Title)
│   └── Text (Subtitle)
├── Spacer
└── Image (Chevron right)
```

##### Styling Details
- **Card**: 16pt padding, white background, rounded corners (16pt radius)
- **Shadow**: Black 8% opacity, 10pt radius, 4pt Y offset
- **Icon Container**: 60x60pt, 12pt corner radius, gradient fill
- **Icon Shadow**: First gradient color at 30% opacity, 8pt radius
- **Press Animation**: Scales to 97% when pressed

##### Interactive Behavior
- **Press Feedback**: Card scales down to 97% on press
- **Animation**: 0.1 second ease-in-out animation
- **Gesture**: Uses `DragGesture(minimumDistance: 0)` for immediate feedback
- **Button Style**: `.plain` to allow custom press handling

## Design Patterns

### 1. **Composition**
The view is composed of reusable `MenuCard` components, promoting code reuse and maintainability.

### 2. **State Management**
Uses SwiftUI's `@State` for local UI state and `@Environment` for dependency injection.

### 3. **Type-Safe Navigation**
The `MenuDestination` enum provides compile-time safety for navigation destinations.

### 4. **Responsive Design**
- `ScrollView` allows content to adapt to different screen sizes
- Flexible spacing and padding for various devices
- Gradient backgrounds that scale naturally

### 5. **Conditional Compilation**
Debug-only features (Developer Tools) are excluded from release builds using `#if DEBUG`.

## Color Scheme

### Background
- **Type**: Linear Gradient
- **Colors**: Blue (10% opacity) → Purple (5% opacity)
- **Direction**: Top-leading to bottom-trailing
- **Coverage**: Full screen with `.ignoresSafeArea()`

### Menu Card Gradients
| Card | Start Color | End Color | Purpose |
|------|------------|-----------|---------|
| Projects | Blue | Cyan | Professional, trust |
| Users | Purple | Pink | Creative, people-focused |
| Tasks | Orange | Red | Energy, action |
| Developer Tools | Green | Mint | Development, growth |

## Typography

| Element | Font | Weight | Size | Design |
|---------|------|--------|------|--------|
| App Title | System | Bold | 32pt | Rounded |
| Card Title | System | Semibold | 20pt | Rounded |
| Subtitle | System | Regular | Subheadline | Default |
| Icon | System | Semibold | 28pt | N/A |

## Accessibility Considerations

### Current Implementation
- ✅ Dynamic Type support (uses system fonts)
- ✅ Clear visual hierarchy
- ✅ High contrast icons and text
- ✅ Sufficient touch targets (minimum 60x60pt)
- ✅ Semantic color usage

### Potential Improvements
- ⚠️ Add `.accessibilityLabel()` to MenuCard for screen readers
- ⚠️ Add `.accessibilityHint()` to describe card actions
- ⚠️ Consider `.accessibilityElement(children: .combine)` for cards
- ⚠️ Add haptic feedback on card tap

### Example Accessibility Enhancement
```swift
.accessibilityLabel("\(title) section")
.accessibilityHint("Double tap to open \(title.lowercased())")
.accessibilityAddTraits(.isButton)
```

## Performance Considerations

### Optimizations
1. **Lazy Loading**: Uses `ScrollView` with immediate content (no lazy loading needed for 3-4 cards)
2. **State Minimization**: Only essential state properties
3. **View Body Complexity**: Simple structure, fast rendering
4. **Animation Performance**: Lightweight scale animations

### Memory Usage
- **Minimal State**: Only 2 state variables in MainMenuView
- **No Heavy Resources**: All images are SF Symbols (vector-based)
- **Efficient Gradients**: Linear gradients are GPU-accelerated

## Testing

### Preview Configuration
```swift
#Preview("With Sample Data", traits: .modifier(SampleDataPreviewModifier())) {
    MainMenuView()
}
```

**Features**:
- Uses custom preview modifier for sample data
- Displays fully populated menu
- Tests with realistic data

### Test Scenarios

#### Manual Testing Checklist
- [ ] App launches to MainMenuView
- [ ] All menu cards are visible and properly styled
- [ ] Tap Projects card navigates to ProjectListView
- [ ] Tap Users card navigates to UserListView
- [ ] Tap Tasks card navigates to TaskListView
- [ ] Developer Tools card only appears in debug builds
- [ ] Sample data loads successfully with toast notification
- [ ] Toast auto-dismisses after 3 seconds
- [ ] Press animations work smoothly
- [ ] Cards return to normal size after tap
- [ ] Navigation dismisses properly when returning to menu
- [ ] Layout adapts to different device sizes
- [ ] Works in both light and dark mode
- [ ] Rotation is handled correctly (if supported)

#### Automated Testing (Future)
```swift
@Test("Menu navigation works")
func testMenuNavigation() async throws {
    let view = MainMenuView()
    
    // Test that tapping projects card sets selectedView
    // Test that fullScreenCover presents ProjectListView
    // Test other navigation scenarios
}
```

## Integration Points

### Dependencies
1. **SwiftData**: Model context for data persistence
2. **ProjectListView**: Full project management interface
3. **UserListView**: User and role management
4. **TaskListView**: Task viewing and management
5. **SampleData**: Provides test data (debug builds)
6. **Toast System**: Success notifications

### Environment Requirements
- iOS 17.0+ (for SwiftData support)
- SwiftUI framework
- Model container configured in app entry point

## Usage Example

### Basic App Structure
```swift
@main
struct DevTaskManagerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Project.self,
            Task.self,
            User.self,
            Role.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainMenuView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

## Best Practices Demonstrated

1. ✅ **Separation of Concerns**: MenuCard is its own component
2. ✅ **Reusability**: MenuCard can be used in other contexts
3. ✅ **Type Safety**: MenuDestination enum prevents navigation errors
4. ✅ **Preview Support**: Includes preview configuration
5. ✅ **Platform-Specific Code**: Debug features properly isolated
6. ✅ **Gradient Customization**: Each card has distinct visual identity
7. ✅ **Animation Quality**: Smooth, responsive press feedback
8. ✅ **Code Organization**: Clear MARK comments for sections

## Future Enhancements

### Potential Features
1. **Statistics Dashboard**: Show counts on each card (e.g., "23 projects")
2. **Recent Items**: Quick access to recently viewed items
3. **Search**: Global search across all entities
4. **Settings**: App preferences and configuration
5. **Notifications**: Badge indicators for pending tasks
6. **Themes**: Customizable color schemes
7. **Onboarding**: First-launch tutorial
8. **Deep Linking**: Direct navigation from notifications/widgets

### Code Improvements
1. **Extract Theme**: Create a centralized theme system
2. **Localization**: Support multiple languages
3. **Card Configuration**: Make cards data-driven for easier customization
4. **Analytics**: Track which cards are most frequently used
5. **Accessibility**: Full VoiceOver and Dynamic Type optimization

## Related Documentation
- [NAVIGATION_REFACTOR_SUMMARY.md](./NAVIGATION_REFACTOR_SUMMARY.md) - Navigation architecture
- [TOAST_IMPLEMENTATION_SUMMARY.md](./TOAST_IMPLEMENTATION_SUMMARY.md) - Toast notification system
- [PREVIEW_TRAITS_GUIDE.md](./PREVIEW_TRAITS_GUIDE.md) - Preview configuration

## Version History

| Date | Change | Author |
|------|--------|--------|
| April 20, 2025 | Initial implementation | Larry Burris |
| February 19, 2026 | Documentation created | AI Assistant |

---

**Note**: This documentation should be kept in sync with code changes. Update this file whenever MainMenuView's interface or behavior changes significantly.
