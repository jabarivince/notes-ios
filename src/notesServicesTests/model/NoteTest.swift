//
//  NoteTest.swift
//  notesTests
//
//  Created by jabari on 4/7/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData
import XCTest
@testable import notesServices

class NoteTest: XCTestCase {
    override func setUp() {
        super.setUp()
        NoteServiceTest.clearDatabase()
    }
    
    override func tearDown() {
        super.tearDown()
        NoteServiceTest.clearDatabase()
    }
    
    func testNoteContainsFullTitleAndBody() {
        let title = "Some title"
        let body = "Some body"
        let note = emptyNote
        
        let precondition = !note.contains(text: title) && !note.contains(text: body)
        
        note.title = title
        note.body = body
    
        let postcondition = note.contains(text: title) && note.contains(text: body)
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
    
    func testNoteContainsPartialTitleAndBody() {
        let title = "Some title"
        let body = "Some body"
        let partialTitle = "Some"
        let partialBody = "body"
        let note = emptyNote
        
        let precondition = !note.contains(text: partialTitle) && !note.contains(text: partialBody)
        
        note.title = title
        note.body = body
        
        let postcondition = note.contains(text: partialTitle) && note.contains(text: partialBody)
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
    
    func testNoteDoesNotContainTitleOrBody() {
        let title = "Some title"
        let body = "Some body"
        let note = emptyNote
        
        note.title = title
        note.body = body
        
        let postcondition = !note.contains(text: "123") && !note.contains(text: "456")
        
        XCTAssert(postcondition)
    }
    
    func testContainsIsNotCaseSensitive() {
        let bigTitle = "TITLE"
        let bigBody = "BODY"
        let littleTitle = "title"
        let littleBody = "body"
        let note = emptyNote
        
        let precondition = !note.contains(text: littleTitle) && !note.contains(text: littleBody)
        
        note.title = bigTitle
        note.body = bigBody
        
        let postcondition = note.contains(text: littleTitle) && note.contains(text: littleBody)
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
    
    func testStringifyingNote() {
        let note = emptyNote
        let stringified = "title:\nbody"
        
        let precondition = stringified != note.stringified
        
        note.title = "title"
        note.body = "body"
        
        let postcondition = stringified == note.stringified
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
    
    func testStringifyingNoteWithEmptyTitle() {
        let note = emptyNote
        let stringified = "body"
        
        let precondition = stringified != note.stringified
        
        note.body = "body"
        
        let postcondition = stringified == note.stringified
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
    
    func testStringifyingNoteWithEmptyBody() {
        let note = emptyNote
        let stringified = "title"
        
        let precondition = stringified != note.stringified
        
        note.title = "title"
        
        let postcondition = stringified == note.stringified
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
    
    func testStringifyingSetOfNotesOfSizeOne() {
        let note = emptyNote
        var noteSet = Set<Note>()
        
        note.title = "title"
        note.body = "body"
        noteSet.insert(note)
        
        let condition = noteSet.stringified == note.stringified
        
        XCTAssert(condition)
    }
    
    func testStringifyingSetOfNotes() {
        let quantity = Int.random(in: 10...50)
        let notes = getNotes(quantity, withTitles: true, withBodies: true)
        let noteSet = Set<Note>(notes)
        var stringified = ""
        
        for (index, note) in notes.enumerated() {
            stringified.append(note.stringified)
            
            if index != notes.count - 1 {
                stringified.append("\n\n")
            }
        }
        
        let condition = noteSet.stringified == stringified
        
        XCTAssert(condition)
    }
    
    func testStringifyingEmptySetOfNotes() {
        let noteSet = Set<Note>()
        
        let condition = noteSet.stringified.isEmpty
        
        XCTAssert(condition)
    }
    
    func testStringifyingSetOfAllEmptyNotes() {
        let quantity = Int.random(in: 10...50)
        let notes = getNotes(quantity, empty: true)
        let noteSet = Set<Note>(notes)
        
        let condition = noteSet.stringified.isEmpty
        
        XCTAssert(condition)
    }
    
    func testStringifyingNotesWithEmptyBodies() {
        let quantity = Int.random(in: 10...50)
        let notes = getNotes(quantity, withTitles: true, withBodies: false)
        let noteSet = Set<Note>(notes)
        var stringified = ""
        
        for (index, note) in notes.enumerated() {
            stringified.append(note.stringified)
            
            if index != notes.count - 1 {
                stringified.append("\n\n")
            }
        }
        
        let condition = noteSet.stringified == stringified
        
        XCTAssert(condition)
    }
    
    func testStringifyingNotesWithEmptyTitles() {
        let quantity = Int.random(in: 10...50)
        let notes = getNotes(quantity, withTitles: false, withBodies: true)
        let noteSet = Set<Note>(notes)
        var stringified = ""
        
        for (index, note) in notes.enumerated() {
            stringified.append(note.stringified)
            
            if index != notes.count - 1 {
                stringified.append("\n\n")
            }
        }
        
        let condition = noteSet.stringified == stringified
        
        XCTAssert(condition)
    }
    
    // TODO: Do not use Note.compaitor. Sort manually
    func testStringifyingWithRandomlyCreatedNotes() {
        let quantity = Int.random(in: 100...150)
        let notes = getNotes(quantity).filter { !$0.stringified.isEmpty }.sorted(by: Note.comparator)
        let noteSet = Set<Note>(notes)
        var stringified = ""
        
        for (index, note) in notes.enumerated() {
            if !note.stringified.isEmpty {
                stringified.append(note.stringified)
                
                if index != notes.count - 1 {
                    stringified.append("\n\n")
                }
            }
        }

        let condition = noteSet.stringified == stringified
        
        XCTAssert(condition)
    }
}

extension NoteTest {
    private var emptyNote: Note {
        let note = NoteServiceTest.getEmptyNote()
        let now = Date()
        
        note.createdDate = now
        note.lastEditedDate = now
        
        return note
    }
    
    private var newNote: Note {
        let note = emptyNote
        
        note.title = "title"
        note.body = "body"
        
        return note
    }
    
    private func getNotes(_ quantity: Int, empty: Bool = false) -> [Note] {
        var notes = [Note]()
        
        if quantity < 1 {
            assertionFailure("Quantity must be greater than 0")
        }
        
        for _ in 1...quantity {
            notes.append(empty ? emptyNote : newNote)
        }
        
        return notes
    }
    
    private func getNotes(_ quantity: Int, withTitles: Bool, withBodies: Bool) -> [Note] {
        var notes = [Note]()
        
        if quantity < 1 {
            assertionFailure("Quantity must be greater than 0")
        }
        
        for _ in 1...quantity {
            let note = emptyNote
            
            if withTitles {
               note.title = "title"
            }
            
            if withBodies {
                note.body = "body"
            }
            
            notes.append(note)
        }
        
        return notes
    }
    
    func getNotes(_ quantity: Int) -> [Note] {
        var notes = [Note]()
        
        if quantity < 1 {
            assertionFailure("Quantity must be greater than 0")
        }
        
        for index in 1...quantity {
            let note = emptyNote
            
            let title = Int.random(in: 1...100) > 50
            let body = Int.random(in: 1...100) > 50
            
            if title {
                note.title = "title\(index)"
            }
            
            if body {
                note.body = "body\(index)"
            }
            
            notes.append(note)
        }
        
        return notes
    }
    
    // TODO: Test sorting notes with Note.comparitor
}
