import Foundation
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
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults?.set(encoded, forKey: dataKey)
            
            // Trigger widget timeline reload
            WidgetCenter.shared.reloadTimelines(ofKind: "PCControllerWidget")
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