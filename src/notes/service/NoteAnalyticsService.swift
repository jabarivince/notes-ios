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
        let event = Event(type: .createNote)
        let parameters = getCreateNoteEventParameters(for: note)
        
        publish(event, parameters: parameters)
    }
    
    /// Read
    func publishReadNoteEvent(for note: Note) {
        let event = Event(type: .readNote)
        let parameters = getReadNoteEventParameters(for: note)
        
        publish(event, parameters: parameters)
    }
    
    /// Update
    func publishUpdateNoteEvent(for note: Note) {
        let event = Event(type: .updateNote)
        let parameters = getUpdateNoteEventParameters(for: note)
        
        publish(event, parameters: parameters)
    }
    
    /// Delete
    func publishDeleteNoteEvent(for note: Note) {
        let event = Event(type: .deleteNote)
        let parameters = getDeleteNoteEventParameters(for: note)
        
        publish(event, parameters: parameters)
    }
    
    /// Delete batch
    func publishDeleteBatchNoteEvent(for notes: Set<Note>) {
        let event = Event(type: .deleteBatchNote)
        let parameters = getDeleteBatchNoteEventParameters(for: notes)
        
        publish(event, parameters: parameters)
    }
    
    /// Send
    func publishSendNoteEvent(for note: Note) {
        let event = Event(type: .sendNote)
        let parameters = getSendNoteEventParameters(for: note)
        
        publish(event, parameters: parameters)
    }
    
    /// Singleton = no public inits
    private init() {}
}

/// Auxiliary functions for preparing parameters for events
extension NoteAnalyticsService {
    
    // Create
    func getCreateNoteEventParameters(for note: Note) -> [String: Any] {
        let parameters: [String: Any] = [: ]
        
        // TODO: Figure out what we want to track
        
        return parameters
    }
    
    // Read
    func getReadNoteEventParameters(for note: Note) -> [String: Any] {
        let parameters: [String: Any] = [: ]
        
        // TODO: Figure out what we want to track
        
        return parameters
    }
    
    // Update
    func getUpdateNoteEventParameters(for note: Note) -> [String: Any] {
        let parameters: [String: Any] = [: ]
        
        // TODO: Figure out what we want to track
        
        return parameters
    }
    
    // Delete
    func getDeleteNoteEventParameters(for note: Note) -> [String: Any] {
        let parameters: [String: Any] = [: ]
        
        // TODO: Figure out what we want to track
        
        return parameters
    }
    
    // Delete batch
    func getDeleteBatchNoteEventParameters(for notes: Set<Note>) -> [String: Any] {
        let parameters: [String: Any] = [: ]
        
        // TODO: Figure out what we want to track
        
        return parameters
    }
    
    // Send
    func getSendNoteEventParameters(for note: Note) -> [String: Any] {
        let parameters: [String: Any] = [: ]
        
        // TODO: Figure out what we want to track
        
        return parameters
    }
}

