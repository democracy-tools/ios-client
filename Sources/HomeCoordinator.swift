//
//  HomeCoordinator.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import UIKit

protocol HomeCoordinatorDelegate: AnyObject {
    func coordinatorDidStartReporting(_ coordinator: HomeCoordinator)
}

class HomeCoordinator: HomeViewModelDelegate {
    weak var delegate: HomeCoordinatorDelegate?
    
    private let model: Model
    private let navigationController: UINavigationController
    private let homeViewController: HomeViewController

    init(model: Model) {
        self.model = model
        
        let homeViewModel = HomeViewModelImpl(model: model)
        homeViewController = HomeViewController(viewModel: homeViewModel)

        navigationController = UINavigationController(rootViewController: homeViewController)
        navigationController.isNavigationBarHidden = true

        homeViewModel.delegate = self
    }
    
    var rootViewController: UIViewController {
        return navigationController
    }
    
    // HomeViewModelDelegate
    
    func viewModelDidStartReporting(_ viewModel: HomeViewModel) {
        delegate?.coordinatorDidStartReporting(self)
    }
}
