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
        
        // set up activity view controller
        let noteToShare = [note.body]
        
        let activityViewController = UIActivityViewController(activityItems: noteToShare as [Any], applicationActivities: nil)
        
        // this adds supports for ipads
        activityViewController.popoverPresentationController?.sourceView = viewController.view
        
        // set the subject line for emails
        activityViewController.setValue(note.title, forKey: "Subject")
        
        // present the controller
        viewController.present(activityViewController, animated: true, completion: nil)
        
    }
    
    private init() {}
}
