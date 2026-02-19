//
//  AppNavigationDestination.swift
//  DevTaskManager
//
//  Created by Assistant on 2/19/26.
//
import Foundation

// Navigation destination enum to support different view types
enum AppNavigationDestination: Hashable {
    case projectTasks(Project)
    case projectDetail(Project)
    case taskDetail(Task)
    
    // Implement Hashable using the model IDs
    func hash(into hasher: inout Hasher) {
        switch self {
        case .projectTasks(let project):
            hasher.combine("projectTasks")
            hasher.combine(project.projectId)
        case .projectDetail(let project):
            hasher.combine("projectDetail")
            hasher.combine(project.projectId)
        case .taskDetail(let task):
            hasher.combine("taskDetail")
            hasher.combine(task.taskId)
        }
    }
    
    static func == (lhs: AppNavigationDestination, rhs: AppNavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.projectTasks(let lhsProject), .projectTasks(let rhsProject)):
            return lhsProject.projectId == rhsProject.projectId
        case (.projectDetail(let lhsProject), .projectDetail(let rhsProject)):
            return lhsProject.projectId == rhsProject.projectId
        case (.taskDetail(let lhsTask), .taskDetail(let rhsTask)):
            return lhsTask.taskId == rhsTask.taskId
        default:
            return false
        }
    }
}
