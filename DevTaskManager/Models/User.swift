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
    var roles: [Role]
    var createdBy: User?
    var dateCreated: Date = Date()
    var lastUpdated: Date?

    @Relationship(deleteRule: .cascade, inverse: \Task.assignedUser)
    var tasks: [Task] = []

    init(userId: String = UUID().uuidString, firstName: String, lastName: String, roles: [Role], createdBy: User? = nil, dateCreated: Date, lastUpdated: Date? = nil, tasks: [Task])
    {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.roles = roles
        self.createdBy = createdBy
        self.dateCreated = dateCreated
        self.lastUpdated = lastUpdated
        self.tasks = tasks
    }
}
