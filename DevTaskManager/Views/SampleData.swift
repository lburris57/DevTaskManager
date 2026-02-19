//
//  SampleData.swift
//  DevTaskManager
//
//  Created by Assistant on 2/17/26.
//
import Foundation
import SwiftData

struct SampleData
{
    /// Creates comprehensive sample data for the DevTaskManager app
    /// - Parameter modelContext: The SwiftData model context to insert data into
    static func createSampleData(in modelContext: ModelContext)
    {
        // Check if sample data already exists
        let projectDescriptor = FetchDescriptor<Project>()
        let existingProjects = (try? modelContext.fetch(projectDescriptor)) ?? []
        
        guard existingProjects.isEmpty else
        {
            Log.info("Sample data already exists, skipping creation")
            return
        }
        
        // Create Roles
        let roles = createRoles()
        for role in roles
        {
            modelContext.insert(role)
        }
        
        // Create Users
        let users = createUsers(with: roles)
        for user in users
        {
            modelContext.insert(user)
        }
        
        // Create Projects with Tasks
        let projects = createProjects(with: users)
        for project in projects
        {
            modelContext.insert(project)
        }
        
        // Save everything
        do
        {
            try modelContext.save()
            Log.info("Sample data created successfully")
        }
        catch
        {
            Log.error("Failed to save sample data: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Create Roles
    
    private static func createRoles() -> [Role]
    {
        return Role.loadRoles()
    }
    
    // MARK: - Create Users
    
    private static func createUsers(with roles: [Role]) -> [User]
    {
        let adminRole = roles.first { $0.roleName == RoleNamesEnum.admin.title }
        let developerRole = roles.first { $0.roleName == RoleNamesEnum.developer.title }
        let validatorRole = roles.first { $0.roleName == RoleNamesEnum.validator.title }
        let baRole = roles.first { $0.roleName == RoleNamesEnum.businessAnalyst.title }
        
        let user1 = User(
            firstName: "Sarah",
            lastName: "Johnson",
            roles: adminRole != nil ? [adminRole!] : [],
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 90) // 90 days ago
        )
        
        let user2 = User(
            firstName: "Michael",
            lastName: "Chen",
            roles: developerRole != nil ? [developerRole!] : [],
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 75) // 75 days ago
        )
        
        let user3 = User(
            firstName: "Emily",
            lastName: "Rodriguez",
            roles: developerRole != nil ? [developerRole!] : [],
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 60) // 60 days ago
        )
        
        let user4 = User(
            firstName: "James",
            lastName: "Williams",
            roles: validatorRole != nil ? [validatorRole!] : [],
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 50) // 50 days ago
        )
        
        let user5 = User(
            firstName: "Olivia",
            lastName: "Martinez",
            roles: baRole != nil ? [baRole!] : [],
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 40) // 40 days ago
        )
        
        return [user1, user2, user3, user4, user5]
    }
    
    // MARK: - Create Projects
    
    private static func createProjects(with users: [User]) -> [Project]
    {
        var projects: [Project] = []
        
        // Project 1: E-Commerce Platform
        let project1 = Project(
            title: "E-Commerce Platform",
            descriptionText: "A comprehensive online shopping platform with cart functionality, payment processing, and order tracking.",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 45), // 45 days ago
            lastUpdated: Date().addingTimeInterval(-60 * 60 * 24 * 2)  // 2 days ago
        )
        
        project1.users = Array(users.prefix(3))
        project1.tasks = createTasksForECommerce(users: users)
        projects.append(project1)
        
        // Project 2: Mobile Banking App
        let project2 = Project(
            title: "Mobile Banking App",
            descriptionText: "Secure mobile banking application with account management, transfers, and bill payment features.",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 30), // 30 days ago
            lastUpdated: Date().addingTimeInterval(-60 * 60 * 24 * 1)  // 1 day ago
        )
        
        project2.users = Array(users.suffix(3))
        project2.tasks = createTasksForBanking(users: users)
        projects.append(project2)
        
        // Project 3: Task Management System
        let project3 = Project(
            title: "Task Management System",
            descriptionText: "Collaborative task management tool with Kanban boards, time tracking, and team collaboration features.",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 20), // 20 days ago
            lastUpdated: Date().addingTimeInterval(-60 * 60 * 3)        // 3 hours ago
        )
        
        project3.users = users
        project3.tasks = createTasksForTaskManager(users: users)
        projects.append(project3)
        
        // Project 4: Social Media Dashboard
        let project4 = Project(
            title: "Social Media Dashboard",
            descriptionText: "Analytics dashboard for managing multiple social media accounts with scheduling and engagement tracking.",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 15), // 15 days ago
            lastUpdated: Date().addingTimeInterval(-60 * 60 * 24 * 5)  // 5 days ago
        )
        
        project4.users = [users[0], users[2], users[4]]
        project4.tasks = createTasksForSocialMedia(users: users)
        projects.append(project4)
        
        // Project 5: Healthcare Portal (just started)
        let project5 = Project(
            title: "Healthcare Portal",
            descriptionText: "Patient portal for appointment scheduling, medical records access, and telehealth consultations.",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 5), // 5 days ago
            lastUpdated: Date().addingTimeInterval(-60 * 60 * 2)       // 2 hours ago
        )
        
        project5.users = [users[1], users[3]]
        project5.tasks = createTasksForHealthcare(users: users)
        projects.append(project5)
        
        // Project 6: Fitness Tracker App (empty project for testing)
        let project6 = Project(
            title: "Fitness Tracker App",
            descriptionText: "Track workouts, nutrition, and fitness goals with AI-powered recommendations.",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 2), // 2 days ago
            lastUpdated: nil
        )
        
        project6.users = []
        project6.tasks = []
        projects.append(project6)
        
        return projects
    }
    
    // MARK: - Create Tasks for E-Commerce
    
    private static func createTasksForECommerce(users: [User]) -> [Task]
    {
        let task1 = Task(
            taskName: "Implement Shopping Cart",
            taskType: TaskTypeEnum.development.title,
            assignedUser: users.count > 1 ? users[1] : nil,
            taskStatus: TaskStatusEnum.inProgress.title,
            taskPriority: TaskPriorityEnum.high.title,
            taskComment: "Add to cart functionality with session persistence",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 10),
            dateAssigned: Date().addingTimeInterval(-60 * 60 * 24 * 9)
        )
        
        let task2 = Task(
            taskName: "Payment Gateway Integration",
            taskType: TaskTypeEnum.development.title,
            assignedUser: users.count > 1 ? users[1] : nil,
            taskStatus: TaskStatusEnum.completed.title,
            taskPriority: TaskPriorityEnum.high.title,
            taskComment: "Integrated Stripe and PayPal",
            dateCompleted: Date().addingTimeInterval(-60 * 60 * 24 * 5),
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 15),
            dateAssigned: Date().addingTimeInterval(-60 * 60 * 24 * 14)
        )
        
        let task3 = Task(
            taskName: "Product Search Optimization",
            taskType: TaskTypeEnum.development.title,
            taskStatus: TaskStatusEnum.unassigned.title,
            taskPriority: TaskPriorityEnum.medium.title,
            taskComment: "Implement full-text search with filters",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 8)
        )
        
        let task4 = Task(
            taskName: "Test Checkout Flow",
            taskType: TaskTypeEnum.testing.title,
            assignedUser: users.count > 3 ? users[3] : nil,
            taskStatus: TaskStatusEnum.inProgress.title,
            taskPriority: TaskPriorityEnum.high.title,
            taskComment: "End-to-end testing of payment process",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 4),
            dateAssigned: Date().addingTimeInterval(-60 * 60 * 24 * 3)
        )
        
        let task5 = Task(
            taskName: "Design Product Detail Page",
            taskType: TaskTypeEnum.design.title,
            taskStatus: TaskStatusEnum.completed.title,
            taskPriority: TaskPriorityEnum.medium.title,
            taskComment: "Mockups completed and approved",
            dateCompleted: Date().addingTimeInterval(-60 * 60 * 24 * 12),
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 20),
            dateAssigned: Date().addingTimeInterval(-60 * 60 * 24 * 19)
        )
        
        return [task1, task2, task3, task4, task5]
    }
    
    // MARK: - Create Tasks for Banking
    
    private static func createTasksForBanking(users: [User]) -> [Task]
    {
        let task1 = Task(
            taskName: "Implement Biometric Authentication",
            taskType: TaskTypeEnum.development.title,
            assignedUser: users.count > 2 ? users[2] : nil,
            taskStatus: TaskStatusEnum.inProgress.title,
            taskPriority: TaskPriorityEnum.high.title,
            taskComment: "Face ID and Touch ID support",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 7),
            dateAssigned: Date().addingTimeInterval(-60 * 60 * 24 * 6)
        )
        
        let task2 = Task(
            taskName: "Account Balance Dashboard",
            taskType: TaskTypeEnum.development.title,
            assignedUser: users.count > 1 ? users[1] : nil,
            taskStatus: TaskStatusEnum.completed.title,
            taskPriority: TaskPriorityEnum.high.title,
            taskComment: "Real-time balance updates implemented",
            dateCompleted: Date().addingTimeInterval(-60 * 60 * 24 * 3),
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 12),
            dateAssigned: Date().addingTimeInterval(-60 * 60 * 24 * 11)
        )
        
        let task3 = Task(
            taskName: "Security Audit Documentation",
            taskType: TaskTypeEnum.documentation.title,
            assignedUser: users.count > 4 ? users[4] : nil,
            taskStatus: TaskStatusEnum.inProgress.title,
            taskPriority: TaskPriorityEnum.high.title,
            taskComment: "Documenting security protocols",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 5),
            dateAssigned: Date().addingTimeInterval(-60 * 60 * 24 * 4)
        )
        
        return [task1, task2, task3]
    }
    
    // MARK: - Create Tasks for Task Manager
    
    private static func createTasksForTaskManager(users: [User]) -> [Task]
    {
        let task1 = Task(
            taskName: "Drag-and-Drop Kanban Board",
            taskType: TaskTypeEnum.development.title,
            assignedUser: users.count > 2 ? users[2] : nil,
            taskStatus: TaskStatusEnum.inProgress.title,
            taskPriority: TaskPriorityEnum.high.title,
            taskComment: "Implementing drag and drop functionality",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 6),
            dateAssigned: Date().addingTimeInterval(-60 * 60 * 24 * 5)
        )
        
        let task2 = Task(
            taskName: "Real-time Collaboration",
            taskType: TaskTypeEnum.development.title,
            taskStatus: TaskStatusEnum.unassigned.title,
            taskPriority: TaskPriorityEnum.medium.title,
            taskComment: "WebSocket implementation needed",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 4)
        )
        
        let task3 = Task(
            taskName: "Time Tracking Widget",
            taskType: TaskTypeEnum.development.title,
            assignedUser: users.count > 1 ? users[1] : nil,
            taskStatus: TaskStatusEnum.completed.title,
            taskPriority: TaskPriorityEnum.low.title,
            taskComment: "Widget completed with start/stop timer",
            dateCompleted: Date().addingTimeInterval(-60 * 60 * 24 * 2),
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 10),
            dateAssigned: Date().addingTimeInterval(-60 * 60 * 24 * 9)
        )
        
        let task4 = Task(
            taskName: "Test Multi-user Permissions",
            taskType: TaskTypeEnum.testing.title,
            assignedUser: users.count > 3 ? users[3] : nil,
            taskStatus: TaskStatusEnum.inProgress.title,
            taskPriority: TaskPriorityEnum.medium.title,
            taskComment: "Testing role-based access control",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 3),
            dateAssigned: Date().addingTimeInterval(-60 * 60 * 24 * 2)
        )
        
        let task5 = Task(
            taskName: "UI/UX Design System",
            taskType: TaskTypeEnum.design.title,
            taskStatus: TaskStatusEnum.completed.title,
            taskPriority: TaskPriorityEnum.high.title,
            taskComment: "Design system documented and shared",
            dateCompleted: Date().addingTimeInterval(-60 * 60 * 24 * 8),
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 15),
            dateAssigned: Date().addingTimeInterval(-60 * 60 * 24 * 14)
        )
        
        let task6 = Task(
            taskName: "API Documentation",
            taskType: TaskTypeEnum.documentation.title,
            assignedUser: users.count > 4 ? users[4] : nil,
            taskStatus: TaskStatusEnum.inProgress.title,
            taskPriority: TaskPriorityEnum.medium.title,
            taskComment: "Writing comprehensive API docs",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 1),
            dateAssigned: Date().addingTimeInterval(-60 * 60 * 12)
        )
        
        return [task1, task2, task3, task4, task5, task6]
    }
    
    // MARK: - Create Tasks for Social Media
    
    private static func createTasksForSocialMedia(users: [User]) -> [Task]
    {
        let task1 = Task(
            taskName: "Post Scheduling System",
            taskType: TaskTypeEnum.development.title,
            assignedUser: users.count > 2 ? users[2] : nil,
            taskStatus: TaskStatusEnum.completed.title,
            taskPriority: TaskPriorityEnum.high.title,
            taskComment: "Schedule posts across platforms",
            dateCompleted: Date().addingTimeInterval(-60 * 60 * 24 * 6),
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 10),
            dateAssigned: Date().addingTimeInterval(-60 * 60 * 24 * 9)
        )
        
        let task2 = Task(
            taskName: "Analytics Dashboard",
            taskType: TaskTypeEnum.development.title,
            assignedUser: users.count > 1 ? users[1] : nil,
            taskStatus: TaskStatusEnum.inProgress.title,
            taskPriority: TaskPriorityEnum.high.title,
            taskComment: "Charts and metrics for engagement",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 5),
            dateAssigned: Date().addingTimeInterval(-60 * 60 * 24 * 4)
        )
        
        let task3 = Task(
            taskName: "Content Calendar Design",
            taskType: TaskTypeEnum.design.title,
            taskStatus: TaskStatusEnum.unassigned.title,
            taskPriority: TaskPriorityEnum.medium.title,
            taskComment: "Monthly view calendar mockup",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 3)
        )
        
        let task4 = Task(
            taskName: "Integration Testing",
            taskType: TaskTypeEnum.testing.title,
            taskStatus: TaskStatusEnum.unassigned.title,
            taskPriority: TaskPriorityEnum.low.title,
            taskComment: "Test API connections",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 1)
        )
        
        return [task1, task2, task3, task4]
    }
    
    // MARK: - Create Tasks for Healthcare
    
    private static func createTasksForHealthcare(users: [User]) -> [Task]
    {
        let task1 = Task(
            taskName: "Patient Authentication System",
            taskType: TaskTypeEnum.development.title,
            assignedUser: users.count > 1 ? users[1] : nil,
            taskStatus: TaskStatusEnum.inProgress.title,
            taskPriority: TaskPriorityEnum.high.title,
            taskComment: "HIPAA-compliant authentication",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 3),
            dateAssigned: Date().addingTimeInterval(-60 * 60 * 24 * 2)
        )
        
        let task2 = Task(
            taskName: "Appointment Scheduling UI",
            taskType: TaskTypeEnum.design.title,
            taskStatus: TaskStatusEnum.unassigned.title,
            taskPriority: TaskPriorityEnum.high.title,
            taskComment: "Calendar-based appointment booking",
            dateCreated: Date().addingTimeInterval(-60 * 60 * 24 * 2)
        )
        
        return [task1, task2]
    }
}
