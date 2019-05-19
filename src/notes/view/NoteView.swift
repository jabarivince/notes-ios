//
//  NoteView.swift
//  notes
//
//  Created by jabari on 5/7/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

// MARK:- NoteView
class NoteView: UITextView {
    private var timer: Timer?
    
    var autosave: (() -> Void)?
    var autosaveTimeout: TimeInterval? {
        willSet(timeout) {
            guard let timeout = timeout, timeout > 0 else {
                fatalError("Timeout should never be less than zero")
            }
        }
    }
    
    static let autosaveTimeout: TimeInterval = 0.2
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        let keyboardToolbar: UIToolbar = {
            let bar       = UIToolbar(frame: CGRect(x: 0, y: 0,  width: frame.size.width, height: 30))
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let doneBtn   = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(hideKeyboard))
            bar.setItems([flexSpace, doneBtn], animated: false)
            bar.sizeToFit()
            return bar
        }()
        
        let tapRecognizer: UITapGestureRecognizer = {
            let r = UITapGestureRecognizer(target: self, action: #selector(textViewTapped))
            r.delegate = self
            r.numberOfTapsRequired = 1
            return r
        }()
        
        let attributes: [NSAttributedString.Key : Any] = [
            .foregroundColor: tintColor ?? UIColor(red: 0, green: 122/255, blue: 1, alpha: 1),
            .underlineStyle : NSUnderlineStyle.single.rawValue
        ]
        
        delegate                          = self
        isEditable                        = false
        adjustsFontForContentSizeCategory = true
        dataDetectorTypes                 = .all
        keyboardDismissMode               = .interactive
        font                              = .preferredFont(forTextStyle: .body)
        inputAccessoryView                = keyboardToolbar
        linkTextAttributes                = attributes
        addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- UITextDelegate
extension NoteView: UITextViewDelegate {
    @objc private func save() {
        autosave?()
    }
    
    /// How it works: Autosave
    ///
    /// This function gets called whenever the text in the
    /// textView changes. We do not want to keep saving on every
    /// function call. So, we use a timer.
    ///
    /// 1. On init, the timer is nil, so we skip the first line and instantiate the first timer
    /// 2. If the user strikes another key before the previous timer expires, the previously
    ///    initialized timer gets invalidated and we instantiate a new timer and start it over.
    /// 3. If the user stops typing for more than 200 milliseconds, and the timer actually reaches is expiration time,
    ///    the designated completion handler fires - the saveNote() function.
    ///
    /// This approach allows us to save when the user stop typing, without worrying
    /// about writing to disk on every keystroke. In the worst case scenario, the
    /// user can lose the last 200 milliseconds of work.
    func textViewDidChange(_ textView: UITextView) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: autosaveTimeout ?? NoteView.autosaveTimeout,
                                     target: self,
                                     selector: #selector(save),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    /// Disabled editing (to re-anble hyperlink detection, etc) and save
    func textViewDidEndEditing(_ textView: UITextView) {
        hideKeyboard()
        autosave?()
    }
}

// MARK:- UIGestureRecognizerDelegate
extension NoteView: UIGestureRecognizerDelegate {
    /// If the tap location is not a URL, this function Enables editing
    /// on textView and displays keyboard, and places cursor at closest
    /// position to area on screen that was tapped. If the tap location is
    /// a URL, the URL is opened.
    @objc private func textViewTapped(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            
            if let position = closestPosition(to: recognizer.location(in: self)) {
                let attr = textStyling(at: position, in: .forward)
                
                if let url = attr?[.link] as? URL {
                    UIApplication.shared.open(url)
                } else {
                    selectedTextRange = textRange(from: position, to: position)
                    showKeyboard()
                }
            }
        }
    }
}

// MARK:- Misc
private extension NoteView {
    func showKeyboard() {
        isEditable = true
        let _ = becomeFirstResponder()
    }
    
    @objc func hideKeyboard() {
        isEditable = false
        let _ = resignFirstResponder()
    }
}
