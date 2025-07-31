# GitHub Actions Workflows for PC Controller

This directory contains GitHub Actions workflows for building and distributing the PC Controller macOS app.

## Available Workflows

### 1. `build-simple.yml` (Recommended for development)
- **Purpose**: Basic build without code signing
- **Triggers**: Push to main/develop, Pull requests
- **Outputs**: 
  - `.app` bundle
  - `.dmg` installer
  - `.xcarchive` file
- **Use case**: Development builds, testing, CI/CD

### 2. `build.yml` (Full production build)
- **Purpose**: Complete build with code signing and notarization
- **Triggers**: Push to main/develop, Pull requests, Release creation
- **Outputs**: 
  - Signed `.app` bundle
  - Notarized `.dmg` installer
  - Test results (when enabled)
- **Use case**: Production releases, App Store distribution
- **Note**: Test workflow is currently disabled (see [TESTING.md](TESTING.md) for setup)

## Quick Start

### For Development (No setup required)
1. Push your code to the `main` or `develop` branch
2. The `build-simple.yml` workflow will automatically run
3. Download artifacts from the Actions tab in GitHub

### For Production Releases
1. Set up code signing certificates (see setup instructions below)
2. Create a GitHub release
3. The `build.yml` workflow will build, sign, and notarize your app

## Setup Instructions

### Code Signing Setup (Required for production)

#### 1. Generate Code Signing Certificate
```bash
# Create a Developer ID Application certificate
security create-keychain -p "your-keychain-password" build.keychain
security default-keychain -s build.keychain
security unlock-keychain -p "your-keychain-password" build.keychain
security set-keychain-settings -t 3600 -l ~/Library/Keychains/build.keychain

# Export your certificate to P12 format
security export -k build.keychain -t identities -f pkcs12 -o certificate.p12
```

#### 2. Set GitHub Secrets
Go to your repository Settings → Secrets and variables → Actions, and add:

**Required for code signing:**
- `P12_BASE64`: Base64 encoded P12 certificate file
- `P12_PASSWORD`: Password for the P12 certificate
- `DEVELOPER_ID`: Your Developer ID (e.g., "Your Name (TEAM_ID)")
- `TEAM_ID`: Your Apple Developer Team ID

**Required for notarization:**
- `APPLE_ID`: Your Apple ID email
- `APPLE_APP_SPECIFIC_PASSWORD`: App-specific password for your Apple ID

#### 3. Convert P12 to Base64
```bash
# Convert your P12 certificate to base64
base64 -i certificate.p12 | pbcopy
# Paste the result into the P12_BASE64 secret
```

### App-Specific Password Setup
1. Go to https://appleid.apple.com
2. Sign in with your Apple ID
3. Go to "Sign-in and Security" → "App-Specific Passwords"
4. Generate a new password for "GitHub Actions"
5. Add it to the `APPLE_APP_SPECIFIC_PASSWORD` secret

## Workflow Details

### Build Process
1. **Checkout**: Clone the repository
2. **Setup**: Select Xcode and show versions
3. **Clean**: Remove previous build artifacts
4. **Build**: Compile the app in Release configuration
5. **Archive**: Create Xcode archive
6. **Package**: Create .app bundle and .dmg installer
7. **Upload**: Store artifacts for download

### Code Signing Process (Production)
1. **Download**: Get build artifacts from previous job
2. **Import**: Load code signing certificates
3. **Sign**: Sign the app with Developer ID
4. **Notarize**: Submit to Apple for notarization
5. **Staple**: Attach notarization ticket
6. **Upload**: Store signed artifacts

## Artifacts

### Build Artifacts
- `PC Controller.app`: The compiled application bundle
- `PC Controller.dmg`: Disk image for distribution
- `PC Controller.xcarchive`: Xcode archive file

### Logs
- Build logs (if build fails)
- Test results (if tests are configured)

## Troubleshooting

### Common Issues

#### Build Fails
- Check that the scheme name matches exactly: "PC Controller"
- Verify all source files are included in the project
- Check for missing dependencies

#### Code Signing Fails
- Verify P12 certificate is valid and not expired
- Check that `DEVELOPER_ID` matches your certificate
- Ensure `TEAM_ID` is correct

#### Notarization Fails
- Verify Apple ID and app-specific password
- Check that the app is properly signed
- Review notarization logs for specific issues

### Debug Commands
```bash
# Check certificate validity
security find-identity -v -p codesigning

# Verify app signature
codesign -dv --verbose=4 "PC Controller.app"

# Check notarization status
xcrun notarytool info [submission-id] --apple-id [email] --password [password] --team-id [team-id]
```

## Customization

### Environment Variables
You can customize the build by modifying the `env` section in the workflow files:

```yaml
env:
  XCODE_PROJECT: "PC Controller.xcodeproj"
  XCODE_SCHEME: "PC Controller"
  APP_NAME: "PC Controller"
```

### Build Configuration
- Change `-configuration Release` to `Debug` for debug builds
- Modify `-destination` for different target platforms
- Add additional build flags as needed

### Triggers
Modify the `on` section to change when workflows run:

```yaml
on:
  push:
    branches: [ main, develop, feature/* ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:  # Manual trigger
```

## Security Notes

- Never commit certificates or passwords to the repository
- Use GitHub Secrets for all sensitive information
- Regularly rotate app-specific passwords
- Keep certificates up to date

## Support

For issues with the workflows:
1. Check the Actions tab for detailed logs
2. Verify all secrets are properly configured
3. Test builds locally first
4. Review Apple Developer documentation for code signing issues 