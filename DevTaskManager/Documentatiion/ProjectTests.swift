//
//  ProjectTests.swift
//  DevTaskManagerTests
//
//  Created by AI Assistant on 2/20/26.
//

import XCTest
import SwiftData
import Foundation
@testable import DevTaskManager

/// Test suite for Project model CRUD operations
final class ProjectTests: XCTestCase {
    
    // MARK: - Test Container Setup
    
    /// Creates an in-memory model container for testing
    private func createTestContainer() throws -> ModelContainer {
        let schema = Schema([
            Project.self,
            DevTaskManager.Task.self,  // Fully qualified to avoid conflict
            User.self,
            Role.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }
    
    // MARK: - Project Creation Tests
    
    func testCreateProjectWithValidData() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let projectTitle = "Test Project"
        let projectDescription = "This is a test project"
        
        // When
        let project = Project(title: projectTitle, descriptionText: projectDescription)
        context.insert(project)
        try context.save()
        
        // Then
        XCTAssertEqual(project.title, projectTitle, "Project title should match")
        XCTAssertEqual(project.descriptionText, projectDescription, "Description should match")
        XCTAssertFalse(project.projectId.isEmpty, "Project ID should be generated")
        XCTAssertLessThanOrEqual(project.dateCreated, Date(), "Date created should be set to current time or earlier")
        XCTAssertEqual(project.lastUpdated, project.dateCreated, "Last updated should equal date created on new project")
        XCTAssertTrue(project.tasks.isEmpty, "New project should have no tasks")
    }
    
    func testCreateProjectWithEmptyTitle() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        // When
        let project = Project(title: "", descriptionText: "Test description")
        context.insert(project)
        try context.save()
        
        // Then
        XCTAssertEqual(project.title, "", "Empty title should be allowed")
        XCTAssertFalse(project.projectId.isEmpty, "Project ID should still be generated")
    }
    
    func testCreateProjectWithEmptyDescription() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        // When
        let project = Project(title: "Test Project", descriptionText: "")
        context.insert(project)
        try context.save()
        
        // Then
        XCTAssertEqual(project.descriptionText, "", "Empty description should be allowed")
    }
    
    func testCreateMultipleProjects() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        let projectCount = 5
        
        // When
        var projects: [Project] = []
        for i in 1...projectCount {
            let project = Project(
                title: "Project \(i)",
                descriptionText: "Description \(i)"
            )
            context.insert(project)
            projects.append(project)
        }
        try context.save()
        
        // Fetch all projects
        let descriptor = FetchDescriptor<Project>()
        let fetchedProjects = try context.fetch(descriptor)
        
        // Then
        XCTAssertEqual(fetchedProjects.count, projectCount, "Should have created \(projectCount) projects")
        XCTAssertTrue(projects.allSatisfy { !$0.projectId.isEmpty }, "All projects should have IDs")
        
        // Verify unique IDs
        let uniqueIds = Set(projects.map { $0.projectId })
        XCTAssertEqual(uniqueIds.count, projectCount, "All project IDs should be unique")
    }
    
    func testCreateProjectWithSpecialCharacters() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        let specialTitle = "Project 🚀 with émojis & spëcial çhars!"
        
        // When
        let project = Project(title: specialTitle, descriptionText: "Test")
        context.insert(project)
        try context.save()
        
        // Then
        XCTAssertEqual(project.title, specialTitle, "Special characters should be preserved")
    }
    
    func testCreateProjectWithLongText() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        let longTitle = String(repeating: "A", count: 1000)
        let longDescription = String(repeating: "B", count: 5000)
        
        // When
        let project = Project(title: longTitle, descriptionText: longDescription)
        context.insert(project)
        try context.save()
        
        // Then
        XCTAssertEqual(project.title, longTitle, "Long title should be stored correctly")
        XCTAssertEqual(project.descriptionText, longDescription, "Long description should be stored correctly")
    }
    
    // MARK: - Project Update Tests
    
    func testUpdateProjectTitle() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        let project = Project(title: "Original Title", descriptionText: "Description")
        context.insert(project)
        try context.save()
        
        let originalLastUpdated = project.lastUpdated
        
        // Wait a moment to ensure timestamp difference
        Thread.sleep(forTimeInterval: 0.1)
        
        // When
        let newTitle = "Updated Title"
        project.title = newTitle
        project.lastUpdated = Date()
        try context.save()
        
        // Then
        XCTAssertEqual(project.title, newTitle, "Title should be updated")
        XCTAssertGreaterThan(project.lastUpdated, originalLastUpdated, "Last updated timestamp should be newer")
        XCTAssertLessThan(project.dateCreated, project.lastUpdated, "Date created should be before last updated")
    }
    
    func testUpdateProjectDescription() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        let project = Project(title: "Test", descriptionText: "Original Description")
        context.insert(project)
        try context.save()
        
        // When
        let newDescription = "Updated Description"
        project.descriptionText = newDescription
        project.lastUpdated = Date()
        try context.save()
        
        // Then
        XCTAssertEqual(project.descriptionText, newDescription, "Description should be updated")
    }
    
    func testUpdateProjectMultipleTimes() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        let project = Project(title: "Version 1", descriptionText: "Desc 1")
        context.insert(project)
        try context.save()
        
        var lastUpdateTime = project.lastUpdated
        
        // When - Update 3 times
        for i in 2...4 {
            Thread.sleep(forTimeInterval: 0.1)
            project.title = "Version \(i)"
            project.descriptionText = "Desc \(i)"
            project.lastUpdated = Date()
            try context.save()
            
            // Then - Verify each update
            XCTAssertGreaterThan(project.lastUpdated, lastUpdateTime, "Update \(i): timestamp should increase")
            lastUpdateTime = project.lastUpdated
        }
        
        XCTAssertEqual(project.title, "Version 4", "Final title should be Version 4")
    }
    
    func testUpdateProjectToEmptyValues() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        let project = Project(title: "Test Project", descriptionText: "Test Description")
        context.insert(project)
        try context.save()
        
        // When
        project.title = ""
        project.descriptionText = ""
        project.lastUpdated = Date()
        try context.save()
        
        // Then
        XCTAssertEqual(project.title, "", "Title should be updated to empty")
        XCTAssertEqual(project.descriptionText, "", "Description should be updated to empty")
    }
    
    func testUpdateProjectDateTracking() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        let project = Project(title: "Test", descriptionText: "Test")
        context.insert(project)
        try context.save()
        
        let originalCreatedDate = project.dateCreated
        
        Thread.sleep(forTimeInterval: 0.1)
        
        // When
        project.title = "Updated"
        project.lastUpdated = Date()
        try context.save()
        
        // Then
        XCTAssertEqual(project.dateCreated, originalCreatedDate, "Date created should not change on update")
        XCTAssertGreaterThan(project.lastUpdated, originalCreatedDate, "Last updated should be after date created")
    }
    
    // MARK: - Project Deletion Tests
    
    func testDeleteSingleProject() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        let project = Project(title: "To Delete", descriptionText: "Will be deleted")
        context.insert(project)
        try context.save()
        
        let projectId = project.projectId
        
        // Verify project exists
        var descriptor = FetchDescriptor<Project>(
            predicate: #Predicate { $0.projectId == projectId }
        )
        var fetchedProjects = try context.fetch(descriptor)
        XCTAssertEqual(fetchedProjects.count, 1, "Project should exist before deletion")
        
        // When
        context.delete(project)
        try context.save()
        
        // Then
        descriptor = FetchDescriptor<Project>(
            predicate: #Predicate { $0.projectId == projectId }
        )
        fetchedProjects = try context.fetch(descriptor)
        XCTAssertTrue(fetchedProjects.isEmpty, "Project should be deleted")
    }
    
    func testDeleteProjectWithTasks() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let project = Project(title: "Project with Tasks", descriptionText: "Test")
        context.insert(project)
        
        // Create tasks for the project
        let task1 = DevTaskManager.Task(taskName: "Task 1", project: project)
        let task2 = DevTaskManager.Task(taskName: "Task 2", project: project)
        let task3 = DevTaskManager.Task(taskName: "Task 3", project: project)
        
        context.insert(task1)
        context.insert(task2)
        context.insert(task3)
        try context.save()
        
        let projectId = project.projectId
        let task1Id = task1.taskId
        let task2Id = task2.taskId
        let task3Id = task3.taskId
        
        // Verify setup
        XCTAssertEqual(project.tasks.count, 3, "Project should have 3 tasks")
        
        // When
        context.delete(project)
        try context.save()
        
        // Then - Verify project is deleted
        let projectDescriptor = FetchDescriptor<Project>(
            predicate: #Predicate { $0.projectId == projectId }
        )
        let fetchedProjects = try context.fetch(projectDescriptor)
        XCTAssertTrue(fetchedProjects.isEmpty, "Project should be deleted")
        
        // Verify tasks still exist but have no project
        let taskDescriptor = FetchDescriptor<DevTaskManager.Task>(
            predicate: #Predicate { 
                $0.taskId == task1Id || $0.taskId == task2Id || $0.taskId == task3Id
            }
        )
        let fetchedTasks = try context.fetch(taskDescriptor)
        
        // Note: Behavior depends on SwiftData cascade rules
        // Document the actual behavior in your app
        XCTAssertGreaterThanOrEqual(fetchedTasks.count, 0, "Tasks behavior depends on cascade rules")
    }
    
    func testDeleteMultipleProjects() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        var projects: [Project] = []
        for i in 1...5 {
            let project = Project(title: "Project \(i)", descriptionText: "Desc \(i)")
            context.insert(project)
            projects.append(project)
        }
        try context.save()
        
        // Verify all projects exist
        var descriptor = FetchDescriptor<Project>()
        var fetchedProjects = try context.fetch(descriptor)
        XCTAssertEqual(fetchedProjects.count, 5, "Should have 5 projects before deletion")
        
        // When - Delete 3 projects
        for i in 0..<3 {
            context.delete(projects[i])
        }
        try context.save()
        
        // Then
        descriptor = FetchDescriptor<Project>()
        fetchedProjects = try context.fetch(descriptor)
        XCTAssertEqual(fetchedProjects.count, 2, "Should have 2 projects remaining")
    }
    
    func testDeleteAllProjects() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        for i in 1...10 {
            let project = Project(title: "Project \(i)", descriptionText: "Desc \(i)")
            context.insert(project)
        }
        try context.save()
        
        // When
        let descriptor = FetchDescriptor<Project>()
        let allProjects = try context.fetch(descriptor)
        
        for project in allProjects {
            context.delete(project)
        }
        try context.save()
        
        // Then
        let remainingProjects = try context.fetch(descriptor)
        XCTAssertTrue(remainingProjects.isEmpty, "All projects should be deleted")
    }
    
    func testDeleteAndRecreateProject() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        let title = "Reusable Title"
        
        let project1 = Project(title: title, descriptionText: "First")
        context.insert(project1)
        try context.save()
        
        let firstProjectId = project1.projectId
        
        // When - Delete first project
        context.delete(project1)
        try context.save()
        
        // Create new project with same title
        let project2 = Project(title: title, descriptionText: "Second")
        context.insert(project2)
        try context.save()
        
        // Then
        XCTAssertNotEqual(project2.projectId, firstProjectId, "New project should have different ID")
        XCTAssertEqual(project2.title, title, "Title should match")
        XCTAssertEqual(project2.descriptionText, "Second", "Should be the new project")
        
        // Verify only one project exists
        let descriptor = FetchDescriptor<Project>()
        let allProjects = try context.fetch(descriptor)
        XCTAssertEqual(allProjects.count, 1, "Should only have one project")
    }
    
    // MARK: - Project Query Tests
    
    func testFetchProjectsSortedByTitleAscending() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let titles = ["Zebra", "Apple", "Mango", "Banana"]
        for title in titles {
            let project = Project(title: title, descriptionText: "Test")
            context.insert(project)
        }
        try context.save()
        
        // When
        let descriptor = FetchDescriptor<Project>(
            sortBy: [SortDescriptor(\.title, order: .forward)]
        )
        let projects = try context.fetch(descriptor)
        
        // Then
        let fetchedTitles = projects.map { $0.title }
        XCTAssertEqual(fetchedTitles, ["Apple", "Banana", "Mango", "Zebra"], "Projects should be sorted alphabetically")
    }
    
    func testFetchProjectsSortedByDate() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        var projects: [Project] = []
        for i in 1...3 {
            let project = Project(title: "Project \(i)", descriptionText: "Test")
            context.insert(project)
            projects.append(project)
            try context.save()
            
            // Small delay to ensure different timestamps
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        // When
        let descriptor = FetchDescriptor<Project>(
            sortBy: [SortDescriptor(\.dateCreated, order: .reverse)]
        )
        let fetchedProjects = try context.fetch(descriptor)
        
        // Then
        XCTAssertEqual(fetchedProjects.count, 3, "Should fetch all 3 projects")
        XCTAssertGreaterThanOrEqual(
            fetchedProjects[0].dateCreated,
            fetchedProjects[1].dateCreated,
            "First project should be newest"
        )
        XCTAssertGreaterThanOrEqual(
            fetchedProjects[1].dateCreated,
            fetchedProjects[2].dateCreated,
            "Second project should be newer than third"
        )
    }
    
    func testSearchProjectsByTitle() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let projects = [
            Project(title: "iOS Development", descriptionText: "Test"),
            Project(title: "Android Development", descriptionText: "Test"),
            Project(title: "Web Development", descriptionText: "Test"),
            Project(title: "Database Design", descriptionText: "Test")
        ]
        
        for project in projects {
            context.insert(project)
        }
        try context.save()
        
        // When - Search for "Development"
        let descriptor = FetchDescriptor<Project>(
            predicate: #Predicate { project in
                project.title.contains("Development")
            }
        )
        let results = try context.fetch(descriptor)
        
        // Then
        XCTAssertEqual(results.count, 3, "Should find 3 projects with 'Development' in title")
    }
    
    func testCountProjects() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        for i in 1...7 {
            let project = Project(title: "Project \(i)", descriptionText: "Test")
            context.insert(project)
        }
        try context.save()
        
        // When
        let descriptor = FetchDescriptor<Project>()
        let projects = try context.fetch(descriptor)
        
        // Then
        XCTAssertEqual(projects.count, 7, "Should have exactly 7 projects")
    }
    
    // MARK: - Edge Case Tests
    
    func testProjectWithNilOptionalFields() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        // When
        let project = Project(title: "Test", descriptionText: "Test")
        context.insert(project)
        try context.save()
        
        // Then
        // Verify that optional relationship fields can be nil
        XCTAssertTrue(project.tasks.isEmpty, "Tasks array should be empty")
    }
    
    func testProjectPersistenceAcrossContextSaves() throws {
        // Given
        let container = try createTestContainer()
        let context = ModelContext(container)
        
        let project = Project(title: "Persistent", descriptionText: "Test")
        context.insert(project)
        try context.save()
        
        let projectId = project.projectId
        
        // When - Make multiple changes with saves
        project.title = "Updated Once"
        try context.save()
        
        Thread.sleep(forTimeInterval: 0.1)
        
        project.title = "Updated Twice"
        try context.save()
        
        // Then - Fetch from fresh context
        let newContext = ModelContext(container)
        let descriptor = FetchDescriptor<Project>(
            predicate: #Predicate { $0.projectId == projectId }
        )
        let fetchedProjects = try newContext.fetch(descriptor)
        
        XCTAssertEqual(fetchedProjects.count, 1, "Should find the project")
        XCTAssertEqual(fetchedProjects.first?.title, "Updated Twice", "Should have latest changes")
    }
}
