//
//  NoteFactory.swift
//  notes
//
//  Created by jabari on 3/24/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData

/// Protocol that specifies the CRUD operations on notes
protocol NoteFactory {
    var notes: [Note] { get }
    func createNote(title: String) -> Note
    func deleteNote(note: Note)
    func saveNote(note : Note, completion: (() -> Void)?)
}

/// Note factory for CRUD operations on notes that
/// will be stored and read from the local database
class DefaultNoteFactory: NoteFactory {
    private var context = AppDelegate.viewContext
    
    /// Computed property that goes out to database,
    /// fetches all notes, and returns them in an array
    /// as Note objects
    var notes: [Note] {
        var array: [Note] = []
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        
        try? array = context.fetch(fetchRequest) as! [Note]
        
        return array
    }
    
    func createNote(title: String) -> Note {
        let note = Note(context: context)
        
        note.title = title
        note.body = nil
        
        // NOTE: Do we want to save right after creation?
        
        return note
    }
    
    func deleteNote(note: Note) {
        context.delete(note)
        try? context.save()
    }
    
    func saveNote(note : Note, completion: (() -> Void)?) {
        try? note.managedObjectContext?.save()
        
        if let completion = completion {
            completion()
        }
    }
}
