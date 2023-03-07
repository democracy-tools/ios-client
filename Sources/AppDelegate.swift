//
//  AppDelegate.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var session: AppSession?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        session = AppSession()
        session?.start()
        return true
    }
    
    // Lifecycle
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        session?.resume()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        session?.pause()
    }
}
