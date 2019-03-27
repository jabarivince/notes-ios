//
//  NoteService.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

class NoteService {
    static let noteFactory = DefaultNoteFactory.singleton
    static let noteSender = DefaultNoteSender.singleton
}
