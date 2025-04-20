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
    var taskName: String = Constants.EMPTY_STRING
    var taskType: String = Constants.EMPTY_STRING
    var assignedUser: User?
    var taskStatus: String = "Unassigned"
    var taskPriority: String = Constants.EMPTY_STRING
    var taskComment: String?
    var dateCompleted: Date?
    var dateCreated: Date = Date()
    var dateAssigned: Date?
    var lastUpdated: Date?

    @Relationship(deleteRule: .cascade, inverse: \TaskItem.parentTask)
    var taskItems: [TaskItem] = []

    init(taskId: String = UUID().uuidString, taskName: String, taskType: String, assignedUser: User? = nil, taskStatus: String, taskPriority: String, taskComment: String? = nil, dateCompleted: Date? = nil, dateCreated: Date, dateAssigned: Date? = nil, lastUpdated: Date? = nil, taskItems: [TaskItem])
    {
        self.taskId = taskId
        self.taskName = taskName
        self.taskType = taskType
        self.assignedUser = assignedUser
        self.taskStatus = taskStatus
        self.taskPriority = taskPriority
        self.taskComment = taskComment
        self.dateCompleted = dateCompleted
        self.dateCreated = dateCreated
        self.dateAssigned = dateAssigned
        self.lastUpdated = lastUpdated
        self.taskItems = taskItems
    }
    
    static func loadTasks() -> [Task]
    {
        let task1 = Task(taskName: "Task1", taskType: TaskTypeEnum.development.title, taskStatus: TaskStatusEnum.unassigned.title, taskPriority: TaskPriorityEnum.low.title, dateCreated: Date(), taskItems: [])
        
        let task2 = Task(taskName: "Task2", taskType: TaskTypeEnum.testing.title, taskStatus: TaskStatusEnum.unassigned.title, taskPriority: TaskPriorityEnum.medium.title, dateCreated: Date(), taskItems: [])
        
        let task3 = Task(taskName: "Task3", taskType: TaskTypeEnum.design.title, taskStatus: TaskStatusEnum.unassigned.title, taskPriority: TaskPriorityEnum.high.title, dateCreated: Date(), taskItems: [])
        
        let task4 = Task(taskName: "Task4", taskType: TaskTypeEnum.documentation.title, taskStatus: TaskStatusEnum.unassigned.title, taskPriority: TaskPriorityEnum.high.title, dateCreated: Date(), taskItems: [])
        
        return [task1, task2, task3, task4]
    }
}
