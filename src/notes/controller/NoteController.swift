//
//  NoteController.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

class NoteController: UIViewController {
    let noteService = NoteService.noteService
    let textView = UITextView()
    private let note: Note
    
    init(note: Note) {
        self.note = note
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textView.frame.size.width = view.bounds.width
        textView.frame.size.height = view.bounds.height
    }
    
    override func viewDidLoad() {        
        title = note.title
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(send))
                
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = note.body
        
        if let existingFont = textView.font?.fontName {
            textView.font = UIFont(name: existingFont, size: 20)
        }
        
        view.addSubview(textView)
    }
}

extension NoteController {
    @objc func send() {
        noteService.emailNote(note: note, viewController: self)
    }
    
    @objc func close() {
        save { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func save(completion: (() -> Void)? = nil) {
        note.body = textView.text
        
        noteService.saveNote(note: note, completion: completion)
    }
}
