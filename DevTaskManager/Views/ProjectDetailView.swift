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
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
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
    
    //  Delete the skeleton project from the database if not edited
    func validateProject()
    {
        if  project.title == Constants.EMPTY_STRING ||
            project.descriptionText == Constants.EMPTY_STRING
        {
            withAnimation
            {
                modelContext.delete(project)
                try? modelContext.save()
            }
        }
    }
    
    //  Set the last updated date value when saving changes
    func saveProject()
    {
        project.lastUpdated = Date()
        
        modelContext.insert(project)
        try? modelContext.save()
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
            .navigationBarItems(trailing: Button("Cancel")
            {
                dismiss()
            })
            .padding(.horizontal)
            .onDisappear(perform: validateProject)
            .navigationTitle(validateFields() ? "Edit Project" : "Add Project").navigationBarTitleDisplayMode(.inline)
        }
    }
