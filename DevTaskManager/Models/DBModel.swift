//
//  DBModel.swift
//  DevTaskManager
//
//  Created by Larry Burris on 4/12/25.
//
import Foundation
import SwiftData

class DBModel
{
    var createdBy: User?
    var dateCreated: Date = Date()
    var lastUpdated: Date?
    
    init(createdBy: User? = nil, dateCreated: Date = Date(), lastUpdated: Date? = nil)
    {
        self.createdBy = createdBy
        self.dateCreated = dateCreated
        self.lastUpdated = lastUpdated
    }
}
