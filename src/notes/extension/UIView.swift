//
//  UIView.swift
//  notes
//
//  Created by jabari on 3/24/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

/// Convenience extensions on UIView for adding subviews and applying
/// common constraints such as filling the parent view.
extension UIView {
    func addAndPinSubview(_ subview: UIView) {
        addSubview(subview)
        pinSubview(subview)
    }
    
    func pinSubview(_ subview: UIView) {
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor),
            subview.leftAnchor.constraint(equalTo: leftAnchor),
            subview.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }
}
