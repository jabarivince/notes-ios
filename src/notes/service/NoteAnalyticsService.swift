//
//  NoteAnalyticsService.swift
//  notes
//
//  Created by jabari on 4/7/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import Firebase
import notesServices

extension AnalyticsService {
    func publish(_ event: Event) {
        let name = event.type.rawValue
        Analytics.logEvent(name, parameters: event.loggable?.parameters)
    }
}

class NoteAnalyticsService: AnalyticsService {
    static let instance = NoteAnalyticsService()
    
    func publishCreateNoteEvent(for note: Note) {
        let event = Event(type: .createNote, loggable: note)
        publish(event)
    }
    
    func publishCreateNoteEventFailed(for note: Note) {
        let event = Event(type: .createNoteFailed, loggable: note)
        publish(event)
    }
    
    func publishReadNoteEvent(for note: Note) {
        let event = Event(type: .readNote, loggable: note)
        publish(event)
    }
    
    func publishReadNoteEventFailed(for note: Note) {
        let event = Event(type: .readNoteFailed, loggable: note)
        publish(event)
    }
    
    func publishUpdateNoteEvent(for note: Note) {
        let event = Event(type: .updateNote, loggable: note)
        publish(event)
    }
    
    func publishUpdateNoteEventFailed(for note: Note) {
        let event = Event(type: .updateNoteFailed, loggable: note)
        publish(event)
    }
    
    func publishDeleteNoteEvent(for note: Note) {
        let event = Event(type: .deleteNote, loggable: note)
        publish(event)
    }
    
    func publishDeleteNoteEventFailed(for note: Note) {
        let event = Event(type: .deleteNoteFailed, loggable: note)
        publish(event)
    }
    
    func publishDeleteBatchNoteEvent(for notes: Set<Note>) {
        let event = Event(type: .deleteBatchNote, loggable: notes)
        publish(event)
    }
    
    func publishDeleteBatchNoteEventFailed(for notes: Set<Note>) {
        let event = Event(type: .deleteBatchNoteFailed, loggable: notes)
        publish(event)
    }
    
    func publishSendNoteEvent(for note: Note) {
        let event = Event(type: .sendNote, loggable: note)
        publish(event)
    }
    
    func publishSendNoteEventFailed(for note: Note) {
        let event = Event(type: .sendNoteFailed, loggable: note)
        publish(event)
    }
    
    func publishSendBatchNoteEvent(for notes: Set<Note>) {
        let event = Event(type: .sendBatchNote, loggable: notes)
        publish(event)
    }
    
    func publishSendBatchNoteEventFailed(for notes: Set<Note>) {
        let event = Event(type: .sendBatchNoteFailed, loggable: notes)
        publish(event)
    }
    
    private init() {}
}


