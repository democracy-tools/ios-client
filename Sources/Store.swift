//
//  Store.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

protocol Action {}

typealias Reducer<S> = (S, Action) -> S

typealias Dispatcher = (Action) -> Void

typealias Middleware = (@escaping Dispatcher) -> (Dispatcher)

protocol StoreSubscriber: AnyObject {
    func storeDidUpdate()
}

class Store<S> {
    private(set) var state: S
    
    private var dispatcher: Dispatcher = { _ in }
    
    private var subscriptions: [Subscription] = [] {
        didSet {
            subscriptions = subscriptions.filter { $0.subscriber !== nil }
        }
    }
    
    init(state: S, reducer: @escaping Reducer<S>, middlewares: [Middleware] = []) {
        self.state = state
        self.dispatcher = makeDispatcher(reducer: reducer, middlewares: middlewares)
    }
    
    func subscribe(_ subscriber: StoreSubscriber) {
        let subscription = Subscription(subscriber: subscriber)
        subscriptions.append(subscription)
        subscriber.storeDidUpdate()
    }
    
    func unsubscribe(_ subscriber: StoreSubscriber) {
        subscriptions = subscriptions.filter { $0.subscriber !== subscriber }
    }
    
    func dispatch(_ action: Action) {
        dispatcher(action)
        notifySubscribers()
    }
    
    private func notifySubscribers() {
        for subscriber in subscriptions.compactMap({ $0.subscriber }) {
            subscriber.storeDidUpdate()
        }
    }
    
    private func makeDispatcher(reducer: @escaping Reducer<S>, middlewares: [Middleware]) -> Dispatcher {
        var dispatcher: Dispatcher = { [unowned self] action in
            self.state = reducer(self.state, action)
        }
        for middleware in middlewares.reversed() {
            dispatcher = middleware(dispatcher)
        }
        return dispatcher
    }
    
    private struct Subscription {
        weak var subscriber: StoreSubscriber?
    }
}
