//
//  UIViewController.swift
//  notes
//
//  Created by jabari on 4/6/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Reusable function for opening a basic yes or no
    /// dialog with a custom message and custom handlers
    /// for both the case where the user taps yes and the
    /// user taps no
    func promptYesOrNo(withMessage message: String, onYes: (() -> Void)? = nil, onNo: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    
        let yes = UIAlertAction(title: "Yes", style: .default) { [weak alert] _ in
            if let onYes = onYes {
                onYes()
            }
            
            alert?.dismiss(animated: true, completion: nil)
        }
        
        let no = UIAlertAction(title: "No", style: .default) { [weak alert] _ in
            if let onNo = onNo {
                onNo()
            }
            
            alert?.dismiss(animated: true, completion: nil)
        }
        
        no.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(yes)
        alert.addAction(no)
        
        present(alert, animated: true, completion: nil)
    }
}
