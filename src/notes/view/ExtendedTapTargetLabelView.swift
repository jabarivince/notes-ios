//
//  LabelView.swift
//  notes
//
//  Created by jabari on 5/9/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

class ExtendedTapTargetLabelView: UILabel {
    let insets: UIEdgeInsets
    
    init(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        insets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.inset(by: insets).contains(point)
    }
}
