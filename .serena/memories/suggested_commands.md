# Suggested Commands for PC Controller Development

## Build and Development Commands

### Local Development
```bash
# Open project in Xcode
open "PC Controller.xcodeproj"

# Build using Xcode command line
xcodebuild build -project "PC Controller.xcodeproj" -scheme "PC Controller"

# Clean build
xcodebuild clean -project "PC Controller.xcodeproj" -scheme "PC Controller"
```

### Using Build Script
```bash
# Make script executable (first time only)
chmod +x scripts/build-local.sh

# Full build process (clean, build, archive, create DMG)
./scripts/build-local.sh

# Individual steps
./scripts/build-local.sh clean    # Clean only
./scripts/build-local.sh build    # Build only  
./scripts/build-local.sh archive  # Archive and create DMG
./scripts/build-local.sh help     # Show help
```

## Testing Commands
**Note: Tests are not currently set up but can be added following .github/TESTING.md**

```bash
# Run tests (when configured)
xcodebuild test -project "PC Controller.xcodeproj" -scheme "PC Controller"

# Run specific test
xcodebuild test -project "PC Controller.xcodeproj" -scheme "PC Controller" \
  -only-testing:PC_ControllerTests/PCControllerTests/testExample
```

## Debug and Analysis Commands

### Code Signing Check
```bash
# Check app permissions and entitlements
codesign -d --entitlements - "PC Controller.app"
```

### Network Debugging
```bash
# Monitor network requests to PC
sudo tcpdump -i any host [PC_IP_ADDRESS]
```

### System Logs
```bash
# Check app logs (adjust time as needed)
log show --predicate 'subsystem contains "PC-Controller"' --last 1h

# Real-time log monitoring
log stream --predicate 'subsystem contains "PC-Controller"'
```

## Git Commands (Standard)
```bash
# Basic git workflow
git status
git add .
git commit -m "Description"
git push origin main

# Branch management
git checkout -b feature/new-feature
git checkout main
git merge feature/new-feature
```

## System Utilities (macOS Darwin)
```bash
# File operations
ls -la              # List files with details
find . -name "*.swift"  # Find Swift files
grep -r "searchterm" .  # Search in files

# Process management
ps aux | grep "PC Controller"  # Find running app processes
killall "PC Controller"        # Kill app processes

# System info
sw_vers                # macOS version
system_profiler SPSoftwareDataType  # Detailed system info
```

## GitHub Actions (Automated)
- Push to `main` or `develop` triggers automatic builds
- Create GitHub release for production builds with code signing
- Manual workflow dispatch available in Actions tab