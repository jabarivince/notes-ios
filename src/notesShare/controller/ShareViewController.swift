//
//  ShareViewController.swift
//  notesShare
//
//  Created by jabari on 5/11/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit
import Social
import notesServices

class ShareViewController: SLComposeServiceViewController {
    private var originalContent: String = ""
    
    private var hasURL: Bool {
        return urlString != nil
    }
    
    private var urlString: String? {
        didSet { refreshView() }
    }
    
    private var note: Note? {
        didSet { refreshView() }
    }
    
    private lazy var selectedNoteTitle: SLComposeSheetConfigurationItem = {
        let select        = SLComposeSheetConfigurationItem()!
        select.title      = "Selected Note:"
        select.value      = "New Note"
        select.tapHandler = saveButtonTapped
        return select
    }()
    
    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        saveNote()
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        return [selectedNoteTitle]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notes"
        navigationController?.navigationBar.topItem?.rightBarButtonItem?.title = "Save"
        originalContent = contentText
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        findURL(then: appendURL)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
}

private extension ShareViewController {
    func addObservers() {
        respondTo(notification: NSNotification.Name.NSExtensionHostDidBecomeActive, with: #selector(refreshNote))
    }
    
    @objc func refreshNote() {
        guard let note = note else { return }
        self.note = NoteService.shared.refresh(note)
    }
    
    func saveButtonTapped() {
        let controller = ShareNoteListViewController()
        controller.delegate = self
        pushConfigurationViewController(controller)
    }
    
    // https://stackoverflow.com/questions/30824486/ios-share-extension-grabbing-url-in-swift
    func findURL(then completion: @escaping (NSURL) -> Void?) {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let attachments = item.attachments {
                for attachment: NSItemProvider in attachments {
                    if attachment.hasItemConformingToTypeIdentifier("public.url") {
                        attachment.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) in
                            if let shareURL = url as? NSURL {
                                DispatchQueue.main.async {
                                    completion(shareURL)
                                }
                            }
                        })
                    }
                }
            }
        }
    }
    
    func appendURL(url: NSURL?) {
        if let url = url {
            urlString = url.absoluteString
        }
    }
    
    func saveNote() {
        let body = textView.text
        
        if let note = note {
            note.body = body
            NoteService.shared.saveNote(note: note)
        } else {
            let title  = selectedNoteTitle.value
            let toSave = NoteService.shared.createNote(with: title, body: body)
            NoteService.shared.saveNote(note: toSave)
        }
    }
    
    func refreshView() {
        var text    = ""
        let content = hasURL ? urlString! : originalContent
        
        if note == nil {
            text = content
            selectedNoteTitle.value = "New Note"
        } else {
            text = note?.body ?? ""
            
            if !text.isEmpty {
                text += "\n\n"
            }
            
            text += content
            selectedNoteTitle.value = note?.title ?? "Untitled"
        }
        
        textView.text = text
    }
}

extension ShareViewController: ShareNoteListViewControllerDelegate {
    func noteSelected(_ note: Note?) {
        self.note = note
        navigationController?.popViewController(animated: true)
    }
}
