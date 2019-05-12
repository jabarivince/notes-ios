//
//  NoteTableViewCellStateTest.swift
//  notesTests
//
//  Created by jabari on 5/19/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import XCTest
@testable import The_Note_App

class NoteTableViewCellStateTest: XCTestCase {
    let note = NoteServiceTest.getEmptyNote()
    
    override class func setUp() {
        super.setUp()
        NoteServiceTest.clearDatabase()
    }
    
    override func setUp() {
        note.createdDate = Date()
        note.lastEditedDate = Date()
    }
    
    override class func tearDown() {
        super.tearDown()
        NoteServiceTest.clearDatabase()
    }
    
    func testEmptyNote() {
        let state = NoteTableViewCellState(from: note)
        let date = note.lastEditedDate!.formattedForDispay
        
        XCTAssert(state.text == "Untitled")
        XCTAssert(state.detailText == "\n\(date)")
        XCTAssert(state.accessibilityText == "Last edited: \(date)")
    }
    
    func testNoteWithTitleAndBody() {
        note.title = "title"
        note.body = "body"
        
        let state = NoteTableViewCellState(from: note)
        let date = note.lastEditedDate!.formattedForDispay
        
        XCTAssert(state.text == "title")
        XCTAssert(state.detailText == "body\n\(date)")
        XCTAssert(state.accessibilityText == "Subject: body, Last edited: \(date)")
    }
    
    func testNoteWithOnlyTitle() {
        note.title = "title"
        
        let state = NoteTableViewCellState(from: note)
        let date = note.lastEditedDate!.formattedForDispay
        
        XCTAssert(state.text == "title")
        XCTAssert(state.detailText == "\n\(date)")
        XCTAssert(state.accessibilityText == "Last edited: \(date)")
    }

    func testNoteWithOnlyBody() {
        note.body = "body"
        
        let state = NoteTableViewCellState(from: note)
        let date = note.lastEditedDate!.formattedForDispay
        
        XCTAssert(state.text == "Untitled")
        XCTAssert(state.detailText == "body\n\(date)")
        XCTAssert(state.accessibilityText == "Subject: body, Last edited: \(date)")
    }
}
