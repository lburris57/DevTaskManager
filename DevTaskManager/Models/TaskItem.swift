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
    var taskDescription: String = Constants.EMPTY_STRING
    var taskItemComment: String?
    var dateCompleted: Date?
    var dateCreated: Date = Date()
    var lastUpdated: Date?

    init(parentTask: Task? = nil, taskDescription: String, taskItemComment: String? = nil, dateCompleted: Date? = nil, dateCreated: Date, lastUpdated: Date? = nil)
    {
        self.parentTask = parentTask
        self.taskDescription = taskDescription
        self.taskItemComment = taskItemComment
        self.dateCompleted = dateCompleted
        self.dateCreated = dateCreated
        self.lastUpdated = lastUpdated
    }
}
