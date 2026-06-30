//
//  ToggleView.swift
//  ShyLaunch
//
//  Created by Hilal Kahraman on 30.06.2026.
//

import SwiftUI
import ServiceManagement

struct ToggleView: View {
    @State private var launchAtLogin: Bool = false
    @Environment(\.appearsActive) var appearsActive
    
    var body: some View {
        HStack {
            Text("Mac Açıldığında ShyLaunch'ı Otomatik Başlat")
                .font(.callout)
            Spacer()
            Toggle("", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { newValue in
                    if newValue == true {
                        try? SMAppService.mainApp.register()
                    } else {
                        try? SMAppService.mainApp.unregister()
                    }
                }
                .onAppear {
                    if SMAppService.mainApp.status == .enabled {
                        launchAtLogin = true
                    } else {
                        launchAtLogin = false
                    }
                }
                .onChange(of: appearsActive) { newValue in
                    guard newValue else { return }
                    if SMAppService.mainApp.status == .enabled {
                        launchAtLogin = true
                    } else {
                        launchAtLogin = false
                    }
                }
                .toggleStyle(.switch)
                .controlSize(.small)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    ToggleView()
}
