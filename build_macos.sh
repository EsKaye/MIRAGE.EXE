#!/bin/bash

# 🪞 MIRAGE.EXE macOS Build Script
# 
# 📋 Purpose: Automated build process for MIRAGE.EXE desktop application on macOS
# 🧩 Features: App icon generation, DMG creation, dependency management
# ⚡ Performance: Optimized for macOS with native tool integration
# 🔒 Security: Sandboxed build process with proper permissions
# 📜 Changelog: Enhanced error handling and platform detection (2024-12-19)

# 🎨 Color definitions for enhanced user experience
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 📊 Build configuration and constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/build"
VERSION_FILE="$PROJECT_ROOT/VERSION"
APP_NAME="MIRAGE.EXE"
APP_BUNDLE="$BUILD_DIR/MIRAGE.app"

# 🛡️ Error handling and logging functions
set -euo pipefail  # Exit on any error, undefined variables, and pipe failures

# 📝 Enhanced logging with timestamps and colors
print_color() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[$timestamp] ${2}${1}${NC}"
}

# 🏷️ Section headers for better build process visibility
print_header() {
    echo -e "\n${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    $1${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}\n"
}

# ⚠️ Error handling with graceful degradation
handle_error() {
    local exit_code=$?
    local line_number=$1
    print_color "❌ Build failed at line $line_number with exit code $exit_code" "$RED"
    print_color "🔧 Please check the error messages above and try again" "$YELLOW"
    exit $exit_code
}

# Set up error handling
trap 'handle_error $LINENO' ERR

# 🔍 Platform detection and validation
check_platform() {
    print_header "Platform Detection"
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_color "❌ This script is designed for macOS only" "$RED"
        print_color "🔧 Current platform: $OSTYPE" "$YELLOW"
        exit 1
    fi
    
    local macos_version=$(sw_vers -productVersion)
    print_color "✅ macOS $macos_version detected" "$GREEN"
    
    # Check for minimum macOS version (10.15 Catalina)
    if [[ "$(echo "$macos_version" | cut -d. -f1)" -lt 10 ]] || \
       ([[ "$(echo "$macos_version" | cut -d. -f1)" -eq 10 ]] && \
        [[ "$(echo "$macos_version" | cut -d. -f2)" -lt 15 ]]); then
        print_color "⚠️  Warning: macOS 10.15+ recommended for optimal performance" "$YELLOW"
    fi
}

# 🔧 Prerequisites validation with automatic installation
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    local missing_deps=()
    
    # Check for Homebrew (required for dependency management)
    if ! command -v brew &> /dev/null; then
        print_color "🍺 Installing Homebrew..." "$YELLOW"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    # Check for create-dmg (DMG creation tool)
    if ! command -v create-dmg &> /dev/null; then
        print_color "📦 Installing create-dmg..." "$YELLOW"
        brew install create-dmg
    fi
    
    # Check for ImageMagick (icon generation)
    if ! command -v convert &> /dev/null; then
        print_color "🖼️  Installing ImageMagick..." "$YELLOW"
        brew install imagemagick
    fi
    
    # Check for Node.js and npm
    if ! command -v node &> /dev/null; then
        print_color "📦 Installing Node.js..." "$YELLOW"
        brew install node
    fi
    
    # Check for Rust (required for Tauri)
    if ! command -v cargo &> /dev/null; then
        print_color "🦀 Installing Rust..." "$YELLOW"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
    fi
    
    # Check for Roblox Studio (optional, for Roblox deployment)
    if [ ! -d "/Applications/Roblox Studio.app" ]; then
        print_color "🎮 Roblox Studio not found in /Applications" "$YELLOW"
        print_color "💡 This is optional for desktop app builds" "$CYAN"
    else
        print_color "✅ Roblox Studio found!" "$GREEN"
    fi
    
    # Check for Rojo (Roblox build tool)
    if ! command -v rojo &> /dev/null; then
        print_color "🔧 Installing Rojo..." "$YELLOW"
        npm install -g @rojo/rbx
    fi
    
    print_color "✅ All prerequisites satisfied!" "$GREEN"
}

# 🎨 App icon generation with error handling
create_app_icon() {
    print_header "Creating App Icon"
    
    if [ ! -f "create_icon.sh" ]; then
        print_color "❌ create_icon.sh not found!" "$RED"
        exit 1
    fi
    
    # Make icon script executable
    chmod +x create_icon.sh
    
    # Run icon creation with error handling
    if ./create_icon.sh; then
        print_color "✅ App icon created successfully!" "$GREEN"
    else
        print_color "❌ Failed to create app icon!" "$RED"
        print_color "🔧 Check ImageMagick installation and permissions" "$YELLOW"
        exit 1
    fi
}

# 🏗️ App structure creation with validation
create_app_structure() {
    print_header "Creating App Structure"
    
    # Create build directory structure
    mkdir -p "$BUILD_DIR/MIRAGE.app/Contents/MacOS"
    mkdir -p "$BUILD_DIR/MIRAGE.app/Contents/Resources"
    
    # Validate source files exist
    local required_files=(
        "src/macos/MIRAGE.app/Contents/MacOS/MIRAGE"
        "src/macos/MIRAGE.app/Contents/Info.plist"
        "src/macos/MIRAGE.app/Contents/Resources/AppIcon.icns"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            print_color "❌ Required file not found: $file" "$RED"
            exit 1
        fi
    done
    
    # Copy app files with progress indication
    print_color "📁 Copying app files..." "$CYAN"
    cp "src/macos/MIRAGE.app/Contents/MacOS/MIRAGE" "$BUILD_DIR/MIRAGE.app/Contents/MacOS/"
    cp "src/macos/MIRAGE.app/Contents/Info.plist" "$BUILD_DIR/MIRAGE.app/Contents/"
    cp "src/macos/MIRAGE.app/Contents/Resources/AppIcon.icns" "$BUILD_DIR/MIRAGE.app/Contents/Resources/"
    
    # Make executable with proper permissions
    chmod +x "$BUILD_DIR/MIRAGE.app/Contents/MacOS/MIRAGE"
    
    print_color "✅ App structure created successfully!" "$GREEN"
}

# 📦 DMG creation with enhanced options
create_dmg() {
    print_header "Creating DMG"
    
    local dmg_path="$BUILD_DIR/MIRAGE.dmg"
    local icon_path="$BUILD_DIR/MIRAGE.app/Contents/Resources/AppIcon.icns"
    
    # Validate icon exists
    if [ ! -f "$icon_path" ]; then
        print_color "❌ App icon not found: $icon_path" "$RED"
        exit 1
    fi
    
    print_color "📦 Creating DMG with create-dmg..." "$CYAN"
    
    # Create DMG with enhanced options
    create-dmg \
        --volname "$APP_NAME" \
        --volicon "$icon_path" \
        --window-pos 200 120 \
        --window-size 800 400 \
        --icon-size 100 \
        --icon "MIRAGE.app" 200 190 \
        --hide-extension "MIRAGE.app" \
        --app-drop-link 600 185 \
        --no-internet-enable \
        "$dmg_path" \
        "$APP_BUNDLE"
    
    if [ $? -eq 0 ]; then
        print_color "✅ DMG created successfully!" "$GREEN"
        print_color "📁 Location: $dmg_path" "$CYAN"
    else
        print_color "❌ Failed to create DMG!" "$RED"
        exit 1
    fi
}

# 🧹 Build directory cleanup with safety checks
clean_build() {
    print_header "Cleaning Build Directory"
    
    if [ -d "$BUILD_DIR" ]; then
        print_color "🧹 Removing existing build directory..." "$YELLOW"
        rm -rf "$BUILD_DIR"
    fi
    
    mkdir -p "$BUILD_DIR"
    print_color "✅ Build directory cleaned!" "$GREEN"
}

# 📊 Build summary and statistics
print_build_summary() {
    print_header "Build Summary"
    
    local dmg_size=$(du -h "$BUILD_DIR/MIRAGE.dmg" | cut -f1)
    local app_size=$(du -h "$APP_BUNDLE" | cut -f1)
    local version=$(cat "$VERSION_FILE" 2>/dev/null || echo "Unknown")
    
    print_color "🎯 Build completed successfully!" "$GREEN"
    print_color "📦 DMG Size: $dmg_size" "$CYAN"
    print_color "📱 App Size: $app_size" "$CYAN"
    print_color "🏷️  Version: $version" "$CYAN"
    print_color "📁 DMG Location: $BUILD_DIR/MIRAGE.dmg" "$CYAN"
    
    # Open the DMG automatically
    print_color "🚀 Opening DMG..." "$CYAN"
    open "$BUILD_DIR/MIRAGE.dmg"
}

# 🎯 Main build orchestration function
build() {
    print_color "\n🪞 Starting MIRAGE.EXE macOS build process...\n" "$BLUE"
    
    # Execute build pipeline with error handling
    check_platform
    check_prerequisites
    clean_build
    create_app_icon
    create_app_structure
    create_dmg
    print_build_summary
    
    print_color "\n🎉 MIRAGE.EXE macOS build completed successfully!" "$GREEN"
}

# 🚀 Script execution with argument handling
main() {
    case "${1:-}" in
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --help, -h     Show this help message"
            echo "  --clean        Clean build directory only"
            echo "  --icon         Create app icon only"
            echo "  --dmg          Create DMG only"
            exit 0
            ;;
        --clean)
            clean_build
            exit 0
            ;;
        --icon)
            check_platform
            check_prerequisites
            create_app_icon
            exit 0
            ;;
        --dmg)
            check_platform
            check_prerequisites
            create_dmg
            exit 0
            ;;
        "")
            build
            ;;
        *)
            print_color "❌ Unknown option: $1" "$RED"
            print_color "💡 Use --help for usage information" "$YELLOW"
            exit 1
            ;;
    esac
}

# 🎬 Execute main function with all arguments
main "$@" 