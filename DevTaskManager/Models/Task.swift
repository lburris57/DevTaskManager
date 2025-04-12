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
    var assignedUser: User?
    var isComplete: Bool = false
    var createdBy: User?
    var dateCreated: Date = Date()
    var lastUpdated: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \TaskItem.parentTask)
    var taskItems: [TaskItem] = []
    
    init(taskId: String = UUID().uuidString, taskName: String, assignedUser: User? = nil, isComplete: Bool, taskItems: [TaskItem])
    {
        self.taskId = taskId
        self.taskName = taskName
        self.assignedUser = assignedUser
        self.isComplete = isComplete
        self.taskItems = taskItems
    }
}
