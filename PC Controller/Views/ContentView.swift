import SwiftUI

struct ContentView: View {
    @StateObject private var networkManager = NetworkManager()
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("PC Controller")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            StatusIndicator(status: networkManager.pcStatus)
            
            VStack(spacing: 10) {
                PCControlButton(
                    title: "Turn On",
                    icon: "power",
                    color: .green,
                    isLoading: networkManager.isLoading
                ) {
                    Task {
                        await networkManager.turnOnPC()
                    }
                }
                
                PCControlButton(
                    title: "Turn Off",
                    icon: "power.circle",
                    color: .red,
                    isLoading: networkManager.isLoading
                ) {
                    Task {
                        await networkManager.turnOffPC()
                    }
                }
                
                PCControlButton(
                    title: "Check Status",
                    icon: "arrow.clockwise",
                    color: .blue,
                    isLoading: networkManager.isLoading
                ) {
                    Task {
                        await networkManager.checkPCStatus()
                    }
                }
            }
            
            if let error = networkManager.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, 4)
                    .padding(.top, 4)
            }
            
            Divider()
                .padding(.horizontal, -8)
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Image(systemName: "power")
                        .font(.system(size: 12))
                    Text("Quit PC Controller")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(16)
        .frame(width: 280)
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

struct StatusIndicator: View {
    let status: PCStatus
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            
            Text(statusText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
    
    private var statusColor: Color {
        switch status {
        case .online:
            return .green
        case .offline:
            return .red
        case .unknown:
            return .yellow
        }
    }
    
    private var statusText: String {
        switch status {
        case .online:
            return "PC is Online"
        case .offline:
            return "PC is Offline"
        case .unknown:
            return "Status Unknown"
        }
    }
}

#Preview {
    ContentView()
}