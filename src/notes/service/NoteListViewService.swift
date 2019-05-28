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
    weak var controller: NoteListViewController! {
        didSet {
            state = .default
        }
    }
    
    static let shared       = NoteListViewService()
    private let noteService = NoteService.shared
    
    private var state: State! {
        didSet {
            let trashButtonIsEnabled: Bool
            let shareButtonIsEnabled: Bool
            let toolbarIsHidden:      Bool
            let title:                String
            let editButtonTitle:      String
            let selectButtonTitle:    String
            let scrollingIsEnabled:   Bool
            let seperatorStyle:       UITableViewCell.SeparatorStyle
            let backgroundView:       NoteListBackgroundView?
            let rightBarButtonState:  NoteListViewState.RightBarButtonState
            let rightBarButtonIsEnabled: Bool
            let selectHandler:        NoteListViewState.SelectHandler
            
            // Table state
            switch state.tableState {
            case .default:
                editButtonTitle         = "Select"
                rightBarButtonState     = .add
                rightBarButtonIsEnabled = true
                
            case .editing:
                editButtonTitle         = "Done"
                rightBarButtonState     = .share
                rightBarButtonIsEnabled = false
                
            case .searching:
                editButtonTitle         = controller.state.editButtonTitle
                rightBarButtonState     = controller.state.rightBarButtonState
                rightBarButtonIsEnabled = true
                
            case .searchingAndEditing:
                editButtonTitle         = "Done"
                rightBarButtonIsEnabled = false
                rightBarButtonState     = controller.state.rightBarButtonState
            }
            
            // Note selection
            switch state.selectionState {
            case .none:
                trashButtonIsEnabled = false
                shareButtonIsEnabled = false
                toolbarIsHidden      = true
                
            case .one, .many:
                trashButtonIsEnabled = true
                shareButtonIsEnabled = true
                toolbarIsHidden      = false
            }
            
            // Select / deselect
            switch state.tableViewSelectionHandler {
            case .select:
                selectHandler = .selectAll
                
            case .deselect:
                selectHandler = .deselectAll
                
            case .none:
                selectHandler = .doNothing
            }
            
            // Background
            switch state.backgroundState {
            case .noNotesAvailable, .noNotesFound:
                backgroundView             = NoteListBackgroundView(frame: controller.tableView.frame)
                backgroundView!.tapHandler = openNewNote
                backgroundView!.state      = state.backgroundState
                scrollingIsEnabled         = false
                seperatorStyle             = .none
                
            default:
                backgroundView     = nil
                scrollingIsEnabled = true
                seperatorStyle     = .singleLine
            }
            
            // Select all button
            switch state.selectAllButtonState {
            case .unselected:
                title             = "The Note App"
                selectButtonTitle = "Select all"
            case .selected:
                title = "\(numberOfSelectedRows) Selected"
                selectButtonTitle = "Unselect \(numberOfSelectedRows) \(singularOrPlural)"
            }
            
            controller.state = NoteListViewState(trashButtonIsEnabled: trashButtonIsEnabled,
                                                 shareButtonIsEnabled: shareButtonIsEnabled,
                                                 toolbarIsHidden: toolbarIsHidden,
                                                 title: title,
                                                 editButtonTitle: editButtonTitle,
                                                 selectButtonTitle: selectButtonTitle,
                                                 backgroundView: backgroundView,
                                                 scrollingEnabled: scrollingIsEnabled,
                                                 seperatorStyle: seperatorStyle,
                                                 rightBarButtonState: rightBarButtonState,
                                                 rightBarButtonIsEnabled: rightBarButtonIsEnabled,
                                                 selectHandler: selectHandler)
        }
    }
    
    override private init() {}
}

extension NoteListViewService {
    func setEditing(_ editing: Bool, animated: Bool) {
        switch state.tableState {
        case .editing, .default:
            state.tableState = editing ? .editing : .default
        case .searching, .searchingAndEditing:
            state.tableState = editing ? .searchingAndEditing : .searching
        }
    }
    
    func refreshCells() {
        controller.tableView.reloadData()
    }
    
    func deleteSelectedNotes() {
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
    
    func sendMultipleNotes() {
        guard atLeastOneNoteSelected else { return }
        noteService.sendNotes(selectedNotes, viewController: controller)
    }
    
    func openNewNote() {
        let note = noteService.createNote(with: nil)
        openNote(note, asNew: true)
    }
    
    func getNotes() {
        state.notes = noteService.getAllNotes(containing: controller.searchController.searchBar.text)
        refreshCells()
    }
    
    func openNote(_ note: Note, asNew: Bool) {
        let noteController = NoteViewController(note: note, isNew: asNew)
        controller.navigationController?.pushViewController(noteController, animated: true)
    }
    
    func selectAllOrDeselectAllNotes() {
        guard state.isEditing else { return }
        state.tableViewSelectionHandler = atLeastOneNoteSelected ? .deselect : .select
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
        if zeroNotesSelected {
            state.selectionState       = .none
            state.selectAllButtonState = .unselected
        } else if moreThanOneNoteSelected {
            state.selectionState       = .many
            state.selectAllButtonState = .selected
        } else {
            state.selectionState       = .one
            state.selectAllButtonState = .selected
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        controller.searchController.searchBar.resignFirstResponder()
        
        if state.isEditing {
            state.selectAllButtonState = .selected
            
            if numberOfSelectedRows > 1 {
                state.selectionState = .many
            } else {
                state.selectionState = .one
            }
            
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
        if state.isEditing && atLeastOneNoteSelected {
            state.tableViewSelectionHandler = .deselect
        }
        return true
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if state.tableState == .editing {
            state.tableState = .searchingAndEditing
        } else {
            state.tableState = .searching
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if state.tableState == .editing {
            state.tableState = .default
        } else if state.tableState == .searchingAndEditing {
            state.tableState = .searching
        }
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
    
    // TODO: PUT THESE IN AN ENUM none, one, many
    
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
