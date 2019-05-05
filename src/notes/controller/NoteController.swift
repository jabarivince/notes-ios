//
//  NoteController.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

class NoteController: UIViewController {
    private let textView: UITextView
    private var trashButton: UIBarButtonItem!
    private var spacer: UIBarButtonItem!
    private var noteTitle = UIButton(type: .custom)
    
    private let note: Note
    private let noteService: NoteService
    
    init(note: Note, noteService: NoteService) {
        self.note = note
        self.noteService = noteService
        self.textView = UITextView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.frame.size.width = view.bounds.width
        textView.frame.size.height = view.bounds.height
        
       // view.pinSubview(textView)
    }
    
    override func viewDidLoad() {
        // set note title
        noteTitle.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        noteTitle.backgroundColor = .clear
        noteTitle.setTitle(note.title, for: .normal)
        noteTitle.titleLabel?.font = noteTitle.titleLabel?.font.bolded
        noteTitle.setTitleColor(.black, for: .normal)
        noteTitle.addTarget(self, action: #selector(changeNoteName), for: .touchUpInside)
        navigationItem.titleView = noteTitle
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sendNote))
        view.translatesAutoresizingMaskIntoConstraints = true
        textView.translatesAutoresizingMaskIntoConstraints = true
        textView.text = note.body
        textView.delegate = self
        view.addSubview(textView)
        
        spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))
        trashButton.tintColor = .red
        toolbarItems = [spacer, trashButton]
        navigationController?.setToolbarHidden(false, animated: false)
        
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closeKeyboard))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        textView.inputAccessoryView = toolbar
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        closeNote()
    }
}

extension NoteController {
    @objc private func sendNote() {
        saveNote()
        noteService.sendNote(note, viewController: self)
    }
    
    @objc private func closeNote(withoutSaving: Bool = false) {
        if !withoutSaving {
            saveNote()
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func deleteNote() {
        let message = "Are you sure you want to delete this note?"
        
        func onYes() {
            noteService.deleteNote(note: note)
            closeNote(withoutSaving: true)
        }

        promptYesOrNo(withMessage: message, onYes: onYes, onNo: nil)
    }
    
    private func saveNote() {
        note.body = textView.text
        noteService.saveNote(note: note)
    }
    
    @objc private func closeKeyboard() {
        textView.resignFirstResponder()
    }
    
    @objc private func changeNoteName() {
            let message = "Rename your note"
            let placeholder = "Untitled"
            
            func onConfirm(title: String?) {
                note.title = title
                self.viewDidLoad()
            }
            
            promptForText(withMessage: message,
                          placeholder: placeholder,
                          onConfirm: onConfirm,
                          onCancel: nil)
    }
}

extension NoteController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        print("HERE")
    }
    
    private func getKeyboardHeight(from notification: Notification) -> CGFloat {
        return ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? .zero).height
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if view.frame.origin.y != 0 {
            var frame = view.frame
            frame.origin.y -= getKeyboardHeight(from: notification)
            view.frame = frame
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y += getKeyboardHeight(from: notification)
        }
    }
}
