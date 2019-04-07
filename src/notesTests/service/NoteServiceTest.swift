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
        NoteTest.clearDatabase()
    }
    
    override func tearDown() {
        super.tearDown()
        NoteTest.clearDatabase()
    }
    
    override class func tearDown() {
        super.tearDown()
        NoteTest.clearDatabase()
    }
    
    func testCreateNote() {
        let title = "title"

        let precondition = NoteTest.allNotes.isEmpty
        
        let _ = noteService.createNote(with: title)

        let postcondition = NoteTest.allNotes.count == 1

        XCTAssert(precondition)
        XCTAssert(postcondition)
    }

    func testDeleteNote() {
        let note = NoteTest.getNote()
        
        let precondition = NoteTest.allNotes.count == 1
        
        noteService.deleteNote(note: note)
        
        let postcondition = NoteTest.allNotes.isEmpty
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }

    func testDeleteMultipleNotes() {
        var notes = Set<Note>()
        
        for _ in 1...10 {
            notes.insert(NoteTest.getNote())
        }
        
        let precondition = NoteTest.allNotes.count == 10
        
        noteService.deleteNotes(notes, completion: nil)
        
        let postcondition = NoteTest.allNotes.isEmpty
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }

    func testSaveNote() {
        let note = NoteTest.getNote()
        let newTitle = "newTitle"
        
        func noteHasNewTitle(element: Note) -> Bool {
            return element.title == newTitle
        }

        let precondition = !NoteTest.allNotes.contains(where: noteHasNewTitle)

        note.title = newTitle
        noteService.saveNote(note: note)

        let postcondition = NoteTest.allNotes.contains(where: noteHasNewTitle)

        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
}

extension NoteServiceTest {
    var noteService: NoteService {
        return NoteService()
    }
}
