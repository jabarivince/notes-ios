//
//  NoteSharingService.swift
//  notesServices
//
//  Created by jabari on 5/16/19.
//  Copyright © 2019 jabari. All rights reserved.
//

class NoteSharingService {
    static let shared = NoteSharingService()
    
    func send<T>(_ value: T,
                        withSubject subject: String = "Notes",
                        viewController: UIViewController,
                        completion: @escaping (T) -> Void) where T: Stringifiable, T: Loggable {
        
        let text = value.stringified
        let activityViewController = UIActivityViewController(activityItems:[text], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = viewController.view
        activityViewController.setValue(subject, forKey: "Subject")
        viewController.presentedVC.present(activityViewController, animated: true) {
            completion(value)
        }
    }
    
    private init() {}
}
