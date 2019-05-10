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
        let format: Format
        
        if occursToday {
            format = .time
        } else if occursThisWeek {
            format = .day
        } else {
            format = .date
        }
        
        let formatter        = DateFormatter()
        formatter.locale     = Locale(identifier: "en_US_POSIX")
        formatter.amSymbol   = "AM"
        formatter.pmSymbol   = "PM"
        formatter.dateFormat = format.rawValue
        
        return formatter.string(from: self)
    }
}

private extension Date {
    var today: Date {
        return Date()
    }
    
    var occursToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var occursThisWeek: Bool {
        return Calendar.current.isDate(self, equalTo: today, toGranularity: .weekOfYear)
    }
    
    enum Format: String {
        case date = "h:mm a 'on' MMMM dd, yyyy"
        case day  = "EEEE"
        case time = "h:mm a"
    }
}
