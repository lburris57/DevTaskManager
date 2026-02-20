//
//  AppNavigationDestination.swift
//  DevTaskManager
//
//  Created by Assistant on 2/19/26.
//
import Foundation

// Task detail source context
enum TaskDetailSourceContext: Hashable {
    case taskList
    case userTasksList
    case projectTasksList
}

// Navigation destination enum to support different view types
enum AppNavigationDestination: Hashable {
    case projectTasks(Project)
    case projectDetail(Project)
    case taskDetail(Task, context: TaskDetailSourceContext)
    case userTasks(User)
    case userDetail(User)
    
    // Implement Hashable using the model IDs
    func hash(into hasher: inout Hasher) {
        switch self {
        case .projectTasks(let project):
            hasher.combine("projectTasks")
            hasher.combine(project.projectId)
        case .projectDetail(let project):
            hasher.combine("projectDetail")
            hasher.combine(project.projectId)
        case .taskDetail(let task, let context):
            hasher.combine("taskDetail")
            hasher.combine(task.taskId)
            hasher.combine(context)
        case .userTasks(let user):
            hasher.combine("userTasks")
            hasher.combine(user.userId)
        case .userDetail(let user):
            hasher.combine("userDetail")
            hasher.combine(user.userId)
        }
    }
    
    static func == (lhs: AppNavigationDestination, rhs: AppNavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.projectTasks(let lhsProject), .projectTasks(let rhsProject)):
            return lhsProject.projectId == rhsProject.projectId
        case (.projectDetail(let lhsProject), .projectDetail(let rhsProject)):
            return lhsProject.projectId == rhsProject.projectId
        case (.taskDetail(let lhsTask, let lhsContext), .taskDetail(let rhsTask, let rhsContext)):
            return lhsTask.taskId == rhsTask.taskId && lhsContext == rhsContext
        case (.userTasks(let lhsUser), .userTasks(let rhsUser)):
            return lhsUser.userId == rhsUser.userId
        case (.userDetail(let lhsUser), .userDetail(let rhsUser)):
            return lhsUser.userId == rhsUser.userId
        default:
            return false
        }
    }
}
