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
    var taskItemComment: String?
    var dateCompleted: Date?
    var createdBy: User?
    var dateCreated: Date = Date()
    var lastUpdated: Date?

    init(parentTask: Task? = nil, taskDescription: String, taskPriority: Int, taskItemComment: String? = nil, dateCompleted: Date? = nil, createdBy: User? = nil, dateCreated: Date, lastUpdated: Date? = nil)
    {
        self.parentTask = parentTask
        self.taskDescription = taskDescription
        self.taskPriority = taskPriority
        self.taskItemComment = taskItemComment
        self.dateCompleted = dateCompleted
        self.createdBy = createdBy
        self.dateCreated = dateCreated
        self.lastUpdated = lastUpdated
    }
}
