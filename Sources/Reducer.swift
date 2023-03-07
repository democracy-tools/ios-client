//
//  Reducer.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import Foundation

enum Actions {
    struct StateLoaded: Action {
        let state: State
    }
    
    struct AddEvents: Action {
        let events: [Event]
    }
    
    struct RemoveEvents: Action {
        let eventIds: [String]
    }
}

extension State {
    static let initial = State(client: .initial, event: .initial)

    static func reducer(state: State, action: Action) -> State {
        var state = state
        
        switch action {
        case let action as Actions.StateLoaded:
            state = action.state

        default:
            state = State(
                client: .reducer(state: state.client, action: action),
                event: .reducer(state: state.event, action: action))
        }
        
        return state
    }
}

private extension ClientState {
    static let initial = ClientState(deviceId: String(NSUUID().uuidString.prefix(8)))
    
    static func reducer(state: ClientState, action: Action) -> ClientState {
        return state
    }
}

private extension EventState {
    static let initial = EventState(events: [])
    
    static func reducer(state: EventState, action: Action) -> EventState {
        var state = state
        
        switch action {
        case let action as Actions.AddEvents:
            state.events.append(contentsOf: action.events)
            
        case let action as Actions.RemoveEvents:
            state.events.removeAll { action.eventIds.contains($0.id) }
            
        default:
            break
        }
        
        return state
    }
}
