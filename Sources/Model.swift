//
//  Model.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import Foundation

class Model: Store<State> {
    init() {
        super.init(state: .initial, reducer: State.reducer, middlewares: [mainThreadMiddleware])
    }
    
    func load() {
        if let state = Persistence.loadState() {
            dispatch(Actions.StateLoaded(state: state))
        }
    }
    
    func save() {
        Persistence.saveStateAsync(state)
    }
}

private let mainThreadMiddleware: Middleware = { next in
    return { action in
        precondition(Thread.isMainThread, "Action must be dispatched on the main thread: \(action)")
        next(action)
    }
}
