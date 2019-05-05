//
//  UIView.swift
//  notes
//
//  Created by jabari on 3/24/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

extension UIView {
    func addAndPinSubview(_ subview: UIView) {
        addSubview(subview)
        pinSubview(subview)
    }
    
    func pinSubview(_ subview: UIView) {
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor),
            subview.topAnchor.constraint(equalTo: topAnchor),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
