//
//  NoNotesFoundView.swift
//  notes
//
//  Created by jabari on 5/5/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

class NoteListBackgroundView: UIView {
    private let label: UILabel
    
    var state: State? = .hiddenState {
        didSet {
            label.text = state?.rawValue
        }
    }
    
    override init(frame: CGRect) {
        label               = UILabel(frame: frame)
        label.textColor     = .darkGray
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        super.init(frame: frame)
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum State: String {
        case hiddenState           = ""
        case noNotesFoundState     = "No notes found"
        case noNotesAvailableState = "Click + to create a new note"
    }
}
