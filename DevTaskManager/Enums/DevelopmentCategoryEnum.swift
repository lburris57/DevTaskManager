//
//  DevelopmentCategoryEnum.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/16/25.
//
import SwiftUI

enum DevelopmentCategoryEnum: String, Identifiable, CaseIterable, Hashable
{
    var id: UUID
    {
        return UUID()
    }

    case all = "All"
    case database = "Database"
    case model = "Model"
    case viewModel = "View Model"
    case view = "View"
    case utils = "Utils"
    case manager = "Manager"
    case helper = "Helper"
    case propertyWrapper = "Property Wrapper"
    case refactor = "Refactor"
}

extension DevelopmentCategoryEnum
{
    var title: String
    {
        switch self
        {
            case .all:
                return "All"
            case .database:
                return "Database"
            case .model:
                return "Model"
            case .viewModel:
                return "View Model"
            case .view:
                return "View"
            case .utils:
                return "Utils"
            case .manager:
                return "Manager"
            case .helper:
                return "Helper"
            case .propertyWrapper:
                return "Property Wrapper"
            case .refactor:
                return "Refactor"
        }
    }
}

