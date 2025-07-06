import SwiftUI
import AppKit

@main
struct PC_ControllerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check if another instance is already running
        if isAnotherInstanceRunning() {
            let alert = NSAlert()
            alert.messageText = "PC Controller is already running"
            alert.informativeText = "Another instance of PC Controller is already running. Only one instance can run at a time."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()
            
            NSApplication.shared.terminate(nil)
            return
        }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "power", accessibilityDescription: "PC Controller")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        popover = NSPopover()
        popover?.contentViewController = NSHostingController(rootView: ContentView())
        popover?.behavior = .transient
        popover?.contentSize = NSSize(width: 280, height: 240)
        
        // Use vibrant material that adapts to system appearance
        if let effectiveAppearance = NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) {
            popover?.appearance = NSAppearance(named: effectiveAppearance == .darkAqua ? .vibrantDark : .vibrantLight)
        } else {
            popover?.appearance = NSAppearance(named: .vibrantDark)
        }
        
        NSApplication.shared.setActivationPolicy(.accessory)
    }
    
    @objc func togglePopover() {
        guard let popover = popover else { return }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            if let button = statusItem?.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    private func isAnotherInstanceRunning() -> Bool {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.pccontroller.app"
        let runningApps = NSWorkspace.shared.runningApplications
        
        let matchingApps = runningApps.filter { app in
            app.bundleIdentifier == bundleIdentifier && app.processIdentifier != ProcessInfo.processInfo.processIdentifier
        }
        
        return !matchingApps.isEmpty
    }
}