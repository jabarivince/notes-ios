//
//  Date.swift
//  notes
//
//  Created by jabari on 3/26/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import Foundation

extension Date {
    var formatted: String {
        let formatter      = DateFormatter()
        formatter.locale   = Locale(identifier: "en_US_POSIX")
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        if isToday {
            formatter.dateFormat = Date.today
        } else if isThisWeek {
            formatter.dateFormat = Date.thisWeek
        } else {
            formatter.dateFormat = Date.beyondLastWeek
        }
        
        return formatter.string(from: self)
    }
}

private extension Date {
    var today: Date {
        return Date()
    }
    
    var isToday: Bool {
        return daysFromToday == 0
    }
    
    var isThisWeek: Bool {
        return daysFromToday <= 6
    }
    
    var daysFromToday: Int {
        return Calendar.current.dateComponents([.day], from: self, to: today).day!
    }
    
    static var today: String {
        return "h:mm a"
    }
    
    static var thisWeek: String {
        return "EEEE"
    }
    
    static var beyondLastWeek: String {
        return "h:mm a 'on' MMMM dd, yyyy"
    }
}
