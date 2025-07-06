# PC Controller - macOS Menu Bar App

A macOS menu bar application that provides quick access to PC control functions: Turn On, Turn Off, and Status Check.

## Project Overview

This is a SwiftUI-based macOS menu bar app that sits in the system menu bar and provides a popover interface with three main functions:
- **Turn On PC**: Send wake-on-LAN or API call to start the PC
- **Turn Off PC**: Send shutdown command via API
- **Check PC Status**: Ping or API call to check if PC is online

## Architecture

- **Menu Bar App**: Uses `NSStatusItem` to create a menu bar presence
- **SwiftUI Interface**: Modern declarative UI in a popover
- **Network Layer**: HTTP API calls for PC control
- **Status Management**: Real-time PC status tracking

## Getting Started with Claude Code

### Initial Setup
```bash
# Create new Xcode project
# Template: macOS App, SwiftUI, Swift
# Name: PC Controller
```

### Key Files to Create/Modify

1. **PC_ControllerApp.swift** - Main app entry point with menu bar setup
2. **ContentView.swift** - SwiftUI interface for the popover menu
3. **NetworkManager.swift** - Handle API calls to PC
4. **PCControlModels.swift** - Data models for PC status and commands
5. **Info.plist** - App configuration
6. **PC Controller.entitlements** - Network permissions

### Project Structure
```
PC Controller/
├── PC_ControllerApp.swift          # App delegate with menu bar setup
├── Views/
│   ├── ContentView.swift           # Main popover interface
│   ├── PCControlButton.swift       # Reusable button component
│   └── SettingsView.swift          # Configuration panel
├── Models/
│   ├── PCControlModels.swift       # Data models
│   └── AppSettings.swift          # User preferences
├── Services/
│   ├── NetworkManager.swift       # API communication
│   ├── WakeOnLAN.swift            # Wake-on-LAN implementation
│   └── PCStatusChecker.swift      # Status monitoring
├── Utils/
│   └── Constants.swift            # App constants
└── Resources/
    ├── Info.plist                 # App configuration
    └── PC Controller.entitlements # Permissions
```

## Implementation Steps

### 1. Menu Bar Setup
- Configure `NSStatusItem` with system tray icon
- Set up popover with SwiftUI content
- Handle click events and popover lifecycle

### 2. SwiftUI Interface
- Create main control panel with three buttons
- Add status indicator and loading states
- Implement responsive button styling

### 3. Network Layer
- HTTP client for API calls
- Error handling and timeout management
- Response parsing and status updates

### 4. PC Control Functions
- **Turn On**: Wake-on-LAN magic packet or HTTP POST
- **Turn Off**: HTTP POST to shutdown endpoint
- **Status Check**: HTTP GET or ping to verify connectivity

### 5. Configuration
- Settings panel for PC IP address
- API endpoint configuration
- Wake-on-LAN MAC address setup

## API Endpoints (Example)

```
POST /api/pc/power-on     # Turn on PC
POST /api/pc/power-off    # Turn off PC
GET  /api/pc/status       # Check PC status
```

## Key Features to Implement

- [x] Menu bar integration
- [x] SwiftUI popover interface
- [ ] Network API calls
- [ ] Wake-on-LAN functionality
- [ ] Status monitoring
- [ ] Error handling
- [ ] Settings persistence
- [ ] Auto-refresh status
- [ ] Notification feedback

## Technical Requirements

- **macOS 13.0+** (for modern SwiftUI features)
- **Network entitlements** for API calls
- **Background app execution** for menu bar operation

## Configuration Options

```swift
struct PCConfig {
    let ipAddress: String
    let apiPort: Int
    let macAddress: String  // For Wake-on-LAN
    let apiKey: String?     // Optional authentication
}
```

## Development Notes

### Menu Bar Best Practices
- Use system-appropriate icons
- Implement proper popover dismissal
- Handle multiple monitor setups
- Respect system dark/light mode

### Network Considerations
- Implement proper timeout handling
- Add retry logic for failed requests
- Cache last known status
- Handle network connectivity changes

### User Experience
- Provide clear feedback for all actions
- Show loading states during operations
- Display helpful error messages
- Auto-refresh status periodically

## Deployment

1. **Code Signing**: Configure development team
2. **Entitlements**: Network access permissions
3. **Info.plist**: Menu bar app configuration
4. **Testing**: Verify on different macOS versions

## Future Enhancements

- Multiple PC support
- Keyboard shortcuts
- Status notifications
- Power scheduling
- Network discovery
- Custom API endpoints

## Troubleshooting

### Common Issues
- **Menu bar icon not appearing**: Check `LSUIElement` in Info.plist
- **Network requests failing**: Verify entitlements and firewall settings
- **Popover positioning**: Test on multiple monitor configurations
- **App not staying open**: Ensure proper app lifecycle management

### Debug Commands
```bash
# Check app permissions
codesign -d --entitlements - "PC Controller.app"

# Monitor network requests
sudo tcpdump -i any host [PC_IP_ADDRESS]

# Check system logs
log show --predicate 'subsystem == "com.yourname.pc-controller"'
```

## Getting Help

When working with Claude Code:
1. **Specify the exact file** you want to work on
2. **Describe the specific functionality** you're implementing
3. **Share error messages** for debugging help
4. **Ask for code reviews** before major changes
5. **Request testing strategies** for each component

Example prompts:
- "Help me implement the NetworkManager.swift file with proper error handling"
- "Create the Wake-on-LAN functionality in WakeOnLAN.swift"
- "Debug this SwiftUI layout issue in ContentView.swift"
- "Add proper async/await networking with URLSession"