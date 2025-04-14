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
    var firstName: String = Constants.EMPTY_STRING
    var lastName: String = Constants.EMPTY_STRING
    var roles: [Role] = []
    var createdBy: User?
    var dateCreated: Date = Date()
    var lastUpdated: Date?

    @Relationship(deleteRule: .cascade, inverse: \Task.assignedUser)
    var tasks: [Task] = []

    init(userId: String = UUID().uuidString, firstName: String, lastName: String, roles: [Role] = [], createdBy: User? = nil, dateCreated: Date = Date(), lastUpdated: Date? = nil, tasks: [Task] = [])
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
    
    func fullName() -> String
    {
        return "\(firstName) \(lastName)"
    }
    
    static func loadUsers() -> [User]
    {
        let user1 = User(userId: "1", firstName: "Larry", lastName: "Burris")
        let user2 = User(userId: "2", firstName: "John", lastName: "Doe")
        let user3 = User(userId: "3", firstName: "Jane", lastName: "Doe")
        let user4 = User(userId: "4", firstName: "Michael", lastName: "Scott")
        
        return [user1, user2, user3, user4]
    }
}
