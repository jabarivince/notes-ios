//
//  NoteSender.swift
//  notes
//
//  Created by jabari on 3/24/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

/// Protocol for defining send operationd for notes.
protocol NoteSender {
    func sendNote(note: Note, viewController: UIViewController)
}
