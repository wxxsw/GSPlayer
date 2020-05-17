//
//  AppDelegate.swift
//  GSPlayer
//
//  Created by Gesen on 04/20/2019.
//  Copyright (c) 2019 Gesen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let nav = UINavigationController(rootViewController: MenuViewController())
        nav.navigationBar.barStyle = .blackTranslucent
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        return true
    }

}

