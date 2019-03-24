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

class DefaultNoteSender: NoteSender {
    func sendNote(note: Note, viewController: UIViewController) {
        // TODO - Figure out how to send the note as an email
        // where the title is the subject and the note body is
        // the email body
        
        let alert = UIAlertController(title: "Coming soon", message: "Feature not yet implemented.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        viewController.present(alert, animated: true)
    }
}
