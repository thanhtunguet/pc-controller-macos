# PC Controller - macOS Menu Bar App

## Project Purpose
A sleek macOS menu bar application that provides quick access to PC control functions directly from your Mac's menu bar. The app enables remote control of a PC through:
- **Turn On PC**: Wake up PC using Wake-on-LAN or API calls
- **Turn Off PC**: Safely shut down PC remotely
- **Status Monitoring**: Real-time PC status checking with visual indicators

## Tech Stack
- **Language**: Swift
- **UI Framework**: SwiftUI
- **Platform**: macOS 13.0+
- **Development Tool**: Xcode 14.0+
- **Architecture**: Clean architecture with separation of concerns
- **Networking**: URLSession with async/await
- **Deployment**: Xcode projects (.xcodeproj)

## Target Platform
- macOS menu bar application
- Requires macOS 13.0 or later
- Uses modern SwiftUI and async/await patterns
- HTTPS-only API communication for security

## Key Features
- Menu bar integration with NSStatusItem
- SwiftUI popover interface
- Network API calls for PC control
- Wake-on-LAN functionality
- Real-time status monitoring
- Settings persistence
- Error handling and timeout management
- Security with HTTPS and domain validation