//
//  NoteAnalyticsServiceTest.swift
//  notesTests
//
//  Created by jabari on 4/13/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import XCTest
@testable import notesServices

class AnalyticsServiceTest: XCTestCase {
    func testThatallEventTypesAreLowercasedSnakeCase() {
        let regex = NSRegularExpression("^[a-z]+(?:_[a-z]+)*$")
        
        for eventType in Event.EventType.allCases {            
            XCTAssert(regex.matches(eventType.rawValue))
        }
    }
}

extension NSRegularExpression {
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
    
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}
