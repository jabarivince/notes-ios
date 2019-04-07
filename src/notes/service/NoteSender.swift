//
//  NoteSender.swift
//  notes
//
//  Created by jabari on 3/24/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

// TODO: We can delete this class. There is no longer
// a need for this becuase we will not be abstracting
// the send() operation. The logic that opens the built-in
// sender can be written right into NoteController. If
// auxiliary functions are needed, they can be bunched together
// with the NoteFactory CRUD functions.

/// Protocol for defining send operationd for notes.
protocol NoteSender {
    static var singleton: NoteSender { get }
    func sendNote(note: Note, viewController: UIViewController)
}

class DefaultNoteSender: NoteSender {
    private static var instance: NoteSender?
    
    static var singleton: NoteSender {
        if instance == nil {
            instance = DefaultNoteSender()
        }
        
        return instance!
    }
    
    func sendNote(note: Note, viewController: UIViewController) {
        // TODO - Figure out how to send the note as an email where
        // the title is the subject and the note body is the email body
        
        let alert = UIAlertController(title: "Coming soon", message: "Feature not yet implemented.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        viewController.present(alert, animated: true)
    }
    
    private init() {}
}
