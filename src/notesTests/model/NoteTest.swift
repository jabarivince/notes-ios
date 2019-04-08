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
}

extension NoteTest {
    private var emptyNote: Note {
        return NoteServiceTest.getEmptyNote()
    }
}
