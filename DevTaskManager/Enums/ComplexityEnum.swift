//
//  ComplexityEnum.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/16/25.
//
import SwiftUI

enum ComplexityEnum: String, Identifiable, CaseIterable, Hashable
{
    var id: UUID
    {
        return UUID()
    }

    case all = "All"
    case trivial = "Trivial"
    case medium = "Medium"
    case complex = "Complex"
}

extension ComplexityEnum
{
    var title: String
    {
        switch self
        {
            case .all:
                return "All"
            case .trivial:
                return "Trivial"
            case .medium:
                return "Medium"
            case .complex:
                return "Complex"
        }
    }
}
