//
//  TaskStatusEnum.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation

enum TaskStatusEnum: String, Identifiable, CaseIterable, Hashable
{
    var id: UUID
    {
        return UUID()
    }
    
    case all = "All"
    case unassigned = "Unassigned"
    case inProgress = "In Progress"
    case completed = "Completed"
    case deferred = "Deferred"
}

extension TaskStatusEnum
{
    var title: String
    {
        switch self
        {
            case .all:
                return "All"
            case .unassigned:
                return "Unassigned"
            case .inProgress:
                return "In Progress"
            case .completed:
                return "Completed"
            case .deferred:
                return "Deferred"
        }
    }
}
