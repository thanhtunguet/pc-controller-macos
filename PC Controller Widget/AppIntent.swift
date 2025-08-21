import AppIntents
import Foundation
import WidgetKit

// Intent for turning on PC
struct TurnOnPCIntent: AppIntent {
    static var title: LocalizedStringResource = "Turn On PC"
    static var description = IntentDescription("Turns on your PC using Wake-on-LAN or API call")
    
    func perform() async throws -> some IntentResult {
        #if !targetEnvironment(simulator)
        // Trigger notification to main app via UserDefaults
        let userDefaults = UserDefaults(suiteName: "group.pccontroller.shared")
        userDefaults?.set("turn-on", forKey: "widgetAction")
        userDefaults?.set(Date(), forKey: "widgetActionTime")
        
        // Update widget after a delay to show status change
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            WidgetCenter.shared.reloadTimelines(ofKind: "PCControllerWidget")
        }
        #endif
        
        return .result()
    }
}

// Intent for turning off PC
struct TurnOffPCIntent: AppIntent {
    static var title: LocalizedStringResource = "Turn Off PC"
    static var description = IntentDescription("Turns off your PC using API call")
    
    func perform() async throws -> some IntentResult {
        #if !targetEnvironment(simulator)
        // Trigger notification to main app via UserDefaults
        let userDefaults = UserDefaults(suiteName: "group.pccontroller.shared")
        userDefaults?.set("turn-off", forKey: "widgetAction")
        userDefaults?.set(Date(), forKey: "widgetActionTime")
        
        // Update widget after a delay to show status change
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            WidgetCenter.shared.reloadTimelines(ofKind: "PCControllerWidget")
        }
        #endif
        
        return .result()
    }
}

// Intent for checking PC status
struct CheckStatusIntent: AppIntent {
    static var title: LocalizedStringResource = "Check PC Status"
    static var description = IntentDescription("Refreshes the PC status")
    
    func perform() async throws -> some IntentResult {
        #if !targetEnvironment(simulator)
        // Trigger notification to main app via UserDefaults
        let userDefaults = UserDefaults(suiteName: "group.pccontroller.shared")
        userDefaults?.set("check-status", forKey: "widgetAction")
        userDefaults?.set(Date(), forKey: "widgetActionTime")
        
        // Immediately refresh widget
        WidgetCenter.shared.reloadTimelines(ofKind: "PCControllerWidget")
        #endif
        
        return .result()
    }
}
