# PC Controller - macOS Menu Bar App

A sleek macOS menu bar application that provides quick access to PC control functions directly from your Mac's menu bar. Control your PC remotely with just a few clicks.

## Features

- **Menu Bar Integration**: Lives in your macOS menu bar for instant access
- **Turn On PC**: Wake up your PC using Wake-on-LAN or API calls
- **Turn Off PC**: Safely shut down your PC remotely
- **Status Monitoring**: Real-time PC status checking with visual indicators
- **Modern UI**: Clean SwiftUI interface with intuitive controls
- **Error Handling**: Comprehensive error reporting and timeout management
- **Secure**: HTTPS-only API communication with optional authentication

## Screenshots

The app provides a clean, minimal interface with three main control buttons and a status indicator showing whether your PC is online, offline, or in an unknown state.

## Requirements

- macOS 13.0 or later
- Xcode 14.0 or later (for development)
- Network connectivity to target PC
- PC with Wake-on-LAN capability (optional)

## Installation

### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/DesktopControllerMacOS.git
   cd DesktopControllerMacOS
   ```

2. Open the project in Xcode:
   ```bash
   open "PC Controller.xcodeproj"
   ```

3. Build and run the project (⌘+R)

## Configuration

1. Click the gear icon in the app's popover to open settings
2. Configure your PC's details:
   - **Base URL**: Your PC's API endpoint (must be HTTPS with domain name)
   - **IP Address**: Your PC's local IP address
   - **MAC Address**: Required for Wake-on-LAN functionality
   - **API Key**: Optional authentication key

### Example Configuration

```
Base URL: https://your-pc-api.example.com
IP Address: 192.168.1.100
MAC Address: 00:11:22:33:44:55
API Key: your-optional-api-key
```

## API Endpoints

The app expects your PC to provide these endpoints:

- `POST /power-on` - Turn on PC
- `POST /power-off` - Turn off PC  
- `GET /status` - Check PC status

### Request Format

```json
{
  "action": "power-on|power-off",
  "apiKey": "optional-api-key"
}
```

### Response Format

**Status Response:**
```json
{
  "status": "online|offline",
  "timestamp": "2024-01-01T00:00:00Z",
  "uptime": 3600
}
```

**Control Response:**
```json
{
  "success": true,
  "message": "PC powered on successfully",
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## Architecture

The app follows a clean architecture pattern:

- **PC_ControllerApp.swift**: Main app entry point with menu bar setup
- **Views/**: SwiftUI interface components
  - `ContentView.swift`: Main popover interface
  - `PCControlButton.swift`: Reusable button component
  - `SettingsView.swift`: Configuration panel
- **Models/**: Data models and types
  - `PCControlModels.swift`: Core data structures
- **Services/**: Business logic layer
  - `NetworkManager.swift`: API communication
  - `PCStatusChecker.swift`: Status monitoring
  - `WakeOnLAN.swift`: Wake-on-LAN implementation
- **Utils/**: Utility functions and constants

## Development

### Project Structure

```
PC Controller/
├── PC_ControllerApp.swift          # App entry point
├── Views/                          # SwiftUI views
├── Models/                         # Data models
├── Services/                       # Network & business logic
├── Utils/                          # Utilities
└── Resources/                      # Assets & configuration
```

### Key Features

- **Async/Await**: Modern concurrency for network operations
- **SwiftUI**: Declarative UI framework
- **Error Handling**: Comprehensive error types and user feedback
- **Security**: HTTPS-only communication with domain validation
- **Performance**: Efficient status checking and caching

## Security

- All API communication uses HTTPS
- Domain name validation (IP addresses rejected for security)
- Optional API key authentication
- Network permissions properly configured in entitlements

## Troubleshooting

### Common Issues

**Menu bar icon not appearing:**
- Ensure `LSUIElement` is set to `true` in Info.plist
- Check that the app has proper code signing

**Network requests failing:**
- Verify network entitlements in `PC Controller.entitlements`
- Check firewall settings on both Mac and PC
- Ensure API endpoints are accessible

**Wake-on-LAN not working:**
- Verify MAC address format (00:11:22:33:44:55)
- Ensure target PC has Wake-on-LAN enabled in BIOS
- Check network configuration allows magic packets

### Debug Commands

```bash
# Check app permissions
codesign -d --entitlements - "PC Controller.app"

# Monitor network requests
sudo tcpdump -i any host [PC_IP_ADDRESS]

# Check system logs
log show --predicate 'subsystem contains "PC-Controller"' --last 1h
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with SwiftUI and modern macOS development practices
- Inspired by the need for simple, secure PC remote control
- Uses system-standard design patterns for menu bar apps