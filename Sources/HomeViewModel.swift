//
//  HomeViewModel.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import Foundation

struct HomeViewState {
    var counter = ""
    var isStarted = false
}

protocol HomeViewModelPresenter: AnyObject {
    func viewModelDidUpdateState(_ viewModel: HomeViewModel)
}

protocol HomeViewModelDelegate: AnyObject {
    func viewModelDidStartReporting(_ viewModel: HomeViewModel)
}

protocol HomeViewModel: AnyObject {
    var presenter: HomeViewModelPresenter? { get set }
    var delegate: HomeViewModelDelegate? { get set }
    var state: HomeViewState { get }
    func handleAppeared()
    func handleDisappeared()
    func handleActionPressed()
}

class HomeViewModelImpl: HomeViewModel, StoreSubscriber {
    weak var presenter: HomeViewModelPresenter?
    weak var delegate: HomeViewModelDelegate?
    
    let model: Model
    var state = HomeViewState()
    
    var timer: Timer?
    var isUpdating = false
    var isStarted = false

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
        
        let counterExpiry: TimeInterval = 1 /* hour */ * 60 /* mins */ * 60 /* secs */
        if model.state.info.updatedAt.timeIntervalBeforeNow < counterExpiry {
            let formatter = NumberFormatter()
            formatter.usesGroupingSeparator = true
            formatter.groupingSize = 3
            state.counter = formatter.string(for: model.state.info.counter) ?? ""
        }
        
        state.isStarted = isStarted
        
        presenter?.viewModelDidUpdateState(self)
    }
    
    // Actions
    
    func handleAppeared() {
        updateState()
        updateCounter()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in
            self?.updateCounter()
        }
    }
    
    func handleDisappeared() {
        timer?.invalidate()
        timer = nil
    }
    
    func handleActionPressed() {
        isStarted = true
        updateState()
        delegate?.viewModelDidStartReporting(self)
    }
    
    // Data
    
    func updateCounter() {
        isUpdating = true
        Task.background {
            do {
                print("Updating counter")
                let counter = try await Network.getCounter()
                await MainActor.run {
                    self.didFinishUpdatingCounter(counter)
                }
            } catch {
                await MainActor.run {
                    self.didFailUpdatingCounter(error)
                }
            }
        }
    }
    
    func didFinishUpdatingCounter(_ value: Int) {
        print("Successfully updated counter: \(value)")
        model.dispatch(Actions.UpdateCounter(value: value, date: Date()))
        model.save()
        self.isUpdating = false
    }
    
    func didFailUpdatingCounter(_ error: Error) {
        print("Fail to update counter: \(error)")
        self.isUpdating = false
    }
}
