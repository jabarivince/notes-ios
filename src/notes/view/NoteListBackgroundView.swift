//
//  NoNotesFoundView.swift
//  notes
//
//  Created by jabari on 5/5/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit

class NoteListBackgroundView: UIView {
    private let recognizer = UITapGestureRecognizer(target: nil, action: nil)
    
    private let label: UILabel = {
        let labelView = ExtendedTapTargetLabelView(top: -30, bottom: -30)
        labelView.adjustsFontForContentSizeCategory = true
        return labelView
    }()
    
    var tapHandler: (() -> Void)?
    
    var state: State = .hidden {
        didSet { respondToStateChange() }
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
    
    enum State: String {
        case hidden           = ""
        case noNotesFound     = "No search results found"
        case noNotesAvailable = "Click + to create a new note"
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

private extension NoteListBackgroundView {
    func respondToStateChange() {
        switch state {
        case .noNotesAvailable:
            configureNoNotesAvailableState()
        default:
            configureDefaultState()
        }
    }
    
    func configureNoNotesAvailableState() {
        let text     = state.rawValue
        let range    = text.asNSString.range(of: "+")
        let color    = tintColor ?? UIColor(red: 0, green: 122/255, blue: 1, alpha: 1)
        let attrText = NSMutableAttributedString(string: text)
        attrText.addAttribute(.foregroundColor, value: color, range: range)
        label.attributedText = attrText
        label.addGestureRecognizer(recognizer)
    }
    
    func configureDefaultState() {
        tapHandler = nil
        label.text = state.rawValue
        label.removeGestureRecognizer(recognizer)
    }
}

extension NoteListBackgroundView: UIGestureRecognizerDelegate {
    
    /// Called when the UILabel detects a single tap anywhere on the UILabel
    @objc private func labelTapped(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        
        if shouldRespondTo(recognizer) {
            tapHandler?()
        }
    }
    
    /// Determines whether or not we should respond to the tap gesture.
    /// Presently, we only want to respond to tap gestures if we are in
    /// the .noNotesAvailable state and the tap location is on the call to
    /// action text (the + icon).
    private func shouldRespondTo(_ recognizer: UITapGestureRecognizer) -> Bool {
        guard state == .noNotesAvailable else { return false }
        
        let point = recognizer.location(in: label)
        return withinRadius(point: point, raduis: 31, of: " + ")
    }
    
    /// Determine whether or not a point falls within a
    /// specified radius of a target substring in the label's text.
    private func withinRadius(point: CGPoint, raduis: CGFloat, of target: String) -> Bool {
        let text   = label.text ?? ""
        let range  = text.asNSString.range(of: target)
        let prefix = text.asNSString.substring(to: range.location)
        let size   = prefix.size(withAttributes: [.font: label.font as Any])
        let target = CGPoint(x: size.width , y: size.height)
        
        return point.distance(from: target) < raduis
    }
}
