//
//  UserDetailView.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/19/25.
//
import FloatingPromptTextField
import SwiftData
import SwiftUI

struct UserDetailView: View
{
    //  This is the user sent from the list view
    @Bindable var user: User
    
    //  This is the navigation path sent from the list view
    @Binding var path: [AppNavigationDestination]
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedRole = Constants.EMPTY_STRING
    @State private var isNewUser: Bool
    @State private var userSaved = false
    
    @Query(sort: \Role.roleName) var roles: [Role]
    
    // Initialize state from user
    init(user: User, path: Binding<[AppNavigationDestination]>) {
        self._user = Bindable(wrappedValue: user)
        self._path = path
        self._isNewUser = State(initialValue: user.firstName == Constants.EMPTY_STRING && user.lastName == Constants.EMPTY_STRING)
    }
    
    //  Populate role from passed in User
    func populateInitialSelectedRoleValue()
    {
        if let userRole = user.roles.first?.roleName, !userRole.isEmpty {
            selectedRole = userRole
        } else {
            // Set default role if none exists
            selectedRole = RoleNamesEnum.allCases.first?.title ?? Constants.EMPTY_STRING
        }
    }
    
    //  Check whether to enable/disable Save button
    func validateFields() -> Bool
    {
        if  user.firstName == Constants.EMPTY_STRING ||
            user.lastName == Constants.EMPTY_STRING
        {
            return false
        }

        return true
    }
    
    //  Clean up if needed - delete unsaved new users
    func validateUser()
    {
        // If this is a new user that wasn't saved, delete it
        if isNewUser && !userSaved {
            modelContext.delete(user)
            try? modelContext.save()
        }
    }
    
    //  Set the role and last updated date values when saving changes
    func saveUser()
    {
        // Clear existing roles first to avoid duplicates
        user.roles.removeAll()
        
        // Find and set the selected role
        if let role = roles.first(where: { $0.roleName == selectedRole }) {
            user.roles.append(role)
        }
        
        user.lastUpdated = Date()
        
        // Insert user if it's new (not already in context)
        if isNewUser {
            modelContext.insert(user)
        }
        
        try? modelContext.save()
        
        // Mark as saved so validateUser doesn't delete it
        userSaved = true
    }
    
    var body: some View
    {
        NavigationView
        {
            VStack(spacing: 15)
            {
                FloatingPromptTextField(text: $user.firstName, prompt: Text("First Name:")
                .foregroundStyle(colorScheme == .dark ? .gray : .blue).fontWeight(.bold))
                .floatingPromptScale(1.0)
                .background(colorScheme == .dark ? .gray.opacity(0.2) : .gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.leading, 15)
                
                FloatingPromptTextField(text: $user.lastName, prompt: Text("Last Name:")
                .foregroundStyle(colorScheme == .dark ? .gray : .blue).fontWeight(.bold))
                .floatingPromptScale(1.0)
                .background(colorScheme == .dark ? .gray.opacity(0.2) : .gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.leading, 15)
                
                HStack
                {
                    Text("Role:")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.leading, 15)
                    
                    Spacer()
                    
                    Picker(Constants.EMPTY_STRING, selection: $selectedRole)
                    {
                        ForEach(RoleNamesEnum.allCases)
                        {
                            role in
                            
                            Text(role.title).tag(role.title)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.trailing, 15)
                }
                
                Button("Save User")
                {
                    saveUser()
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
            }
            .navigationBarItems(trailing: Button("Cancel")
            {
                dismiss()
            })
            .padding(.horizontal)
            .onAppear(perform: populateInitialSelectedRoleValue)
            .onDisappear(perform: validateUser)
            .navigationTitle(validateFields() ? "Edit User" : "Add User").navigationBarTitleDisplayMode(.inline)
        }
}
