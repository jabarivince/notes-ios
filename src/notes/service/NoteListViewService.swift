//
//  NoteListViewService.swift
//  notes
//
//  Created by jabari on 5/26/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

class NoteListViewService {
    var controller: NoteListViewController!
    
    enum Mode {
        case none
        case searching
        case editing
        case searchingAndEditing
    }
    
    enum NoteListState {
        case none
        case one
        case many
    }
    
    enum SelectState {
        case none
        case one
        case many
    }
    
    struct State {
        var mode: Mode
        var noteListState: NoteListState
        var selectState: SelectState
    }
    
    enum ActionButtonMode {
        case add
        case share
    }
    
    struct ViewState {
        let actionButtonMode: ActionButtonMode
        let selectButtonTitle: String
        let selectAllButtonTitle: String
        let selectButtonIsEnabled: Bool
        let shareButtonIsEnabled: Bool
        let addButtonIsEnabled: Bool
        let selectAllButtonIsEnabled: Bool
        let deleteButtonIsEnabled: Bool
        let backgroundState: NoteListBackgroundView.State
    }
}
