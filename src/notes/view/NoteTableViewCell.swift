//
//  NoteTableViewCell.swift
//  notes
//
//  Created by jabari on 5/7/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

// TODO:- Convert to MVVM
class NoteTableViewCell: UITableViewCell {
    var note: Note! {
        didSet {
            textLabel?.font = textLabel?.font.bolded
            textLabel?.text = note.title
            
            var accessibility = ""
            var detail = note.body?.firstLine.truncated(after: 30) ?? ""
            
            if !detail.isEmpty {
                accessibility += "Subject: \(detail)"
            }
            
            if let date = note.lastEditedDate?.formatted {
                detail        += "\n\(date)"
                accessibility += ", Last edited: \(date)"
            }
            
            detailTextLabel?.numberOfLines      = 0
            detailTextLabel?.textColor          = .gray
            detailTextLabel?.text               = detail
            detailTextLabel?.accessibilityLabel = accessibility
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
