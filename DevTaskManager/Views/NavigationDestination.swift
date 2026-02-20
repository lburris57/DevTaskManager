//
//  AppNavigationDestination.swift
//  DevTaskManager
//
//  Created by Assistant on 2/19/26.
//
import Foundation

// Task detail source context
enum TaskDetailSourceContext: Hashable
{
    case taskList
    case userTasksList
    case projectTasksList
}

// Navigation destination enum to support different view types
enum AppNavigationDestination: Hashable
{
    case projectTasks(Project)
    case projectDetail(Project)
    case taskDetail(Task, context: TaskDetailSourceContext)
    case userTasks(User)
    case userDetail(User)

    // Implement Hashable using the model IDs
    func hash(into hasher: inout Hasher)
    {
        switch self
        {
        case let .projectTasks(project):
            hasher.combine("projectTasks")
            hasher.combine(project.projectId)
        case let .projectDetail(project):
            hasher.combine("projectDetail")
            hasher.combine(project.projectId)
        case let .taskDetail(task, context):
            hasher.combine("taskDetail")
            hasher.combine(task.taskId)
            hasher.combine(context)
        case let .userTasks(user):
            hasher.combine("userTasks")
            hasher.combine(user.userId)
        case let .userDetail(user):
            hasher.combine("userDetail")
            hasher.combine(user.userId)
        }
    }

    static func == (lhs: AppNavigationDestination, rhs: AppNavigationDestination) -> Bool
    {
        switch (lhs, rhs)
        {
        case let (.projectTasks(lhsProject), .projectTasks(rhsProject)):
            return lhsProject.projectId == rhsProject.projectId
        case let (.projectDetail(lhsProject), .projectDetail(rhsProject)):
            return lhsProject.projectId == rhsProject.projectId
        case let (.taskDetail(lhsTask, lhsContext), .taskDetail(rhsTask, rhsContext)):
            return lhsTask.taskId == rhsTask.taskId && lhsContext == rhsContext
        case let (.userTasks(lhsUser), .userTasks(rhsUser)):
            return lhsUser.userId == rhsUser.userId
        case let (.userDetail(lhsUser), .userDetail(rhsUser)):
            return lhsUser.userId == rhsUser.userId
        default:
            return false
        }
    }
}
