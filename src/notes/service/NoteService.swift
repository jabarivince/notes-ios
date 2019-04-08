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
    static let entityName = "Note"
    static let persistentContainerName = "NotesDataModel"
    
    /// Singleton
    static let instance = NoteService()
    
    // TODO: Store the number of unnamed notes to disk?
    // This way when we kill and restart the app,
    // we do not start from 0 again
    private static var newNoteNumber = 0
    
    private let analyticsService = NoteAnalyticsService.instance
    private let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: NoteService.entityName)
    
    /// SQL: SELECT * FROM Note
    var notes: [Note] {
        var array: [Note] = []
        
        let sortDescriptor = NSSortDescriptor(key: "lastEditedDate", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            try array = context.fetch(fetchRequest) as! [Note]
        } catch _ {
            // TODO: LOG ERROR
        }
        
        return array
    }
    
    /// SQL: INSERT INTO Note (title, body) values (title, null)
    func createNote(with title: String?) -> Note {
        let note = Note(context: context)
        let now = Date()
        
        note.createdDate = now
        note.lastEditedDate = now
        
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
        
        do {
            try context.save()
        } catch _ {
            // TODO: LOG ERROR
        }
        
        analyticsService.publishCreateNoteEvent(for: note)
        return note
    }
    
    /// SQL: DELETE FROM Note WHERE id = id
    func deleteNote(note: Note) {
        analyticsService.publishDeleteNoteEvent(for: note)
        
        context.delete(note)
        
        do {
            try context.save()
        } catch _ {
            // TODO: LOG ERROR
        }
    }
    
    /// SQL: DELETE FROM Note WHERE id IN (id_1, id_2, ...)
    func deleteNotes(_ notes: Set<Note>, completion: (() -> Void)?) {
        analyticsService.publishDeleteBatchNoteEvent(for: notes)
        
        for note in notes {
            context.delete(note)
        }
        
        do {
            try context.save()
        } catch _ {
            // TODO: LOG ERROR
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
        
        do {
            try context.save()
        } catch _ {
            // TODO: LOG ERROR
        }
        
        analyticsService.publishUpdateNoteEvent(for: note)
    }
    
    /// Opens view for sending note via email, imessage, etc.
    func sendNote(note: Note, viewController: UIViewController) {
        analyticsService.publishSendNoteEvent(for: note)
        
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
    
    // Opens view to send multiple notes
    func sendNotes(_ notes: Set<Note>, viewController: UIViewController) {
       
        var notesToSend = ""
    
        for note in notes {
            notesToSend.append(note.title ?? "")
            notesToSend.append(":")
            notesToSend.append("\n")
            notesToSend.append(note.body ?? "")
            notesToSend.append("\n")
            notesToSend.append("\n")
        }
        
        notesToSend.removeLast()
        
        
        let notesToShare = [notesToSend]
        let activityViewController = UIActivityViewController(activityItems: notesToShare as [Any], applicationActivities: nil)
        
        // this enables support for ipads
        activityViewController.popoverPresentationController?.sourceView = viewController.view
        
        // set the subject line for emails
        activityViewController.setValue("Notes from...", forKey: "Subject")
        
        // present the controller
        viewController.presentedVC.present(activityViewController, animated: true, completion: nil)
        
    }
    
    /// Lazy init database connection because this is an expensive task
    /// so we only initialize it once we actually need it. Typically, we
    /// do not want to open a database connection until we actually need it.
    lazy var container: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: NoteService.persistentContainerName)
        
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
