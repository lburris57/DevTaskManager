//
//  MainMenuView.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/20/25.
//
import SwiftUI
import SwiftData

struct MainMenuView: View
{
    @Environment(\.modelContext) var modelContext
    @State private var showSuccessToast = false
    @State private var selectedView: MenuDestination?
    
    enum MenuDestination: Hashable, Identifiable {
        case projectList
        case userList
        case taskList
        
        var id: Self { self }
    }

    var body: some View
    {
        NavigationStack
        {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header section with app title and subtitle
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.top, 20)
                        
                        Text("Dev Task Manager")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text("Organize your development workflow")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 10)
                    }
                    .padding(.vertical, 20)
                    
                    // Main menu cards
                    ScrollView {
                        VStack(spacing: 16) {
                            // Projects Card
                            MenuCard(
                                icon: "folder.fill",
                                title: "Projects",
                                subtitle: "Manage your projects",
                                gradientColors: [.blue, .cyan],
                                action: { selectedView = .projectList }
                            )
                            
                            // Users Card
                            MenuCard(
                                icon: "person.3.fill",
                                title: "Users",
                                subtitle: "Manage team members",
                                gradientColors: [.purple, .pink],
                                action: { selectedView = .userList }
                            )
                            
                            // Tasks Card
                            MenuCard(
                                icon: "checklist",
                                title: "Tasks",
                                subtitle: "View all tasks",
                                gradientColors: [.orange, .red],
                                action: { selectedView = .taskList }
                            )
                            
                            #if DEBUG
                            // Developer Tools Card (Debug only)
                            MenuCard(
                                icon: "hammer.fill",
                                title: "Developer Tools",
                                subtitle: "Load sample data",
                                gradientColors: [.green, .mint],
                                action: loadSampleData
                            )
                            #endif
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
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
            .successToast(
                isShowing: $showSuccessToast,
                message: "Sample data loaded successfully! 🎉"
            )
        }
    }
    
    // Load sample data with visual feedback
    private func loadSampleData() {
        SampleData.createSampleData(in: modelContext)
        
        // Show success toast (auto-dismisses after 3 seconds)
        withAnimation {
            showSuccessToast = true
        }
    }
}

// MARK: - MenuCard Component

struct MenuCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradientColors: [Color]
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon with gradient background
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: gradientColors.first?.opacity(0.3) ?? .clear, radius: 8, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Title and subtitle
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

#Preview("With Sample Data", traits: .modifier(SampleDataPreviewModifier())) {
    MainMenuView()
}
