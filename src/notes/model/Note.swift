//
//  Note.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData

class Note: NSManagedObject {
    
    /// Determines if a note has a given string in
    /// its title or in its body. This function is
    /// not case sensitive.
    func contains(text: String?) -> Bool {
        var titleContains = false
        var bodyContains = false
        
        if let text = text?.lowercased() {
            
            if let title = title?.lowercased() {
                titleContains = title.contains(text)
            }
            
            if let body = body?.lowercased() {
                bodyContains = body.contains(text)
            }
        }
        
        return titleContains || bodyContains
    }
}

/// Sending related properties
extension Note: Stringifiable {
    var stringified: String {
        var string = ""
        var appendedTitle = false
        
        if let title = title {
            string += title
            appendedTitle = true
        }
        
        if let body = body {
            if appendedTitle {
                string += ":\n"
            }
            
            string += body
        }
        
        return string
    }
}

/// Analytics related properties
extension Note: Loggable {
    var parameters: [String: Any] {
        return [
            "created_date": createdDate as Any,
            "last_edited_date": lastEditedDate as Any,
            "is_dirty": isDirty,
            "has_empty_title": hasEmptyTitle,
            "has_empty_body": hasEmptyBody,
            "is_empty": isEmpty,
            "title_length": titleLength,
            "body_length": bodyLength,
            "length": length
        ]
    }
    
    /// If the not has been edited after 1st save
    var isDirty: Bool {
        return createdDate != lastEditedDate
    }
    
    /// If title is nil or empty string.
    var hasEmptyTitle: Bool {
        return title?.isEmpty ?? true
    }
    
    /// If body is nil or empty string.
    var hasEmptyBody: Bool {
        return body?.isEmpty ?? true
    }
    
    /// If title and body is empty.
    var isEmpty: Bool {
        return hasEmptyTitle && hasEmptyBody
    }
    
    /// Length of title.
    var titleLength: Int {
        return title?.count ?? 0
    }
    
    /// Length of body.
    var bodyLength: Int {
        return body?.count ?? 0
    }
    
    /// Length of title + length of body.
    var length: Int {
        return titleLength + bodyLength
    }
}
