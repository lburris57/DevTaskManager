//
//  Project.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation
import SwiftData

@Model
final class Project
{
    var projectId: String = UUID().uuidString
    var title: String = Constants.EMPTY_STRING
    var descriptionText: String = Constants.EMPTY_STRING
    var createdBy: User?
    var dateCreated: Date = Date()
    var lastUpdated: Date?
    var users: [User] = []
    var tasks: [Task] = []

    init(projectId: String, title: String, descriptionText: String, createdBy: User? = nil, dateCreated: Date, lastUpdated: Date? = nil, users: [User] = [], tasks: [Task] = [])
    {
        self.projectId = projectId
        self.title = title
        self.descriptionText = descriptionText
        self.createdBy = createdBy
        self.dateCreated = dateCreated
        self.lastUpdated = lastUpdated
        self.users = users
        self.tasks = tasks
    }
}
