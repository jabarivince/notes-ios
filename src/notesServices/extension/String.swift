//
//  String.swift
//  notes
//
//  Created by jabari on 3/26/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

public extension String {
    var asNSString: NSString {
        return self as NSString
    }
    
    var firstLine: String {
        return components(separatedBy: "\n")[0]
    }
    
    func truncated(after length: Int, trailedWith trailing: String = "…") -> String {
        return (count > length) ? prefix(length) + trailing : self
    }
}
