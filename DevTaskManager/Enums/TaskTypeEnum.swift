//
//  TaskTypeEnum.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation

enum TaskTypeEnum: String, Identifiable, CaseIterable, Hashable
{
    case development = "Development"
    case requirements = "Requirements"
    case design = "Design"
    case useCases = "Use Cases"
    case testing = "Testing"
    case documentation = "Documentation"
    case database = "Database"
    case defectCorrection = "Defect Correction"
    
    static var allCases: [TaskTypeEnum]
    {
        [.development, .requirements, .design, .useCases, .testing, .documentation, .database, .defectCorrection]
    }
    
    var id: String
    {
        rawValue
    }
}
