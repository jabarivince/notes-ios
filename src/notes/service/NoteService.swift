//
//  NoteService.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

class NoteService {
    private static var instance: NoteService? = nil
    
    static var singleton: NoteService {
        if instance == nil {
            instance = NoteService()
        }
        
        return instance!
    }
    
    let noteFactory = DefaultNoteFactory.singleton
    let noteSender = DefaultNoteSender.singleton
    
    private init() {}
}
