//
//  AppCoordinator.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import UIKit

class AppCoordinator {
    let model: Model
    let window: AppWindow
    let homeCoordinator: HomeCoordinator
    
    init(model: Model) {
        self.model = model
        self.window = AppWindow()
        self.homeCoordinator = HomeCoordinator(model: model)
    }
    
    var rootViewController: UIViewController {
        return homeCoordinator.rootViewController
    }
    
    // Lifecycle
    
    func start() {
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
    func pause() {
    }
    
    func resume() {
    }
}
