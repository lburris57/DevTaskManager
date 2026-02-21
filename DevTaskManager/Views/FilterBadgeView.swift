//
//  FilterBadgeView.swift
//  DevTaskManager
//
//  Created by Assistant on 2/20/26.
//
import SwiftUI

/// A reusable badge component to display active filters in list views
struct FilterBadgeView: View {
    let filterText: String
    let icon: String
    let onClear: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            
            Text(filterText)
                .font(.caption)
                .fontWeight(.medium)
            
            Button(action: onClear) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.indigo.opacity(0.15))
        )
        .foregroundStyle(.indigo)
    }
}

/// Helper to display multiple filter badges in a horizontal scroll
struct FilterBadgesContainer: View {
    let badges: [FilterBadge]
    
    struct FilterBadge: Identifiable {
        let id = UUID()
        let text: String
        let icon: String
        let onClear: () -> Void
    }
    
    var body: some View {
        if !badges.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(badges) { badge in
                        FilterBadgeView(
                            filterText: badge.text,
                            icon: badge.icon,
                            onClear: badge.onClear
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Example Usage

/*
 
 In your list view, add this state:
 
 @State private var selectedPriority: String? = nil
 @State private var selectedStatus: String? = nil
 @State private var selectedUser: String? = nil
 
 Then create the badges:
 
 var activeFilterBadges: [FilterBadgesContainer.FilterBadge] {
     var badges: [FilterBadgesContainer.FilterBadge] = []
     
     if let priority = selectedPriority {
         badges.append(
             FilterBadgesContainer.FilterBadge(
                 text: "Priority: \(priority)",
                 icon: "exclamationmark.triangle",
                 onClear: { selectedPriority = nil }
             )
         )
     }
     
     if let status = selectedStatus {
         badges.append(
             FilterBadgesContainer.FilterBadge(
                 text: "Status: \(status)",
                 icon: "checkmark.circle",
                 onClear: { selectedStatus = nil }
             )
         )
     }
     
     if let user = selectedUser {
         badges.append(
             FilterBadgesContainer.FilterBadge(
                 text: "User: \(user)",
                 icon: "person",
                 onClear: { selectedUser = nil }
             )
         )
     }
     
     return badges
 }
 
 In your view hierarchy:
 
 VStack {
     // Header
     ModernHeaderView(...)
     
     // Filter badges (shows active filters)
     FilterBadgesContainer(badges: activeFilterBadges)
     
     // Your list content
     ScrollView {
         ...
     }
 }
 
 */

// MARK: - Preview

#Preview("Single Filter") {
    VStack {
        FilterBadgeView(
            filterText: "Priority: High",
            icon: "exclamationmark.triangle",
            onClear: {}
        )
        .padding()
    }
}

#Preview("Multiple Filters") {
    FilterBadgesContainer(badges: [
        .init(text: "Priority: High", icon: "exclamationmark.triangle", onClear: {}),
        .init(text: "Status: In Progress", icon: "checkmark.circle", onClear: {}),
        .init(text: "User: Sarah Johnson", icon: "person", onClear: {})
    ])
}
