//
//  DevTaskManagerApp.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Inject
import SwiftData
import SwiftUI

/*
 Just 3 steps to enable injection in your SwiftUI Views

 1. Import Inject in each view
 2. Add @ObserveInjection var inject to your view struct
 3. Call .enableInjection() at the end of your body definition
 */

@main
struct DevTaskManagerApp: App
{
    @Environment(\.modelContext) var modelContext

    var body: some Scene
    {
        WindowGroup
        {
            MainMenuView()
        }
        .modelContainer(for: [Project.self, User.self, Role.self, Task.self, TaskItem.self])
    }

    init()
    {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}

extension ModelContext
{
    var sqliteCommand: String
    {
        if let url = container.configurations.first?.url.path(percentEncoded: false)
        {
            "sqlite3 \"\(url)\""
        }
        else
        {
            "No SQLite database found."
        }
    }
}
