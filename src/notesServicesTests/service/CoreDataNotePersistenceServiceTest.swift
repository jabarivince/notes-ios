//
//  CoreDataNotePersistenceServiceTest.swift
//  notesServicesTests
//
//  Created by jabari on 5/16/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData
import XCTest
@testable import notesServices

class CoreDataNotePersistenceServiceTest: XCTestCase {
    let bundleID     = Bundle.main.bundleIdentifier!
    let userDefaults = UserDefaults(suiteName: "group.com.jabaridash.notes")!
    
    override func setUp() {
        CoreDataNotePersistenceService.shared.userDefaults = userDefaults
    }
    
    override func tearDown() {
        userDefaults.removePersistentDomain(forName: bundleID)
        NoteServiceTest.clearDatabase()
    }
    
    func testThatANoteWithUnpersistedChangesHasNoPendingChanges() {
        let note   = NoteServiceTest.getEmptyNote()
        note.title = "hey"
        note.body  = "there"
        XCTAssertFalse(CoreDataNotePersistenceService.shared.hasPendingChanges)
    }
    
    func testThatSetPendingChangesInSameProcessHasNoEffect() {
        CoreDataNotePersistenceService.shared.setHasPendingChanges()
        XCTAssertFalse(CoreDataNotePersistenceService.shared.hasPendingChanges)
    }
    
    func testThatSetPendingChangesInFromDifferentBundleIDHasAnEffect() {
        CoreDataNotePersistenceService.shared.setHasPendingChanges()
        userDefaults.set("xyz", forKey: "lastWriter")
        XCTAssert(CoreDataNotePersistenceService.shared.hasPendingChanges)
    }
    
    func testRefreshingReflectsChanges() {
        let note = NoteServiceTest.getEmptyNote()
        note.title = "123"
        note.body  = "456"
        try! note.managedObjectContext?.save()
        let refresh = CoreDataNotePersistenceService.shared.refresh(note)
        XCTAssertNotNil(refresh)
        XCTAssertEqual(refresh!.title, "123")
        XCTAssertEqual(refresh!.body, "456")
    }
    
    func testThatRefreshingaADeletedNoteReturnsNil() {
        let note = NoteServiceTest.getEmptyNote()
        note.managedObjectContext?.delete(note)
        try! note.managedObjectContext?.save()
        let refresh = CoreDataNotePersistenceService.shared.refresh(note)
        XCTAssertNil(refresh)
    }
    
    static var inMemoryContainer: NSPersistentContainer = {
        let container   = NSPersistentContainer(name: "NotesDataModel")
        let description = NSPersistentStoreDescription()
        
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
}
