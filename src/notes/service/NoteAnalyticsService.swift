//
//  NoteAnalyticsService.swift
//  notes
//
//  Created by jabari on 4/7/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import Firebase

/// Events related to Notes
class NoteAnalyticsService: AnalyticsService {
    
    /// Singleton
    static let instance = NoteAnalyticsService()
    
    /// Create
    func publishCreateNoteEvent(for note: Note) {
        let event = Event(type: .createNote, loggable: note)
        publish(event)
    }
    
    /// Read
    func publishReadNoteEvent(for note: Note) {
        let event = Event(type: .readNote, loggable: note)
        publish(event)
    }
    
    /// Update
    func publishUpdateNoteEvent(for note: Note) {
        let event = Event(type: .updateNote, loggable: note)
        publish(event)
    }
    
    /// Delete
    func publishDeleteNoteEvent(for note: Note) {
        let event = Event(type: .deleteNote, loggable: note)
        publish(event)
    }
    
    /// Delete batch
    func publishDeleteBatchNoteEvent(for notes: Set<Note>) {
        // TODO: Conform Set<Note> to Loggable
        let event = Event(type: .deleteBatchNote, loggable: nil)
        publish(event)
    }
    
    /// Send
    func publishSendNoteEvent(for note: Note) {
        let event = Event(type: .sendNote, loggable: note)
        publish(event)
    }
    
    /// Singleton = no public inits
    private init() {}
}

