import Foundation

enum PCStatus {
    case online
    case offline
    case unknown
}

struct PCConfig {
    let baseURL: String
    let ipAddress: String
    let macAddress: String
    let apiKey: String?
    
    static func validateURL(_ url: String) -> Bool {
        guard let validURL = URL(string: url),
              let scheme = validURL.scheme,
              scheme.lowercased() == "https",
              let host = validURL.host,
              !host.isEmpty,
              !isIPAddress(host) else {
            return false
        }
        return true
    }
    
    private static func isIPAddress(_ host: String) -> Bool {
        let ipv4Regex = try! NSRegularExpression(pattern: "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$")
        let ipv6Regex = try! NSRegularExpression(pattern: "^(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$")
        
        let range = NSRange(location: 0, length: host.count)
        return ipv4Regex.firstMatch(in: host, options: [], range: range) != nil ||
               ipv6Regex.firstMatch(in: host, options: [], range: range) != nil
    }
}

struct PCControlRequest: Codable {
    let action: String
    let apiKey: String?
}

struct PCStatusResponse: Codable {
    let status: String
    let timestamp: Date
    let uptime: Int?
    
    enum CodingKeys: String, CodingKey {
        case status, timestamp, uptime
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(String.self, forKey: .status)
        uptime = try container.decodeIfPresent(Int.self, forKey: .uptime)
        
        if let timestampString = try? container.decode(String.self, forKey: .timestamp) {
            let formatter = ISO8601DateFormatter()
            timestamp = formatter.date(from: timestampString) ?? Date()
        } else {
            timestamp = Date()
        }
    }
}

struct PCControlResponse: Codable {
    let success: Bool
    let message: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case success, message, timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        message = try container.decode(String.self, forKey: .message)
        
        if let timestampString = try? container.decode(String.self, forKey: .timestamp) {
            let formatter = ISO8601DateFormatter()
            timestamp = formatter.date(from: timestampString) ?? Date()
        } else {
            timestamp = Date()
        }
    }
}

enum PCControlError: Error, LocalizedError {
    case invalidConfiguration
    case invalidURL
    case networkError(String)
    case invalidResponse
    case serverError(String)
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Invalid PC configuration. Please check settings."
        case .invalidURL:
            return "Base URL must be HTTPS and use a domain name (not IP address)."
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from PC"
        case .serverError(let message):
            return "Server error: \(message)"
        case .timeout:
            return "Request timed out"
        }
    }
}

// MARK: - Widget Support

import WidgetKit

// Shared data structure that both main app and widget can use
struct SharedPCData: Codable {
    let status: PCStatus
    let lastUpdated: Date
    let config: SharedPCConfig?
    let lastError: String?
    
    static var `default`: SharedPCData {
        SharedPCData(
            status: .unknown,
            lastUpdated: Date(),
            config: nil,
            lastError: nil
        )
    }
}

// Simplified config for sharing with widget
struct SharedPCConfig: Codable {
    let baseURL: String
    let hasValidConfig: Bool
    
    init(from pcConfig: PCConfig) {
        self.baseURL = pcConfig.baseURL
        self.hasValidConfig = PCConfig.validateURL(pcConfig.baseURL)
    }
}

// Widget data manager for sharing data between main app and widget
class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let userDefaults = UserDefaults(suiteName: "group.pccontroller.shared")
    private let dataKey = "PCControllerWidgetData"
    
    private init() {}
    
    func saveData(_ data: SharedPCData) {
        guard let userDefaults = userDefaults else { return }
        
        do {
            let encoded = try JSONEncoder().encode(data)
            userDefaults.set(encoded, forKey: dataKey)
            
            // Force synchronization
            userDefaults.synchronize()
            
            // Trigger widget timeline reload
            WidgetCenter.shared.reloadTimelines(ofKind: "PCControllerWidget")
        } catch {
            print("Failed to encode shared PC data: \(error)")
        }
    }
    
    func loadData() -> SharedPCData {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: dataKey),
              let decoded = try? JSONDecoder().decode(SharedPCData.self, from: data) else {
            return .default
        }
        return decoded
    }
}

extension PCStatus: Codable {
    enum CodingKeys: String, CodingKey {
        case rawValue
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawValue = try container.decode(String.self, forKey: .rawValue)
        
        switch rawValue {
        case "online":
            self = .online
        case "offline":
            self = .offline
        default:
            self = .unknown
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let rawValue: String
        
        switch self {
        case .online:
            rawValue = "online"
        case .offline:
            rawValue = "offline"
        case .unknown:
            rawValue = "unknown"
        }
        
        try container.encode(rawValue, forKey: .rawValue)
    }
}
