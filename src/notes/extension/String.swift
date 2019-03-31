//
//  String.swift
//  notes
//
//  Created by jabari on 3/26/19.
//  Copyright © 2019 jabari. All rights reserved.
//

extension String {
    var firstLine: String {
        return components(separatedBy: "\n")[0]
    }
    
    func truncated(after length: Int, trailedWith trailing: String = "…") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
}
