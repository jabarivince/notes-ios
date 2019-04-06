//
//  NoteService.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

class NoteService {
    
    // TODO: Get rid of this service, this is no longer
    // necessary because we will not be supporting cloud
    // storage, so there is no need to abstract note operations.
    
    let noteFactory = DefaultNoteFactory.singleton
    let noteSender = DefaultNoteSender.singleton
}
