//
//  AppDelegate.swift
//  ReplyKit-Practice
//
//  Created by i9400503 on 2019/9/30.
//  Copyright © 2019 BrilleShine. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.


        let recordVC = UIStoryboard(name: "BrRecorderStoryboard", bundle: nil).instantiateViewController(withIdentifier: "BrRecorderStoryboard")




        let nav = UINavigationController(rootViewController: recordVC)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = nav

        window?.makeKeyAndVisible()

        return true
    }

    // MARK: UISceneSession Lifecycle

  
    func applicationDidBecomeActive(_ application: UIApplication) {

    }

}


