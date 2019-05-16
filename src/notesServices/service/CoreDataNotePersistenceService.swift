//
//  CoreDataNotePersistenceService.swift
//  notesServices
//
//  Created by jabari on 5/16/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData

class CoreDataNotePersistenceService: NotePersistenceService {
    static let shared = CoreDataNotePersistenceService()
    
    func delete(_ note: Note) {
        context.delete(note)
        commit()
    }
    
    func delete(_ notes: Set<Note>) {
        notes.forEach(context.delete)
        commit()
    }
    
    func save(_ note: Note) {
        commit()
    }
    
    func createNote() -> Note {
        return Note(context: context)
    }
    
    private func commit() {
        do {
            try context.save()
        } catch _ {
            // Report this somewhere?
        }
    }
    
    internal init() {}
    
    var allNotes: [Note] {
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
    
    static let entityName    = "Note"
    static let containerName = "NotesDataModel"
    let fetchRequest      = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataNotePersistenceService.entityName)
    private(set) lazy var context = container.viewContext
    
    internal lazy var container: NSPersistentContainer = {
        let momdName = "NotesDataModel"
        let modelURL = Bundle(for: type(of: self)).url(forResource: momdName, withExtension:"momd")
        let mom      = NSManagedObjectModel(contentsOf: modelURL!)
        
        let persistentContainer = PersistantContainer(name: momdName, managedObjectModel: mom!)
        
        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return persistentContainer
    }()
}

class PersistantContainer : NSPersistentContainer {
    private static let id = "group.com.jabaridash.notes"
    
    static let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)!
    let storeDescription = NSPersistentStoreDescription(url: url)
    
    override class func defaultDirectoryURL() -> URL {
        return url
    }
}
