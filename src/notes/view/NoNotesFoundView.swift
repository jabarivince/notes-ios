//
//  NoNotesFoundView.swift
//  notes
//
//  Created by jabari on 5/5/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

class NoNotesFoundView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let label           = UILabel(frame: frame)
        label.text          = "No notes available"
        label.textColor     = .black
        label.textAlignment = .center
        addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
