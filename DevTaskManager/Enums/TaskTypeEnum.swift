//
//  TaskTypeEnum.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation

enum TaskTypeEnum: String, Identifiable, CaseIterable, Hashable
{
    var id: UUID
    {
        return UUID()
    }
    
    case all = "All"
    case development = "Development"
    case requirements = "Requirements"
    case design = "Design"
    case useCases = "Use Cases"
    case testing = "Testing"
    case documentation = "Documentation"
    case database = "Database"
    case defectCorrection = "Defect Correction"
}

extension TaskTypeEnum
{
    var title: String
    {
        switch self
        {
            case .all:
                return "All"
            case .development:
                return "Devlopment"
            case .requirements:
                return "Requirements"
            case .design:
                return "Design"
            case .useCases:
                return "Use Cases"
            case .testing:
                return "Testing"
            case .documentation:
                return "Documentation"
            case .database:
                return "Database"
            case .defectCorrection:
                return "Defense Correction"
        }
    }
}
