#!/bin/bash

# DevTaskManager - macOS Compatibility Fix Script
# Run this script to fix all remaining cross-platform issues

echo "🔧 Fixing macOS compatibility issues..."

cd "$(dirname "$0")/DevTaskManager/Views"

# Fix all UIColor references
echo "  Fixing UIColor references..."
find . -name "*.swift" -type f -exec sed -i '' 's/Color(UIColor\.systemBackground)/Color.systemBackground/g' {} \;
find . -name "*.swift" -type f -exec sed -i '' 's/Color(UIColor\.secondarySystemBackground)/Color.secondarySystemBackground/g' {} \;

# Fix toolbar placements
echo "  Fixing toolbar placements..."
find . -name "*.swift" -type f -exec sed -i '' 's/placement: \.topBarLeading/placement: .navigation/g' {} \;
find . -name "*.swift" -type f -exec sed -i '' 's/placement: \.topBarTrailing/placement: .primaryAction/g' {} \;
find . -name "*.swift" -type f -exec sed -i '' 's/placement: \.navigationBarLeading/placement: .navigation/g' {} \;

# Touch all Swift files to force Xcode to reload
echo "  Updating file timestamps..."
find . -name "*.swift" -type f -exec touch {} \;

echo "✅ Done! Now:"
echo "   1. Close all open files in Xcode (⌘W repeatedly)"
echo "   2. Clean Build Folder (⌘⇧K)"
echo "   3. Build (⌘B)"
echo ""
echo "Or simply quit and reopen Xcode."
