//
//  NoteTest.swift
//  notesTests
//
//  Created by jabari on 4/7/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData
import XCTest
@testable import notes

class NoteTest: XCTestCase {
    override func setUp() {
        super.setUp()
        NoteTest.clearDatabase()
    }
    
    override func tearDown() {
        super.tearDown()
        NoteTest.clearDatabase()
    }
    
    func testCanSaveNoteTitle() {
        let note = NoteTest.getNote()
        
        let precondition = !NoteTest.allNotes.contains(where: noteHasNilTitle)
        
        note.title = nil
        note.save()
        
        let postcondition = NoteTest.allNotes.contains(where: noteHasNilTitle)
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
    
    func testCanSaveNoteBody() {
        let note = NoteTest.getNote()
        
        let precondition = !NoteTest.allNotes.contains(where: noteHasNilBody)
        
        note.body = nil
        note.save()
        
        let postcondition = NoteTest.allNotes.contains(where: noteHasNilBody)
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
    
    func testCanDeleteNote() {
        let note = NoteTest.getNote()
        
        let precondition = NoteTest.allNotes.count == 1
        
        note.delete()
        
        let postcondition = NoteTest.allNotes.isEmpty
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
    
    func testNoteContainsFullTitleAndBody() {
        let title = "Some title"
        let body = "Some body"
        let note = Note(context: AppDelegate.viewContext)
        
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
        let note = Note(context: AppDelegate.viewContext)
        
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
        let note = Note(context: AppDelegate.viewContext)
        
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
        let note = Note(context: AppDelegate.viewContext)
        
        let precondition = !note.contains(text: littleTitle) && !note.contains(text: littleBody)
        
        note.title = bigTitle
        note.body = bigBody
        
        let postcondition = note.contains(text: littleTitle) && note.contains(text: littleBody)
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
}

extension NoteTest {
    static var fetchRequest: NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
    }
    
    static var deleteRequest: NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: fetchRequest)
    }
    
    static var allNotes: [Note] {
        return try! AppDelegate.viewContext.fetch(NoteTest.fetchRequest) as! [Note]
    }
    
    static func getNote() -> Note {
        let title = "title"
        let body = "body"
        
        let note = Note(context: AppDelegate.viewContext)
        note.title = title
        note.body = body
        
        return note
    }
    
    static func clearDatabase() {
        try! AppDelegate.viewContext.execute(NoteTest.deleteRequest)
    }
    
    func noteHasNilBody(entity: Note) -> Bool {
        return entity.body == nil
    }
    
    func noteHasNilTitle(entity: Note) -> Bool {
        return entity.title == nil
    }
}
