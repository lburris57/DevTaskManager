//
//  ProjectDetailView.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/17/25.
//
import SwiftData
import SwiftUI

struct ProjectDetailView: View
{
    //  This is the project sent from the list view
    @Bindable var project: Project

    //  This is the navigation path sent from the list view
    @Binding var path: [AppNavigationDestination]

    // Optional callback to dismiss to main menu
    var onDismissToMain: (() -> Void)?
    
    // Optional binding for macOS NavigationSplitView detail column
    var detailSelection: Binding<AppNavigationDestination?>?

    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var isNewProject: Bool
    @State private var projectSaved = false

    // Initialize state from project
    init(project: Project, path: Binding<[AppNavigationDestination]>, onDismissToMain: (() -> Void)? = nil, detailSelection: Binding<AppNavigationDestination?>? = nil)
    {
        _project = Bindable(wrappedValue: project)
        _path = path
        self.onDismissToMain = onDismissToMain
        self.detailSelection = detailSelection
        _isNewProject = State(initialValue: project.title == Constants.EMPTY_STRING && project.descriptionText == Constants.EMPTY_STRING)
    }

    //  Check whether to enable/disable Save button
    func validateFields() -> Bool
    {
        if project.title == Constants.EMPTY_STRING ||
            project.descriptionText == Constants.EMPTY_STRING
        {
            return false
        }

        return true
    }

    //  Clean up if needed - delete unsaved new projects
    func validateProject()
    {
        // If this is a new project that wasn't saved, delete it
        if isNewProject && !projectSaved
        {
            modelContext.delete(project)
            try? modelContext.save()
        }
    }

    //  Set the last updated date value when saving changes
    func saveProject()
    {
        project.lastUpdated = Date()

        // Insert project if it's new (not already in context)
        if isNewProject
        {
            modelContext.insert(project)
        }

        try? modelContext.save()

        // Mark as saved so validateProject doesn't delete it
        projectSaved = true
    }

    var body: some View
    {
        ZStack
        {
            // Solid background to prevent content showing through
            Color.systemBackground
                .platformIgnoreSafeArea()

            // Modern gradient background overlay
            AppGradients.mainBackground
                .platformIgnoreSafeArea()

            VStack(spacing: 0)
            {
                // Modern header
                ModernHeaderView(
                    icon: "folder.fill",
                    title: isNewProject ? "New Project" : "Edit Project",
                    subtitle: project.tasks.isEmpty ? "No tasks" : "\(project.tasks.count) task\(project.tasks.count == 1 ? "" : "s")",
                    gradientColors: [.blue, .cyan]
                )

                ScrollView
                {
                    VStack(spacing: 16)
                    {
                        // Title Card
                        ModernFormCard
                        {
                            VStack(alignment: .leading, spacing: 12)
                            {
                                Text("Project Title")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                TextField("Enter project title", text: $project.title)
                                    .textFieldStyle(.plain)
                                    .font(.body)
                            }
                        }

                        // Description Card
                        ModernFormCard
                        {
                            VStack(alignment: .leading, spacing: 12)
                            {
                                Text("Description")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                TextEditor(text: $project.descriptionText)
                                    .frame(minHeight: 120)
                                    .scrollContentBackground(.hidden)
                                    .font(.body)
                            }
                        }

                        // Save Button
                        Button(action: {
                            saveProject()
                            dismiss()
                        })
                        {
                            Text("Save Project")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            validateFields() ?
                                                LinearGradient(
                                                    colors: [.blue, .cyan],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ) :
                                                LinearGradient(
                                                    colors: [.gray.opacity(0.5), .gray.opacity(0.5)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                        )
                                        .shadow(color: validateFields() ? .blue.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                                )
                        }
                        .disabled(!validateFields())
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    }
                    .padding(.top, 8)
                }
            }
        }
        .toolbar
        {
            toolbarLeadingContent
            toolbarTrailingContent
        }
        .platformNavigationBar()
        .onDisappear(perform: validateProject)
    }

    // MARK: - Toolbar Components

    @ToolbarContentBuilder
    private var toolbarLeadingContent: some ToolbarContent
    {
        ToolbarItem(placement: .platformLeading)
        {
            navigationMenu
        }
    }

    @ToolbarContentBuilder
    private var toolbarTrailingContent: some ToolbarContent
    {
        ToolbarItem(placement: .platformCancellation)
        {
            Button("Cancel")
            {
                Log.info("Cancel button pressed")
                Log.info("detailSelection exists: \(detailSelection != nil)")
                
                validateProject() // Clean up unsaved projects before dismissing
                
                #if os(macOS)
                // On macOS with NavigationSplitView, clear the detail selection
                if let detailSelection = detailSelection {
                    Log.info("Clearing detailSelection on macOS")
                    detailSelection.wrappedValue = nil
                } else {
                    Log.info("No detailSelection, calling dismiss()")
                    dismiss()
                }
                #else
                dismiss()
                #endif
            }
            .foregroundStyle(AppGradients.projectGradient)
        }
    }

    // MARK: - Helper Views

    private var navigationMenu: some View
    {
        Menu
        {
            Button
            {
                navigateBackOneLevel()
            } label: {
                Label("Back To Project List", systemImage: "folder.fill")
            }

            Button
            {
                navigateToMainMenu()
            } label: {
                Label("Back To Main Menu", systemImage: "house.fill")
            }
        } label: {
            HStack(spacing: 4)
            {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .foregroundStyle(AppGradients.projectGradient)
        }
    }

    // MARK: - Navigation Actions

    private func navigateBackOneLevel()
    {
        validateProject() // Clean up unsaved projects before navigating
        #if os(macOS)
        // On macOS with NavigationSplitView, clear the detail selection
        if let detailSelection = detailSelection {
            detailSelection.wrappedValue = nil
        } else {
            if !path.isEmpty {
                path.removeLast()
            }
            dismiss()
        }
        #else
        if !path.isEmpty {
            path.removeLast()
        }
        dismiss()
        #endif
    }

    private func navigateToMainMenu()
    {
        validateProject() // Clean up unsaved projects before navigating
        #if os(macOS)
        // On macOS with NavigationSplitView, clear the detail selection
        if let detailSelection = detailSelection {
            detailSelection.wrappedValue = nil
        } else {
            path.removeAll()
            if let onDismissToMain = onDismissToMain {
                onDismissToMain()
            } else {
                dismiss()
            }
        }
        #else
        path.removeAll()
        if let onDismissToMain = onDismissToMain {
            onDismissToMain()
        } else {
            dismiss()
        }
        #endif
    }
}
