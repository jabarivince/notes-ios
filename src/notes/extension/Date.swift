//
//  Date.swift
//  notes
//
//  Created by jabari on 3/26/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import Foundation

extension Date {
    var formattedForDispay: String {
        let format: Format
        
        if occursToday {
            format = .time
        } else if occursThisWeek {
            format = .day
        } else {
            format = .date
        }
        
        let f = formatter
        f.dateFormat = format.rawValue
        
        return f.string(from: self)
    }
    
    var formatted: String {
        return formatter.string(from: self)
    }
}

extension Date {
    var today: Date {
        return DateService.now()
    }
    
    var formatter: DateFormatter {
        let f        = DateFormatter()
        f.locale     = Locale(identifier: "en_US_POSIX")
        f.amSymbol   = "AM"
        f.pmSymbol   = "PM"
        f.dateFormat = Format.date.rawValue
        return f
    }
    
    var occursToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var occursThisWeek: Bool {
        return Calendar.current.isDate(self, equalTo: today, toGranularity: .weekOfYear)
    }
    
    private enum Format: String {
        case date = "h:mm a 'on' MMMM dd, yyyy"
        case day  = "EEEE"
        case time = "h:mm a"
    }
}
