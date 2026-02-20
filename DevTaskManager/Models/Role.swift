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
    var permissions: [String] = []
    var dateCreated: Date = Date()
    var lastUpdated: Date?
    
    init(roleName: String, permissions: [String])
    {
        self.roleName = roleName
        self.permissions = permissions
        self.lastUpdated = Date()
    }
    
    static func loadRoles() -> [Role]
    {
        let role1 = Role(roleName: RoleNamesEnum.admin.title, permissions: [PermissionsEnum.admin.title])
        let role2 = Role(roleName: RoleNamesEnum.businessAnalyst.title, permissions: [PermissionsEnum.useCases.title, PermissionsEnum.createReport.title])
        let role3 = Role(roleName: RoleNamesEnum.developer.title, permissions: [PermissionsEnum.addTask.title, PermissionsEnum.completeTask.title, PermissionsEnum.createDefect.title, PermissionsEnum.closeDefect.title])
        let role4 = Role(roleName: RoleNamesEnum.validator.title, permissions: [PermissionsEnum.createDefect.title, PermissionsEnum.closeDefect.title, PermissionsEnum.createReport.title])
        
        return [role1, role2, role3, role4]
    }
}
