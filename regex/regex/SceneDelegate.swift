//
//  SceneDelegate.swift
//  regex
//
//  Created by Augustin on 13.09.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        // Create the window
        let window = UIWindow(windowScene: windowScene)

        // Set your main view controller (wrapped in a navigation controller)
        let mainVC = ViewController()
        let navVC = UINavigationController(rootViewController: mainVC)
        window.rootViewController = navVC

        // Make it visible
        self.window = window
        window.makeKeyAndVisible()
    }

}
