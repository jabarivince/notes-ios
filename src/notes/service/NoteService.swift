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
    
    // TODO: Dynamically grab # of unamed notes. This way
    // if the app restarts, we do not start from zero again!
    private static var newNoteNumber = 0
    private var context = AppDelegate.viewContext
    
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
            let num = NoteService.newNoteNumber
            
            note.title = "Untitled"
            
            if num > 0 {
                note.title?.append(" \(num)")
            }
        } else {
            note.title = title
        }
        
        NoteService.newNoteNumber += 1
        
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
    
    func sendNote(note: Note, viewController: UIViewController) {
        
        // set up activity view controller
        let noteToShare = [note.body]
        
        let activityViewController = UIActivityViewController(activityItems: noteToShare as [Any], applicationActivities: nil)
        
        // this enables support for ipads
        activityViewController.popoverPresentationController?.sourceView = viewController.view
        
        // set the subject line for emails
        activityViewController.setValue(note.title, forKey: "Subject")
        
        // present the controller
        viewController.presentedVC.present(activityViewController, animated: true, completion: nil)
    }
}
