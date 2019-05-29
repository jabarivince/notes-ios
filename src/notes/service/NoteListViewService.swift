//
//  NoteListViewService.swift
//  notes
//
//  Created by jabari on 5/26/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit
import notesServices

class NoteListViewService: NSObject {
    static let shared       = NoteListViewService()
    private let noteService = NoteService.shared
    private var viewState   = NoteListViewState.default
    
    weak var controller: NoteListViewController! {
        didSet {
            state = .default
        }
    }
    
    private var state: State! {
        didSet {
            // Note selection
            if !controller.isEditing || (controller.isEditing && zeroNotesSelected) {
                viewState.trashButtonIsEnabled = false
                viewState.shareButtonIsEnabled = false
                viewState.toolbarIsHidden      = true
                viewState.title                = "The Note App"
                viewState.selectButtonTitle    = "Select all"
                
                if controller.isEditing {
                    viewState.editButtonTitle         = "Done"
                    viewState.rightBarButtonState     = .share
                    viewState.rightBarButtonIsEnabled = false
                } else {
                    viewState.editButtonTitle         = "Select"
                    viewState.rightBarButtonState     = .add
                    viewState.rightBarButtonIsEnabled = true
                }
                
            } else {
                viewState.trashButtonIsEnabled    = true
                viewState.shareButtonIsEnabled    = true
                viewState.toolbarIsHidden         = false
                viewState.title                   = "\(numberOfSelectedRows) Selected"
                viewState.selectButtonTitle       = "Unselect \(numberOfSelectedRows) \(singularOrPlural)"
                viewState.editButtonTitle         = "Done"
                viewState.rightBarButtonState     = .share
                viewState.rightBarButtonIsEnabled = true
            }
            
            // Background
            if state.notes.isEmpty {
                viewState.backgroundView             = NoteListBackgroundView(frame: controller.tableView.frame)
                viewState.backgroundView!.tapHandler = handleAddButtonTapped
                viewState.seperatorStyle             = .none
                viewState.scrollingEnabled           = false
                viewState.leftBarButtonIsEnabled     = false
                
                if state.isSearching && !(controller.searchText ?? "").isEmpty {
                    viewState.backgroundView!.state = .noNotesFound
                } else {
                    viewState.backgroundView!.state = .noNotesAvailable
                }
            } else {
                viewState.seperatorStyle         = .singleLine
                viewState.backgroundView         = nil
                viewState.scrollingEnabled       = true
                viewState.leftBarButtonIsEnabled = true
            }
      
            // Trigger view refresh in view controller
            controller.state = viewState
        }
    }
    
    override private init() {}
}

extension NoteListViewService {
    func viewWillAppear() {
        getNotes()
    }
    
    func setEditing(_ editing: Bool, animated: Bool) {
        refreshState()
    }
    
    @objc func handleTrashButtonTapped() {
        guard atLeastOneNoteSelected else { return }
        
        let thisOrThese   = moreThanOneNoteSelected ? "these" : "this"
        let numberOfNotes = moreThanOneNoteSelected ? "\(numberOfSelectedRows) " : ""
        let message       = "Deleting \(thisOrThese) \(numberOfNotes)\(singularOrPlural) cannot be undone"
        
        controller.promptToContinue(withMessage: message, onYesText: "Delete", onNoText: "Cancel") { [weak self] in
            guard let self = self else { return }
            
            self.noteService.deleteNotes(self.selectedNotes)
            self.controller.setEditing(false, animated: true)
            self.getNotes()
        }
    }
    
    @objc func handleShareButtonTapped() {
        guard atLeastOneNoteSelected else { return }
        noteService.sendNotes(selectedNotes, viewController: controller)
    }
    
    @objc func handleAddButtonTapped() {
        let note = noteService.createNote(with: nil)
        openNote(note, asNew: true)
    }
    
    @objc func handleSelectAllButtonTapped() {
        guard controller.isEditing else { return }
        
        if atLeastOneNoteSelected {
            controller.tableView.deselectAllRows()
        } else {
            controller.tableView.selectAllRows()
        }
        
        refreshState()
    }
    
    @objc func respondToDidBecomeActiveNotification() {
        getNotes()
    }
    
    @objc func respondToSignificantTimeChangeNotification() {
        refreshCells()
    }
}

extension NoteListViewService: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.notes.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let note = state.notes.remove(at: indexPath.row)
        noteService.deleteNote(note: note)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell   = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.cellId) as! NoteTableViewCell
        let note   = state.notes[indexPath.row]
        let state  = NoteTableViewCellState(from: note)
        cell.state = state
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        refreshState()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        controller.searchController.searchBar.resignFirstResponder()
        
        if controller.isEditing {
            refreshState()
        } else {
            openNote(state.notes[indexPath.row], asNew: false)
        }
    }
}

// MARK:- UITextViewDelegate
extension NoteListViewService : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getNotes()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if controller.isEditing && atLeastOneNoteSelected {
            controller.tableView.deselectAllRows()
        }
        
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        state.isSearching = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        state.isSearching = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        state.isSearching = false
        controller.setEditing(false, animated: true)
    }
}

private extension NoteListViewService {
    func refreshState() {
        state = { state }()
    }
    
    func refreshCells() {
        controller.tableView.reloadData()
    }
    
    func getNotes() {
        state.notes = noteService.getAllNotes(containing: controller.searchText)
        refreshCells()
    }
    
    func openNote(_ note: Note, asNew: Bool) {
        let noteController = NoteViewController(note: note, isNew: asNew)
        controller.navigationController?.pushViewController(noteController, animated: true)
    }
}

// MARK:- Select all / deselect all
private extension NoteListViewService {
    var singularOrPlural: String {
        return moreThanOneNoteSelected ? "notes" : "note"
    }
    
    var numberOfSelectedRows: Int {
        return selectedIndices.count
    }
    
    var zeroNotesSelected: Bool {
        return numberOfSelectedRows == 0
    }
    
    var moreThanOneNoteSelected: Bool {
        return numberOfSelectedRows > 1
    }
    
    var atLeastOneNoteSelected: Bool {
        return numberOfSelectedRows > 0
    }
    
    var selectedNotes: Set<Note> {
        var selection: Set<Note> = []
        
        if atLeastOneNoteSelected {
            selection = Set(selectedIndices.map { state.notes[$0.row] })
        }
        
        return selection
    }
    
    var selectedIndices: [IndexPath] {
        return controller.tableView.indexPathsForSelectedRows ?? []
    }
}
