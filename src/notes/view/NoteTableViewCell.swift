//
//  NoteTableViewCell.swift
//  notes
//
//  Created by jabari on 5/7/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit
import notesServices

class NoteTableViewCell: UITableViewCell {
    var state: NoteTableViewCellState = .empty {
        didSet {
            textLabel?.text = state.text
            detailTextLabel?.text = state.detailText
            detailTextLabel?.accessibilityLabel = state.accessibilityText
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        detailTextLabel?.numberOfLines = 0
        detailTextLabel?.textColor     = .gray
        textLabel?.font                = textLabel?.font.bolded
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
