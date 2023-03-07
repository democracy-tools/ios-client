//
//  Extensions.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import UIKit

extension UIView {
    func addStandardMotionEffects(x: CGFloat, y: CGFloat) {
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -1 * x
        horizontal.maximumRelativeValue =  1 * x
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -1 * y
        vertical.maximumRelativeValue =  1 * y
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        
        addMotionEffect(group)
    }
}

extension Task where Failure == Error, Success == Void {
    static func background(name: String = #function, priority: TaskPriority? = nil, operation: @escaping @Sendable () async throws -> Success) {
        UIApplication.shared.performBackgroundTask { completion in
            Task(priority: priority) {
                defer {
                    completion()
                }
                try await operation()
            }
        }
    }
}

extension UIApplication {
    func performBackgroundTask(withName name: String = #function, task: (@escaping () -> Void) -> Void) {
        var identifier = UIBackgroundTaskIdentifier.invalid
        let handler = { [self] in
            if identifier != .invalid {
                endBackgroundTask(identifier)
                identifier = .invalid
            }
        }
        identifier = beginBackgroundTask(withName: name, expirationHandler: handler)
        task(handler)
    }
}
