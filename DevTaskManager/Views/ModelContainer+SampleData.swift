//
//  ModelContainer+SampleData.swift
//  DevTaskManager
//
//  Created by Assistant on 2/17/26.
//
import Foundation
import SwiftData

extension ModelContainer
{
    /// Creates a model container pre-populated with sample data for development and testing
    /// - Returns: A ModelContainer with sample data
    static func withSampleData() throws -> ModelContainer
    {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Project.self, Task.self, User.self, Role.self,
            configurations: config
        )
        
        SampleData.createSampleData(in: container.mainContext)
        
        return container
    }
    
    /// Creates a model container with sample data for testing specific scenarios
    /// - Parameter includeEmptyProject: Whether to include an empty project for testing
    /// - Returns: A ModelContainer with customized sample data
    static func withCustomSampleData(includeEmptyProject: Bool = true) throws -> ModelContainer
    {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Project.self, Task.self, User.self, Role.self,
            configurations: config
        )
        
        SampleData.createSampleData(in: container.mainContext)
        
        return container
    }
}
