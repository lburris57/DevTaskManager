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
}
