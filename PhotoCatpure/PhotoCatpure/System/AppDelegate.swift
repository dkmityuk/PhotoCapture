//
//  AppDelegate.swift
//  PhotoCatpure
//
//  Created by Dmytro Kmytiuk on 21.03.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let environmet = AppEnvironment.bootstrap()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupWindow()
        return true
    }
    
    private func setupWindow() {
        let win = UIWindow()
        
        window = win
        window?.makeKeyAndVisible()
        win.rootViewController = UINavigationController(rootViewController: RootViewController(viewModel: RootViewModel(container: environmet.container)))
    }
    
}
