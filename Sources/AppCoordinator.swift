//
//  AppCoordinator.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import UIKit

protocol AppCoordinatorDelegate: AnyObject {
    func coordinatorDidStartReporting(_ coordinator: AppCoordinator)
}

class AppCoordinator: HomeCoordinatorDelegate {
    weak var delegate: AppCoordinatorDelegate?

    let model: Model
    let window: AppWindow
    let homeCoordinator: HomeCoordinator
    var started = false
    
    init(model: Model) {
        self.model = model
        self.window = AppWindow()
        self.homeCoordinator = HomeCoordinator(model: model)
        self.homeCoordinator.delegate = self
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
    
    // HomeCoordinatorDelegate
    
    func coordinatorDidStartReporting(_ coordinator: HomeCoordinator) {
        delegate?.coordinatorDidStartReporting(self)
    }
}
