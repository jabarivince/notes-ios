//
//  NotePersistenceService.swift
//  notesServices
//
//  Created by jabari on 5/16/19.
//  Copyright © 2019 jabari. All rights reserved.
//

protocol NotePersistenceService {
    var allNotes: [Note] { get }
    func createNote() -> Note
    func delete(_ note: Note)
    func delete(_ notes: Set<Note>)
    func save(_ note : Note)
}
