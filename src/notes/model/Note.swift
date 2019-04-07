//
//  Note.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData
import Foundation

class Note: NSManagedObject {
    func delete() {
        guard let context = managedObjectContext else { return }
        
        context.delete(self)
        try? context.save()
    }
    
    func save() {
        let now = Date()
        
        if createdDate == nil {
            createdDate = now
        }
        
        lastEditedDate = now
        try? managedObjectContext?.save()
    }
    
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

