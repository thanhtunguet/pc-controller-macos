import Foundation
import Network

@MainActor
class NetworkManager: ObservableObject {
    @Published var pcStatus: PCStatus = .unknown
    @Published var isLoading = false
    @Published var lastError: String?
    
    private let urlSession: URLSession
    private var statusTimer: Timer?
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 15.0
        self.urlSession = URLSession(configuration: config)
        
        startStatusMonitoring()
    }
    
    deinit {
        statusTimer?.invalidate()
        statusTimer = nil
    }
    
    private func getCurrentConfig() -> PCConfig? {
        let baseURL = UserDefaults.standard.string(forKey: "baseURL") ?? ""
        let ipAddress = UserDefaults.standard.string(forKey: "pcIPAddress") ?? ""
        let macAddress = UserDefaults.standard.string(forKey: "macAddress") ?? ""
        let apiKey = UserDefaults.standard.string(forKey: "apiKey")
        
        guard !baseURL.isEmpty,
              PCConfig.validateURL(baseURL) else {
            return nil
        }
        
        return PCConfig(
            baseURL: baseURL,
            ipAddress: ipAddress,
            macAddress: macAddress,
            apiKey: apiKey?.isEmpty == false ? apiKey : nil
        )
    }
    
    func turnOnPC() async {
        await performAction(endpoint: "/turn-on", fallbackToWakeOnLAN: true)
    }
    
    func turnOffPC() async {
        await performAction(endpoint: "/turn-off", fallbackToWakeOnLAN: false)
    }
    
    func checkPCStatus() async {
        await performStatusCheck()
    }
    
    private func performAction(endpoint: String, fallbackToWakeOnLAN: Bool) async {
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        guard let config = getCurrentConfig() else {
            lastError = "Please configure PC settings first"
            return
        }
        
        do {
            let url = URL(string: config.baseURL + endpoint)!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let (data, response) = try await urlSession.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                    let trimmedResponse = responseString.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if trimmedResponse.lowercased() == "success" || trimmedResponse.lowercased() == "ok" || trimmedResponse.lowercased() == "true" {
                        await performStatusCheck()
                    } else if !trimmedResponse.isEmpty {
                        lastError = trimmedResponse
                    }
                } else {
                    throw PCControlError.serverError("HTTP \(httpResponse.statusCode)")
                }
            }
        } catch {
            if fallbackToWakeOnLAN && endpoint.contains("turn-on") {
                await performWakeOnLAN()
            } else {
                lastError = error.localizedDescription
            }
        }
    }
    
    private func performStatusCheck() async {
        guard let config = getCurrentConfig() else {
            pcStatus = .unknown
            return
        }
        
        do {
            let url = URL(string: config.baseURL + "/is-online")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let (data, response) = try await urlSession.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    let responseString = String(data: data, encoding: .utf8) ?? ""
                    pcStatus = responseString.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "true" ? .online : .offline
                } else {
                    pcStatus = .offline
                }
            }
        } catch {
            pcStatus = .offline
        }
    }
    
    private func performWakeOnLAN() async {
        guard let config = getCurrentConfig() else {
            lastError = "Wake-on-LAN: Invalid configuration"
            return
        }
        
        do {
            let wakeOnLAN = WakeOnLAN()
            try await wakeOnLAN.wake(macAddress: config.macAddress, ipAddress: config.ipAddress)
            
            try await Task.sleep(nanoseconds: 3_000_000_000)
            await performStatusCheck()
        } catch {
            lastError = "Wake-on-LAN failed: \(error.localizedDescription)"
        }
    }
    
    private func startStatusMonitoring() {
        statusTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            Task {
                await self.performStatusCheck()
            }
        }
        
        Task {
            await performStatusCheck()
        }
    }
    
    private func stopStatusMonitoring() {
        statusTimer?.invalidate()
        statusTimer = nil
    }
}
