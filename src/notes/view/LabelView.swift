//
//  LabelView.swift
//  notes
//
//  Created by jabari on 5/9/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

class LabelView: UILabel {
    /// Add a 30 point vertical padding for acknowledging
    // touch events to expand the tap area / hit radius
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let insets = UIEdgeInsets(top: -30, left: 0, bottom: -30, right: 0)
        let frame  = bounds.inset(by: insets)
        return frame.contains(point)
    }
}
