//
//  NoNotesFoundView.swift
//  notes
//
//  Created by jabari on 5/5/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

class NoteListBackgroundView: UIView {
    enum State: String {
        case hiddenState           = ""
        case noNotesFoundState     = "No search results found"
        case noNotesAvailableState = "Click + to create a new note"
    }
    
    private let label = UILabel()
    
    var state: State? = .hiddenState {
        didSet {
            guard let state = state else { return }
            
            switch state {
            case .noNotesAvailableState:
                let text     = state.rawValue
                let attrText = NSMutableAttributedString(string: text)
                let range    = (text as NSString).range(of: "+")
                let color    = tintColor ?? UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
                
                attrText.addAttribute(.foregroundColor, value: color, range: range)
                label.attributedText = attrText
                
            case .noNotesFoundState, .hiddenState:
                callback = nil
                fallthrough
            default:
                label.text = state.rawValue
            }
        }
    }
    
    var callback: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupLabel()
        setupTapGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension NoteListBackgroundView {
    func setupSubviews() {
        let view = UIView(frame: frame)
        view.addSubview(label)
        addSubview(view)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func setupLabel() {
        label.textColor                                 = .darkGray
        label.textAlignment                             = .center
        label.isUserInteractionEnabled                  = true
        label.adjustsFontForContentSizeCategory         = true
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupTapGestureRecognizer() {
        let recognizer                  = UITapGestureRecognizer(target: nil, action: nil)
        recognizer.delegate             = self
        recognizer.numberOfTapsRequired = 1
        recognizer.addTarget(self, action: #selector(labelTapped))
        label.addGestureRecognizer(recognizer)
    }
}


extension NoteListBackgroundView: UIGestureRecognizerDelegate {
    @objc private func labelTapped(_ recognizer: UITapGestureRecognizer) {
        if attributedTextTapped(recognizer) {
            callback?()
        }
    }
    
    private func attributedTextTapped(_ recognizer: UITapGestureRecognizer) -> Bool {
        guard state == .noNotesAvailableState else { return false }
        
        // TODO: Implement logic to determine if attributed text was clicked
        return true
    }
}
