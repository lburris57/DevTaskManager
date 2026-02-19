//
//  SampleDataPreviewModifier.swift
//  DevTaskManager
//
//  Created by Assistant on 2/17/26.
//
import SwiftUI
import SwiftData

/// A preview modifier that provides sample data for SwiftUI previews
struct SampleDataPreviewModifier: PreviewModifier {
    
    static func makeSharedContext() async throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Project.self, Task.self, User.self, Role.self,
            configurations: config
        )
        
        // Load sample data on the main actor
        await MainActor.run {
            SampleData.createSampleData(in: container.mainContext)
        }
        
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
    }
}
/// A preview modifier that provides an empty model container (no data)
struct EmptyDataPreviewModifier: PreviewModifier {
    
    static func makeSharedContext() async throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Project.self, Task.self, User.self, Role.self,
            configurations: config
        )
        
        // Don't load any sample data - useful for testing empty states
        
        return container
    }
    
    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
    }
}


