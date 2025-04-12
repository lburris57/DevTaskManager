//
//  Task.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation
import SwiftData

@Model
class Task
{
    @Attribute(.unique) var taskId = UUID().uuidString
    var taskName: String
    var taskType: String
    var assignedUser: User?
    var taskStatus: String = "Unassigned"
    var taskComment: String?
    var dateCompleted: Date?
    var createdBy: User?
    var dateCreated: Date = Date()
    var dateAssigned: Date?
    var lastUpdated: Date?

    @Relationship(deleteRule: .cascade, inverse: \TaskItem.parentTask)
    var taskItems: [TaskItem] = []

    init(taskId: String = UUID().uuidString, taskName: String, taskType: String, assignedUser: User? = nil, taskStatus: String, taskComment: String? = nil, dateCompleted: Date? = nil, createdBy: User? = nil, dateCreated: Date, dateAssigned: Date? = nil, lastUpdated: Date? = nil, taskItems: [TaskItem])
    {
        self.taskId = taskId
        self.taskName = taskName
        self.taskType = taskType
        self.assignedUser = assignedUser
        self.taskStatus = taskStatus
        self.taskComment = taskComment
        self.dateCompleted = dateCompleted
        self.createdBy = createdBy
        self.dateCreated = dateCreated
        self.dateAssigned = dateAssigned
        self.lastUpdated = lastUpdated
        self.taskItems = taskItems
    }
}
