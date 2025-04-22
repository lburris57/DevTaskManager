//
//  MainMenuView.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/20/25.
//
import SwiftUI

struct MainMenuView: View
{
    @State private var path = NavigationPath()

    var body: some View
    {
        NavigationStack
        {
            List
            {
                VStack
                {
                    NavigationLink("Project List", destination: ProjectListView())
                }
                
                VStack
                {
                    NavigationLink("User List", destination: UserListView())
                }
                
                VStack
                {
                    NavigationLink("Task List", destination: TaskListView())
                }
            }
            .navigationBarTitle(Text("Main Menu"), displayMode: .inline)
            .listStyle(.plain)
        }
    }
}

#Preview
{
    MainMenuView()
}
