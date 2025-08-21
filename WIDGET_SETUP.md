# PC Controller Widget Setup Guide

## Overview
The PC Controller now includes a macOS desktop widget that displays your PC's status and provides quick access to power controls directly from your desktop.

## Setup Steps

### 1. Add Widget Extension Target in Xcode

1. Open your `PC Controller.xcodeproj` in Xcode
2. Go to **File** → **New** → **Target**
3. Choose **Widget Extension** 
4. Set the target name to: `PC Controller Widget`
5. Product Name: `PC Controller Widget`
6. Bundle Identifier: `com.yourcompany.pc-controller.widget` (adjust to match your main app's bundle ID)
7. **Check "Include Configuration Intent"** if you want configurable widgets (optional)
8. Click **Finish**

### 2. Configure App Groups

1. In Xcode, select your main app target (`PC Controller`)
2. Go to **Signing & Capabilities**
3. Click **+ Capability** and add **App Groups**
4. Add the group: `group.pccontroller.shared`

5. Select the widget target (`PC Controller Widget`)
6. Go to **Signing & Capabilities**
7. Click **+ Capability** and add **App Groups**
8. Add the same group: `group.pccontroller.shared`

### 3. Add Files to Widget Target

In Xcode, you need to add the following files to your widget target:

**For the Widget target, add these files:**
- `PC Controller Widget/PCControllerWidget.swift`
- `PC Controller Widget/PCControllerWidgetIntents.swift`
- `PC Controller Widget/PCControllerWidgetBundle.swift`
- `PC Controller Widget/Info.plist`
- `PC Controller Widget/PC Controller Widget.entitlements`

**For the Main app target, add this file to both targets (main app + widget):**
- `PC Controller/Models/SharedPCData.swift`

To add files to targets:
1. Select the file in Project Navigator
2. In File Inspector (right panel), check the target membership boxes
3. Make sure `SharedPCData.swift` is checked for both main app and widget targets

### 4. Update Build Settings

For both targets, ensure:
- **Deployment Target**: macOS 13.0 or later
- **Swift Language Version**: Swift 5

### 5. Build and Test

1. Build both targets (`Cmd+B`)
2. Run the main app
3. Add the widget to your desktop:
   - Right-click on desktop → **Edit Widgets**
   - Search for "PC Controller"
   - Add the widget in small or medium size

## Widget Features

### Small Widget
- Shows PC status with colored indicator
- Displays current status text
- Turn On button (when PC is offline)

### Medium Widget
- Shows PC status with colored indicator
- Displays status text and last update time
- Turn On/Turn Off buttons (context-dependent)
- Refresh button to check status
- Error messages when applicable

## Widget Interactions

The widget buttons perform the following actions:
- **Turn On**: Sends wake-on-LAN packet or API call to start PC
- **Turn Off**: Sends API shutdown command to PC
- **Refresh**: Checks current PC status
- **Widget Tap**: Opens the main PC Controller app

## Data Synchronization

The widget automatically updates every 30 seconds and syncs with the main app through:
- Shared UserDefaults via App Groups
- Widget timeline refresh triggered by main app actions
- URL scheme communication between widget and main app

## Troubleshooting

### Widget Not Appearing
- Ensure both targets build successfully
- Check that App Groups are configured correctly
- Verify widget target has the correct bundle identifier

### Widget Not Updating
- Check that `group.pccontroller.shared` App Group is added to both targets
- Ensure main app is running to sync data
- Try removing and re-adding the widget

### Button Actions Not Working
- Verify URL scheme (`pccontroller://`) is registered in main app's Info.plist
- Check that main app handles URL events in `AppDelegate`
- Ensure main app is running in background

### Build Errors
- Clean build folder (`Cmd+Shift+K`)
- Check that all required files are added to correct targets
- Verify deployment target is macOS 13.0+

## File Structure

```
PC Controller/
├── Models/
│   ├── SharedPCData.swift          # Shared between app and widget
│   └── PCControlModels.swift       # Main app models
└── Services/
    └── NetworkManager.swift        # Updated with widget sync

PC Controller Widget/
├── PCControllerWidget.swift        # Main widget implementation  
├── PCControllerWidgetIntents.swift # Widget button actions
├── PCControllerWidgetBundle.swift  # Widget bundle entry point
├── Info.plist                      # Widget configuration
└── PC Controller Widget.entitlements # Widget permissions
```

## Next Steps

After successful setup:
1. Configure your PC settings in the main app
2. Test all widget buttons to ensure proper communication
3. Customize widget refresh intervals if needed
4. Consider adding widget configuration options for multiple PCs