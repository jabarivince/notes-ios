//
//  NSRange.swift
//  notes
//
//  Created by jabari on 5/9/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import Foundation

extension NSRange {
    func contains(_ index: Int) -> Bool {
        return index > location && index < location + length
    }
}
