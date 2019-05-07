//
//  NoteController.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

class NoteController: UIViewController {
    private let textView:    UITextView
    private let titleButton: UIButton
    private let noteService: NoteService
    private let note:        Note
    private var isDirty:     Bool
    private var timer:       Timer?
    
    init(note: Note, noteService: NoteService) {
        self.isDirty     = false
        self.note        = note
        self.noteService = noteService
        self.textView    = UITextView()
        self.titleButton = UIButton(type: .custom)
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
        titleButton.frame            = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleButton.backgroundColor  = .clear
        titleButton.titleLabel?.font = titleButton.titleLabel?.font.bolded
        titleButton.setTitleColor(.black, for: .normal)
        titleButton.addTarget(self, action: #selector(changeNoteName), for: .touchUpInside)
        
        titleButton.setTitle(note.title, for: .normal)
        
        navigationItem.titleView          = titleButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sendNote))
        
        let spacer            = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let menuButton        = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(openMenu))
        let trashButton       = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))
        toolbarItems          = [menuButton, spacer, trashButton]
        trashButton.tintColor = .red
        
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
        textView.linkTextAttributes                = [
            .foregroundColor: view.tintColor ?? UIColor(red: 0, green: 122/255, blue: 1, alpha: 1),
            .underlineStyle : NSUnderlineStyle.single.rawValue
        ]
        textView.addGestureRecognizer(tapRecognizer)
        view.addSubview(textView)
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
        isDirty = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5,
                                     target: self,
                                     selector: #selector(saveNote),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    /// Disabled editing (to re-anble hyperlink detection, etc) and save
    func textViewDidEndEditing(_ textView: UITextView) {
        isDirty = true
        textView.isEditable = false
        textView.resignFirstResponder()
        saveNote()
    }
}

private extension NoteController {
    @objc func openMenu() {
        let alert = UIAlertController(title: "Additional options", message: nil, preferredStyle: .actionSheet)
        
        let changeNoteTitle: UIAlertAction = {
            let action = UIAlertAction(title: "Change note title", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.changeNoteName()
            }
            
            return action
        }()

        alert.addAction(changeNoteTitle)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        presentedVC.present(alert, animated: true, completion: nil)
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
    
    @objc func deleteNote() {
        let message = "Are you sure you want to delete this note?"
        
        func onYes() {
            noteService.deleteNote(note: note)
            closeNote(withoutSaving: true)
        }
        
        promptYesOrNo(withMessage: message, onYes: onYes, onNo: nil)
    }
    
    @objc func saveNote() {
        note.body = textView.text
        noteService.saveNote(note: note)
    }
    
    @objc func closeKeyboard() {
        textView.resignFirstResponder()
    }
    
    @objc func changeNoteName() {
        let message     = "Rename your note"
        let placeholder = "Untitled"
        
        func onConfirm(title: String?) {
            isDirty    = title != note.title
            note.title = title
            self.viewDidLoad()
        }
        
        promptForText(withMessage: message,
                      placeholder: placeholder,
                      initialValue: note.title,
                      onConfirm: onConfirm,
                      onCancel: nil)
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func removeObservers() {
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
    func getKeyboardSize(from notification: Notification) -> CGRect? {
        return (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
    }
    
    /// Shrinks scrollview height such that keyboard does not cover bottom
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = getKeyboardSize(from: notification) else { return }
        
        var contentInset      = textView.contentInset
        contentInset.bottom   = keyboardSize.height
        textView.contentInset = contentInset
        var frame             = textView.frame
        frame.size.height    -= keyboardSize.height
    }
    
    /// Restores scrollView height to full height
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            let contentInset           = UIEdgeInsets.zero
            self.textView.contentInset = contentInset
        }
    }
}
