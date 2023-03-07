//
//  HomeViewModel.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import Foundation

struct HomeViewState {
}

protocol HomeViewModelDelegate: AnyObject {
    func viewModelDidUpdateState(_ viewModel: HomeViewModel)
}

protocol HomeViewModelCoordinator: AnyObject {
}

protocol HomeViewModel: AnyObject {
    var delegate: HomeViewModelDelegate? { get set }
    var coordinator: HomeViewModelCoordinator? { get set }
    var state: HomeViewState { get }
    func handleAppeared()
    func handleDisappeared()
    func handleActionPressed()
}

class HomeViewModelImpl: HomeViewModel, StoreSubscriber {
    weak var delegate: HomeViewModelDelegate?
    weak var coordinator: HomeViewModelCoordinator?
    
    let model: Model
    var state = HomeViewState()
    
    init(model: Model) {
        self.model = model
        self.model.subscribe(self)
    }
    
    deinit {
        model.unsubscribe(self)
    }
    
    func storeDidUpdate() {
        updateState()
    }
    
    func updateState() {
        state = HomeViewState()
        
        delegate?.viewModelDidUpdateState(self)
    }
    
    func handleAppeared() {
        updateState()
    }
    
    func handleDisappeared() {
    }
    
    func handleActionPressed() {
    }
}
