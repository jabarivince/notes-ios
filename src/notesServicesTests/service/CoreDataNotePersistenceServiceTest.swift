//
//  CoreDataNotePersistenceServiceTest.swift
//  notesServicesTests
//
//  Created by jabari on 5/16/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import CoreData
import XCTest
@testable import notesServices

class CoreDataNotePersistenceServiceTest: XCTestCase {
    
    static var inMemoryContainer: NSPersistentContainer = {
        let container   = NSPersistentContainer(name: "NotesDataModel")
        let description = NSPersistentStoreDescription()
        
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        return container
    }()
}
