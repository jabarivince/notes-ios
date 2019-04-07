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
    
    /// Eagerly initialized Singleton. This is ok
    /// because our persistentContainer is lazily initialized.
    static var instance = NoteService()
    
    // TODO: Store the number of unnamed notes?
    // This way when we kill and restart the app,
    // we do not start from 0 again
    private static var newNoteNumber = 0
    
    /// SQL: SELECT * FROM Note
    var notes: [Note] {
        var array: [Note] = []
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        let sortDescriptor = NSSortDescriptor(key: "lastEditedDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        try? array = context.fetch(fetchRequest) as! [Note]
        
        return array
    }
    
    /// SQL: INSERT INTO Note (title, body) values (title, null)
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
        
        saveNote(note: note)
        
        return note
    }
    
    /// SQL: DELETE FROM Note WHERE id = id
    func deleteNote(note: Note) {
        context.delete(note)
        try? context.save()
    }
    
    /// SQL: DELETE FROM Note WHERE id IN (id_1, id_2, ...)
    func deleteNotes(_ notes: Set<Note>, completion: (() -> Void)?) {
        
        // NOTE: This can be optimized!!
        for note in notes {
            deleteNote(note: note)
        }
        
        if let completion = completion {
            completion()
        }
    }
    
    /// SQL: INSERT INTO Note (title, body) VALUES (title, body)
    func saveNote(note : Note) {
        let now = Date()
        
        if note.createdDate == nil {
            note.createdDate = now
        }
        
        note.lastEditedDate = now
        
        try? context.save()
    }
    
    /// Opens view for sending note via email, imessage, etc.
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
    
    /// Lazy init database connection because this is an expensive task
    /// so we only initialize it once we actually need it. Typically, we
    /// do not want to open a database connection until we actually need it.
    lazy var container: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "NotesDataModel")
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return persistentContainer
    }()
    
    private(set) lazy var context = container.viewContext
    
    /// This class is a Singleton, so we lock down the init.
    private init() {}
}
