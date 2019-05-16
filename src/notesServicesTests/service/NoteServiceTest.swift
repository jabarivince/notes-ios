//
//  NoteServiceTest.swift
//  notesTests
//
//  Created by jabari on 4/7/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData
import XCTest
@testable import notesServices

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
        
        let note = noteService.createNote(with: title)

        let postcondition = allNotes.isOfSize(1) && note.title == title

        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
    
    /// Notes should always have a created date
    func testCreatedDateIsNeverNilOnCreateNote() {
        let note = noteService.createNote(with: "title")
        
        XCTAssertNotNil(note.createdDate)
    }
    
    /// Notes should always have a last edited date
    func testLastEditedDateIsNeverNilOnCreateNote() {
        let note = noteService.createNote(with: "title")
        
        XCTAssertNotNil(note.lastEditedDate)
    }
    
    /// Last edit date are always equal oninitial creation
    func testCreatedAndLastEditedDatesAreEqualOnCreateNote() {
        let note = noteService.createNote(with: "title")
        
        XCTAssertEqual(note.createdDate, note.lastEditedDate)
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

    /// Make N notes, delete all N, make sure DB has 0 notes
    func testDeleteMultipleNotes() {
        let size = Int.random(in: 1...50)
        var notes = Set<Note>()
        
        for _ in 1...size {
            notes.insert(getNote())
        }
        
        let precondition = allNotes.isOfSize(size)
        
        noteService.deleteNotes(notes)
    
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
    
    /// Make a note, edit it, save it, check lastEditedDate was updated
    func testLastEditedDateIncreasedOnSave() {
        var note = getNote()
        let now = Date()
        
        note.createdDate = now
        note.lastEditedDate = now
        save()
        
        let precondition = note.lastEditedDate == note.createdDate
        
        noteService.saveNote(note: note)
        note = allNotes[0]
        let lastEditedDate = note.lastEditedDate!
        let createdDate = note.createdDate!
        
        let postcondition = lastEditedDate > createdDate
        
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
    
    /// Create N notes, Delete N notes, DB should be empty.
    func testAddingAndDeletingSameNumberOfNotes() {
        var notes = [Note]()
        let additions = Int.random(in: 1...50)
        
        let precondition = allNotes.isEmpty
        
        for _ in 1...additions {
            notes.append(noteService.createNote(with: "title"))
        }
        
        let midcondition = !allNotes.isEmpty && allNotes.isOfSize(notes.count)
        
        for note in notes {
            noteService.deleteNote(note: note)
        }
        
        let postcondition = allNotes.isEmpty
        
        XCTAssert(precondition)
        XCTAssert(midcondition)
        XCTAssert(postcondition)
    }
    
    /// Add M notes, delete N notes, where M > N, DB.count == M - N
    func testAdditionsAndDeletionsWhereNotesAreLeftOver() {
        var notes = [Note]()
        let addRange = 25...50
        let deleteRange = 1...20
        let additions = Int.random(in: addRange)
        let deletions = Int.random(in: deleteRange)
        
        let precondition = allNotes.isEmpty
        
        for _ in 1...additions {
            notes.append(noteService.createNote(with: "title"))
        }
        
        let midcondition = !allNotes.isEmpty && allNotes.isOfSize(notes.count)
        
        for i in 1...deletions {
            noteService.deleteNote(note: notes[i])
        }
        
        let postcondition = allNotes.isOfSize(additions - deletions)
        
        XCTAssert(precondition)
        XCTAssert(midcondition)
        XCTAssert(postcondition)
    }
    
    func testGetAllNotesWithoutArgument() {
        let precondition = allNotes.isEmpty
        
        for _ in 1...Int.random(in: 1...50) {
            let _ = getNote()
        }
        
        save()
        
        let notes = noteService.getAllNotes()
        
        let postcondition = notes.count == allNotes.count
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
    
    func testGetAllNotesWithNilArgument() {
        let precondition = allNotes.isEmpty
        
        for _ in 1...Int.random(in: 1...50) {
            let _ = getNote()
        }
        
        save()
        
        let notes = noteService.getAllNotes(containing: nil)
        
        let postcondition = notes.count == allNotes.count
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
    
    func testGetAllNotesWithEmptyArgument() {
        let precondition = allNotes.isEmpty
        
        for _ in 1...Int.random(in: 1...50) {
            let _ = getNote()
        }
        
        save()
        
        let notes = noteService.getAllNotes(containing: "")
        
        let postcondition = notes.count == allNotes.count
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
    
    func testGetAllNotesContainingStringThatIsNotPresent() {
        for _ in 1...Int.random(in: 1...50) {
            let note = getNote()
            note.title = "SOMETHING"
            note.body  = "ELSE"
        }
        
        save()
        
        let notes = noteService.getAllNotes(containing: "0123456789")
        
        let condition = notes.isEmpty
        
        XCTAssert(condition)
    }
    
    func testGetAllNotesContainingStringThatIsPresentInAll() {
        let title = "SOME TITLE"
        
        for _ in 1...Int.random(in: 1...50) {
            let note = getNote()
            note.title = title
        }
        
        save()
        
        let notes = noteService.getAllNotes(containing: title)
        
        let condition = notes.count == allNotes.count
        
        XCTAssert(condition)
    }
    
    func testGetAllNotesContainingStringThatIsPresentInSome() {
        let text = "SOME TITLE"
        let numberOfNotesToAdd = Int.random(in: 20...50)
        let numberOfNotesWithText = Int.random(in: 1...15)
        
        for _ in 1...numberOfNotesToAdd {
            let _ = getNote()
        }
        
        for i in 1...numberOfNotesWithText {
            allNotes[i].title = text
        }
        
        save()
        
        let notes = noteService.getAllNotes(containing: text)
        
        let firstCondition  = notes.count < allNotes.count
        let secondCondition = notes.count == numberOfNotesWithText
        
        XCTAssert(firstCondition)
        XCTAssert(secondCondition)
    }
}

/// Auxiliary functions and wrappers
extension NoteServiceTest {
    private var allNotes: [Note] {
        return NoteServiceTest.persistenceService.allNotes
    }
    
    private var noteService: NoteService {
        return NoteServiceTest.noteService
    }
    
    private func noteHasNilTitle(element: Note) -> Bool {
        return element.title == nil
    }
    
    private func noteHasNilBody(entity: Note) -> Bool {
        return entity.body == nil
    }
    
    private func save() {
        let service = NoteServiceTest.persistenceService as! CoreDataNotePersistenceService
        try! service.container.viewContext.save()
    }
    
    private func getNote() -> Note {
        let title  = "title"
        let body   = "body"
        let note   = NoteServiceTest.persistenceService.createNote()
        note.title = title
        note.body  = body
        return note
    }
}

/// Static reusable properties and Core Data related logic
extension NoteServiceTest {
    private static let persistenceService: NotePersistenceService = {
        let service       = CoreDataNotePersistenceService()
        service.container = CoreDataNotePersistenceServiceTest.inMemoryContainer
        return service
    }()
    
    private static let noteService: NoteService = {
        let service                  = NoteService.shared
        service.persistenceService   = persistenceService
        return service
    }()
    
    static func clearDatabase() {
        persistenceService.allNotes.forEach(persistenceService.delete)
    }
    
    static func getEmptyNote() -> Note {
        let note   = persistenceService.createNote()
        note.title = nil
        note.body  = nil
        return note
    }
}

extension Array {
    func isOfSize(_ size: Int) -> Bool {
        return self.count == size
    }
}
