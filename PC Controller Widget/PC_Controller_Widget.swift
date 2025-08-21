import WidgetKit
import SwiftUI
import Foundation

// MARK: - Shared Types for Widget
enum PCStatus: Codable {
    case online
    case offline
    case unknown
    
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

struct SharedPCConfig: Codable {
    let baseURL: String
    let hasValidConfig: Bool
}

class WidgetDataManager {
    static let shared = WidgetDataManager()
    
    private let userDefaults: UserDefaults?
    private let dataKey = "PCControllerWidgetData"
    
    private init() {
        self.userDefaults = UserDefaults(suiteName: "group.pccontroller.shared")
    }
    
    func saveData(_ data: SharedPCData) {
        guard let userDefaults = userDefaults else { return }
        
        do {
            let encoded = try JSONEncoder().encode(data)
            userDefaults.set(encoded, forKey: dataKey)
            
            // Only trigger reload if we're not in preview mode
            #if !targetEnvironment(simulator)
            WidgetCenter.shared.reloadTimelines(ofKind: "PCControllerWidget")
            #endif
        } catch {
            print("Failed to encode widget data: \(error)")
        }
    }
    
    func loadData() -> SharedPCData {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: dataKey) else {
            return .default
        }
        
        do {
            return try JSONDecoder().decode(SharedPCData.self, from: data)
        } catch {
            print("Failed to decode widget data: \(error)")
            return .default
        }
    }
}

struct PCControllerWidget: Widget {
    let kind: String = "PCControllerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PCControllerTimelineProvider()) { entry in
            PCControllerWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("PC Controller")
        .description("Quick access to PC power controls and status")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PCControllerEntry: TimelineEntry {
    let date: Date
    let pcData: SharedPCData
}

struct PCControllerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PCControllerEntry {
        PCControllerEntry(date: Date(), pcData: .default)
    }

    func getSnapshot(in context: Context, completion: @escaping (PCControllerEntry) -> ()) {
        let pcData: SharedPCData
        
        if context.isPreview {
            // Use mock data in preview mode
            pcData = SharedPCData(
                status: .online,
                lastUpdated: Date(),
                config: SharedPCConfig(baseURL: "https://example.com", hasValidConfig: true),
                lastError: nil
            )
        } else {
            pcData = WidgetDataManager.shared.loadData()
        }
        
        let entry = PCControllerEntry(date: Date(), pcData: pcData)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let pcData: SharedPCData
        
        if context.isPreview {
            // Use mock data in preview mode
            pcData = SharedPCData(
                status: .offline,
                lastUpdated: Date(),
                config: SharedPCConfig(baseURL: "https://example.com", hasValidConfig: true),
                lastError: nil
            )
        } else {
            pcData = WidgetDataManager.shared.loadData()
        }
        
        let entry = PCControllerEntry(date: currentDate, pcData: pcData)
        
        // Refresh every 30 seconds, but longer in preview mode
        let refreshInterval: TimeInterval = context.isPreview ? 3600 : 30
        let nextUpdate = Calendar.current.date(byAdding: .second, value: Int(refreshInterval), to: currentDate) ?? Date().addingTimeInterval(refreshInterval)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

struct PCControllerWidgetEntryView: View {
    var entry: PCControllerTimelineProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: PCControllerEntry
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "power")
                    .foregroundColor(.primary)
                Text("PC Controller")
                    .font(.caption2)
                    .fontWeight(.medium)
                Spacer()
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                StatusIndicator(status: entry.pcData.status)
                Text(statusText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if entry.pcData.status == .offline {
                Button(intent: TurnOnPCIntent()) {
                    HStack {
                        Image(systemName: "power")
                        Text("Turn On")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green)
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .widgetURL(URL(string: "pccontroller://open"))
    }
    
    private var statusText: String {
        switch entry.pcData.status {
        case .online:
            return "Online"
        case .offline:
            return "Offline"
        case .unknown:
            return "Unknown"
        }
    }
}

struct MediumWidgetView: View {
    let entry: PCControllerEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "power")
                        .foregroundColor(.primary)
                    Text("PC Controller")
                        .font(.headline)
                        .fontWeight(.medium)
                    Spacer()
                }
                
                HStack {
                    StatusIndicator(status: entry.pcData.status)
                    Text(statusText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                
                if let lastError = entry.pcData.lastError {
                    Text(lastError)
                        .font(.caption2)
                        .foregroundColor(.red)
                        .lineLimit(2)
                } else {
                    Text("Last updated: \(timeFormatter.string(from: entry.pcData.lastUpdated))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                if entry.pcData.status == .offline {
                    Button(intent: TurnOnPCIntent()) {
                        HStack {
                            Image(systemName: "power")
                            Text("Turn On")
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Button(intent: TurnOffPCIntent()) {
                        HStack {
                            Image(systemName: "power")
                            Text("Turn Off")
                        }
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Button(intent: CheckStatusIntent()) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Refresh")
                    }
                    .font(.caption)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .widgetURL(URL(string: "pccontroller://open"))
    }
    
    private var statusText: String {
        switch entry.pcData.status {
        case .online:
            return "Online"
        case .offline:
            return "Offline"
        case .unknown:
            return "Unknown"
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct StatusIndicator: View {
    let status: PCStatus
    
    var body: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 12, height: 12)
    }
    
    private var statusColor: Color {
        switch status {
        case .online:
            return .green
        case .offline:
            return .red
        case .unknown:
            return .orange
        }
    }
}
