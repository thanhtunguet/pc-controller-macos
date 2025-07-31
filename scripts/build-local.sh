#!/bin/bash

# Local build script for PC Controller macOS app
# This script mirrors the GitHub Actions workflow for local testing

set -e  # Exit on any error

# Configuration
XCODE_PROJECT="PC Controller.xcodeproj"
XCODE_SCHEME="PC Controller"
APP_NAME="PC Controller"
BUILD_DIR="./build"
DERIVED_DATA="./DerivedData"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Xcode is installed
    if ! command -v xcodebuild &> /dev/null; then
        log_error "Xcode is not installed or not in PATH"
        exit 1
    fi
    
    # Check if project file exists
    if [ ! -d "$XCODE_PROJECT" ]; then
        log_error "Project file not found: $XCODE_PROJECT"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Show versions
show_versions() {
    log_info "Xcode version:"
    xcodebuild -version
    
    log_info "Swift version:"
    swift --version
}

# Clean build
clean_build() {
    log_info "Cleaning build artifacts..."
    
    # Remove derived data
    if [ -d "$DERIVED_DATA" ]; then
        rm -rf "$DERIVED_DATA"
    fi
    
    # Remove build directory
    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
    fi
    
    # Clean Xcode project
    xcodebuild clean -project "$XCODE_PROJECT" -scheme "$XCODE_SCHEME"
    
    log_success "Clean completed"
}

# Build app
build_app() {
    log_info "Building app..."
    
    xcodebuild build \
        -project "$XCODE_PROJECT" \
        -scheme "$XCODE_SCHEME" \
        -configuration Release \
        -destination 'platform=macOS' \
        -derivedDataPath "$DERIVED_DATA" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO
        
    log_success "Build completed"
}

# Archive app
archive_app() {
    log_info "Creating archive..."
    
    mkdir -p "$BUILD_DIR"
    
    xcodebuild archive \
        -project "$XCODE_PROJECT" \
        -scheme "$XCODE_SCHEME" \
        -configuration Release \
        -destination 'platform=macOS' \
        -archivePath "$BUILD_DIR/$APP_NAME.xcarchive" \
        -derivedDataPath "$DERIVED_DATA" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO
        
    log_success "Archive created"
}

# Create app bundle
create_app_bundle() {
    log_info "Creating app bundle..."
    
    mkdir -p "$BUILD_DIR/App"
    cp -R "$BUILD_DIR/$APP_NAME.xcarchive/Products/Applications/$APP_NAME.app" "$BUILD_DIR/App/"
    
    log_success "App bundle created"
}

# Create DMG
create_dmg() {
    log_info "Creating DMG..."
    
    hdiutil create -volname "$APP_NAME" -srcfolder "$BUILD_DIR/App" -ov -format UDZO "$BUILD_DIR/$APP_NAME.dmg"
    
    log_success "DMG created"
}

# Show build results
show_results() {
    log_info "Build completed successfully!"
    log_info "Build artifacts:"
    echo "  - App bundle: $BUILD_DIR/App/$APP_NAME.app"
    echo "  - DMG installer: $BUILD_DIR/$APP_NAME.dmg"
    echo "  - Archive: $BUILD_DIR/$APP_NAME.xcarchive"
    
    # Show file sizes
    if [ -d "$BUILD_DIR/App/$APP_NAME.app" ]; then
        APP_SIZE=$(du -sh "$BUILD_DIR/App/$APP_NAME.app" | cut -f1)
        log_info "App bundle size: $APP_SIZE"
    fi
    
    if [ -f "$BUILD_DIR/$APP_NAME.dmg" ]; then
        DMG_SIZE=$(du -sh "$BUILD_DIR/$APP_NAME.dmg" | cut -f1)
        log_info "DMG size: $DMG_SIZE"
    fi
}

# Main build process
main() {
    log_info "Starting local build for $APP_NAME"
    
    check_prerequisites
    show_versions
    clean_build
    build_app
    archive_app
    create_app_bundle
    create_dmg
    show_results
    
    log_success "Local build completed successfully!"
}

# Handle script arguments
case "${1:-}" in
    "clean")
        clean_build
        ;;
    "build")
        check_prerequisites
        build_app
        ;;
    "archive")
        check_prerequisites
        archive_app
        create_app_bundle
        create_dmg
        show_results
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  (no args)  Full build process (default)"
        echo "  clean      Clean build artifacts"
        echo "  build      Build app only"
        echo "  archive    Create archive and DMG"
        echo "  help       Show this help message"
        ;;
    *)
        main
        ;;
esac 