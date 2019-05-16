//
//  NoteListBackgroundViewTest.swift
//  notesTests
//
//  Created by jabari on 5/16/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import XCTest
@testable import The_Note_App

class NoteListBackgroundViewTest: XCTestCase {
    func testThatInitialStateIsHidden() {
        let view = NoteListBackgroundView(frame: .zero)
        XCTAssertEqual(view.state, .hidden)
    }
    
    func testNoNotesAvailableState() {
        let view    = NoteListBackgroundView(frame: .zero)
        let state   = NoteListBackgroundView.State.noNotesAvailable
        view.state  = state
        
        XCTAssertNotNil(view.label.gestureRecognizers)
        XCTAssertEqual(view.label.gestureRecognizers!.count, 1)
        XCTAssertEqual(view.label.text, state.rawValue)
    }
    
    func testHiddenState() {
        let view   = NoteListBackgroundView(frame: .zero)
        let state  = NoteListBackgroundView.State.hidden
        view.state = state
        
        XCTAssertNil(view.tapHandler)
        XCTAssertNil(view.label.gestureRecognizers)
        XCTAssertEqual(view.label.text, state.rawValue)
    }
    
    func testNoNoteFoundState() {
        let view   = NoteListBackgroundView(frame: .zero)
        let state  = NoteListBackgroundView.State.noNotesFound
        view.state = state
        
        XCTAssertNil(view.tapHandler)
        XCTAssertNil(view.label.gestureRecognizers)
        XCTAssertEqual(view.label.text, state.rawValue)
    }
}
