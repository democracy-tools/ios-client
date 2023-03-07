//
//  HomeCoordinator.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import UIKit

class HomeCoordinator {
    private let model: Model
    private let navigationController: UINavigationController
    private let homeViewController: HomeViewController

    init(model: Model) {
        self.model = model
        
        let homeViewModel = HomeViewModelImpl(model: model)
        homeViewController = HomeViewController(viewModel: homeViewModel)
        
        navigationController = UINavigationController(rootViewController: homeViewController)
        navigationController.isNavigationBarHidden = true
    }
    
    var rootViewController: UIViewController {
        return navigationController
    }
}
