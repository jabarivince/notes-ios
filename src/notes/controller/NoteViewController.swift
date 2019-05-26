//
//  NoteController.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit
import notesServices

// MARK:- UIViewController
class NoteViewController: UIViewController {
    private let noteViewService: NoteViewService
    internal let noteView: NoteView
    internal let titleButton: UIButton
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noteView.frame.size.width  = view.bounds.width
        noteView.frame.size.height = view.bounds.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
        removeObservers()
        handleViewWillDisappear()
    }
    
    override func viewDidLoad() {
        setupToolbars()
        setupTitleButton()
        setupTextView()
        handleDidLoad()
    }
    
    init(note: Note, isNew: Bool) {
        self.titleButton     = UIButton(type: .custom)
        self.noteView        = NoteView()
        self.noteViewService = NoteViewService(note, isNew: isNew)
        super.init(nibName: nil, bundle: nil)
        self.noteViewService.controller = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- Setup UI
extension NoteViewController {
    func setupToolbars() {
        let spacer      = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(handleShareButtonTapped))
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action:  #selector(handleDeleteButtonTapped))
        let menuButton  = UIBarButtonItem(title: "•••", style: .plain, target: self, action:  #selector(handleMenuButtonTapped))
        toolbarItems    = [menuButton, spacer, trashButton]
        
        shareButton.accessibilityLabel    = "Share this note"
        trashButton.accessibilityLabel    = "Delete this note"
        menuButton.accessibilityLabel     = "Options menu"
        navigationItem.rightBarButtonItem = shareButton
    }
    
    func setupTitleButton() {
        titleButton.setTitleColor(.black, for: .normal)
        titleButton.addTarget(self, action: #selector(handleTitleTapped), for: .touchUpInside)
        titleButton.frame              = CGRect(x: 0, y: 0, width: 100, height: 40)
        titleButton.backgroundColor    = .clear
        titleButton.titleLabel?.font   = titleButton.titleLabel?.font.bolded
        navigationItem.titleView       = titleButton
    }
    
    func setupTextView() {
        view.addSubview(noteView)
    }
    
    func addObservers() {
        respondTo(UIResponder.keyboardWillShowNotification,   with: #selector(respondToKeyboardWillShowNotification))
        respondTo(UIResponder.keyboardWillHideNotification,   with: #selector(respondToKeyboardWillHideNotification))
        respondTo(UIApplication.didBecomeActiveNotification,  with: #selector(respondToDidBecomeActiveNotification))
        respondTo(UIApplication.willResignActiveNotification, with: #selector(respondToWillResignActiveNotification))
        respondTo(UIApplication.willTerminateNotification,    with: #selector(respondToWillTerminateNotification))
    }
}

// MARK:- Service function calls
private extension NoteViewController {
    @objc func respondToKeyboardWillShowNotification(notification: Notification) {
        noteViewService.respondToKeyboardWillShowNotification(notification)
    }
    
    @objc func respondToKeyboardWillHideNotification() {
        noteViewService.respondToKeyboardWillHideNotification()
    }
    
    @objc func respondToDidBecomeActiveNotification() {
        noteViewService.respondToDidBecomeActiveNotification()
    }
    
    @objc func respondToWillResignActiveNotification() {
        noteViewService.respondToWillResignActiveNotification()
    }
    
    @objc func respondToWillTerminateNotification() {
        noteViewService.respondToWillTerminateNotification()
    }
    
    @objc func handleMenuButtonTapped() {
        noteViewService.handleMenuButtonTapped()
    }
    
    @objc func handleDeleteButtonTapped() {
        noteViewService.handleDeleteButtonTapped()
    }
    
    @objc func handleShareButtonTapped() {
        noteViewService.handleShareButtonTapped()
    }
    
    @objc func handleTitleTapped() {
        noteViewService.handleTitleButtonTapped()
    }
    
    func handleViewWillDisappear() {
        noteViewService.respondToViewWillDisapper()
    }
    
    func handleDidLoad() {
        noteViewService.handleViewDidLoad()
    }
}
