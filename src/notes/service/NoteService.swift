//
//  NoteService.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

class NoteService {
    let noteFactory = DefaultNoteFactory.singleton
    let noteSender = DefaultNoteSender.singleton
}
