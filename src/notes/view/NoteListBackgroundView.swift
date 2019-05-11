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
    
    private let label      = LabelView()
    private let recognizer = UITapGestureRecognizer(target: nil, action: nil)
    
    private var text: String {
        return label.text ?? ""
    }
    
    var callback: (() -> Void)?
    
    var state: State? = .hiddenState {
        didSet {
            guard let state = state else { return }
            
            switch state {
            case .noNotesAvailableState:
                let text     = state.rawValue
                let attrText = NSMutableAttributedString(string: text)
                let range    = text.asNSString.range(of: "+")
                let color    = tintColor ?? UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
                attrText.addAttribute(.foregroundColor, value: color, range: range)
                label.attributedText = attrText
                label.addGestureRecognizer(recognizer)
                
            case .noNotesFoundState, .hiddenState:
                callback = nil
                fallthrough
            default:
                label.text = state.rawValue
                label.removeGestureRecognizer(recognizer)
            }
        }
    }
    
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
        recognizer.delegate             = self
        recognizer.numberOfTapsRequired = 1
        recognizer.addTarget(self, action: #selector(labelTapped))
    }
}

extension NoteListBackgroundView: UIGestureRecognizerDelegate {
    
    /// Called when the UILabel detects a single tap anywhere on the UILabel
    /// However, we chose to respond to the tap if and only if the user tapped
    /// on the target text that indicates the call to action.
    @objc private func labelTapped(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        
        if shouldRespondTo(recognizer) {
            callback?()
        }
    }
    
    /// Determines whether or not we should respond to the tap gesture.
    /// Presently, we only want to respond to tap gestures if we are in
    /// the .noNotesAvailable state and the tap location is on the call to
    /// action text (the +).
    private func shouldRespondTo(_ recognizer: UITapGestureRecognizer) -> Bool {
        guard state == .noNotesAvailableState else { return false }
        
        let point = recognizer.location(in: label)
        return withinRadius(point: point, raduis: 31, of: " + ")
    }
    
    private func withinRadius(point: CGPoint, raduis: CGFloat, of target: String) -> Bool {
        let range  = text.asNSString.range(of: target)
        let prefix = text.asNSString.substring(to: range.location)
        let size   = prefix.size(withAttributes: [.font: label.font as Any])
        let target = CGPoint(x: size.width , y: size.height)
        
        return distance(from: point, to: target) < raduis
    }
    
    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        let dx = from.x - to.x
        let dy = from.y - to.y
        return ( (dx * dx) + (dy * dy) ).squareRoot()
    }
}
