//
//  NoteAnalyticsService.swift
//  notes
//
//  Created by jabari on 4/7/19.
//  Copyright © 2019 jabari. All rights reserved.
//

public class NoteAnalyticsService: AnalyticsService {
    public var publish: ((Event) -> Void)?
    public static let shared = NoteAnalyticsService()
    
    func publishSendNoteEvent(for note: Note) {
        let event = Event(type: .sendNote, loggable: note)
        publish?(event)
    }
    
    func publishSendBatchNoteEvent(for notes: Set<Note>) {
        let event = Event(type: .sendBatchNote, loggable: notes)
        publish?(event)
    }
    
    func publishSendNoteFailedEvent(for loggable: Loggable) {
        let event = Event(type: .sendNoteFailed, loggable: loggable)
        publish?(event)
    }
    
    public func publishRefreshNoteFailed(for note: Note) {
        let event = Event(type: .refreshNoteFailed, loggable: note)
        publish?(event)
    }
    
    private init() {}
}




