//
//  SceneDelegate.swift
//  PureExample
//
//  Created by Łukasz Śliwiński on 19/02/2020.
//  Copyright © 2020 plum. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    private var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: scene)
        guard let window = self.window else { return }
        
        window.rootViewController = appDelegate.dependency.listViewControllerFactory()
        window.makeKeyAndVisible()
    }
}
