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
        var notes: [Note]
        var isSearching: Bool
        
        static let `default` = State(notes: [], isSearching: false)
    }
}
