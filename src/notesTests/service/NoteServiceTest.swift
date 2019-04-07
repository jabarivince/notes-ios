//
//  NoteServiceTest.swift
//  notesTests
//
//  Created by jabari on 4/7/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData
import XCTest
@testable import notes

class NoteServiceTest: XCTestCase {
    override func setUp() {
        super.setUp()
        NoteServiceTest.clearDatabase()
    }
    
    override func tearDown() {
        super.tearDown()
        NoteServiceTest.clearDatabase()
    }
    
    /// Make a note and check that DB has 1 note
    func testCreateNote() {
        let title = "title"

        let precondition = allNotes.isEmpty
        
        let _ = noteService.createNote(with: title)

        let postcondition = allNotes.isOfSize(1)

        XCTAssert(precondition)
        XCTAssert(postcondition)
    }

    /// Make a note, delete it, make sure DB has 0 notes
    func testDeleteNote() {
        let note = getNote()
        
        let precondition = allNotes.isOfSize(1)
        
        noteService.deleteNote(note: note)
        
        let postcondition = allNotes.isEmpty
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }

    /// Make 10 notes, delete all 10, make sure DB has 0 notes
    func testDeleteMultipleNotes() {
        let size = 10
        var notes = Set<Note>()
        
        for _ in 1...size {
            notes.insert(getNote())
        }
        
        let precondition = allNotes.isOfSize(size)
        
        noteService.deleteNotes(notes, completion: nil)
    
        let postcondition = allNotes.isEmpty
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }

    /// Make a note, set title, check DB has a note with specified title
    func testSaveNoteTitle() {
        let note = getNote()

        let precondition = !allNotes.contains(where: noteHasNilTitle)

        note.title = nil
        noteService.saveNote(note: note)

        let postcondition = allNotes.contains(where: noteHasNilTitle)

        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
    
    /// Make a note, set body, check DB has a note with specified body
    func testCanSaveNoteBody() {
        let note = getNote()
        
        let precondition = !allNotes.contains(where: noteHasNilBody)
        
        note.body = nil
        noteService.saveNote(note: note)
        
        let postcondition = allNotes.contains(where: noteHasNilBody)
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
}

/// Private auxiliary functions and wrappers
extension NoteServiceTest {
    private var allNotes: [Note] {
        return NoteServiceTest.allNotes
    }
    
    private var noteService: NoteService {
        return NoteServiceTest.noteService
    }
    
    private var context: NSManagedObjectContext {
        return NoteServiceTest.context
    }
    
    private func noteHasNilTitle(element: Note) -> Bool {
        return element.title == nil
    }
    
    private func noteHasNilBody(entity: Note) -> Bool {
        return entity.body == nil
    }
    
    /// Creates a note with values in all fields
    private func getNote() -> Note {
        let title = "title"
        let body = "body"
        
        let note = Note(context: context)
        note.title = title
        note.body = body
        
        return note
    }
}

/// Static reusable properties and Core Data related logic
extension NoteServiceTest {
    private static var context: NSManagedObjectContext {
        return noteService.context
    }
    
    /// Note service for use in testing
    private static let noteService: NoteService = {
        let service = NoteService.instance
        
        // Use an in-memory database rather than storing
        // to disk. This way we avoid leaving state (test data) on
        // on the device that the tests are running on
        service.container = {
            let container = NSPersistentContainer(name: "NotesDataModel")
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
    
        return service
    }()
    
    /// SQL: SELECT * FROM Note
    private static var allNotes: [Note] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        return try! context.fetch(fetchRequest) as! [Note]
    }
    
    /// SQL: DELETE FROM Note
    static func clearDatabase() {
        // Batch delete does not work with in-memory database
        
        for note in allNotes {
            context.delete(note)
        }
        
        try! context.save()
    }
    
    /// SQL: INSERT INTO (title, body) Note VALUES (null, null)
    static func getEmptyNote() -> Note {
        let note = Note(context: context)
        note.title = nil
        note.body = nil
        
        return note
    }
}

extension Array {
    func isOfSize(_ size: Int) -> Bool {
        return self.count == size
    }
}
