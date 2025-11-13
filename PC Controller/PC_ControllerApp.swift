import SwiftUI
import SwiftUI
import AppKit
import ServiceManagement
import Combine
import UserNotifications
import Network

class LoginItemsManager: ObservableObject {
    static let shared = LoginItemsManager()
    
    private init() {}
    
    @MainActor
    func isLoginItemEnabled() -> Bool {
        let status = SMAppService.mainApp.status
        return status == .enabled
    }
    
    @MainActor
    func setLoginItemEnabled(_ enabled: Bool) async -> Bool {
        do {
            if enabled {
                if SMAppService.mainApp.status == .enabled {
                    return true
                }
                
                try SMAppService.mainApp.register()
                return true
            } else {
                if SMAppService.mainApp.status == .notRegistered {
                    return true
                }
                
                try await SMAppService.mainApp.unregister()
                return true
            }
        } catch {
            print("Failed to \(enabled ? "enable" : "disable") login item: \(error.localizedDescription)")
            return false
        }
    }
    
    func getLoginItemStatus() -> SMAppService.Status {
        return SMAppService.mainApp.status
    }
    
    func getStatusDescription() -> String {
        switch SMAppService.mainApp.status {
        case .enabled:
            return "Enabled"
        case .notRegistered:
            return "Disabled"
        case .notFound:
            return "Not Found"
        case .requiresApproval:
            return "Requires Approval"
        @unknown default:
            return "Unknown"
        }
    }
}

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
    var networkManager: NetworkManager?
    private var statusObservationCancellables: Set<AnyCancellable> = []
    private var networkMonitor: NWPathMonitor?
    private var networkQueue = DispatchQueue(label: "NetworkMonitor")
    private var wasNetworkConnected = false
    
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
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Initialize NetworkManager
        networkManager = NetworkManager()
        
        // Set initial menu bar icon with unknown status
        updateMenuBarIcon(for: .unknown)
        
        // Observe PC status changes to update menu bar icon
        Task { @MainActor in
            setupStatusObserver()
        }
        
        // Setup wake-from-sleep detection and network monitoring
        setupWakeDetection()
        setupNetworkMonitoring()
        
        // Request notification permissions
        requestNotificationPermissions()
        
        popover = NSPopover()
        popover?.contentViewController = NSHostingController(rootView: ContentView().environmentObject(networkManager!))
        popover?.behavior = .transient
        popover?.contentSize = NSSize(width: 280, height: 240)
        
        // Use vibrant material that adapts to system appearance
        if let effectiveAppearance = NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) {
            popover?.appearance = NSAppearance(named: effectiveAppearance == .darkAqua ? .vibrantDark : .vibrantLight)
        } else {
            popover?.appearance = NSAppearance(named: .vibrantDark)
        }
        
        NSApplication.shared.setActivationPolicy(.accessory)
        
        // Initialize login items state synchronization
        initializeLoginItemsState()
        
        // Register URL scheme handler
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }
    
    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString) else {
            return
        }
        
        handleWidgetAction(url: url)
    }
    
    private func handleWidgetAction(url: URL) {
        guard url.scheme == "pccontroller",
              let networkManager = networkManager else {
            return
        }
        
        switch url.host {
        case "turn-on":
            Task {
                await networkManager.turnOnPC()
            }
        case "turn-off":
            Task {
                await networkManager.turnOffPC()
            }
        case "check-status":
            Task {
                await networkManager.checkPCStatus()
            }
        case "open":
            // Show the main app popover
            togglePopover()
        default:
            break
        }
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
    
    @MainActor
    private func initializeLoginItemsState() {
        let loginItemsManager = LoginItemsManager.shared
        let isCurrentlyEnabled = loginItemsManager.isLoginItemEnabled()
        let userDefaultsValue = UserDefaults.standard.bool(forKey: Constants.UserDefaults.startOnLogin)
        
        // Sync UserDefaults with actual system state
        if isCurrentlyEnabled != userDefaultsValue {
            UserDefaults.standard.set(isCurrentlyEnabled, forKey: Constants.UserDefaults.startOnLogin)
        }
    }
    
    @MainActor
    private func setupStatusObserver() {
        guard let networkManager = networkManager else { return }
        
        // Observe PC status changes using Combine
        networkManager.$pcStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.updateMenuBarIcon(for: status)
            }
            .store(in: &statusObservationCancellables)
    }
    
    private func setupWakeDetection() {
        // Monitor wake from sleep
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleWakeFromSleep),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        
        // Monitor screen wake (in case system doesn't fully sleep)
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleWakeFromSleep),
            name: NSWorkspace.screensDidWakeNotification,
            object: nil
        )
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor = NWPathMonitor()
        
        networkMonitor?.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let isConnected = path.status == .satisfied
                
                // Check if network was restored after being disconnected
                if isConnected && !(self?.wasNetworkConnected ?? true) {
                    self?.handleNetworkRestored()
                }
                
                self?.wasNetworkConnected = isConnected
            }
        }
        
        networkMonitor?.start(queue: networkQueue)
    }
    
    private func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    @objc private func handleWakeFromSleep() {
        // Delay the status check slightly to allow network to stabilize
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.checkPCStatusAndNotify(reason: "wake from sleep")
        }
    }
    
    private func handleNetworkRestored() {
        // Delay the status check to allow network to fully establish
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.checkPCStatusAndNotify(reason: "network restored")
        }
    }
    
    private func checkPCStatusAndNotify(reason: String) {
        guard let networkManager = networkManager else { return }
        
        Task {
            await networkManager.checkPCStatus()
            
            // Wait a moment for the status to update
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                if networkManager.pcStatus == .online {
                    self?.sendPCOnlineNotification(reason: reason)
                }
            }
        }
    }
    
    private func sendPCOnlineNotification(reason: String) {
        let content = UNMutableNotificationContent()
        content.title = "PC Controller"
        content.body = "Your PC is running after \(reason)"
        content.sound = .default
        
        // Add action to open the app
        let openAction = UNNotificationAction(
            identifier: "OPEN_APP",
            title: "Open App",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: "PC_STATUS",
            actions: [openAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "PC_STATUS"
        
        let request = UNNotificationRequest(
            identifier: "pc_online_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil // Immediate delivery
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
    
    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        networkMonitor?.cancel()
    }
}

// MARK: - Status Indicator Extension
extension AppDelegate {
    func updateMenuBarIcon(for status: PCStatus) {
        guard let button = statusItem?.button else { return }
        
        DispatchQueue.main.async {
            button.image = self.createIconWithStatusIndicator(status: status)
        }
    }
    
    private func createIconWithStatusIndicator(status: PCStatus) -> NSImage? {
        // Get the base power icon
        guard let baseIcon = NSImage(systemSymbolName: "power", accessibilityDescription: "PC Controller") else {
            return nil
        }
        
        // For offline/unknown status, just return the base icon without indicator
        guard status == .online else {
            baseIcon.isTemplate = true
            return baseIcon
        }
        
        // Create a composite image with indicator only when PC is online
        let iconSize = NSSize(width: 18, height: 18)
        let image = NSImage(size: iconSize)
        
        image.lockFocus()
        
        // Draw the base power icon
        baseIcon.draw(in: NSRect(origin: .zero, size: iconSize))
        
        // Draw online indicator (small filled circle in bottom-right corner)
        let indicatorSize: CGFloat = 6
        let indicatorRect = NSRect(
            x: iconSize.width - indicatorSize - 1,
            y: 1,
            width: indicatorSize,
            height: indicatorSize
        )
        
        // Draw indicator as a solid white circle (will appear correctly in both light/dark modes)
        NSColor.white.setFill()
        NSBezierPath(ovalIn: indicatorRect).fill()
        
        image.unlockFocus()
        
        // Ensure the image is rendered as a template image for proper dark mode support
        image.isTemplate = true
        
        return image
    }
}
