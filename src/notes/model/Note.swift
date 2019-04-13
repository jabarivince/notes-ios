//
//  Note.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData
import Foundation

class Note: NSManagedObject, Stringifiable {
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

// The protocol
protocol Stringifiable {
    var stringified: String { get }
}

