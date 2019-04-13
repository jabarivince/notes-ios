//
//  Set.swift
//  notes
//
//  Created by Vince G on 4/12/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import Foundation

// Conform Set<Note> to stringifiable
extension Set: Stringifiable where Element == Note {
    static func comparator(lhs: Note, rhs: Note) -> Bool {
        if
            let left = lhs.lastEditedDate,
            let right = rhs.lastEditedDate {
            
            return left < right
        }
        
        return false
    }
    
    var stringified: String {
        return sorted(by: Set.comparator)
            .map { $0.stringified }
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
    }
}
