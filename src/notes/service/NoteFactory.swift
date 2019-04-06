//
//  NoteFactory.swift
//  notes
//
//  Created by jabari on 3/24/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData

protocol NoteFactory {
    static var singleton: NoteFactory { get }
    var notes: [Note] { get }
    func createNote(with title: String?) -> Note
    func deleteNote(note: Note)
    func deleteNotes(_ notes: Set<Note>, completion: (() -> Void)?)
    func saveNote(note : Note)
}

class DefaultNoteFactory: NoteFactory {
    private static var instance: NoteFactory?
    
    // TODO: Dynamically grab # of unamed notes. This way
    // if the app restarts, we do not start from zero again!
    private static var newNoteNumber = 0
    private var context = AppDelegate.viewContext
    
    static var singleton: NoteFactory {
        if instance == nil {
            instance = DefaultNoteFactory()
        }
        
        return instance!
    }
    
    /// Computed property that goes out to database,
    /// fetches all notes, and returns them in an array
    /// as Note objects
    var notes: [Note] {
        var array: [Note] = []
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        let sortDescriptor = NSSortDescriptor(key: "lastEditedDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        try? array = context.fetch(fetchRequest) as! [Note]
        
        return array
    }
    
    func createNote(with title: String?) -> Note {
        let note = Note(context: context)
        
        if title?.isEmpty ?? true {
            let num = DefaultNoteFactory.newNoteNumber
            
            note.title = "Untitled"
            
            if num > 0 {
                note.title?.append(" \(num)")
            }
        } else {
            note.title = title
        }
        
        DefaultNoteFactory.newNoteNumber += 1
        
        note.body = nil
        note.save()
        
        return note
    }
    
    func deleteNote(note: Note) {
        note.delete()
    }
    
    func deleteNotes(_ notes: Set<Note>, completion: (() -> Void)?) {
        
        // NOTE: This can be optimized!!
        for note in notes {
            deleteNote(note: note)
        }
        
        if let completion = completion {
            completion()
        }
    }
    
    func saveNote(note : Note) {
        note.save()
    }
    
    private init() {}
}
