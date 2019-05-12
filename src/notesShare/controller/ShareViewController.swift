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
    private var urlString: String? {
        didSet { refreshView() }
    }
    
    private var note: Note? {
        didSet { refreshView() }
    }
    
    private lazy var selectedNoteTitle: SLComposeSheetConfigurationItem = {
        let select        = SLComposeSheetConfigurationItem()!
        select.title      = "Selected Note:"
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
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem?.title = "Save"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        findURL(then: appendURL)
    }
}

private extension ShareViewController {
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
        var noteToSave = note
        
        if noteToSave == nil {
            let title = "New Note"
            let body = textView.text
            noteToSave = NoteService.instance.createNote(with: title, body: body)
        }
        
        guard let toSave = noteToSave else { return }
        
        NoteService.instance.saveNote(note: toSave)
    }
    
    func refreshView() {
        var text = ""
        
        if note == nil {
            selectedNoteTitle.value = "New Note"
        } else {
            selectedNoteTitle.value = note?.title ?? "Untitled"
            text = note?.body ?? ""
        }
        
        if let urlString = urlString {
            if text.isEmpty {
                text = urlString
            } else {
                text += "\n\n\(urlString)"
            }
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
