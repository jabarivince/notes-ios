//
//  NoteViewService.swift
//  notes
//
//  Created by jabari on 5/25/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import notesServices
import UIKit

class NoteViewService {
    weak var controller: NoteViewController!
    private var noteService = NoteService.shared
    
    private var isNew: Bool
    
    private var noteView: NoteView {
        return controller.noteView
    }
    
    private var note: Note {
        didSet {
            noteTitle = note.title
            noteBody  = note.body
        }
    }
    
    private var noteTitle: String? {
        didSet {
            controller.titleButton.setTitle(noteTitle, for: .normal)
            controller.titleButton.accessibilityLabel = "Tap to change title from current title: \(noteTitle ?? "")"
        }
    }
    
    private var noteBody: String? {
        get {
            return noteView.text
        }
        
        set {
            noteView.text = newValue
        }
    }
    
    init(_ note: Note, isNew: Bool) {
        self.note  = note
        self.isNew = isNew
    }
}

// MARK:- Private API
private extension NoteViewService {
    var isDirty: Bool {
        return noteTitle != note.title || noteBody != note.body
    }
    
    /// This function writes any changes
    /// that are in memoru out to disk.
    func persistChanges() {
        note.title = noteTitle
        note.body  = noteBody
        noteService.saveNote(note: note)
    }
    
    /// Either saves the note, or deletes it. The purpose
    /// of this function is to delete a newly created unmodified
    /// note when closing it. In all other cases, use autosaveNote().
    func manuallySaveNote(orDelete: Bool = false) {
        let isClean = noteTitle == note.title && noteBody == ""
        
        if isNew {
            if isClean {
                if orDelete {
                    noteService.deleteNote(note: note)
                }
            } else {
                persistChanges()
            }
            
        } else if isDirty {
            persistChanges()
        }
    }
    
    /// Automatically save any in-memory changes
    /// that have not yet been persisted.
    func autosaveNote() {
        if isNew {
            manuallySaveNote()
        } else if isDirty {
            persistChanges()
        }
    }
    
    /// Closes the note and returns
    /// to the previous view controller.
    func closeNote() {
        controller.navigationController?.popViewController(animated: true)
    }
    
    /// Refreshed the note from disk
    func refreshNote() {
        let refreshedNote = noteService.refresh(note)
        
        if refreshedNote != nil {
            note = refreshedNote!
        } else {
            NoteAnalyticsService.shared.publishRefreshNoteFailed(for: note)

            controller.alert(title: "Error", message: "This note is no longer available") { [weak self] _ in
                guard let self = self else { return }
                self.controller.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK:- Publish API
extension NoteViewService {
    func respondToDidBecomeActiveNotification() {
        refreshNote()
    }
    
    func respondToWillResignActiveNotification() {
        manuallySaveNote(orDelete: false)
    }
    
    func respondToWillTerminateNotification() {
        manuallySaveNote(orDelete: true)
    }
    
    func respondToViewWillDisapper() {
        manuallySaveNote(orDelete: true)
    }
    
    func handleViewDidLoad() {
        noteTitle = note.title
        noteBody  = note.body
        noteView.autosave = autosaveNote
        noteView.autosaveTimeout = 0.2
    }
    
    func handleTitleButtonTapped() {
        let msg     = "Change note title"
        let initial = "Untitled"
        
        controller.promptForText(saying: msg, placeholder: initial, initialValue: noteTitle) { [weak self] title in
            guard let self = self else { return }
            self.noteTitle = title
        }
    }
    
    func handleMenuButtonTapped() {
        controller.presentActionSheet(for: [
            (title: (text: "Change title", style: .default),     action: handleTitleButtonTapped),
            (title: (text: "Share",        style: .default),     action: handleShareButtonTapped),
            (title: (text: "Delete",       style: .destructive), action: handleDeleteButtonTapped),
        ])
    }
    
    func handleShareButtonTapped() {
        autosaveNote()
        noteService.sendNote(note, viewController: controller, completion: refreshNote)
    }
    
    /// Opens a dialog that prompts the user
    /// to delete the currently opened note.
    func handleDeleteButtonTapped() {
        let msg    = "Deleting this note cannot be undone"
        let yesTxt = "Delete"
        let noTxt  = "Cancel"
        
        controller.promptToContinue(withMessage: msg, onYesText: yesTxt, onNoText: noTxt) { [weak self] in
            guard let self = self else { return }
            self.noteService.deleteNote(note: self.note)
            self.closeNote()
        }
    }
    
    /// Returns size frame of the keyboard
    func getKeyboardSize(from notification: Notification) -> CGRect? {
        return (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
    }
    
    /// Shrinks scrollView height such that keyboard does not cover it
    func respondToKeyboardWillShowNotification(_ notification: Notification) {
        guard let keyboardSize = getKeyboardSize(from: notification) else { return }
        var contentInset       = noteView.contentInset
        contentInset.bottom    = keyboardSize.height
        noteView.contentInset  = contentInset
        var frame              = noteView.frame
        frame.size.height     -= keyboardSize.height
    }
    
    /// Restores scrollView height to original height
    func respondToKeyboardWillHideNotification() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self   = self else { return }
            let contentInset = UIEdgeInsets.zero
            self.noteView.contentInset = contentInset
        }
    }
}
