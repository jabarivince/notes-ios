//
//  ExtendedTapTargetLabelView.swift
//  notesTests
//
//  Created by jabari on 5/16/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import XCTest
@testable import The_Note_App

class ExtendedTapTargetLabelViewTest: XCTestCase {
    func testInitializerWithAllValues() {
        let top: CGFloat    = .random(in: 1...100)
        let left: CGFloat   = .random(in: 1...100)
        let bottom: CGFloat = .random(in: 1...100)
        let right: CGFloat  = .random(in: 1...100)
        
        let label = ExtendedTapTargetLabelView(top: top, left: left, bottom: bottom, right: right)
        
        XCTAssertEqual(top, label.insets.top)
        XCTAssertEqual(left, label.insets.left)
        XCTAssertEqual(bottom, label.insets.bottom)
        XCTAssertEqual(left, label.insets.left)
    }
    
    func testInitializerWithNoArguments() {
        let label = ExtendedTapTargetLabelView()
        XCTAssertEqual(label.insets, .zero)
    }
}
