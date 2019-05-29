//
//  NoteListViewState.swift
//  notes
//
//  Created by jabari on 5/27/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

struct NoteListViewState {
    var trashButtonIsEnabled    = false
    var shareButtonIsEnabled    = false
    var toolbarIsHidden         = true
    var title                   = ""
    var editButtonTitle         = ""
    var selectButtonTitle       = ""
    var scrollingEnabled        = true
    var seperatorStyle          = UITableViewCell.SeparatorStyle.none
    var rightBarButtonState     = RightBarButtonState.add
    var rightBarButtonIsEnabled = false
    var leftBarButtonIsEnabled  = true
    var backgroundView: NoteListBackgroundView? = nil
    
    enum RightBarButtonState {
        case add
        case share
    }

    static let `default` = NoteListViewState()
}
