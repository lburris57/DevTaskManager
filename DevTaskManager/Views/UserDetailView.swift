//
//  UserDetailView.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/19/25.
//
import SwiftData
import SwiftUI

struct UserDetailView: View
{
    //  This is the user sent from the list view
    @Bindable var user: User

    //  This is the navigation path sent from the list view
    @Binding var path: [AppNavigationDestination]
    
    // Optional binding for macOS NavigationSplitView detail column
    var detailSelection: Binding<AppNavigationDestination?>?

    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var selectedRole = Constants.EMPTY_STRING
    @State private var isNewUser: Bool
    @State private var userSaved = false

    @Query(sort: \Role.roleName) var roles: [Role]

    // Initialize state from user
    init(user: User, path: Binding<[AppNavigationDestination]>, detailSelection: Binding<AppNavigationDestination?>? = nil)
    {
        _user = Bindable(wrappedValue: user)
        _path = path
        self.detailSelection = detailSelection
        _isNewUser = State(initialValue: user.firstName == Constants.EMPTY_STRING && user.lastName == Constants.EMPTY_STRING)
        
        // Initialize selectedRole immediately to avoid picker warnings
        let initialRole: String
        if let userRole = user.roles.first?.roleName, !userRole.isEmpty, userRole != RoleNamesEnum.all.title
        {
            initialRole = userRole
        }
        else
        {
            // Set default role to first valid option (excluding "All")
            initialRole = RoleNamesEnum.allCases.first(where: { $0 != .all })?.title ?? Constants.EMPTY_STRING
        }
        _selectedRole = State(initialValue: initialRole)
    }



    //  Check whether to enable/disable Save button
    func validateFields() -> Bool
    {
        if user.firstName == Constants.EMPTY_STRING ||
            user.lastName == Constants.EMPTY_STRING
        {
            return false
        }

        return true
    }

    //  Clean up if needed - delete unsaved new users
    func validateUser()
    {
        // If this is a new user that was never saved, we need to ensure it's not in the context
        // This handles the case where user cancels or navigates away without saving
        if isNewUser && !userSaved
        {
            // Check if user is in the model context and remove it
            if modelContext.model(for: user.id) != nil
            {
                modelContext.delete(user)
                try? modelContext.save()
            }
        }
    }

    //  Set the role and last updated date values when saving changes
    func saveUser()
    {
        print("💾 ========== SAVING USER ==========")
        print("   Name: \(user.fullName())")
        print("   Selected Role: \(selectedRole)")

        // Clear existing roles
        user.roles.removeAll()

        // Create a new Role instance for this user (not shared)
        let newRole = Role(roleName: selectedRole, permissions: [])
        user.roles.append(newRole)

        print("   ✅ Assigned role: \(selectedRole)")

        user.lastUpdated = Date()

        // Insert user if it's new (not already in context)
        if isNewUser
        {
            modelContext.insert(user)
            print("   📝 Inserted new user")
        }

        do
        {
            try modelContext.save()
            print("   ✅ Context saved successfully")
        }
        catch
        {
            print("   ❌ Error saving context: \(error)")
        }

        // Mark as saved so validateUser doesn't delete it
        userSaved = true

        dismiss()
    }

    var body: some View
    {
        ZStack
        {
            // Solid background to prevent content showing through
            Color.systemBackground
                .ignoresSafeArea()

            // Modern gradient background overlay
            AppGradients.mainBackground
                .ignoresSafeArea()

            VStack(spacing: 0)
            {
                // Modern header
                ModernHeaderView(
                    icon: "person.fill",
                    title: isNewUser ? "New User" : "Edit User",
                    subtitle: user.tasks.isEmpty ? "No tasks assigned" : "\(user.tasks.count) task\(user.tasks.count == 1 ? "" : "s") assigned",
                    gradientColors: [.purple, .pink]
                )

                ScrollView
                {
                    VStack(spacing: 16)
                    {
                        // First Name Card
                        ModernFormCard
                        {
                            VStack(alignment: .leading, spacing: 12)
                            {
                                Text("First Name")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                TextField("Enter first name", text: $user.firstName)
                                    .textFieldStyle(.plain)
                                    .font(.body)
                            }
                        }

                        // Last Name Card
                        ModernFormCard
                        {
                            VStack(alignment: .leading, spacing: 12)
                            {
                                Text("Last Name")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                TextField("Enter last name", text: $user.lastName)
                                    .textFieldStyle(.plain)
                                    .font(.body)
                            }
                        }

                        // Role Card
                        ModernFormCard
                        {
                            HStack
                            {
                                Text("Role")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)

                                Spacer()

                                Picker("Select Role", selection: $selectedRole)
                                {
                                    ForEach(RoleNamesEnum.allCases.filter { $0 != .all })
                                    {
                                        role in
                                        Text(role.title).tag(role.title)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.purple)
                            }
                        }

                        // Save Button
                        Button(action: {
                            saveUser()
                        })
                        {
                            Text("Save User")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            validateFields() ?
                                                LinearGradient(
                                                    colors: [.purple, .pink],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ) :
                                                LinearGradient(
                                                    colors: [.gray.opacity(0.5), .gray.opacity(0.5)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                        )
                                        .shadow(color: validateFields() ? .purple.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
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
            ToolbarItem(placement: .navigation)
            {
                Button(action: {
                    validateUser() // Clean up unsaved users before navigating back
                    #if os(macOS)
                    // On macOS with NavigationSplitView, clear the detail selection
                    if let detailSelection = detailSelection {
                        detailSelection.wrappedValue = nil
                    } else {
                        dismiss()
                    }
                    #else
                    dismiss()
                    #endif
                })
                {
                    HStack(spacing: 4)
                    {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                        Text("Back")
                            .font(.body)
                    }
                    .foregroundStyle(AppGradients.userGradient)
                }
            }

            ToolbarItem(placement: .primaryAction)
            {
                Button("Cancel")
                {
                    validateUser() // Clean up unsaved users before dismissing
                    #if os(macOS)
                    // On macOS with NavigationSplitView, clear the detail selection
                    if let detailSelection = detailSelection {
                        detailSelection.wrappedValue = nil
                    } else {
                        dismiss()
                    }
                    #else
                    dismiss()
                    #endif
                }
                .foregroundStyle(AppGradients.userGradient)
            }
        }
        #if os(iOS)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        #endif
        .onDisappear(perform: validateUser)
    }
}
