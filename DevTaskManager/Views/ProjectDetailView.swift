//
//  ProjectDetailView.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/17/25.
//
import SwiftUI
import SwiftData
import FloatingPromptTextField

struct ProjectDetailView: View
{
    //  This is the project sent from the list view
    @Bindable var project: Project
    
    //  This is the navigation path sent from the list view
    @Binding var path: [AppNavigationDestination]
    
    // Optional callback to dismiss to main menu
    var onDismissToMain: (() -> Void)? = nil
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var isNewProject: Bool
    @State private var projectSaved = false
    
    // Initialize state from project
    init(project: Project, path: Binding<[AppNavigationDestination]>, onDismissToMain: (() -> Void)? = nil) {
        self._project = Bindable(wrappedValue: project)
        self._path = path
        self.onDismissToMain = onDismissToMain
        self._isNewProject = State(initialValue: project.title == Constants.EMPTY_STRING && project.descriptionText == Constants.EMPTY_STRING)
    }
    
    //  Check whether to enable/disable Save button
    func validateFields() -> Bool
    {
        if  project.title == Constants.EMPTY_STRING ||
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
        if isNewProject && !projectSaved {
            modelContext.delete(project)
            try? modelContext.save()
        }
    }
    
    //  Set the last updated date value when saving changes
    func saveProject()
    {
        project.lastUpdated = Date()
        
        // Insert project if it's new (not already in context)
        if isNewProject {
            modelContext.insert(project)
        }
        
        try? modelContext.save()
        
        // Mark as saved so validateProject doesn't delete it
        projectSaved = true
    }
    
    var body: some View
    {
        //NavigationView
        //{
            VStack(spacing: 15)
            {
                FloatingPromptTextField(text: $project.title, prompt: Text("Title:")
                .foregroundStyle(colorScheme == .dark ? .gray : .blue).fontWeight(.bold))
                .floatingPromptScale(1.0)
                .background(colorScheme == .dark ? .gray.opacity(0.2) : .gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.leading, 15)
                
                VStack(alignment: .leading, spacing: 5)
                {
                    Text(" Description:")
                        .foregroundColor(colorScheme == .dark ? .gray : .blue)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    TextEditor(text: $project.descriptionText)
                        .lineLimit(6)
                        .border(.secondary, width: 1)
                        .padding(.horizontal)
                }
                
                Button("Save Project")
                {
                    saveProject()
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .disabled(!validateFields())
                .padding(10)
                .background(Color.blue).opacity(!validateFields() ? 0.6 : 1)
                .foregroundColor(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10.0, style: .continuous))
                .shadow(color: .black, radius: 2.0, x: 2.0, y: 2.0)
                
                Spacer()
                
                }.padding()
            //}
            .toolbar {
                toolbarLeadingContent
                toolbarTrailingContent
            }
            .padding(.horizontal)
            .onDisappear(perform: validateProject)
            .navigationTitle(validateFields() ? "Edit Project" : "Add Project")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
    }
    
    // MARK: - Toolbar Components
    
    @ToolbarContentBuilder
    private var toolbarLeadingContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            navigationMenu
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarTrailingContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Cancel") {
                dismiss()
            }
        }
    }
    
    // MARK: - Helper Views
    
    private var navigationMenu: some View {
        Menu {
            Button {
                navigateBackOneLevel()
            } label: {
                Label("Back To Project List", systemImage: "folder.fill")
            }
            
            Button {
                navigateToMainMenu()
            } label: {
                Label("Back To Main Menu", systemImage: "house.fill")
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
        }
    }
    
    // MARK: - Navigation Actions
    
    private func navigateBackOneLevel() {
        if !path.isEmpty {
            path.removeLast()
        }
        dismiss()
    }
    
    private func navigateToMainMenu() {
        path.removeAll()
        if let onDismissToMain = onDismissToMain {
            onDismissToMain()
        } else {
            dismiss()
        }
    }
}
