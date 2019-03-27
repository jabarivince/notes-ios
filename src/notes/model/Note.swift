//
//  Note.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData

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
}

