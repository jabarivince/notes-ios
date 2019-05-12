//
//  Loggable.swift
//  notes
//
//  Created by jabari on 5/19/19.
//  Copyright © 2019 jabari. All rights reserved.
//

/// Protocol used for sending a note,
/// or multiple notes CRUD events to Firebase
protocol Loggable {
    var parameters: [String: Any] { get }
}
