//
//  NoteViewTest.swift
//  notesTests
//
//  Created by jabari on 5/16/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import XCTest
@testable import The_Note_App

class NoteViewTest: XCTestCase {
    func testThatAutosaveExecutesAfterEditing() {
        var invokations = 0
        
        let autoSave = {
            invokations += 1
        }
        
        let view = NoteView(frame: .zero)
        view.autosave = autoSave
        
        view.textViewDidEndEditing(view)
        
        XCTAssertEqual(invokations, 1)
    }
    
    func testThatAutosaveExecutesWithInOneSecondAfterChanging() {
        var invokations = 0
        
        let autoSave = {
            invokations += 1
        }
        
        let view = NoteView(frame: .zero)
        view.autosave = autoSave
        
        view.textViewDidChange(view)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            XCTAssertEqual(invokations, 1)
        })
    }
}
