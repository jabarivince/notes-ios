//
//  NoteController.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

/// Clase responsible for displaying a note
/// and handling events such as save and send.
class NoteController: UIViewController {
    private let noteService: NoteService
    private let note: Note
    private let textView = UITextView()
    
    init(note: Note, noteService: NoteService) {
        self.note = note
        self.noteService = noteService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// We set the textview size here because
    /// we are using AutoLayout rather than LayoutConstraints
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Textview should take up full screen (for now)
        textView.frame.size.width = view.bounds.width
        textView.frame.size.height = view.bounds.height
    }
    
    /// One time function call to setup initial state of view
    override func viewDidLoad() {
        title = note.title
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(send))
                
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = note.body
        view.addSubview(textView)
    }
    
    /// Do not use large titles. Takes too much screen space.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
}

/// Callbacks for buttons presses such as sending
/// the note in an email, text, saving it, or closing
/// the currently opened note
extension NoteController {
    @objc private func send() {
        noteService.noteSender.sendNote(note: note, viewController: self)
    }
    
    @objc private func close() {
        note.body = textView.text
        noteService.noteFactory.saveNote(note: note)
        navigationController?.popViewController(animated: true)
    }
}
