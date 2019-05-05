//
//  NoteController.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

class NoteController: UIViewController {
    private let textView = UITextView()
    private let noteService: NoteService
    private let note: Note
    private var timer: Timer? = nil
    
    init(note: Note, noteService: NoteService) {
        self.note = note
        self.noteService = noteService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.frame.size.width  = view.bounds.width
        textView.frame.size.height = view.bounds.height
    }
    
    override func viewDidLoad() {
        let noteTitle              = UIButton(type: .custom)
        noteTitle.frame            = CGRect(x: 0, y: 0, width: 100, height: 40)
        noteTitle.backgroundColor  = .clear
        noteTitle.titleLabel?.font = noteTitle.titleLabel?.font.bolded
        noteTitle.setTitle(note.title, for: .normal)
        noteTitle.setTitleColor(.black, for: .normal)
        noteTitle.addTarget(self, action: #selector(changeNoteName), for: .touchUpInside)
        navigationItem.titleView = noteTitle
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self,
                                                            action: #selector(sendNote))
        
        let spacer            = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let trashButton       = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))
        trashButton.tintColor = .red
        toolbarItems          = [spacer, trashButton]
        navigationController?.setToolbarHidden(false, animated: false)
        
        let toolbar   = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBtn   = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closeKeyboard))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        textView.text               = note.body
        textView.delegate           = self
        textView.inputAccessoryView = toolbar
        view.addSubview(textView)
        addObservers()
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
    
    @objc private func saveNote() {
        note.body = textView.text
        noteService.saveNote(note: note)
    }
    
    @objc private func closeKeyboard() {
        textView.resignFirstResponder()
    }
    
    @objc private func changeNoteName() {
            let message     = "Rename your note"
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

extension NoteController {
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    /// Returns size frame of the keyboard
    private func getKeyboardSize(from notification: Notification) -> CGRect? {
        return (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
    }
    
    /// Shrinks scrollview height such that keyboard does not cover bottom
    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = getKeyboardSize(from: notification) else { return }
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        var frame         = view.frame
        
        textView.contentInset          = contentInsets
        textView.scrollIndicatorInsets = contentInsets
        frame.size.height             -= keyboardSize.height
    }
    
    /// Restores scrollView height to full height
    @objc private func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            let contentInsets                   = UIEdgeInsets.zero
            self.textView.contentInset          = contentInsets
            self.textView.scrollIndicatorInsets = contentInsets
        }
    }
}

extension NoteController: UITextViewDelegate {
    
    /// Autosave half a second after stop typing
    func textViewDidChange(_ textView: UITextView) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5,
                                     target: self,
                                     selector: #selector(saveNote),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        saveNote()
    }
}
