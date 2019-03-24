//
//  NoteFactory.swift
//  notes
//
//  Created by jabari on 3/24/19.
//  Copyright © 2019 jabari. All rights reserved.
//

/// Protocol that specifies the CRUD operations on notes
protocol NoteFactory {
    var notes: [Note] { get }
    func createNote(title: String) -> Note
    func deleteNote(note: Note)
    func saveNote(note : Note, completion: (() -> Void)?)
}
