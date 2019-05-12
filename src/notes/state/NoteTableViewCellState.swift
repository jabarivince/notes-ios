//
//  NoteTableViewCellState.swift
//  notes
//
//  Created by jabari on 5/19/19.
//  Copyright © 2019 jabari. All rights reserved.
//

struct NoteTableViewCellState {
    let text: String
    let detailText: String
    let accessibilityText: String
    
    init(from note: Note) {
        let title = note.title ?? "Untitled"
        var accessibility = ""
        var detail = note.body?.firstLine.truncated(after: 30) ?? ""
        
        if !detail.isEmpty {
            accessibility += "Subject: \(detail)"
        }
        
        if let date = note.lastEditedDate?.formattedForDispay {
            detail += "\n\(date)"
            
            if !accessibility.isEmpty {
                accessibility += ", "
            }
            
            accessibility += "Last edited: \(date)"
        }
        
        text = title
        detailText = detail
        accessibilityText = accessibility
    }
}
