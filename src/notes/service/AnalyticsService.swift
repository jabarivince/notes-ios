//
//  EventService.swift
//  notes
//
//  Created by jabari on 4/7/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import Firebase

/// Publishes events to Firebase
protocol AnalyticsService {
    
    /// Publish the event
    func publish(_ event: Event, parameters: [String: Any])
}

/// Provides a default implementation for publish method
extension AnalyticsService {
    
    /// Publishes event to Firebase
    func publish(_ event: Event, parameters: [String: Any]) {
        let name = event.type.rawValue
        Analytics.logEvent(name, parameters: parameters)
    }
}

/// Helper class for limiting the types of events
/// (by name) that can be published to Firebase.
class Event {
    var type: EventType
    
    init(type: EventType) {
        self.type = type
    }
    
    enum EventType: String {
        case createNote = "create_note"
        case readNote = "read_note"
        case updateNote = "update_note"
        case deleteNote = "delete_note"
        case deleteBatchNote = "delete_batch_note"
        case sendNote = "send_note"
    }
}
