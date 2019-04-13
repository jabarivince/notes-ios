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
        let event = Event(type: .deleteBatchNote, loggable: notes)
        publish(event)
    }
    
    /// Send
    func publishSendNoteEvent(for note: Note) {
        let event = Event(type: .sendNote, loggable: note)
        publish(event)
    }
    
    /// Send batch
    func publishSendBatchNoteEvent(for notes: Set<Note>) {
        let event = Event(type: .sendBatchNote, loggable: notes)
        publish(event)
    }
    
    /// Generic function for logging stringifiable send events
    func publishSendStringifiableLoggableEvent<T>(for value: T) where T: Loggable, T: Stringifiable {
        if let note = value as? Note {
            publishSendNoteEvent(for: note)
            
        } else if let notes = value as? Set<Note> {
            
            publishSendBatchNoteEvent(for: notes)
        } else {
            // Error or log no associated function
        }
    }
    
    /// Singleton = no public inits
    private init() {}
}

