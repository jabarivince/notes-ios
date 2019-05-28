//
//  NoteListViewState.swift
//  notes
//
//  Created by jabari on 5/27/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

struct NoteListViewState {
    let trashButtonIsEnabled: Bool
    let shareButtonIsEnabled: Bool
    let toolbarIsHidden: Bool
    let title: String
    let editButtonTitle: String
    let selectButtonTitle: String
    let backgroundView: UIView?
    let scrollingEnabled: Bool
    let seperatorStyle: UITableViewCell.SeparatorStyle
    let rightBarButtonState: RightBarButtonState
    let rightBarButtonIsEnabled: Bool
    let selectHandler: SelectHandler
    
    enum SelectHandler {
        case doNothing
        case selectAll
        case deselectAll
    }
    
    enum RightBarButtonState {
        case add
        case share
    }
}
