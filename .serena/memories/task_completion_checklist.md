# Task Completion Checklist

## When a Development Task is Completed

### 1. Code Quality Checks
- **Build Verification**: Ensure code compiles without errors
  ```bash
  xcodebuild build -project "PC Controller.xcodeproj" -scheme "PC Controller"
  ```
- **SwiftUI Preview**: Verify SwiftUI previews work correctly in Xcode
- **Code Style**: Follow established Swift conventions and patterns
- **Error Handling**: Ensure proper error handling is implemented

### 2. Testing (When Tests Are Available)
- **Unit Tests**: Run relevant unit tests
  ```bash
  xcodebuild test -project "PC Controller.xcodeproj" -scheme "PC Controller"
  ```
- **Manual Testing**: Test functionality in the actual app
- **Edge Cases**: Verify error conditions and boundary cases

### 3. Security and Permissions
- **Entitlements**: Verify network entitlements are properly configured
- **HTTPS Only**: Ensure all network communication uses HTTPS
- **No Secrets**: Confirm no API keys or secrets are hardcoded
- **Input Validation**: Verify user input is properly validated

### 4. Integration Testing
- **Menu Bar**: Test menu bar integration and popover behavior
- **Network Calls**: Verify API endpoints work correctly
- **Settings**: Test settings persistence and loading
- **Widget Integration**: If applicable, test widget functionality

### 5. Performance and UX
- **Responsiveness**: Ensure UI remains responsive during network operations
- **Error Messages**: Provide clear, helpful error messages
- **Loading States**: Show appropriate loading indicators
- **Memory Usage**: Check for memory leaks or excessive usage

### 6. Documentation Updates
- **Code Comments**: Add necessary inline documentation
- **CLAUDE.md**: Update if architectural changes were made
- **README.md**: Update if user-facing features changed

## Pre-Commit Checklist
1. ✅ Code builds successfully
2. ✅ No compiler warnings introduced
3. ✅ Functionality tested manually
4. ✅ Follows project code style
5. ✅ Error handling implemented
6. ✅ Security best practices followed
7. ✅ Documentation updated if needed

## Release Checklist (Major Changes)
1. ✅ Full app testing on multiple macOS versions
2. ✅ Network functionality tested with real PC
3. ✅ Menu bar behavior tested on multiple monitor setups
4. ✅ Settings migration tested (if applicable)
5. ✅ Archive and DMG creation tested
6. ✅ Code signing verified (for distribution)