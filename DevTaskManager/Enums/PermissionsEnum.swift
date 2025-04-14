//
//  PermissionsEnum.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation

/*
 
 USAGE:
 
 @Bindable var role: Role
 
 var body: some View
 {
    ...
 
    VStack(alignment: .leading, spacing: 5)
     {
         Text("Role:").font(.body).foregroundStyle(colorScheme == .dark ? .gray : .blue)
     
         Picker(Constants.EMPTY_STRING, selection: $role.permissions)
         {
             ForEach(PermissionsEnum.allCases)
             {
                 permission in
                 
                 Text(permission.title).tag(permission.title)
             }
         }
         .pickerStyle(.menu)
         .labelsHidden()
     }
 }
 
 */

enum PermissionsEnum: String, Identifiable, CaseIterable, Hashable
{
    var id: UUID
    {
        return UUID()
    }
    
    case all = "All"
    case addUser = "Add User"
    case deleteUser = "Delete User"
    case addTask = "Add Task"
    case completeTask = "Complete Task"
    case deleteTask = "Delete Task"
    case taskAssignment = "Task Assignment"
    case createDefect = "Create Defect"
    case closeDefect = "Close Defect"
    case createReport = "Create Report"
    case useCases = "User Cases"
    case admin = "Admin"
}

extension PermissionsEnum
{
    var title: String
    {
        switch self
        {
            case .all:
                return "All"
            case .addUser:
                return "Add User"
            case .deleteUser:
                return "Delete User"
            case .addTask:
                return "Add Task"
            case .completeTask:
                return "Complete Task"
            case .deleteTask:
                return "Delete Task"
            case .taskAssignment:
                return "Task Assignment"
            case .createDefect:
                return "Create Defect"
            case .closeDefect:
                return "Close Defect"
            case .createReport:
                return "Create Report"
            case .useCases:
                return "Use Cases"
            case .admin:
                return "Admin"
        }
    }
}
