//
//  AppWindow.swift
//  CountMeIn
//
//  Created by Gil Shapira on 04/03/2023.
//

import UIKit

class AppWindow: UIWindow {
    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = .black
        tintColor = .systemBlue
        overrideUserInterfaceStyle = .dark
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
