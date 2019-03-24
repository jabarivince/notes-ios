//
//  NoteService.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

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
        
        // TODO - Figure out how to save?
        
        notesById[note.uuid] = note
        
        if let completion = completion {
            completion()
        }
    }
    
    static func emailNote(note: Note, viewController: UIViewController) {
        // TODO - Figure out how to send the note as an email
        // where the title is the subject and the note body is
        // the email body
        
        let alert = UIAlertController(title: "Coming soon", message: "Feature not yet implemented.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        viewController.present(alert, animated: true)
    }
}
