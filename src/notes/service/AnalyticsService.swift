//
//  EventService.swift
//  notes
//
//  Created by jabari on 4/7/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import Firebase

protocol AnalyticsService {
    func publish(_ event: Event)
}

extension AnalyticsService {
    func publish(_ event: Event) {
        let name = event.type.rawValue
        Analytics.logEvent(name, parameters: event.loggable?.parameters)
    }
}

struct Event {
    var type: EventType
    var loggable: Loggable?
    
    init(type: EventType, loggable: Loggable?) {
        self.type = type
        self.loggable = loggable
    }
    
    /// All events in alphabetical order
    enum EventType: String, CaseIterable {
        case createNote = "create_note_succeeded"
        case createNoteFailed = "create_note_failed"
        case deleteBatchNote = "delete_batch_note_succeeded"
        case deleteBatchNoteFailed = "delete_batch_note_failed"
        case deleteNote = "delete_note_succeeded"
        case deleteNoteFailed = "delete_note_failed"
        case readNote = "read_note_succeeded"
        case readNoteFailed = "read_note_failed"
        case sendBatchNote = "send_batch_note_succeeded"
        case sendBatchNoteFailed = "send_batch_note_failed"
        case sendNote = "send_note_succeeded"
        case sendNoteFailed = "send_note_failed"
        case unknownError = "unknown_error"
        case updateNote = "update_note_succeeded"
        case updateNoteFailed = "update_note_failed"
    }
}

protocol Loggable {
    var parameters: [String: Any] { get }
}
