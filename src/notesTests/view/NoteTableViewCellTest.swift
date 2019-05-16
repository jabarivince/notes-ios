//
//  NoteTableViewCellTest.swift
//  notesTests
//
//  Created by jabari on 5/16/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import XCTest
import notesServices
@testable import The_Note_App

class NoteTableViewCellTest: XCTestCase {
    func testThatInitialStateIsAlwaysEmpty() {
        let cell = NoteTableViewCell(style: .default, reuseIdentifier: "cellId")
        XCTAssertEqual(cell.state, .empty)
    }
    
    func testThatStateChangesProperly() {
        let text              = "text"
        let detailText        = "detail"
        let accessibilityText = "accessibility"
        
        let cell   = NoteTableViewCell(style: .default, reuseIdentifier: "cellId")
        let state  = NoteTableViewCellState(text: text, detailText: detailText, accessibilityText: accessibilityText)
        cell.state = state
        
        XCTAssertEqual(cell.textLabel?.text, text)
        XCTAssertEqual(cell.detailTextLabel?.text, detailText)
        XCTAssertEqual(cell.detailTextLabel?.accessibilityLabel, accessibilityText)
    }
}
