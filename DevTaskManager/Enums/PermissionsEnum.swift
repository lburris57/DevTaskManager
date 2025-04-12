//
//  PermissionsEnum.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation

enum PermissionsEnum: String, CaseIterable
{
    case addUser = "Add User"
    case deleteUser = "Delete User"
    case addTask = "Add Task"
    case deleteTask = "Delete Task"
    case taskAssignment = "Task Assignment"
    case createReport = "Create Report"

    var id: String
    {
        rawValue
    }
}
