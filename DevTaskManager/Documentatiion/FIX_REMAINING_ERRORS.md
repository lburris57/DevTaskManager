# Fix Remaining Compilation Errors

## ✅ Already Fixed
- **MainMenuView.swift** - Updated to use `SimpleReportsView()` instead of `ReportsView()`

## 🔧 Manual Steps Required

### 1. Delete Duplicate File: ReportViewComponents.swift

**Location:** `/DevTaskManager/Views/ReportViewComponents.swift`

**Why:** This file contains duplicate declarations of components that already exist in `ViewsDesignSystem.swift`:
- `ModernHeaderView` (duplicate)
- `EmptyStateCard` (duplicate)
- `ModernFormCard` (duplicate)
- `ModernListRow` (duplicate)

**How to Delete:**
1. In Xcode's **Project Navigator** (left sidebar)
2. Find the file: **ReportViewComponents.swift**
3. Right-click on it
4. Select **"Delete"**
5. Choose **"Move to Trash"** (not just "Remove Reference")

This will resolve all 4 "Invalid redeclaration" errors.

---

### 2. Rename Physical Files in Xcode

After deleting `ReportViewComponents.swift`, rename the report view files:

#### Rename ReportsView.swift → SimpleReportsView.swift
1. In Project Navigator, find **ReportsView.swift**
2. Right-click → **Rename**
3. Change to: **SimpleReportsView.swift**
4. Press Enter

#### Rename ReportView.swift → DetailedReportsView.swift
1. In Project Navigator, find **ReportView.swift**
2. Right-click → **Rename**
3. Change to: **DetailedReportsView.swift**
4. Press Enter

---

### 3. Verify All Changes

After completing the above steps, build your project (**Cmd+B**) to verify:
- ✅ No "Cannot find 'ReportsView' in scope" errors
- ✅ No "Invalid redeclaration" errors
- ✅ All views compile successfully

---

## Summary of All Changes Made

### Code Changes (Already Done)
1. ✅ `ReportsView` struct renamed to `SimpleReportsView`
2. ✅ `ReportView` struct renamed to `DetailedReportsView`
3. ✅ `MainMenuView.swift` updated to reference `SimpleReportsView()`
4. ✅ All preview code updated in both report views

### Manual File System Changes (You Need to Do)
1. 🔧 Delete `ReportViewComponents.swift` (duplicate file)
2. 🔧 Rename `ReportsView.swift` → `SimpleReportsView.swift`
3. 🔧 Rename `ReportView.swift` → `DetailedReportsView.swift`

---

## Expected Result

After completing these steps:
- Your project should compile without errors
- Reports can be accessed from the main menu
- Both `SimpleReportsView` and `DetailedReportsView` are properly named and functional
- No duplicate component definitions

---

## If You See Other References to Old Names

If you find other files still referencing the old names, use Xcode's Find and Replace:

1. Press **Cmd+Shift+F** (Find in Project)
2. Search for: `ReportsView()`
3. Replace with: `SimpleReportsView()`
4. Click **Replace All**

Do the same for:
- `ReportView()` → `DetailedReportsView()`

---

## Questions?

If you encounter any issues:
1. Clean the build folder: **Product > Clean Build Folder** (Cmd+Shift+K)
2. Restart Xcode
3. Rebuild the project (Cmd+B)
