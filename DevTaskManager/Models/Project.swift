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
    var dateCreated: Date = Date()
    var lastUpdated: Date?
    var users: [User] = []

    @Relationship(deleteRule: .cascade, inverse: \Task.project)
    var tasks: [Task] = []

    init(projectId: String = UUID().uuidString, title: String = "", descriptionText: String = "", dateCreated: Date = Date(), lastUpdated: Date? = nil, users: [User] = [], tasks: [Task] = [])
    {
        self.projectId = projectId
        self.title = title
        self.descriptionText = descriptionText
        self.dateCreated = dateCreated

        // If lastUpdated is not provided, set it to dateCreated for new projects
        self.lastUpdated = lastUpdated ?? dateCreated
        self.users = users
        self.tasks = tasks
    }

    static func loadSampleProject() -> Project
    {
        return Project(title: "Sample Project", descriptionText: "This is a sample project.")
    }
}
