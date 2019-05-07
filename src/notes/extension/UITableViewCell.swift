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
        guard
            let textLabel       = textLabel,
            let detailTextLabel = detailTextLabel
        else { return }
        
        textLabel.font = textLabel.font.bolded
        textLabel.text = note.title
        
        var accessibility = ""
        var detail = note.body?.firstLine.truncated(after: 30) ?? ""
        
        if !detail.isEmpty {
            accessibility += "Subject: \(detail)"
        }
        
        if let date = note.lastEditedDate?.formatted {
            detail        += "\n\(date)"
            accessibility += ", Last edited at: \(date)"
        }
        
        detailTextLabel.numberOfLines      = 0
        detailTextLabel.textColor          = .gray
        detailTextLabel.text               = detail
        detailTextLabel.accessibilityLabel = accessibility
    }
}
