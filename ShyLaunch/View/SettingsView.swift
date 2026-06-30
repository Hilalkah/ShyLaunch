//
//  ContentView.swift
//  ShyLaunch
//
//  Created by Hilal Kahraman on 28.06.2026.
//

import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @State private var appsList: [AppModel] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // Üst Başlık Alanı
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Shy Launch Mac")
                        .font(.system(size: 20, weight: .bold))
                    Text("Başlangıçta sessizce arkaya gizlenecek uygulamalar")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // Uygulama Ekleme Butonu
                AddAppButton(action: selectAppFromDisk)
            }
            .padding()
            
            Divider()
            
            // Uygulama Listesi
            if appsList.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray.and.arrow.down")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("Henüz hiç uygulama eklemediniz.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(appsList) { app in
                        HStack(spacing: 12) {
                            // Gerçek Mac Uygulama Logosu
                            Image(nsImage: app.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .cornerRadius(8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(app.name)
                                    .font(.headline)
                                Text(app.bundleID)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Listeden Kaldırma Butonu
                            DeleteButton(action: { removeApp(app) })
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.inset)
                .scrollContentBackground(.hidden)
            }
            
            Divider()
            ToggleView()
        }
        .frame(minWidth: 500, minHeight: 400)
        .onAppear(perform: loadSavedApps)
    }
    
    // Diskten Uygulama Seçme Fonksiyonu
    func selectAppFromDisk() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Gizlenecek Uygulamayı Seçin"
        openPanel.allowedContentTypes = [.application]
        openPanel.directoryURL = URL(fileURLWithPath: "/Applications")
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        
        openPanel.begin { response in
            if response == .OK, let appURL = openPanel.url {
                createAppModel(from: appURL)
            }
        }
    }
    
    // Seçilen URL'den İkon ve İsim Bilgilerini Çıkartan Fonksiyon
    func createAppModel(from url: URL) {
        if let bundle = Bundle(url: url), let bundleID = bundle.bundleIdentifier {
            // Eğer uygulama zaten listedeyse tekrar ekleme
            if appsList.contains(where: { $0.bundleID == bundleID }) { return }
            
            // Uygulamanın görünen adını ve sistem ikonunu alıyoruz
            let appName = url.deletingPathExtension().lastPathComponent
            let appIcon = NSWorkspace.shared.icon(forFile: url.path)
            
            let newApp = AppModel(bundleID: bundleID, name: appName, icon: appIcon, path: url.path)
            
            DispatchQueue.main.async {
                self.appsList.append(newApp)
                saveToUserDefaults()
            }
        }
    }
    
    // Listeden Eleman Silme
    func removeApp(_ app: AppModel) {
        appsList.removeAll { $0.bundleID == app.bundleID }
        saveToUserDefaults()
    }
    
    // Verileri Kalıcı Kaydetme (Sadece Path'leri kaydediyoruz)
    func saveToUserDefaults() {
        let paths = appsList.map { $0.path }
        UserDefaults.standard.set(paths, forKey: "ShyLaunchSavedPaths")
    }
    
    // Uygulama Açıldığında Kayıtlı Verileri Yükleme
    func loadSavedApps() {
        if let savedPaths = UserDefaults.standard.stringArray(forKey: "ShyLaunchSavedPaths") {
            var loadedApps: [AppModel] = []
            for path in savedPaths {
                let url = URL(fileURLWithPath: path)
                if let bundle = Bundle(url: url), let bundleID = bundle.bundleIdentifier {
                    let appName = url.deletingPathExtension().lastPathComponent
                    let appIcon = NSWorkspace.shared.icon(forFile: path)
                    
                    let app = AppModel(bundleID: bundleID, name: appName, icon: appIcon, path: path)
                    loadedApps.append(app)
                }
            }
            self.appsList = loadedApps
        }
    }
}

#Preview {
    SettingsView()
}
