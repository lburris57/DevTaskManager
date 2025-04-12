//
//  User.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation
import SwiftData

@Model
class User
{
    @Attribute(.unique) var userId = UUID().uuidString
    var firstName: String
    var lastName: String
    var role: Role
    var createdBy: User?
    var dateCreated: Date = Date()
    var lastUpdated: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \Task.assignedUser)
    var tasks: [Task] = []
    
    init(userId: String, firstName: String, lastName: String, role: Role, tasks: [Task])
    {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.tasks = tasks
    }
}
    

