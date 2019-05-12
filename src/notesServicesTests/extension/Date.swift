//
//  Date.swift
//  notesTests
//
//  Created by jabari on 5/9/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import XCTest
@testable import notesServices

class DateTest: XCTestCase {
    let calendar = Calendar.current
    
    let formatter: DateFormatter = {
        let f        = DateFormatter()
        f.locale     = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "h:mm a 'on' MMMM dd, yyyy"
        f.amSymbol   = "AM"
        f.pmSymbol   = "PM"
        return f
    }()
    
    enum Weekday: Int {
        case sunday    = 1
        case monday    = 2
        case tuesday   = 3
        case wednesday = 4
        case thursday  = 5
        case friday    = 6
        case saturday  = 7
    }
    
    /// Reset the date service after each test
    override func tearDown() {
        formatter.dateFormat = "h:mm a 'on' MMMM dd, yyyy"
        DateService.now = {
            return Date()
        }
    }
    
//    Is it possible to simulate running on Sunday?
//    func testDateFormattedForDisplayedYesterdayOnSunday() {
//        XCTAssert(false)
//    }
    
    func testDateFormattedForDisplayedCreatedYesterdayNotOnSunday() {
        formatter.dateFormat = "EEEE"
        var today   = Date()
        let weekday = calendar.component(.weekday, from: today)
        
        if weekday == 1 {
            let twoDays = DateComponents(year: 0, month: 0, day: 2, hour: 0, minute: 0, second: 0)
            today = calendar.date(byAdding: twoDays, to: today)!
        }
        
        let components = DateComponents(year: 0, month: 0, day: -1, hour: 0, minute: 0, second: 0)
        let yesterday  = calendar.date(byAdding: components, to: today)!
        let expected   = formatter.string(from: yesterday)
        let actual     = yesterday.formattedForDispay
        XCTAssert(actual == expected)
    }
    
    func testDateFormattedForDisplayedCreatedMoreThanAWeekAgo() {
        let date     = formatter.date(from: "12:33 PM on May 09, 2018")!
        let actual   = date.formattedForDispay
        let expected = formatter.string(from: date)
        XCTAssert(actual == expected)
    }
    
    func testDateFormattedForDisplayedCreatedToday() {
        formatter.dateFormat = "h:mm a"
        let today    = Date()
        let actual   = today.formattedForDispay
        let expected = formatter.string(from: today)
        XCTAssert(actual == expected)
    }
    
    func testDateFormattedForDisplayedTomorrow() {
        let components = DateComponents(year: 0, month: 0, day: 1, hour: 0, minute: 0, second: 0)
        let yesterday  = calendar.date(byAdding: components, to: Date())!
        let actual     = yesterday.formatted
        let expected   = formatter.string(from: yesterday)
        XCTAssert(actual == expected)
    }
    
    func testDateDefaultFormatForDateInPast() {
        let date     = formatter.date(from: "12:33 PM on May 09, 2018")!
        let actual   = date.formatted
        let expected = formatter.string(from: date)
        XCTAssert(actual == expected)
    }
    
    func testDateDefaultFormatForYesterday() {
        let components = DateComponents(year: 0, month: 0, day: -1, hour: 0, minute: 0, second: 0)
        let yesterday  = calendar.date(byAdding: components, to: Date())!
        let actual     = yesterday.formatted
        let expected   = formatter.string(from: yesterday)
        XCTAssert(actual == expected)
    }
    
    func testDateDefaultFormatForToday() {
        let date     = Date()
        let actual   = date.formatted
        let expected = formatter.string(from: date)
        XCTAssert(actual == expected)
    }
    
    func testDateDefaultFormatForTomorrow() {
        let components = DateComponents(year: 0, month: 0, day: 1, hour: 0, minute: 0, second: 0)
        let yesterday  = calendar.date(byAdding: components, to: Date())!
        let actual     = yesterday.formatted
        let expected   = formatter.string(from: yesterday)
        XCTAssert(actual == expected)
    }
    
    func testDateDefaultFormatForTheFuture() {
        let components = DateComponents(year: 1, month: 3, day: 1, hour: 3, minute: 2, second: 7)
        let yesterday  = calendar.date(byAdding: components, to: Date())!
        let actual     = yesterday.formatted
        let expected   = formatter.string(from: yesterday)
        XCTAssert(actual == expected)
    }
}
