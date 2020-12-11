//
//  AppDelegate.swift
//  PureExample
//
//  Created by Łukasz Śliwiński on 19/02/2020.
//  Copyright © 2020 plum. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let dependency: AppDependency
    
    /// Called from the system (it's private: not accessible in the testing environment)
    private override init() {
      self.dependency = AppDependency.resolve()
      super.init()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
