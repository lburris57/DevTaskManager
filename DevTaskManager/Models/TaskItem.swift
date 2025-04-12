//
//  TaskItem.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation
import SwiftData

@Model
class TaskItem
{
    var parentTask: Task?
    var taskDescription: String
    var taskPriority: Int
    var taskStatus: String
    var TaskType: String
    var dateAssigned: Date = Date()
    var dateCompleted: Date?
    var createdBy: User?
    var dateCreated: Date = Date()
    var lastUpdated: Date?
    
    init(parentTask: Task? = nil, taskDescription: String, taskPriority: Int, taskStatus: String, TaskType: String, dateAssigned: Date, dateCompleted: Date? = nil)
    {
        self.parentTask = parentTask
        self.taskDescription = taskDescription
        self.taskPriority = taskPriority
        self.taskStatus = taskStatus
        self.TaskType = TaskType
        self.dateAssigned = dateAssigned
        self.dateCompleted = dateCompleted
    }
    
}
