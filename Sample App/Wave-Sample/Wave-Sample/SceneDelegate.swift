//
//  SceneDelegate.swift
//  Wave
//
//  Copyright (c) 2022 Janum Trivedi.
//

import UIKit
import Wave

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .white

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = .white

        let tabViewController = UITabBarController()
        tabViewController.tabBar.standardAppearance = tabBarAppearance
        tabViewController.tabBar.scrollEdgeAppearance = tabBarAppearance

        tabViewController.viewControllers = [
            PictureInPictureViewController(),
            GridViewController(),
            SheetViewController(),
            SwiftUIViewController()
        ]

        tabViewController.selectedIndex = 0

        self.window?.rootViewController = tabViewController
        self.window?.makeKeyAndVisible()

    }

}
