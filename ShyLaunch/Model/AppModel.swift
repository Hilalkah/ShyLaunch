//
//  AppModel.swift
//  ShyLaunch
//
//  Created by Hilal Kahraman on 28.06.2026.
//

import AppKit

struct AppModel: Identifiable, Hashable {
    let id = UUID()
    let bundleID: String
    let name: String
    let icon: NSImage
    let path: String
}
