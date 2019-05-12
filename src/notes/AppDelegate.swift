//
//  AppDelegate.swift
//  notes
//
//  Created by jabari on 3/23/19.
//  Copyright © 2019 jabari. All rights reserved.
//

import Firebase
import Fabric
import UIKit
import notesServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initialize()
        return true
    }

    func applicationWillResignActive(_    application: UIApplication) {}
    func applicationDidEnterBackground(_  application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_     application: UIApplication) {}
    func applicationWillTerminate(_       application: UIApplication) {}
}

private extension AppDelegate {
    func initialize() {
        setupAnalytics()
        setupView()
    }
    
    func setupAnalytics() {
        FirebaseApp.configure()
        Fabric.sharedSDK().debug = true
    }
    
    func setupView() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = UINavigationController(rootViewController: NoteListViewController())
        window?.makeKeyAndVisible()
    }
}

