//
//  UIViewController.swift
//  notes
//
//  Created by jabari on 4/6/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // Determine which View Controller to present with
    // that way we avoid the warning for already presenting
    var presentedVC: UIViewController {
        return presentedViewController ?? self
    }
    
    /// Prompt for text with callback for confirm and cancel events
    func promptForText(withMessage message: String,
                       placeholder: String? = nil,
                       onConfirm: ((String?) -> Void)? = nil,
                       onCancel: ((String?) -> Void)? = nil) {
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = placeholder
        }
        
        let ok = UIAlertAction(title: "Ok", style: .default) { [weak alert] _ in
            let title = alert?.textFields?[0].text
            
            if let onConfirm = onConfirm {
                onConfirm(title)
            }
            
            alert?.dismiss(animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { [weak alert] _ in
            let title = alert?.textFields?[0].text
            
            if let onCancel = onCancel {
                onCancel(title)
            }
            
            alert?.dismiss(animated: true, completion: nil)
        }
        
        cancel.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(ok)
        alert.addAction(cancel)
        
        presentedVC.present(alert, animated: true, completion: nil)
    }
    
    /// Prompt yes or no with callbacks for both actions
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
        
        presentedVC.present(alert, animated: true, completion: nil)
    }
}
