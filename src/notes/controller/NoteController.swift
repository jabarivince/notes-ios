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
    private let noteService: NoteService
    private let note: Note
    private var timer: Timer?
    
    init(note: Note, noteService: NoteService) {
        self.note        = note
        self.noteService = noteService
        self.textView    = UITextView()
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
        let noteTitle: UIButton = {
            let button              = UIButton(type: .custom)
            button.frame            = CGRect(x: 0, y: 0, width: 100, height: 40)
            button.backgroundColor  = .clear
            button.titleLabel?.font = button.titleLabel?.font.bolded
            button.setTitle(note.title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.addTarget(self, action: #selector(changeNoteName), for: .touchUpInside)
            return button
        }()
        
        navigationItem.titleView          = noteTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sendNote))
        
        let spacer            = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let trashButton       = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))
        toolbarItems          = [spacer, trashButton]
        trashButton.tintColor = .red
        navigationController?.setToolbarHidden(false, animated: false)
        
        let keyboardToolbar: UIToolbar = {
            let bar       = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneBtn   = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(closeKeyboard))
            bar.setItems([flexSpace, doneBtn], animated: false)
            bar.sizeToFit()
            return bar
        }()
        
        let tapRecognizer: UITapGestureRecognizer = {
            let r = UITapGestureRecognizer(target: self, action: #selector(textViewTapped))
            r.delegate = self
            r.numberOfTapsRequired = 1
            return r
        }()
        
        textView.delegate                          = self
        textView.isEditable                        = false
        textView.adjustsFontForContentSizeCategory = true
        textView.dataDetectorTypes                 = .all
        textView.keyboardDismissMode               = .interactive
        textView.font                              = .preferredFont(forTextStyle: .body)
        textView.text                              = note.body
        textView.inputAccessoryView                = keyboardToolbar
        textView.addGestureRecognizer(tapRecognizer)
        view.addSubview(textView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
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
    
    private func removeObservers() {
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
        
        var contentInset      = textView.contentInset
        contentInset.bottom   = keyboardSize.height
        textView.contentInset = contentInset
        var frame             = textView.frame
        frame.size.height    -= keyboardSize.height
    }
    
    /// Restores scrollView height to full height
    @objc private func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            let contentInset           = UIEdgeInsets.zero
            self.textView.contentInset = contentInset
        }
    }
}

extension NoteController: UIGestureRecognizerDelegate {
    /// Enables editing on textView and displays keyboard,
    /// places cursor at end of line that was tapped
    @objc private func textViewTapped(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            let location = recognizer.location(in: textView)

            if let position = textView.closestPosition(to: location) {
                textView.selectedTextRange = textView.textRange(from: position, to: position)
            }
            
            textView.isEditable = true
            textView.becomeFirstResponder()
        }
    }
}

extension NoteController: UITextViewDelegate {
    /// Autosaves half a second after stop typing
    func textViewDidChange(_ textView: UITextView) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5,
                                     target: self,
                                     selector: #selector(saveNote),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    /// Disabled editing (to re-anble hyperlink detection, etc) and save
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.isEditable = false
        textView.resignFirstResponder()
        saveNote()
    }
}
