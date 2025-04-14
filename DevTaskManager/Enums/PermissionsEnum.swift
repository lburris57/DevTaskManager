//
//  PermissionsEnum.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation

enum PermissionsEnum: String, Identifiable, CaseIterable, Hashable
{
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
    
    static var allValues: [PermissionsEnum]
    {
        [.addUser, .deleteUser, .addTask, .completeTask, .deleteTask, .taskAssignment, .createDefect, .closeDefect, .createReport, .useCases, .admin]
    }

    var id: String
    {
        rawValue
    }
}
