//
//  Date.swift
//  notesTests
//
//  Created by jabari on 5/9/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import XCTest
@testable import The_Note_App

class DateTest: XCTestCase {
    let formatter: DateFormatter = {
        let f      = DateFormatter()
        f.locale   = Locale(identifier: "en_US_POSIX")
        f.amSymbol = "AM"
        f.pmSymbol = "PM"
        return f
    }()
    
    func testDateCreatedToday() {
        formatter.dateFormat = "h:mm a"
        
        let today    = Date()
        let actual   = today.formatted
        let expected = formatter.string(from: today)    
        XCTAssert(actual == expected)
    }
    
    func testDateCreatedThisWeek() {
        formatter.dateFormat = "EEEE"
        
        let components = DateComponents(year: 0, month: 0, day: -1, hour: 0, minute: 0, second: 0)
        let yesterday  = Calendar.current.date(byAdding: components, to: Date())!
        let expected   = formatter.string(from: yesterday)
        let actual     = yesterday.formatted
        XCTAssert(actual == expected)
    }
    
    func testDateCreatedMoreThanAWeekAgo() {
        formatter.dateFormat = "h:mm a 'on' MMMM dd, yyyy"
        
        let today    = formatter.date(from: "12:33 PM on May 09, 2018")!
        let actual   = today.formatted
        let expected = formatter.string(from: today)
        XCTAssert(actual == expected)
    }
}
