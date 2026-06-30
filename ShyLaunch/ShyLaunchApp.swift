//
//  ShyLaunchApp.swift
//  ShyLaunch
//
//  Created by Hilal Kahraman on 28.06.2026.
//

import SwiftUI

@main
struct ShyLaunchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SettingsView()
        }
    }
}
