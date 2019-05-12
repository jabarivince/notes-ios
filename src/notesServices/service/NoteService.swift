//
//  NoteService.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData
import UIKit

public class NoteService {
    public func getAllNotes(containing searchText: String? = nil) -> [Note] {
        guard let searchText = searchText, !searchText.isEmpty else { return notes }
        
        return notes.filter { note in
            note.contains(text: searchText)
        }
    }
    
    /// SQL: INSERT INTO Note (title, body) values (title, null)
    public func createNote(with title: String?, body: String? = nil) -> Note {
        let note = Note(context: context)
        let now  = Date()
        
        note.createdDate    = now
        note.lastEditedDate = now
        
        if title?.isEmpty ?? true {
            note.title = "Untitled"
        } else {
            note.title = title
        }
        
        note.body = body
        
        do {
            try context.save()
            analyticsService.publishCreateNoteEvent(for: note)

        } catch _ {
            analyticsService.publishCreateNoteEventFailed(for: note)
        }
        
        return note
    }
    
    /// SQL: DELETE FROM Note WHERE id = id
    public func deleteNote(note: Note) {
        context.delete(note)
        
        do {
            try context.save()
            analyticsService.publishDeleteNoteEvent(for: note)
            
        } catch _ {
            analyticsService.publishDeleteNoteEventFailed(for: note)
        }
    }
    
    /// SQL: DELETE FROM Note WHERE id IN (id_1, id_2, ...)
    public func deleteNotes(_ notes: Set<Note>, completion: (() -> Void)? = nil) {
        for note in notes {
            context.delete(note)
        }
        
        do {
            try context.save()
            analyticsService.publishDeleteBatchNoteEvent(for: notes)
           
        } catch _ {
            analyticsService.publishDeleteBatchNoteEventFailed(for: notes)
        }
        
        if let completion = completion {
            completion()
        }
    }
    
    /// SQL: INSERT INTO Note (title, body) VALUES (title, body)
    public func saveNote(note : Note) {
        let now = Date()
        
        if note.createdDate == nil {
            note.createdDate = now
        }
        
        note.lastEditedDate = now
        
        do {
            try context.save()
            analyticsService.publishUpdateNoteEvent(for: note)
            
        } catch _ {
            analyticsService.publishUpdateNoteEventFailed(for: note)
        }
    }
    
    public func sendNote(_ note: Note, viewController: UIViewController) {
        send(note, viewController: viewController, completion: analyticsService.publishSendNoteEvent)
    }
    
    public func sendNotes(_ notes: Set<Note>, viewController: UIViewController) {
        send(notes, viewController: viewController, completion: analyticsService.publishSendBatchNoteEvent)
    }
    
    static let entityName              = "Note"
    static let persistentContainerName = "NotesDataModel"
    public static let instance         = NoteService()
    
    private let analyticsService  = NoteAnalyticsService.instance
    private let fetchRequest      = NSFetchRequest<NSFetchRequestResult>(entityName: NoteService.entityName)
    private(set) lazy var context = container.viewContext
    
    internal lazy var container: NSPersistentContainer = {
        let persistentContainer = PersistantContainer(name: NoteService.persistentContainerName)
        
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return persistentContainer
    }()
    
    private init() {}
}

private extension NoteService {
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
    
    func send<T>(_ value: T,
                 withSubject subject: String = "Notes",
                 viewController: UIViewController,
                 completion: @escaping (T) -> Void) where T: Stringifiable, T: Loggable {
        
        let text = value.stringified
        let activityViewController = UIActivityViewController(activityItems:[text], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = viewController.view
        activityViewController.setValue(subject, forKey: "Subject")
        viewController.presentedVC.present(activityViewController, animated: true) {
            
            completion(value)
        }
    }
}

class PersistantContainer : NSPersistentContainer {
    private static let id = "group.com.jabaridash.notes"
    
    static let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)!
    let storeDescription = NSPersistentStoreDescription(url: url)
    
    override class func defaultDirectoryURL() -> URL {
        return url
    }
}
