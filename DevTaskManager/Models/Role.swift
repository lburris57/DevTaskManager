//
//  Role.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation
import SwiftData

@Model
class Role
{
    @Attribute(.unique) var roleName: String = Constants.EMPTY_STRING
    var permisssions: [String] = []
    var createdBy: User?
    var dateCreated: Date = Date()
    var lastUpdated: Date?
    
    init(roleName: String, permisssions: [String])
    {
        self.roleName = roleName
        self.permisssions = permisssions
    }
    
    static func loadRoles() -> [Role]
    {
        let role1 = Role(roleName: RoleNamesEnum.admin.id, permisssions: [PermissionsEnum.admin.id])
        let role2 = Role(roleName: RoleNamesEnum.businessAnalyst.id, permisssions: [PermissionsEnum.useCases.id, PermissionsEnum.createReport.id])
        let role3 = Role(roleName: RoleNamesEnum.developer.id, permisssions: [PermissionsEnum.addTask.id, PermissionsEnum.completeTask.id])
        let role4 = Role(roleName: RoleNamesEnum.validator.id, permisssions: [PermissionsEnum.createDefect.id, PermissionsEnum.closeDefect.id, PermissionsEnum.createReport.id])
        
        return [role1, role2, role3, role4]
    }
}
