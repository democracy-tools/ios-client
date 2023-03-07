//
//  Network.swift
//  CountMeIn
//
//  Created by Gil Shapira on 06/03/2023.
//

import UIKit

enum Network {
    static func sendEvents(_ events: [Event], from deviceId: String) async throws {
        let jsonData = try serializeEvents(events, from: deviceId)

        let url = URL(string: "https://countmein-vsd34q224q-zf.a.run.app/announcements")!
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        print("Sending \(events.count) events to server")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, (200 ... 299) ~= response.statusCode else {
            let body = String(bytes: data, encoding: .utf8) ?? "---"
            print("Failed to send event to server: \(body)")
            throw URLError(.badServerResponse)
        }
        print("Events sent successfully")
    }
}

private func serializeEvents(_ events: [Event], from deviceId: String) throws -> Data {
    let json = [
        "announcements": events.map { serializeEvent($0, from: deviceId) },
    ]
    return try JSONSerialization.data(withJSONObject: json)
}

private func serializeEvent(_ event: Event, from deviceId: String) -> [String: Any] {
    return [
        "user_id": UIDevice.current.name, // TODO
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