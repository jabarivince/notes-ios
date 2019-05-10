//
//  UIViewController.swift
//  notes
//
//  Created by jabari on 4/6/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// TODO: MAKE SURE THESE CLOSURE / FUNCTIONS ARE NOT EXPOSING MEMORY CYCLES
    
    // Avoids the issue for already presenting
    var presentedVC: UIViewController {
        return presentedViewController ?? self
    }
    
    func presentActionSheet(title: String? = nil,
                            message: String? = nil,
                            for actions: [(title: String, action: () -> Void)]) {
        
        let alert = getActionSheet(title: title,
                                   message: message,
                                   for: actions)
        
        presentedVC.present(alert, animated: true, completion: nil)
    }
    
    func getActionSheet(title: String? = nil,
                        message: String? = nil,
                        for actions: [(title: String, action: () -> Void)]) -> UIAlertController {
        
        let alert = UIAlertController(title: title,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        for (title, action) in actions {
            let alertAction = UIAlertAction(title: title, style: .default) { _ in
                action()
            }
            
            alert.addAction(alertAction)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: nil))
        
        return alert
    }
    
    func promptForText(withMessage message: String,
                       placeholder: String? = nil,
                       initialValue: String? = nil,
                       onConfirm: ((String?) -> Void)?) {
        
        promptForText(withMessage: message,
                      placeholder: placeholder,
                      initialValue: initialValue,
                      onConfirm: onConfirm,
                      onCancel: nil)
    }
    
    func promptForText(withMessage message: String,
                       placeholder: String? = nil,
                       initialValue: String? = nil,
                       onConfirm: ((String?) -> Void)?,
                       onCancel: ((String?) -> Void)?) {
        
        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = initialValue
            textField.placeholder = placeholder
            textField.clearButtonMode = .whileEditing
        }
        
        let ok = UIAlertAction(title: "Ok", style: .default) { [weak alert] _ in
            let title = alert?.textFields?[0].text
            
            onConfirm?(title)
            
            alert?.dismiss(animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { [weak alert] _ in
            let title = alert?.textFields?[0].text
            
            onCancel?(title)
            
            alert?.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        presentedVC.present(alert, animated: true, completion: nil)
    }
    
    func promptToContinue(withMessage message: String, onYes: @escaping () -> Void) {
        promptYesOrNo(withMessage: message,
                      onYes: onYes,
                      onNo: nil)
    }
    
    func promptYesOrNo(withTitle title: String? = "Are you sure?",
                       withMessage message: String,
                       onYes: (() -> Void)?,
                       onNo: (() -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
        let yes = UIAlertAction(title: "Yes", style: .destructive) { [weak alert] _ in
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
        
        alert.addAction(no)
        alert.addAction(yes)
        
        presentedVC.present(alert, animated: true, completion: nil)
    }
}
