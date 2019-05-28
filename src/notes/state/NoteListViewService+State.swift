//
//  NoteListState.swift
//  notes
//
//  Created by jabari on 5/27/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import notesServices

extension NoteListViewService {
    struct State {
        var notes: [Note] {
            didSet {
                if !notes.isEmpty {
                    backgroundState = .hidden
                } else {
                    switch tableState {
                    case .searching, .searchingAndEditing:
                        backgroundState = .noNotesFound
                    default:
                        backgroundState = .noNotesAvailable
                    }
                }
            }
        }
        
        var tableState: TableState
        var backgroundState: NoteListBackgroundView.State
        var selectAllButtonState: SelectAllButtonState
        var selectionState: SelectionState
        var tableViewSelectionHandler: TableViewSelectionHandler
        
        static let `default` = State(notes: [],
                                     tableState: .default,
                                     backgroundState: .hidden,
                                     selectAllButtonState: .unselected,
                                     selectionState: .none,
                                     tableViewSelectionHandler: .none)
        
        var isEditing: Bool {
            return tableState == .editing || tableState == .searchingAndEditing
        }
        
        var isSearching: Bool {
            return tableState == .searching || tableState == .searchingAndEditing
        }
        
        enum TableViewSelectionHandler {
            case none
            case select
            case deselect
        }
        
        enum SelectionState {
            case none
            case one
            case many
        }
        
        enum TableState {
            case `default`
            case editing
            case searching
            case searchingAndEditing
        }
        
        enum SelectAllButtonState {
            case selected
            case unselected
        }
    }
}
