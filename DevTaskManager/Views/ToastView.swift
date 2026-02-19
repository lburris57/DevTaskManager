//
//  ToastView.swift
//  DevTaskManager
//
//  Created by Assistant on 2/17/26.
//
import SwiftUI

/// A reusable toast notification component
struct ToastView: View {
    let message: String
    let icon: String
    let iconColor: Color
    
    init(message: String, icon: String = "checkmark.circle.fill", iconColor: Color = .green) {
        self.message = message
        self.icon = icon
        self.iconColor = iconColor
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.title2)
            
            Text(message)
                .font(.body)
                .fontWeight(.medium)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
    }
}

/// View modifier for showing toast notifications
struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let icon: String
    let iconColor: Color
    let duration: TimeInterval
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if isShowing {
                    ToastView(message: message, icon: icon, iconColor: iconColor)
                        .padding(.top, 60)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isShowing)
                        .onAppear {
                            Task {
                                try? await Task.sleep(for: .seconds(duration))
                                await MainActor.run {
                                    withAnimation {
                                        isShowing = false
                                    }
                                }
                            }
                        }
                }
            }
    }
}

extension View {
    /// Shows a toast notification that auto-dismisses
    /// - Parameters:
    ///   - isShowing: Binding to control visibility
    ///   - message: The message to display
    ///   - icon: SF Symbol name for the icon
    ///   - iconColor: Color of the icon
    ///   - duration: How long to show the toast (default: 3 seconds)
    func toast(
        isShowing: Binding<Bool>,
        message: String,
        icon: String = "checkmark.circle.fill",
        iconColor: Color = .green,
        duration: TimeInterval = 3.0
    ) -> some View {
        modifier(ToastModifier(
            isShowing: isShowing,
            message: message,
            icon: icon,
            iconColor: iconColor,
            duration: duration
        ))
    }
}

// MARK: - Convenience Methods

extension View {
    /// Shows a success toast
    func successToast(isShowing: Binding<Bool>, message: String, duration: TimeInterval = 3.0) -> some View {
        toast(
            isShowing: isShowing,
            message: message,
            icon: "checkmark.circle.fill",
            iconColor: .green,
            duration: duration
        )
    }
    
    /// Shows an error toast
    func errorToast(isShowing: Binding<Bool>, message: String, duration: TimeInterval = 3.0) -> some View {
        toast(
            isShowing: isShowing,
            message: message,
            icon: "xmark.circle.fill",
            iconColor: .red,
            duration: duration
        )
    }
    
    /// Shows an info toast
    func infoToast(isShowing: Binding<Bool>, message: String, duration: TimeInterval = 3.0) -> some View {
        toast(
            isShowing: isShowing,
            message: message,
            icon: "info.circle.fill",
            iconColor: .blue,
            duration: duration
        )
    }
    
    /// Shows a warning toast
    func warningToast(isShowing: Binding<Bool>, message: String, duration: TimeInterval = 3.0) -> some View {
        toast(
            isShowing: isShowing,
            message: message,
            icon: "exclamationmark.triangle.fill",
            iconColor: .orange,
            duration: duration
        )
    }
}

#Preview("Success Toast") {
    struct PreviewWrapper: View {
        @State private var showToast = true
        
        var body: some View {
            VStack {
                Text("Content Below Toast")
                    .font(.title)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .successToast(isShowing: $showToast, message: "Sample data loaded successfully!")
        }
    }
    
    return PreviewWrapper()
}

#Preview("Error Toast") {
    struct PreviewWrapper: View {
        @State private var showToast = true
        
        var body: some View {
            VStack {
                Text("Content Below Toast")
                    .font(.title)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .errorToast(isShowing: $showToast, message: "Failed to load data")
        }
    }
    
    return PreviewWrapper()
}

#Preview("Info Toast") {
    struct PreviewWrapper: View {
        @State private var showToast = true
        
        var body: some View {
            VStack {
                Text("Content Below Toast")
                    .font(.title)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .infoToast(isShowing: $showToast, message: "New feature available")
        }
    }
    
    return PreviewWrapper()
}

#Preview("Warning Toast") {
    struct PreviewWrapper: View {
        @State private var showToast = true
        
        var body: some View {
            VStack {
                Text("Content Below Toast")
                    .font(.title)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .warningToast(isShowing: $showToast, message: "Low storage space")
        }
    }
    
    return PreviewWrapper()
}
