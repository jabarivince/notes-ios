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
    
    /// The state object contains all of the state of
    /// the service. This massive didSet we can think about
    /// as way of always keeping the view up to date. Whenever
    /// events are dispatched from the view, their delegates
    /// just modify / refresh the state. At the end of this
    /// didSet, the controller viewState object is modified,
    /// causing the didSet in the view controller to update the
    /// view. This approach allows interactions to flow in one direction.
    /// The view controller calls the service, the service updates
    /// the state, and the state is sent back to the view controller.
    /// We can think about it like a refresh cycle.
    private var state: State! {
        didSet {
            // Either we are not editing or we just started editing
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
                    viewState.toolbarIsHidden         = false
                } else {
                    viewState.editButtonTitle         = "Select"
                    viewState.rightBarButtonState     = .add
                    viewState.rightBarButtonIsEnabled = true
                    viewState.toolbarIsHidden         = true
                }
                
            // We have already selected at least 1 note
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
            
            // No notes are on screen
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
                
            // Notes are on screen so remove background
            } else {
                viewState.seperatorStyle         = .singleLine
                viewState.backgroundView         = nil
                viewState.scrollingEnabled       = true
                viewState.leftBarButtonIsEnabled = true
            }
            
            // Select all button is disabled when editing,
            // searching, and no notes are found
            if controller.isEditing && state.isSearching && state.notes.isEmpty {
                viewState.selectButtonIsEnabled = false
                
            // Otherwise it is always enabled
            } else {
                viewState.selectButtonIsEnabled = true
            }
      
            // Trigger view refresh in view controller
            controller.state = viewState
        }
    }
    
    override private init() {}
}

// MARK:- Public non-state-affecting functions
// All functions that are publically exposed to
// the controller that DO NOT modify the state.
// That means, they should not in anyway trigger
// the didSet on the state.
extension NoteListViewService {
    @objc func handleShareButtonTapped() {
        guard atLeastOneNoteSelected else { return }
        noteService.sendNotes(selectedNotes, viewController: controller)
    }
    
    @objc func handleAddButtonTapped() {
        let note = noteService.createNote(with: nil)
        openNote(note, asNew: true)
    }
}

// MARK:- Public state-affecting functions
// All functions in here respond to some UI event and must
// trigger the didSet on the state by either modifying the
// state, or manually calling the refreshState() function.
// This way we trigger a view refresh within the view controller.
extension NoteListViewService {
    func viewWillAppear() {
        getNotes()
    }
    
    func setEditing() {
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
            // We set this to avoid already presenting issues
            // https://stackoverflow.com/questions/31487824/error-application-tried-to-present-modal-view-controller-on-itself-while-activ
            controller.searchController.isActive = false
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
    /// Manually triggers the didSet on the state.
    /// This is used merely to manually trigger a view
    /// even when there is no new data to send to
    /// the state object.
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
