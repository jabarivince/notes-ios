//
//  NoteController.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {
    private let titleButton: UIButton
    private let noteService: NoteService
    private let noteView:    NoteView
    private let note:        Note
    
    private var noteTitle: String? {
        didSet {
            titleButton.setTitle(noteTitle, for: .normal)
        }
    }
    
    private var noteBody: String? {
        return noteView.text
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noteView.frame.size.width  = view.bounds.width
        noteView.frame.size.height = view.bounds.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
        removeObservers()
        closeNote()
    }
    
    override func viewDidLoad() {
        setupToolbars()
        setupTitleButton()
        setupTextView()
    }
    
    init(note: Note, noteService: NoteService) {
        self.noteView    = NoteView()
        self.titleButton = UIButton(type: .custom)
        self.note        = note
        self.noteService = noteService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- CRUD opertions
private extension NoteViewController {
    @objc func deleteNote() {
        promptToContinue(withMessage: "Deleting this note cannot be undone") { [weak self] in
            guard let self = self else { return }
            self.noteService.deleteNote(note: self.note)
            self.closeNote(withoutSaving: true)
        }
    }
    
    @objc func saveNote() {
        guard isDirty else { return }
        note.title = noteTitle
        note.body  = noteBody
        noteService.saveNote(note: note)
    }
    
    @objc func changeNoteName() {
        promptForText(withMessage: "Rename your note", placeholder: "Untitled", initialValue: noteTitle) { [weak self] title in
            guard let self = self else { return }
            self.noteTitle = title
        }
    }
}

// MARK:- Button callbacks
private extension NoteViewController {
    private var isDirty: Bool  {
        return noteTitle != note.title || noteBody != note.body
    }
    
    @objc func openMenu() {
        presentActionSheet(for: [
            (title: "Change note title", action: changeNoteName)
        ])
    }
    
    @objc func sendNote() {
        saveNote()
        noteService.sendNote(note, viewController: self)
    }
    
    @objc func closeNote(withoutSaving: Bool = false) {
        if !withoutSaving {
            saveNote()
        }
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK:- UI setup
private extension NoteViewController {
    func setupToolbars() {
        let spacer            = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let shareButton       = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sendNote))
        let trashButton       = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))
        let menuButton        = UIBarButtonItem(title: "•••", style: .plain, target: self, action: #selector(openMenu))
        trashButton.tintColor = .red
        toolbarItems          = [menuButton, spacer, trashButton]
        navigationItem.rightBarButtonItem = shareButton
    }
    
    func setupTitleButton() {
        titleButton.setTitleColor(.black, for: .normal)
        titleButton.addTarget(self, action: #selector(changeNoteName), for: .touchUpInside)
        titleButton.frame            = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleButton.backgroundColor  = .clear
        titleButton.titleLabel?.font = titleButton.titleLabel?.font.bolded
        noteTitle                    = note.title
        navigationItem.titleView     = titleButton
    }
    
    func setupTextView() {
        noteView.text            = note.body
        noteView.autosave        = saveNote
        noteView.autosaveTimeout = 0.2
        view.addSubview(noteView)
    }
}

// MARK:- Notification observers
private extension NoteViewController {
    func addObservers() {
        respondTo(notification: UIResponder.keyboardWillShowNotification, with: #selector(keyboardWillShow))
        respondTo(notification: UIResponder.keyboardWillHideNotification, with: #selector(keyboardWillHide))
    }
    
    
    
    /// Returns size frame of the keyboard
    func getKeyboardSize(from notification: Notification) -> CGRect? {
        return (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
    }
    
    /// Shrinks scrollView height such that keyboard does not cover it
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = getKeyboardSize(from: notification) else { return }
        var contentInset       = noteView.contentInset
        contentInset.bottom    = keyboardSize.height
        noteView.contentInset  = contentInset
        var frame              = noteView.frame
        frame.size.height     -= keyboardSize.height
    }
    
    /// Restores scrollView height to original height
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            let contentInset           = UIEdgeInsets.zero
            self.noteView.contentInset = contentInset
        }
    }
}
