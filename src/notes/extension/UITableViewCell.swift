//
//  UITableViewCell.swift
//  notes
//
//  Created by jabari on 5/7/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

extension UITableViewCell {
    func initialize(from note: Note) {
        guard let textLabel = textLabel else { return }
        textLabel.font = textLabel.font.bolded
        textLabel.text = note.title
        
        var detail = ""
        
        if let date = note.lastEditedDate?.formatted {
            detail += "\(date)\n"
        }
        
        detail += note.body?.firstLine.truncated(after: 30) ?? ""
        
        detailTextLabel?.text          = detail
        detailTextLabel?.textColor     = .gray
        detailTextLabel?.numberOfLines = 0
    }
}
