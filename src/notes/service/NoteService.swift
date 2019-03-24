//
//  NoteService.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData
import UIKit

class NoteService {
    private var container = AppDelegate.persistentContainer
    private var context = AppDelegate.viewContext
    static var noteService = NoteService()
    
    var notes: [Note] {
        var array: [Note] = []
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        
        try? array = context.fetch(fetchRequest) as! [Note]
        
        return array
    }
    
    func newNote(title: String) -> Note {
        let note = Note(context: context)
        
        note.title = title
        note.body = nil
        
        return note
    }
    
    func deleteNote(note: Note) {
        context.delete(note)
        try? context.save()
    }
    
    func saveNote(note : Note, completion: (() -> Void)? = nil) {
        try? note.managedObjectContext?.save()
        
        if let completion = completion {
            completion()
        }
    }
    
    func emailNote(note: Note, viewController: UIViewController) {
        // TODO - Figure out how to send the note as an email
        // where the title is the subject and the note body is
        // the email body
        
        let alert = UIAlertController(title: "Coming soon", message: "Feature not yet implemented.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        viewController.present(alert, animated: true)
    }
    
    private init() {}
}
