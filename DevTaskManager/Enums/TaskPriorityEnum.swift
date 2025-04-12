//
//  TaskPriorityEnum.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation

enum TaskPriorityEnum: String, Identifiable, CaseIterable, Hashable
{
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case enhancement = "Enhancement"
    
    static var allCases: [TaskPriorityEnum]
    {
        [.low, .medium, .high, .enhancement]
    }
    
    var id: String
    {
        rawValue
    }
}
