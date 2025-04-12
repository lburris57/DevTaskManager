//
//  RoleNamesEnum.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation

enum RoleNamesEnum: String, CaseIterable
{
    case admin = "Administrator"
    case developer = "Developer"
    case businessAnalyst = "Business Analyst"
    case validator = "Validator"
    
    static var allValues: [RoleNamesEnum]
    {
        [.admin, .developer, .businessAnalyst, .validator]
    }
    
    var id: String
    {
        rawValue
    }
}
