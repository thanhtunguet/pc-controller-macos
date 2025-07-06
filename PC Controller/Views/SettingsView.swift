import SwiftUI

struct SettingsView: View {
    @AppStorage("baseURL") private var baseURL = ""
    @AppStorage("pcIPAddress") private var pcIPAddress = ""
    @AppStorage("macAddress") private var macAddress = ""
    @AppStorage("apiKey") private var apiKey = ""
    @Environment(\.dismiss) private var dismiss
    @State private var urlError: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PC Controller Settings")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Base URL (HTTPS with domain name)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("https://example.com", text: $baseURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: baseURL) { _, newValue in
                        validateURL(newValue)
                    }
                
                if let urlError = urlError {
                    Text(urlError)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("PC IP Address (for Wake-on-LAN)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("192.168.1.100", text: $pcIPAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("MAC Address (for Wake-on-LAN)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("00:11:22:33:44:55", text: $macAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("API Key (Optional)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                SecureField("Enter API key", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            HStack {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Save") {
                    if validateAndSave() {
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(urlError != nil)
            }
        }
        .padding()
        .frame(width: 400, height: 350)
    }
    
    private func validateURL(_ url: String) {
        if url.isEmpty {
            urlError = nil
            return
        }
        
        if PCConfig.validateURL(url) {
            urlError = nil
        } else {
            urlError = "URL must be HTTPS and use a domain name (not IP address)"
        }
    }
    
    private func validateAndSave() -> Bool {
        validateURL(baseURL)
        return urlError == nil
    }
}