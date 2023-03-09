//
//  Network.swift
//  CountMeIn
//
//  Created by Gil Shapira on 06/03/2023.
//

import UIKit

private let baseURL = "https://countmein-vsd34q224q-zf.a.run.app"

enum Network {
    static func getCounter() async throws -> Int {
        let url = URL(string: "\(baseURL)/demonstrations")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("Fetching demonstration counter")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, (200 ... 299) ~= response.statusCode else {
            let body = String(bytes: data, encoding: .utf8) ?? ""
            print("Failed fetching demonstrations counter: \(body)")
            throw URLError(.badServerResponse)
        }
        
        let json = try JSONSerialization.jsonObject(with: data)
        guard let dict = json as? [String: Any] else { throw URLError(.resourceUnavailable) }
        guard let demonstrations = dict["demonstrations"] as? [String: Any] else { throw URLError(.resourceUnavailable) }
        guard let count = demonstrations["count"] as? Int else { throw URLError(.resourceUnavailable) }
        return count
    }
    
    static func sendEvents(_ events: [Event], from deviceId: String) async throws {
        let jsonData = try serializeEvents(events, from: deviceId)

        let url = URL(string: "\(baseURL)/announcements")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, (200 ... 299) ~= response.statusCode else {
            let body = String(bytes: data, encoding: .utf8) ?? ""
            print("Failed to send \(events.count) events to server: \(body)")
            throw URLError(.badServerResponse)
        }
    }
}

private func serializeEvents(_ events: [Event], from deviceId: String) throws -> Data {
    let json = [
        "announcements": events.map { serializeEvent($0, from: deviceId) },
    ]
    return try JSONSerialization.data(withJSONObject: json)
}

private func serializeEvent(_ event: Event, from deviceId: String) -> [String: Any] {
    #if targetEnvironment(simulator)
    let userId = "Simulator"
    #else
    let userId = UIDevice.current.name
    #endif
    return [
        "user_id": userId,
        "device_id": [
            "id": deviceId,
            "type": "",
        ],
        "seen_device": [
            "id": event.name,
            "type": "",
        ],
        "location": [
            "latitude": roundedLocationValue(event.latitude),
            "longitude": roundedLocationValue(event.longitude),
        ],
        "time": roundedTimeInterval(event.date.timeIntervalSince1970),
    ]
}

func roundedTimeInterval(_ value: TimeInterval) -> TimeInterval {
    return (value / 60.0).rounded(.toNearestOrEven) * 60.0
}

func roundedLocationValue(_ value: Double) -> Double {
    return Double(round(10000 * value) / 10000)
}
