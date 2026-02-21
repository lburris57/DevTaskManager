//
//  PlatformHelpers.swift
//  DevTaskManager
//
//  Cross-platform compatibility helpers
//
import SwiftUI

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

// MARK: - Color Extensions

extension Color
{
    /// System background color (cross-platform)
    static var systemBackground: Color
    {
        #if canImport(UIKit)
            return Color(UIColor.systemBackground)
        #else
            return Color(NSColor.windowBackgroundColor)
        #endif
    }

    /// Secondary system background color (cross-platform)
    static var secondarySystemBackground: Color
    {
        #if canImport(UIKit)
            return Color(UIColor.secondarySystemBackground)
        #else
            return Color(NSColor.controlBackgroundColor)
        #endif
    }

    /// Tertiary system background color (cross-platform)
    static var tertiarySystemBackground: Color
    {
        #if canImport(UIKit)
            return Color(UIColor.tertiarySystemBackground)
        #else
            return Color(NSColor.textBackgroundColor)
        #endif
    }
}

// MARK: - Platform Detection

struct Platform
{
    static var isIOS: Bool
    {
        #if os(iOS)
            return true
        #else
            return false
        #endif
    }

    static var isMacOS: Bool
    {
        #if os(macOS)
            return true
        #else
            return false
        #endif
    }

    static var isiPadOS: Bool
    {
        #if os(iOS)
            return UIDevice.current.userInterfaceIdiom == .pad
        #else
            return false
        #endif
    }
}

// MARK: - View Extensions

extension View
{
    /// Apply platform-specific navigation bar styles
    @ViewBuilder
    func platformNavigationBar() -> some View
    {
        #if os(iOS)
            toolbarBackground(.visible, for: .navigationBar)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
        #else
            self // macOS doesn't need this
        #endif
    }

    /// Apply platform-specific ignore safe area
    @ViewBuilder
    func platformIgnoreSafeArea() -> some View
    {
        #if os(iOS)
            ignoresSafeArea()
        #else
            ignoresSafeArea(edges: .top)
        #endif
    }
}

// MARK: - Toolbar Item Placement

extension ToolbarItemPlacement
{
    /// Cross-platform trailing placement
    static var platformTrailing: ToolbarItemPlacement
    {
        #if os(iOS)
            return .topBarTrailing
        #else
            return .primaryAction
        #endif
    }

    /// Cross-platform leading placement
    static var platformLeading: ToolbarItemPlacement
    {
        #if os(iOS)
            return .navigationBarLeading
        #else
            return .navigation
        #endif
    }

    /// Cancel action position (platform-appropriate)
    static var platformCancellation: ToolbarItemPlacement
    {
        #if os(iOS)
            return .topBarTrailing
        #else
            return .cancellationAction
        #endif
    }

    /// Confirmation action position (platform-appropriate)
    static var platformConfirmation: ToolbarItemPlacement
    {
        #if os(iOS)
            return .topBarTrailing
        #else
            return .confirmationAction
        #endif
    }
}
