//
//  TaskStatusEnum.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation

enum TaskStatusEnum: String, CaseIterable
{
    case unassigned = "Unassigned"
    case inProgress = "In Progress"
    case completed = "Completed"
    case deferred = "Deferred"
    
    static var allCases: [TaskStatusEnum]
    {
        [.unassigned, .inProgress, .completed, .deferred]
    }
    
    var id: String
    {
        rawValue
    }
}
