# Codebase Structure

## Project Layout
```
PC Controller/
├── PC_ControllerApp.swift          # Main app entry point with menu bar setup
├── Views/                          # SwiftUI interface components
│   ├── ContentView.swift           # Main popover interface
│   ├── PCControlButton.swift       # Reusable button component
│   └── SettingsView.swift          # Configuration panel
├── Models/                         # Data models and types
│   ├── PCControlModels.swift       # Core data structures (PCStatus, PCConfig, etc.)
│   └── SharedPCData.swift          # Shared data for widget integration
├── Services/                       # Business logic layer
│   ├── NetworkManager.swift       # API communication
│   ├── PCStatusChecker.swift      # Status monitoring
│   └── WakeOnLAN.swift            # Wake-on-LAN implementation
├── Utils/                         # Utility functions and constants
├── Resources/                     # Assets & configuration
│   ├── Info.plist                # App configuration
│   └── PC Controller.entitlements # Network permissions
└── Preview Content/               # SwiftUI preview assets

PC Controller Widget/              # Widget extension (separate target)
├── Widget implementation files

Additional Files:
├── PC Controller.xcodeproj/       # Xcode project file
├── scripts/build-local.sh         # Local build script
├── .github/workflows/             # GitHub Actions CI/CD
├── README.md                      # Project documentation
└── CLAUDE.md                      # Development instructions
```

## Architecture Layers
1. **App Layer**: PC_ControllerApp.swift - Main entry point and menu bar setup
2. **View Layer**: SwiftUI views for user interface
3. **Model Layer**: Data structures and shared state
4. **Service Layer**: Network operations and business logic
5. **Utils Layer**: Helper functions and constants

## Key Components
- **Menu Bar Integration**: NSStatusItem with SwiftUI popover
- **Network Layer**: URLSession with modern async/await patterns
- **Widget Support**: Shared data structures for widget extension
- **Settings Management**: UserDefaults for configuration persistence