//
//  Log.swift
//  DemoBluetooth
//
//  Created by Reuven on 26/02/2023.
//  Copyright © 2023 Ioannis Diamantidis. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreLocation

struct Location{
    var latitute: Double
    var longitude: Double
}

struct LogKey : Hashable, Equatable {
    var latitude: Double
    var longitude: Double
    var deviceName: String
    var timestamp: Double
}

struct LogEntry {
    var timestamp: Date
}

typealias Logs = Dictionary<LogKey, LogEntry>

func updateServer(logKey: LogKey) {
    do {
        let jsonData = try logKeyToAnnouncements(logKey: logKey)

        let url = URL(string: "https://countmein-vsd34q224q-zf.a.run.app/announcements")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let response = response as? HTTPURLResponse,
                error == nil
            else {                                                               // check for fundamental networking error
                print("error", error ?? URLError(.badServerResponse))
                return
            }

            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
        }
        task.resume()
    } catch {
        return
    }
}

func logKeyToAnnouncements(logKey: LogKey) throws -> Data  {
    let announcements: [String: Any] = ["announcements": [logKeyToAnnouncement(logKey: logKey)]]

    do {
        let jsonData = try JSONSerialization.data(withJSONObject: announcements)
        return jsonData
    } catch {
        print("error converting to json")
        throw error
    }
}

func logKeyToAnnouncement(logKey: LogKey) -> Any {
    let loc:[String: Double?] = ["latitute": logKey.latitude,
                                 "longitude": logKey.longitude]
    
    let announcement: [String: Any] = ["user-id": "Reuven",
                                       "device-id": "reuven-iphone",
                                       "seen-device": logKey.deviceName,
                                       "location": loc,
                                       "timestamp": logKey.timestamp]
    return announcement
}
