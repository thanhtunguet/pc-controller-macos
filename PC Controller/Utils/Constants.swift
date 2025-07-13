import Foundation

struct Constants {
    
    // MARK: - API Endpoints
    struct API {
        static let powerOn = "/api/pc/power-on"
        static let powerOff = "/api/pc/power-off"
        static let status = "/api/pc/status"
    }
    
    // MARK: - Network Configuration
    struct Network {
        static let requestTimeout: TimeInterval = 10.0
        static let resourceTimeout: TimeInterval = 15.0
        static let wakeOnLANPort: UInt16 = 9
        static let statusCheckInterval: TimeInterval = 30.0
    }
    
    // MARK: - User Defaults Keys
    struct UserDefaults {
        static let baseURL = "baseURL"
        static let pcIPAddress = "pcIPAddress"
        static let macAddress = "macAddress"
        static let apiKey = "apiKey"
        static let startOnLogin = "startOnLogin"
    }
    
    // MARK: - UI Configuration
    struct UI {
        static let popoverWidth: CGFloat = 250
        static let popoverHeight: CGFloat = 200
        static let settingsWidth: CGFloat = 350
        static let settingsHeight: CGFloat = 300
    }
    
    // MARK: - App Configuration
    struct App {
        static let bundleIdentifier = "com.pccontroller.macos"
        static let displayName = "PC Controller"
        static let version = "1.0.0"
    }
}