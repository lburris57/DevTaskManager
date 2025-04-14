//
//  TaskPriorityEnum.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation

enum TaskPriorityEnum: String, Identifiable, CaseIterable, Hashable
{
    var id: UUID
    {
        return UUID()
    }
    
    case all = "All"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case enhancement = "Enhancement"
}

extension TaskPriorityEnum
{
    var title: String
    {
        switch self
        {
            case .all:
                return "All"
            case .low:
                return "Low"
            case .medium:
                return "Medium"
            case .high:
                return "High"
            case .enhancement:
                return "Enhancement"
        }
    }
}
