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
            List
            {
                Button {
                    selectedView = .projectList
                } label: {
                    HStack {
                        Text("Project List")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                
                Button {
                    selectedView = .userList
                } label: {
                    HStack {
                        Text("User List")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                
                Button {
                    selectedView = .taskList
                } label: {
                    HStack {
                        Text("Task List")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                
                #if DEBUG
                Section("Development Tools")
                {
                    Button(action: loadSampleData)
                    {
                        HStack
                        {
                            Image(systemName: "tray.fill")
                            Text("Load Sample Data")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                #endif
            }
            .navigationBarTitle(Text("Main Menu"), displayMode: .inline)
            .listStyle(.plain)
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

#Preview("With Sample Data", traits: .modifier(SampleDataPreviewModifier())) {
    MainMenuView()
}
