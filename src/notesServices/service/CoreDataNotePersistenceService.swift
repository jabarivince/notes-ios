//
//  CoreDataNotePersistenceService.swift
//  notesServices
//
//  Created by jabari on 5/16/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData

class CoreDataNotePersistenceService: NotePersistenceService {
    static let groupdID = "group.com.jabaridash.notes"
    static let shared   = CoreDataNotePersistenceService()
    var userDefaults    = UserDefaults(suiteName: CoreDataNotePersistenceService.groupdID)!
    
    internal init() {}
    
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
        let note = Note(context: context)
        commit()
        return note
    }
    
    func refresh(_ note: Note) -> Note? {
        if hasPendingChanges {
            context.reset()
        }
        
        do {
            let fetchedNote = try context.existingObject(with: note.objectID) as! Note
            context.refresh(fetchedNote, mergeChanges: true)
            return fetchedNote
        } catch _ {
            return nil
        }
    }
    
    /// Persist any changes that are in memory to disk
    /// and sets the bundle ID of the lastWriter to the currently
    /// active bundle ID. We perform these two steps after
    /// every write so that, in the event that the user switches
    /// to another app / extension that has access to this same data,
    /// we can manually synchronize / merge pending changes to keep
    /// data up to date adn consistent.
    private func commit() {
        do {
            try context.save()
            setHasPendingChanges()
        } catch _ {
            // Report this somewhere?
        }
    }
    
    /// Sets the last writer to the bundle ID of
    /// the process that just finished writing to disk.
    /// That way, when a different target (extension or main app)
    /// performs a read operaiton, it can compare its bundle ID with the
    /// bundle ID of the last writer. If the bundle IDs match,
    /// then, the data is up to date. If not, there are pending
    /// writes that the current app must read in and synchronize to reflect the
    /// latest state of the data store. This must be done before performing new any
    /// write operations to prevent inconsistency, corruption, and overwriting
    /// the data on disk.
    func setHasPendingChanges() {
        guard let bundleID = Bundle.main.bundleIdentifier else { return }
        userDefaults.set(bundleID, forKey: "lastWriter")
    }
    
    /// Determines if there are pending changes by comparing
    /// the bundle ID of the last app / extension that wrote to
    /// disk with the bundle ID of the currently active app or extension.
    /// If the IDs match, we are up to date. If not, the current app
    /// needs to read in pending changes that the previous app has made.
    var hasPendingChanges: Bool {
        guard let lastWriter = userDefaults.string(forKey: "lastWriter") else { return false }
        return lastWriter != Bundle.main.bundleIdentifier
    }
    
    /// Fetches all of the notes from the data store,
    /// and sorts them by last edit date, where the notes
    /// that have been most recently editted are towards the
    /// front of the list. We also reset the ManagedObjectContext
    /// before performing the read operation if we detect that
    /// there are any pending writes that need to be merged.
    var allNotes: [Note] {
        if hasPendingChanges {
            context.reset()
        }
        
        var array: [Note]  = []
        let sortDescriptor = NSSortDescriptor(key: "lastEditedDate", ascending: false)
        let fetchRequest   = NSFetchRequest<NSFetchRequestResult>(entityName: CoreDataNotePersistenceService.entityName)
                
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            try array = context.fetch(fetchRequest) as! [Note]
        } catch _ {
            // TODO: LOG ERROR
        }
        
        return array
    }
    
    static let entityName         = "Note"
    static let containerName      = "NotesDataModel"
    private(set) lazy var context = container.viewContext
    
    internal lazy var container: NSPersistentContainer = {
        let momdName = "NotesDataModel"
        let modelURL = Bundle(for: type(of: self)).url(forResource: momdName, withExtension:"momd")
        let mom      = NSManagedObjectModel(contentsOf: modelURL!)
        
        let persistentContainer = PersistantContainer(name: momdName, managedObjectModel: mom!)
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.stalenessInterval = 0

        persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return persistentContainer
    }()
}

/// Wrapper around NSPersistentContainer that allows
/// us to override the deftaultDirectoryURL so that
/// we can manually specify the ManagedObjectModel URL.
class PersistantContainer : NSPersistentContainer {
    static let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: CoreDataNotePersistenceService.groupdID)!
    let storeDescription = NSPersistentStoreDescription(url: url)
    
    override class func defaultDirectoryURL() -> URL {
        return url
    }
}
