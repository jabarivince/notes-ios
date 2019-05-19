//
//  NoteService.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

public class NoteService {
    public static let shared = NoteService()
    
    internal var sharingService:   NoteSharingService
    internal var analyticsService: NoteAnalyticsService
    internal var coreDataService:  NotePersistenceService
    
    public func getAllNotes(containing searchText: String? = nil) -> [Note] {
        guard let searchText = searchText, !searchText.isEmpty else { return coreDataService.allNotes }
        
        return coreDataService.allNotes.filter { note in
            note.contains(text: searchText)
        }
    }
    
    public func createNote(with title: String?, body: String? = nil) -> Note {
        let note = coreDataService.createNote()
        let now  = Date()
        
        note.createdDate    = now
        note.lastEditedDate = now
        
        if title?.isEmpty ?? true {
            note.title = "Untitled"
        } else {
            note.title = title
        }
        
        note.body = body
        coreDataService.save(note)
        return note
    }
    
    public func deleteNote(note: Note) {
        coreDataService.delete(note)
    }
    
    public func deleteNotes(_ notes: Set<Note>) {
        coreDataService.delete(notes)
    }
    
    public func saveNote(note : Note) {
        let now = Date()
        
        if note.createdDate == nil {
            note.createdDate = now
        }
        
        note.lastEditedDate = now
        coreDataService.save(note)
    }
    
    public func refresh(_ note: Note) -> Note {
        return coreDataService.refresh(note)
    }
    
    public func sendNote(_ note: Note, viewController: UIViewController) {
        sharingService.send(note, viewController: viewController, completion: analyticsService.publishSendNoteEvent)
    }
    
    public func sendNotes(_ notes: Set<Note>, viewController: UIViewController) {
        sharingService.send(notes, viewController: viewController, completion: analyticsService.publishSendBatchNoteEvent)
    }
    
    private init() {
        analyticsService = NoteAnalyticsService.shared
        sharingService   = NoteSharingService.shared
        coreDataService  = CoreDataNotePersistenceService.shared
    }
}
