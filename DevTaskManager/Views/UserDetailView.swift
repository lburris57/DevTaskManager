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
    @Binding var path: NavigationPath
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedRole = Constants.EMPTY_STRING
    
    @Query(sort: \Role.roleName) var roles: [Role]
    
    //  Populate role from passed in User
    func populateInitialSelectedRoleValue()
    {
        selectedRole = user.roles.first?.roleName ?? Constants.EMPTY_STRING
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
    
    //  Delete the skeleton user from the database if not edited
    func validateUser()
    {
        if  user.firstName == Constants.EMPTY_STRING ||
            user.lastName == Constants.EMPTY_STRING
        {
            withAnimation
            {
                modelContext.delete(user)
                try? modelContext.save()
            }
        }
    }
    
    //  Set the role and last updated date values when saving changes
    func saveUser()
    {
        let role = roles.first(where: { $0.roleName == selectedRole }) ?? roles[0]
        
        user.roles.append(role)
        user.lastUpdated = Date()
        
        modelContext.insert(user)
        try? modelContext.save()
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
                
                VStack(alignment: .leading, spacing: 5)
                {
                    HStack
                    {
                        FloatingPromptTextField(text: $selectedRole, prompt: Text("Role:")
                            .foregroundStyle(colorScheme == .dark ? .gray : .blue).fontWeight(.bold))
                        .floatingPromptScale(1.0)
                        .background(colorScheme == .dark ? .gray.opacity(0.2) : .gray.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.leading, 15)
                        
                        Picker(Constants.EMPTY_STRING, selection: $selectedRole)
                        {
                            ForEach(RoleNamesEnum.allCases)
                            {
                                role in
                                
                                Text(role.title).tag(role.title)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
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
