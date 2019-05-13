//
//  Stringifiable.swift
//  notes
//
//  Created by jabari on 5/19/19.
//  Copyright © 2019 jabari. All rights reserved.
//

/// Protocol used for sending a note,
/// or multiple notes via iOS sharing view
public protocol Stringifiable {
    var stringified: String { get }
}
