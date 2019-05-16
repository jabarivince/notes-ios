//
//  EventService.swift
//  notes
//
//  Created by jabari on 4/7/19.
//  Copyright © 2019 jabari. All rights reserved.
//

public protocol AnalyticsService {
    func publish(_ event: Event)
}

public struct Event {
    public var type: EventType
    public var loggable: Loggable?
    
    public init(type: EventType, loggable: Loggable?) {
        self.type = type
        self.loggable = loggable
    }
    
    /// All events in alphabetical order.
    /// All events must be lowercase and snakecase.
    public enum EventType: String, CaseIterable {
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
