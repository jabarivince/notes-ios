//
//  Note.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import Foundation

struct Note: Equatable {
    var title: String?
    var body: String?
    var uuid: UUID
    
    init(title: String?, body: String?) {
        self.title = title
        self.body = body
        self.uuid = UUID()
    }
}
