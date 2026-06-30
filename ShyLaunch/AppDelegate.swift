import AppKit
import os.log

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var bundleIDsToWatch: Set<String> = []
    private var hideTimer: Timer?
    private let logger = Logger(subsystem: "com.shylaunch.debug", category: "Watchdog")
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let env = ProcessInfo.processInfo.environment
        let isAutomaticLaunch = env["LaunchInstanceID"] != nil
        writeLog("🚀 Mod: \(isAutomaticLaunch ? "Hayalet" : "Arayüz")")
        
        if isAutomaticLaunch {
            NSApp.setActivationPolicy(.prohibited)
            // Tüm pencereleri kapat
            DispatchQueue.main.async {
                NSApp.windows.forEach { $0.close() }
            }
            setupWatchdog()
            startShyLaunchEngine()
            
        } else {
            NSApp.setActivationPolicy(.regular)
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.windows.first?.makeKeyAndOrderFront(nil)
            }
        }
    }
    
    private func setupWatchdog() {
        let center = NSWorkspace.shared.notificationCenter
        center.addObserver(self,
                           selector: #selector(appDidLaunchOrActivate(_:)),
                           name: NSWorkspace.didLaunchApplicationNotification,
                           object: nil)
        center.addObserver(self,
                           selector: #selector(appDidLaunchOrActivate(_:)),
                           name: NSWorkspace.didActivateApplicationNotification,
                           object: nil)
    }
    
    @objc private func appDidLaunchOrActivate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let runningApp = userInfo[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleID = runningApp.bundleIdentifier else { return }
        
        guard bundleIDsToWatch.contains(bundleID) else { return }
        
        let appName = runningApp.localizedName ?? bundleID
        writeLog("🎯 Hedef yakalandı: \(appName) [\(bundleID)]")
        
        // Hem anında hem gecikmeyle gizle (session restore için kritik)
        hideApp(runningApp, name: appName)
        
        // Watchdog'a da ekle — session restore penceresi geç açılırsa yakala
        bundleIDsToWatch.insert(bundleID)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.hideApp(runningApp, name: appName)
            self.bundleIDsToWatch.remove(bundleID)
            if self.bundleIDsToWatch.isEmpty {
                self.writeLog("🏁 Tüm uygulamalar gizlendi, kapanıyor.")
                NSApp.terminate(nil)
            }
        }
    }
    
    private func hideApp(_ app: NSRunningApplication, name: String) {
        performHide(app, name: name)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.verifyHidden(app, name: name, attempt: 1)
        }
    }

    private func performHide(_ app: NSRunningApplication, name: String) {
        app.hide()

        let script = """
        tell application "System Events"
            set visible of process "\(name)" to false
        end tell
        tell application "\(name)"
            close every window
        end tell
        """

        if let appleScript = NSAppleScript(source: script) {
            var err: NSDictionary?
            appleScript.executeAndReturnError(&err)
        }
    }

    private func verifyHidden(_ app: NSRunningApplication,
                              name: String,
                              attempt: Int) {

        guard !app.isTerminated else {
            writeLog("✅ \(name) zaten kapanmış.")
            return
        }

        guard !app.isHidden else {
            writeLog("✅ \(name) gizlendi.")
            return
        }

        guard attempt <= 5 else {
            writeLog("⚠️ \(name) 5 denemeye rağmen gizlenemedi.")
            return
        }

        writeLog("🔁 \(name) hâlâ görünür. Tekrar gizleniyor (\(attempt)/5)")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.performHide(app, name: name)
            self.verifyHidden(app, name: name, attempt: attempt + 1)
        }
    }
    
    func startShyLaunchEngine() {
        guard let savedPaths = UserDefaults.standard.stringArray(forKey: "ShyLaunchSavedPaths"),
              !savedPaths.isEmpty else {
            self.writeLog("🏁 Kapatilacak uygulama bulunamadi, kapanıyor.")
            NSApp.terminate(nil)
            return
        }
        
        let alreadyRunning = NSWorkspace.shared.runningApplications
        
        for path in savedPaths {
            let url = URL(fileURLWithPath: path)
            guard let bundle = Bundle(url: url),
                  let bundleID = bundle.bundleIdentifier else { continue }
            
            let appName = url.deletingPathExtension().lastPathComponent
            
            if let runningApp = alreadyRunning.first(where: { $0.bundleIdentifier == bundleID }) {
                writeLog("♻️ Zaten çalışıyor, gizleniyor: \(appName)")
                hideApp(runningApp, name: runningApp.localizedName ?? appName)
            } else {
                writeLog("⏭️ Kapalı, atlanıyor: \(appName)")
            }
        }
        
        // Watchdog için zaman aşımı
        DispatchQueue.main.asyncAfter(deadline: .now() + 25.0) {
            self.writeLog("🏁 Watchdog için zaman aşımı, tüm uygulamalar gizlendi, kapanıyor.")
            NSApp.terminate(nil)
        }
    }
    
    private func writeLog(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        let line = "[\(formatter.string(from: Date()))] \(message)\n"
        
        let logURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Desktop/ShyLaunch.log")
        
        if let data = line.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: logURL.path) {
                if let handle = try? FileHandle(forWritingTo: logURL) {
                    handle.seekToEndOfFile()
                    handle.write(data)
                    handle.closeFile()
                }
            } else {
                try? data.write(to: logURL)
            }
        }
    }
}
