//
//  UIViewController.swift
//  notes
//
//  Created by jabari on 4/6/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

// MARK:- UIAlertController
public extension UIViewController {
        
    /// Avoids the issue for already presenting
    var presentedVC: UIViewController {
        return presentedViewController ?? self
    }
    
    func alert(title: String,
               message: String,
               buttonText: String = "Dismiss",
               style: UIAlertAction.Style = .default,
               handler: ((UIAlertAction)->Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: buttonText, style: style, handler: handler)
        alert.addAction(ok)
        presentedVC.present(alert, animated: true)
    }
    
    @inlinable func promptForText(saying message: String,
                                  placeholder: String? = nil,
                                  initialValue: String? = nil,
                                  onConfirm: @escaping (String?) -> Void) {
        
        promptForText(withMessage: message,
                      placeholder: placeholder,
                      initialValue: initialValue,
                      onConfirm: onConfirm,
                      onCancel: nil)
    }
    
    func promptForText(withMessage message: String,
                       placeholder: String? = nil,
                       initialValue: String? = nil,
                       onConfirmText: String? = "Ok",
                       onCanelText: String? = "Cancel",
                       onConfirm: @escaping (String?) -> Void?,
                       onCancel: ((String?) -> Void)?) {
        
        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = initialValue
            textField.placeholder = placeholder
            textField.clearButtonMode = .whileEditing
            textField.autocapitalizationType = .sentences
        }
        
        let ok = UIAlertAction(title: onConfirmText, style: .default) { [weak alert] _ in
            let title = alert?.textFields?[0].text
            onConfirm(title)
            alert?.dismiss(animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: onCanelText, style: .cancel) { [weak alert] _ in
            let title = alert?.textFields?[0].text
            onCancel?(title)
            alert?.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(ok)
        alert.addAction(cancel)
        presentedVC.present(alert, animated: true, completion: nil)
    }
    
    @inlinable func promptToContinue(withMessage message: String,
                                     onYesText: String? = "Yes",
                                     onNoText: String? = "No",
                                     onYes: @escaping () -> Void) {
        promptYesOrNo(withMessage: message,
                      onYesText: onYesText,
                      onNoText: onNoText,
                      onYes: onYes,
                      onNo: nil)
    }
    
    func promptYesOrNo(withTitle title: String? = "Are you sure?",
                       withMessage message: String,
                       onYesText: String? = "Yes",
                       onNoText: String? = "No",
                       onYes: @escaping () -> Void,
                       onNo: (() -> Void)?) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
    
        let yes = UIAlertAction(title: onYesText, style: .destructive) { [weak alert] _ in
            onYes()
            alert?.dismiss(animated: true, completion: nil)
        }
        
        let no = UIAlertAction(title: onNoText, style: .cancel) { [weak alert] _ in
            onNo?()
            alert?.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(no)
        alert.addAction(yes)
        presentedVC.present(alert, animated: true, completion: nil)
    }
    
    func presentActionSheet(title: String? = nil,
                            message: String? = nil,
                            for actions: [(title: (text: String, style: UIAlertAction.Style), action: () -> Void)]) {
        
        let alert = getActionSheet(title: title,
                                   message: message,
                                   for: actions)
        
        presentedVC.present(alert, animated: true, completion: nil)
    }
    
    func getActionSheet(title: String? = nil,
                        message: String? = nil,
                        cancellable: Bool? = true,
                        for actions: [(title: (text: String, style: UIAlertAction.Style), action: () -> Void)]) -> UIAlertController {
        
        let alert = UIAlertController(title: title,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        for (title, action) in actions {
            let alertAction = UIAlertAction(title: title.text, style: title.style) { _ in
                action()
            }
            
            alert.addAction(alertAction)
        }
        
        if let cancellable = cancellable, cancellable {
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancel)
        }
        
        return alert
    }
}

// MARK:- Notification Center
public extension UIViewController {
    @inlinable func respondTo(_ notification: NSNotification.Name?, with selector: Selector, observer: Any) {
        NotificationCenter.default.addObserver(observer,
                                               selector: selector,
                                               name: notification,
                                               object: nil)
    }
    
    @inlinable func respondTo(_ notification: NSNotification.Name?, with selector: Selector) {
        NotificationCenter.default.addObserver(self,
                                               selector: selector,
                                               name: notification,
                                               object: nil)
    }
    
    @inlinable func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}
