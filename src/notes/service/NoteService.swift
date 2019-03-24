//
//  NoteService.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

class NoteService {
    private static var noteService: NoteService? = nil
    
    static private var initialNotes: [Note] = [
        Note(title: "First note", body: "The body"),
        Note(title: "Second note", body: "The second body"),
        Note(title: "Third note", body: "The third body"),
        Note(title: "Fourth note", body: "The fourth body"),
        Note(title: "Fifth note", body: "The dark meat body"),
        Note(title: "Sixth note", body: "The sixth body"),
        Note(title: nil, body: "The seventh note")
    ]
    
    static private var notesById: [String: Note] = {
        var map: [String: Note] = [: ]
        
        for note in initialNotes {
            map[note.uuid] = note
        }
        
        return map
    }()
    
    static var notes: [Note] {
        var array: [Note] = []
        
        for (_, val) in notesById {
            array.append(val)
        }
        
        return array
    }
    
    static func saveNote(note: Note, completion: (() -> Void)? = nil) {
        notesById[note.uuid] = note
        
        if let completion = completion {
            completion()
        }
    }
}
