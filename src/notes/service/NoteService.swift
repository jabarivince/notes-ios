//
//  NoteService.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData
import UIKit

/// This is a singleton. We only want one instance of the note service
/// because the context (core data API) is not thread safe. So we do not
/// want to accidently create multiple instances of the NoteService.
class NoteService {
    private var context = AppDelegate.viewContext
    static private var noteService = NoteService()
    
    /// Wrapper around static NoteService that only exposes
    /// the the service as a NoteFactory. This way we do not
    /// expose any internals of the NoteService by accident.
    static var noteFactory: NoteFactory {
        return noteService
    }
    
    static var noteSender: NoteSender {
        return noteService
    }
    
    /// init is private on purpose. We do not want
    /// any class to be able to instantiate a NoteService.
    /// Otherwise, we cannot guarantee this class is a singleton.
    private init() {}
}

/// CRUD operations for Note objects
/// as defined in NoteFactory
extension NoteService: NoteFactory {
    
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

/// Functions associated with sending
/// notes via email, imessage, etc
extension NoteService: NoteSender {

    func sendNote(note: Note, viewController: UIViewController) {
        // TODO - Figure out how to send the note as an email
        // where the title is the subject and the note body is
        // the email body
        
        let alert = UIAlertController(title: "Coming soon", message: "Feature not yet implemented.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        viewController.present(alert, animated: true)
    }
}
