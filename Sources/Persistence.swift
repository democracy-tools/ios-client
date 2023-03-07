//
//  PersistenceService.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import UIKit

private let storeFilename = "store.json"
private let persistenceQueue = DispatchQueue(label: "PersistenceService", qos: .userInitiated)

enum Persistence {
    static func loadState() -> State? {
        do {
            return try readState()
        } catch {
            print("Error loading state: \(error)")
            return nil
        }
    }
    
    static func saveStateAsync(_ state: State) {
        UIApplication.shared.performBackgroundTask { completion in
            persistenceQueue.async {
                do {
                    try writeState(state)
                } catch {
                    print("Error saving state: \(error)")
                }
                completion()
            }
        }
    }
    
    private static func readState() throws -> State? {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return nil }
        let data = try Data(contentsOf: storeURL, options: [])
        let state = try JSONDecoder().decode(State.self, from: data)
        return state
    }
    
    private static func writeState(_ state: State) throws {
        let data = try JSONEncoder().encode(state)
        try data.write(to: storeURL, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    }
    
    private static let storeURL: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent(storeFilename)
    }()
}
