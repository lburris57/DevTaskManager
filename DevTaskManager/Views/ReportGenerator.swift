//
//  ReportGenerator.swift
//  DevTaskManager
//
//  Created by Assistant on 2/20/26.
//
import Foundation
import SwiftData

/// Data structure for report generation
struct ReportData
{
    let generatedDate: Date
    
    // Project Statistics
    let totalProjects: Int
    let projectsList: [ProjectSummary]
    
    // User Statistics
    let totalUsers: Int
    let usersList: [UserSummary]
    
    // Task Statistics
    let totalTasks: Int
    let completedTasks: Int
    let inProgressTasks: Int
    let unassignedTasks: Int
    let deferredTasks: Int
    let tasksByType: [String: Int]
    let tasksByPriority: [String: Int]
    let tasksList: [TaskSummary]
    
    // Computed properties
    var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedTasks) / Double(totalTasks) * 100
    }
    
    var tasksPerProject: Double {
        guard totalProjects > 0 else { return 0 }
        return Double(totalTasks) / Double(totalProjects)
    }
    
    var tasksPerUser: Double {
        guard totalUsers > 0 else { return 0 }
        return Double(totalTasks) / Double(totalUsers)
    }
}

struct ProjectSummary: Identifiable
{
    let id: String
    let title: String
    let description: String
    let dateCreated: Date
    let taskCount: Int
    let completedTaskCount: Int
    
    var completionRate: Double {
        guard taskCount > 0 else { return 0 }
        return Double(completedTaskCount) / Double(taskCount) * 100
    }
}

struct UserSummary: Identifiable
{
    let id: String
    let name: String
    let roleName: String
    let dateCreated: Date
    let assignedTaskCount: Int
    let completedTaskCount: Int
}

struct TaskSummary: Identifiable
{
    let id: String
    let name: String
    let type: String
    let status: String
    let priority: String
    let projectName: String?
    let assignedUserName: String?
    let dateCreated: Date
    let dateCompleted: Date?
}

/// Report generator that queries the database and creates report data
class ReportGenerator
{
    static func generateReport(context: ModelContext, startDate: Date? = nil, endDate: Date? = nil) throws -> ReportData
    {
        // Fetch all data
        var projectDescriptor = FetchDescriptor<Project>()
        var userDescriptor = FetchDescriptor<User>()
        var taskDescriptor = FetchDescriptor<Task>()
        
        // Apply date filter to tasks if provided
        if let start = startDate, let end = endDate {
            taskDescriptor.predicate = #Predicate<Task> { task in
                task.dateCreated >= start && task.dateCreated <= end
            }
        } else if let start = startDate {
            taskDescriptor.predicate = #Predicate<Task> { task in
                task.dateCreated >= start
            }
        } else if let end = endDate {
            taskDescriptor.predicate = #Predicate<Task> { task in
                task.dateCreated <= end
            }
        }
        
        let projects = try context.fetch(projectDescriptor)
        let users = try context.fetch(userDescriptor)
        let tasks = try context.fetch(taskDescriptor)
        
        // Generate project summaries (filter tasks by date range)
        let projectSummaries = projects.map { project in
            let filteredTasks = project.tasks.filter { task in
                if let start = startDate, let end = endDate {
                    return task.dateCreated >= start && task.dateCreated <= end
                } else if let start = startDate {
                    return task.dateCreated >= start
                } else if let end = endDate {
                    return task.dateCreated <= end
                }
                return true
            }
            let completedTasks = filteredTasks.filter { $0.taskStatus.lowercased() == "completed" }.count
            return ProjectSummary(
                id: project.projectId,
                title: project.title.isEmpty ? "Untitled Project" : project.title,
                description: project.descriptionText,
                dateCreated: project.dateCreated,
                taskCount: filteredTasks.count,
                completedTaskCount: completedTasks
            )
        }
        
        // Generate user summaries (filter tasks by date range)
        let userSummaries = users.map { user in
            let filteredTasks = user.tasks.filter { task in
                if let start = startDate, let end = endDate {
                    return task.dateCreated >= start && task.dateCreated <= end
                } else if let start = startDate {
                    return task.dateCreated >= start
                } else if let end = endDate {
                    return task.dateCreated <= end
                }
                return true
            }
            let completedTasks = filteredTasks.filter { $0.taskStatus.lowercased() == "completed" }.count
            return UserSummary(
                id: user.userId,
                name: user.fullName(),
                roleName: user.roles.first?.roleName ?? "No Role",
                dateCreated: user.dateCreated,
                assignedTaskCount: filteredTasks.count,
                completedTaskCount: completedTasks
            )
        }
        
        // Generate task summaries
        let taskSummaries = tasks.map { task in
            TaskSummary(
                id: task.taskId,
                name: task.taskName.isEmpty ? "Untitled Task" : task.taskName,
                type: task.taskType,
                status: task.taskStatus,
                priority: task.taskPriority,
                projectName: task.project?.title.isEmpty == true ? "Untitled Project" : task.project?.title,
                assignedUserName: task.assignedUser?.fullName(),
                dateCreated: task.dateCreated,
                dateCompleted: task.dateCompleted
            )
        }
        
        // Calculate task statistics
        let completedTasks = tasks.filter { $0.taskStatus.lowercased() == "completed" }.count
        let inProgressTasks = tasks.filter { $0.taskStatus.lowercased() == "in progress" }.count
        let unassignedTasks = tasks.filter { $0.taskStatus.lowercased() == "unassigned" }.count
        let deferredTasks = tasks.filter { $0.taskStatus.lowercased() == "deferred" }.count
        
        // Group tasks by type
        var tasksByType: [String: Int] = [:]
        for task in tasks {
            tasksByType[task.taskType, default: 0] += 1
        }
        
        // Group tasks by priority
        var tasksByPriority: [String: Int] = [:]
        for task in tasks {
            tasksByPriority[task.taskPriority, default: 0] += 1
        }
        
        return ReportData(
            generatedDate: Date(),
            totalProjects: projects.count,
            projectsList: projectSummaries,
            totalUsers: users.count,
            usersList: userSummaries,
            totalTasks: tasks.count,
            completedTasks: completedTasks,
            inProgressTasks: inProgressTasks,
            unassignedTasks: unassignedTasks,
            deferredTasks: deferredTasks,
            tasksByType: tasksByType,
            tasksByPriority: tasksByPriority,
            tasksList: taskSummaries
        )
    }
}
// MARK: - Extended Report Types (for detailed reporting)

struct DevTaskManagerReport
{
    let generatedDate: Date
    let projectsSummary: ProjectsSummary
    let usersSummary: UsersSummary
    let tasksSummary: TasksSummary
    let detailedProjects: [ProjectReport]
    let detailedUsers: [UserReport]
    let detailedTasks: [TaskReport]
}

struct ProjectsSummary
{
    let totalProjects: Int
    let projectsWithTasks: Int
    let projectsWithoutTasks: Int
    let totalTasksAcrossProjects: Int
    let averageTasksPerProject: Double
    let oldestProject: Date?
    let newestProject: Date?
}

struct UsersSummary
{
    let totalUsers: Int
    let usersWithTasks: Int
    let usersWithoutTasks: Int
    let totalTasksAssigned: Int
    let averageTasksPerUser: Double
    let mostActiveUser: String?
    let mostActiveUserTaskCount: Int
}

struct TasksSummary
{
    let totalTasks: Int
    let unassignedTasks: Int
    let inProgressTasks: Int
    let completedTasks: Int
    let deferredTasks: Int
    let tasksByType: [String: Int]
    let tasksByPriority: [String: Int]
    let oldestTask: Date?
    let newestTask: Date?
    let completedThisWeek: Int
    let completedThisMonth: Int
}

struct ProjectReport: Identifiable
{
    let id: String
    let title: String
    let description: String
    let dateCreated: Date
    let lastUpdated: Date?
    let taskCount: Int
    let completedTaskCount: Int
    let inProgressTaskCount: Int
    let unassignedTaskCount: Int
    let userCount: Int
}

struct UserReport: Identifiable
{
    let id: String
    let name: String
    let roles: [String]
    let dateCreated: Date
    let totalTasksAssigned: Int
    let completedTasks: Int
    let inProgressTasks: Int
    let unassignedTasks: Int
}

struct TaskReport: Identifiable
{
    let id: String
    let name: String
    let projectName: String
    let assignedUserName: String?
    let taskType: String
    let taskStatus: String
    let taskPriority: String
    let dateCreated: Date
    let dateAssigned: Date?
    let dateCompleted: Date?
}

// MARK: - Extended Report Generator Methods

extension ReportGenerator
{
    static func generateDetailedReport(context: ModelContext) throws -> DevTaskManagerReport
    {
        let projects = try fetchProjects(context: context)
        let users = try fetchUsers(context: context)
        let tasks = try fetchTasks(context: context)
        
        return DevTaskManagerReport(
            generatedDate: Date(),
            projectsSummary: generateProjectsSummary(projects: projects),
            usersSummary: generateUsersSummary(users: users),
            tasksSummary: generateTasksSummary(tasks: tasks),
            detailedProjects: generateProjectReports(projects: projects),
            detailedUsers: generateUserReports(users: users),
            detailedTasks: generateTaskReports(tasks: tasks)
        )
    }
    
    private static func fetchProjects(context: ModelContext) throws -> [Project]
    {
        let descriptor = FetchDescriptor<Project>(sortBy: [SortDescriptor(\.title)])
        return try context.fetch(descriptor)
    }
    
    private static func fetchUsers(context: ModelContext) throws -> [User]
    {
        let descriptor = FetchDescriptor<User>(sortBy: [SortDescriptor(\.lastName)])
        return try context.fetch(descriptor)
    }
    
    private static func fetchTasks(context: ModelContext) throws -> [Task]
    {
        let descriptor = FetchDescriptor<Task>(sortBy: [SortDescriptor(\.dateCreated)])
        return try context.fetch(descriptor)
    }
    
    private static func generateProjectsSummary(projects: [Project]) -> ProjectsSummary
    {
        let projectsWithTasks = projects.filter { !$0.tasks.isEmpty }
        let totalTasks = projects.reduce(0) { $0 + $1.tasks.count }
        let averageTasks = projects.isEmpty ? 0.0 : Double(totalTasks) / Double(projects.count)
        
        return ProjectsSummary(
            totalProjects: projects.count,
            projectsWithTasks: projectsWithTasks.count,
            projectsWithoutTasks: projects.count - projectsWithTasks.count,
            totalTasksAcrossProjects: totalTasks,
            averageTasksPerProject: averageTasks,
            oldestProject: projects.map(\.dateCreated).min(),
            newestProject: projects.map(\.dateCreated).max()
        )
    }
    
    private static func generateUsersSummary(users: [User]) -> UsersSummary
    {
        let usersWithTasks = users.filter { !$0.tasks.isEmpty }
        let totalTasks = users.reduce(0) { $0 + $1.tasks.count }
        let averageTasks = users.isEmpty ? 0.0 : Double(totalTasks) / Double(users.count)
        
        let mostActive = users.max { $0.tasks.count < $1.tasks.count }
        
        return UsersSummary(
            totalUsers: users.count,
            usersWithTasks: usersWithTasks.count,
            usersWithoutTasks: users.count - usersWithTasks.count,
            totalTasksAssigned: totalTasks,
            averageTasksPerUser: averageTasks,
            mostActiveUser: mostActive?.fullName(),
            mostActiveUserTaskCount: mostActive?.tasks.count ?? 0
        )
    }
    
    private static func generateTasksSummary(tasks: [Task]) -> TasksSummary
    {
        let unassigned = tasks.filter { $0.taskStatus.lowercased() == "unassigned" }.count
        let inProgress = tasks.filter { $0.taskStatus.lowercased() == "in progress" }.count
        let completed = tasks.filter { $0.taskStatus.lowercased() == "completed" }.count
        let deferred = tasks.filter { $0.taskStatus.lowercased() == "deferred" }.count
        
        var typeDict: [String: Int] = [:]
        for task in tasks {
            typeDict[task.taskType, default: 0] += 1
        }
        
        var priorityDict: [String: Int] = [:]
        for task in tasks {
            priorityDict[task.taskPriority, default: 0] += 1
        }
        
        let now = Date()
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
        let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
        
        let completedThisWeek = tasks.filter {
            $0.taskStatus.lowercased() == "completed" &&
            ($0.dateCompleted ?? .distantPast) >= weekAgo
        }.count
        
        let completedThisMonth = tasks.filter {
            $0.taskStatus.lowercased() == "completed" &&
            ($0.dateCompleted ?? .distantPast) >= monthAgo
        }.count
        
        return TasksSummary(
            totalTasks: tasks.count,
            unassignedTasks: unassigned,
            inProgressTasks: inProgress,
            completedTasks: completed,
            deferredTasks: deferred,
            tasksByType: typeDict,
            tasksByPriority: priorityDict,
            oldestTask: tasks.map(\.dateCreated).min(),
            newestTask: tasks.map(\.dateCreated).max(),
            completedThisWeek: completedThisWeek,
            completedThisMonth: completedThisMonth
        )
    }
    
    private static func generateProjectReports(projects: [Project]) -> [ProjectReport]
    {
        projects.map { project in
            let tasks = project.tasks
            let completed = tasks.filter { $0.taskStatus.lowercased() == "completed" }.count
            let inProgress = tasks.filter { $0.taskStatus.lowercased() == "in progress" }.count
            let unassigned = tasks.filter { $0.taskStatus.lowercased() == "unassigned" }.count
            
            return ProjectReport(
                id: project.projectId,
                title: project.title.isEmpty ? "Untitled Project" : project.title,
                description: project.descriptionText,
                dateCreated: project.dateCreated,
                lastUpdated: project.lastUpdated,
                taskCount: tasks.count,
                completedTaskCount: completed,
                inProgressTaskCount: inProgress,
                unassignedTaskCount: unassigned,
                userCount: project.users.count
            )
        }
    }
    
    private static func generateUserReports(users: [User]) -> [UserReport]
    {
        users.map { user in
            let tasks = user.tasks
            let completed = tasks.filter { $0.taskStatus.lowercased() == "completed" }.count
            let inProgress = tasks.filter { $0.taskStatus.lowercased() == "in progress" }.count
            let unassigned = tasks.filter { $0.taskStatus.lowercased() == "unassigned" }.count
            
            return UserReport(
                id: user.userId,
                name: user.fullName(),
                roles: user.roles.map { $0.roleName },
                dateCreated: user.dateCreated,
                totalTasksAssigned: tasks.count,
                completedTasks: completed,
                inProgressTasks: inProgress,
                unassignedTasks: unassigned
            )
        }
    }
    
    private static func generateTaskReports(tasks: [Task]) -> [TaskReport]
    {
        tasks.map { task in
            TaskReport(
                id: task.taskId,
                name: task.taskName.isEmpty ? "Untitled Task" : task.taskName,
                projectName: task.project?.title ?? "No Project",
                assignedUserName: task.assignedUser?.fullName(),
                taskType: task.taskType,
                taskStatus: task.taskStatus,
                taskPriority: task.taskPriority,
                dateCreated: task.dateCreated,
                dateAssigned: task.dateAssigned,
                dateCompleted: task.dateCompleted
            )
        }
    }
    
    static func generateTextReport(report: DevTaskManagerReport) -> String
    {
        var text = """
        ═══════════════════════════════════════════════════════════
        DEV TASK MANAGER - COMPREHENSIVE REPORT
        ═══════════════════════════════════════════════════════════
        Generated: \(report.generatedDate.formatted(date: .long, time: .shortened))
        
        
        """
        
        text += """
        ───────────────────────────────────────────────────────────
        PROJECTS SUMMARY
        ───────────────────────────────────────────────────────────
        Total Projects: \(report.projectsSummary.totalProjects)
        Projects with Tasks: \(report.projectsSummary.projectsWithTasks)
        Projects without Tasks: \(report.projectsSummary.projectsWithoutTasks)
        Total Tasks Across All Projects: \(report.projectsSummary.totalTasksAcrossProjects)
        Average Tasks per Project: \(String(format: "%.1f", report.projectsSummary.averageTasksPerProject))
        
        
        """
        
        text += """
        ───────────────────────────────────────────────────────────
        USERS SUMMARY
        ───────────────────────────────────────────────────────────
        Total Users: \(report.usersSummary.totalUsers)
        Users with Tasks: \(report.usersSummary.usersWithTasks)
        Users without Tasks: \(report.usersSummary.usersWithoutTasks)
        Total Tasks Assigned: \(report.usersSummary.totalTasksAssigned)
        Average Tasks per User: \(String(format: "%.1f", report.usersSummary.averageTasksPerUser))
        Most Active User: \(report.usersSummary.mostActiveUser ?? "N/A") (\(report.usersSummary.mostActiveUserTaskCount) tasks)
        
        
        """
        
        text += """
        ───────────────────────────────────────────────────────────
        TASKS SUMMARY
        ───────────────────────────────────────────────────────────
        Total Tasks: \(report.tasksSummary.totalTasks)
        
        By Status:
          • Unassigned: \(report.tasksSummary.unassignedTasks)
          • In Progress: \(report.tasksSummary.inProgressTasks)
          • Completed: \(report.tasksSummary.completedTasks)
          • Deferred: \(report.tasksSummary.deferredTasks)
        
        Completed This Week: \(report.tasksSummary.completedThisWeek)
        Completed This Month: \(report.tasksSummary.completedThisMonth)
        
        By Type:
        """
        
        for (type, count) in report.tasksSummary.tasksByType.sorted(by: { $0.key < $1.key }) {
            text += "\n  • \(type): \(count)"
        }
        
        text += "\n\nBy Priority:\n"
        for (priority, count) in report.tasksSummary.tasksByPriority.sorted(by: { $0.key < $1.key }) {
            text += "  • \(priority): \(count)\n"
        }
        
        text += """
        
        
        ═══════════════════════════════════════════════════════════
        DETAILED PROJECT REPORTS
        ═══════════════════════════════════════════════════════════
        
        """
        
        for project in report.detailedProjects {
            text += """
            Project: \(project.title)
            Description: \(project.description.isEmpty ? "No description" : project.description)
            Created: \(project.dateCreated.formatted(date: .abbreviated, time: .omitted))
            Tasks: \(project.taskCount) (✓ \(project.completedTaskCount) | ⏳ \(project.inProgressTaskCount) | ○ \(project.unassignedTaskCount))
            
            
            """
        }
        
        text += """
        ═══════════════════════════════════════════════════════════
        DETAILED USER REPORTS
        ═══════════════════════════════════════════════════════════
        
        """
        
        for user in report.detailedUsers {
            text += """
            User: \(user.name)
            Roles: \(user.roles.joined(separator: ", "))
            Created: \(user.dateCreated.formatted(date: .abbreviated, time: .omitted))
            Tasks: \(user.totalTasksAssigned) (✓ \(user.completedTasks) | ⏳ \(user.inProgressTasks) | ○ \(user.unassignedTasks))
            
            
            """
        }
        
        text += """
        ═══════════════════════════════════════════════════════════
        DETAILED TASK REPORTS
        ═══════════════════════════════════════════════════════════
        
        """
        
        for task in report.detailedTasks {
            text += """
            Task: \(task.name)
            Project: \(task.projectName)
            Assigned To: \(task.assignedUserName ?? "Unassigned")
            Type: \(task.taskType) | Priority: \(task.taskPriority) | Status: \(task.taskStatus)
            Created: \(task.dateCreated.formatted(date: .abbreviated, time: .omitted))
            
            
            """
        }
        
        text += """
        ═══════════════════════════════════════════════════════════
        END OF REPORT
        ═══════════════════════════════════════════════════════════
        """
        
        return text
    }
    
    static func generateCSVReport(report: DevTaskManagerReport) -> String
    {
        var csv = "DevTaskManager Report - Generated \(report.generatedDate.formatted())\n\n"
        
        csv += "PROJECTS\n"
        csv += "Title,Description,Date Created,Last Updated,Total Tasks,Completed,In Progress,Unassigned\n"
        for project in report.detailedProjects {
            csv += "\"\(project.title)\",\"\(project.description)\",\(project.dateCreated.formatted(date: .abbreviated, time: .omitted)),\(project.lastUpdated?.formatted(date: .abbreviated, time: .omitted) ?? "N/A"),\(project.taskCount),\(project.completedTaskCount),\(project.inProgressTaskCount),\(project.unassignedTaskCount)\n"
        }
        
        csv += "\nUSERS\n"
        csv += "Name,Roles,Date Created,Total Tasks,Completed,In Progress,Unassigned\n"
        for user in report.detailedUsers {
            csv += "\"\(user.name)\",\"\(user.roles.joined(separator: "; "))\",\(user.dateCreated.formatted(date: .abbreviated, time: .omitted)),\(user.totalTasksAssigned),\(user.completedTasks),\(user.inProgressTasks),\(user.unassignedTasks)\n"
        }
        
        csv += "\nTASKS\n"
        csv += "Name,Project,Assigned To,Type,Status,Priority,Date Created,Date Assigned,Date Completed\n"
        for task in report.detailedTasks {
            csv += "\"\(task.name)\",\"\(task.projectName)\",\"\(task.assignedUserName ?? "Unassigned")\",\(task.taskType),\(task.taskStatus),\(task.taskPriority),\(task.dateCreated.formatted(date: .abbreviated, time: .omitted)),\(task.dateAssigned?.formatted(date: .abbreviated, time: .omitted) ?? "N/A"),\(task.dateCompleted?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")\n"
        }
        
        return csv
    }
}

