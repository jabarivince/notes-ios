//
//  Note.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData
import Foundation

/// Class that is connected to the Note entity
/// in Core Data database. The fields are generated
/// automatically and available at runtime. No fields
/// or functions are required. However, additional
/// convenience functions can be writting here.
class Note: NSManagedObject {
    func delete() {
        managedObjectContext?.delete(self)
        save()
    }
    
    func save() {
        let now = Date()
        
        if createdDate == nil {
            createdDate = now
        }
        
        lastEditedDate = now
        try? managedObjectContext?.save()
    }
    
    /// Determines if note contains a string
    /// in either the title or the body
    func contains(text: String?) -> Bool {
        var titleContains = false
        var bodyContains = false
        
        if let text = text?.lowercased() {
            
            if let title = title?.lowercased() {
                titleContains =  title.contains(text)
            }
            
            if let body = body?.lowercased() {
                bodyContains = body.contains(text)
            }
        }
        
        return titleContains || bodyContains
    }
}

