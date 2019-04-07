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
        clearDatabase()
    }
    
    override func tearDown() {
        super.tearDown()
        clearDatabase()
    }
    
    func testCanSaveNoteTitle() {
        let note = getNote()
        
        let precondition = !allNotes.contains(where: noteHasNilTitle)
        
        note.title = nil
        note.save()
        
        let postcondition = allNotes.contains(where: noteHasNilTitle)
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
    
    func testCanSaveNoteBody() {
        let note = getNote()
        
        let precondition = !allNotes.contains(where: noteHasNilBody)
        
        note.body = nil
        note.save()
        
        let postcondition = allNotes.contains(where: noteHasNilBody)
        
        XCTAssert(precondition)
        XCTAssert(postcondition)
    }
    
    func testCanDeleteNote() {
        let note = getNote()
        
        let precondition = allNotes.count == 1
        
        note.delete()
        
        let postcondition = allNotes.count == 0
        
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
    var fetchRequest: NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
    }
    
    var deleteRequest: NSBatchDeleteRequest {
        return NSBatchDeleteRequest(fetchRequest: fetchRequest)
    }
    
    var allNotes: [Note] {
        return try! AppDelegate.viewContext.fetch(fetchRequest) as! [Note]
    }
    
    func getNote() -> Note {
        let title = "title"
        let body = "body"
        
        let note = Note(context: AppDelegate.viewContext)
        note.title = title
        note.body = body
        
        return note
    }
    
    func clearDatabase() {
        try! AppDelegate.viewContext.execute(deleteRequest)
    }
    
    func noteHasNilBody(entity: Note) -> Bool {
        return entity.body == nil
    }
    
    func noteHasNilTitle(entity: Note) -> Bool {
        return entity.title == nil
    }
}
