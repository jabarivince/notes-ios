//
//  ShareViewController.swift
//  notesShare
//
//  Created by jabari on 5/11/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {
    private var textString: String {
        get {
            return textView.text ?? ""
        }
    }
    
    private var urlString: String? {
        didSet {
            guard let urlString = urlString else { return }
            
            if textString.isEmpty {
                textView.text = urlString
            } else {
                textView.text = textString + "\n\n" + urlString
            }
        }
    }
    
    private lazy var selectNote: SLComposeSheetConfigurationItem = {
        let select        = SLComposeSheetConfigurationItem()!
        select.title      = "Selected Note:"
        select.value      = "New note"
        select.tapHandler = saveButtonTapped
        return select
    }()
    
    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        return [selectNote]
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notes"
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem?.title = "Save"
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
}

extension ShareViewController: ShareNoteListViewControllerDelegate {
    func noteSelected(_ title: String) {
        selectNote.value = title
        navigationController?.popViewController(animated: true)
    }
}
