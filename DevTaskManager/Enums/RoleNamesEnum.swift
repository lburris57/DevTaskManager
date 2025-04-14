//
//  RoleNamesEnum.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation

enum RoleNamesEnum: String, Identifiable, CaseIterable, Hashable
{
    var id: UUID
    {
        return UUID()
    }
    
    case all = "All"
    case admin = "Administrator"
    case developer = "Developer"
    case businessAnalyst = "Business Analyst"
    case validator = "Validator"
}

extension RoleNamesEnum
{
    var title: String
    {
        switch self
        {
            case .all:
                return "All"
            case .admin:
                return "Administrator"
            case .developer:
                return "Developer"
            case .businessAnalyst:
                return "Business Analyst"
            case .validator:
                return "Validator"
        }
    }
}
    
