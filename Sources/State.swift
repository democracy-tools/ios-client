//
//  State.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import Foundation

struct State: Codable {
    var client: ClientState
    var info: InfoState
    var event: EventState
}

struct ClientState: Codable {
    var deviceId: String
}

struct InfoState: Codable {
    var counter: Int
    var updatedAt: Date
}

struct EventState: Codable {
    var events: [Event]
}

struct Event: Codable {
    var id: String
    var date: Date
    var name: String
    var latitude: Double
    var longitude: Double
}
