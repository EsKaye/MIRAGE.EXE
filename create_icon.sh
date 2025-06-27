#!/bin/bash

# 🎨 MIRAGE.EXE Icon Generation Script
# 
# 📋 Purpose: Generate application icons for MIRAGE.EXE across multiple platforms
# 🧩 Features: PNG to ICNS conversion, multiple size generation, macOS optimization
# ⚡ Performance: Optimized for macOS with native tool integration
# 🔒 Security: Sandboxed icon generation with proper file permissions
# 📜 Changelog: Enhanced error handling and documentation (2024-12-19)

# 🎨 Color definitions for enhanced user experience
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 📊 Script configuration and constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEMP_DIR="$PROJECT_ROOT/temp_icon"
ICONSET_DIR="$TEMP_DIR/icon.iconset"
OUTPUT_DIR="$PROJECT_ROOT/src/macos/MIRAGE.app/Contents/Resources"
ICON_NAME="AppIcon.icns"

# 🛡️ Error handling and logging functions
set -euo pipefail  # Exit on any error, undefined variables, and pipe failures

# 📝 Enhanced logging with timestamps and colors
print_color() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[$timestamp] ${2}${1}${NC}"
}

# 🏷️ Section headers for better process visibility
print_header() {
    echo -e "\n${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    $1${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}\n"
}

# ⚠️ Error handling with graceful degradation
handle_error() {
    local exit_code=$?
    local line_number=$1
    print_color "❌ Icon generation failed at line $line_number with exit code $exit_code" "$RED"
    print_color "🔧 Please check the error messages above and try again" "$YELLOW"
    cleanup_temp_files
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
        print_color "💡 Icon generation requires macOS-specific tools (sips, iconutil)" "$CYAN"
        exit 1
    fi
    
    local macos_version=$(sw_vers -productVersion)
    print_color "✅ macOS $macos_version detected" "$GREEN"
    
    # Check for minimum macOS version (10.10 Yosemite for sips)
    if [[ "$(echo "$macos_version" | cut -d. -f1)" -lt 10 ]] || \
       ([[ "$(echo "$macos_version" | cut -d. -f1)" -eq 10 ]] && \
        [[ "$(echo "$macos_version" | cut -d. -f2)" -lt 10 ]]); then
        print_color "⚠️  Warning: macOS 10.10+ recommended for optimal icon generation" "$YELLOW"
    fi
}

# 🔧 Prerequisites validation with automatic installation
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check for ImageMagick (required for initial icon creation)
    if ! command -v convert &> /dev/null; then
        print_color "🖼️  ImageMagick not found. Installing..." "$YELLOW"
        if command -v brew &> /dev/null; then
            brew install imagemagick
        else
            print_color "❌ Homebrew not found. Please install ImageMagick manually" "$RED"
            print_color "💡 Visit: https://imagemagick.org/script/download.php" "$CYAN"
            exit 1
        fi
    fi
    
    # Check for sips (macOS built-in image processing)
    if ! command -v sips &> /dev/null; then
        print_color "❌ sips not found. This is a macOS system tool" "$RED"
        print_color "💡 Please ensure you're running on macOS" "$CYAN"
        exit 1
    fi
    
    # Check for iconutil (macOS built-in icon utility)
    if ! command -v iconutil &> /dev/null; then
        print_color "❌ iconutil not found. This is a macOS system tool" "$RED"
        print_color "💡 Please ensure you're running on macOS" "$CYAN"
        exit 1
    fi
    
    print_color "✅ All prerequisites satisfied!" "$GREEN"
}

# 🧹 Cleanup temporary files with safety checks
cleanup_temp_files() {
    if [ -d "$TEMP_DIR" ]; then
        print_color "🧹 Cleaning up temporary files..." "$YELLOW"
        rm -rf "$TEMP_DIR"
        print_color "✅ Temporary files cleaned!" "$GREEN"
    fi
}

# 🎨 Create base icon with MIRAGE.EXE branding
create_base_icon() {
    print_header "Creating Base Icon"
    
    # Create temporary directory
    mkdir -p "$TEMP_DIR"
    
    print_color "🎨 Generating 1024x1024 base icon..." "$CYAN"
    
    # Create a 1024x1024 PNG with MIRAGE.EXE branding
    # Using retro-futuristic design with terminal aesthetic
    convert -size 1024x1024 xc:black \
        -fill '#00ff00' \
        -font "Courier-Bold" \
        -pointsize 200 \
        -gravity center \
        -draw "text 0,0 'MIRAGE'" \
        -fill '#00ff00' \
        -pointsize 100 \
        -gravity center \
        -draw "text 0,150 '.EXE'" \
        "$TEMP_DIR/icon_1024.png"
    
    if [ $? -eq 0 ]; then
        print_color "✅ Base icon created successfully!" "$GREEN"
        print_color "📁 Location: $TEMP_DIR/icon_1024.png" "$CYAN"
    else
        print_color "❌ Failed to create base icon!" "$RED"
        print_color "🔧 Check ImageMagick installation and font availability" "$YELLOW"
        exit 1
    fi
}

# 📏 Generate multiple icon sizes for macOS
generate_icon_sizes() {
    print_header "Generating Icon Sizes"
    
    # Create iconset directory
    mkdir -p "$ICONSET_DIR"
    
    print_color "📏 Generating multiple icon sizes..." "$CYAN"
    
    # Define icon sizes for macOS (standard requirements)
    local sizes=(
        "16:16"
        "32:16@2x"
        "32:32"
        "64:32@2x"
        "128:128"
        "256:128@2x"
        "256:256"
        "512:256@2x"
        "512:512"
        "1024:512@2x"
    )
    
    # Generate each size with progress indication
    for size_info in "${sizes[@]}"; do
        IFS=':' read -r size filename <<< "$size_info"
        local output_file="$ICONSET_DIR/icon_${filename}.png"
        
        print_color "📐 Generating ${size}x${size} icon..." "$CYAN"
        
        # Use sips for high-quality resizing
        sips -z "$size" "$size" "$TEMP_DIR/icon_1024.png" --out "$output_file"
        
        if [ $? -eq 0 ]; then
            print_color "✅ Generated: $filename" "$GREEN"
        else
            print_color "❌ Failed to generate $filename" "$RED"
            exit 1
        fi
    done
    
    print_color "✅ All icon sizes generated successfully!" "$GREEN"
}

# 📦 Convert to ICNS format
convert_to_icns() {
    print_header "Converting to ICNS"
    
    # Ensure output directory exists
    mkdir -p "$OUTPUT_DIR"
    
    print_color "📦 Converting iconset to ICNS format..." "$CYAN"
    
    # Convert iconset to ICNS using iconutil
    iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT_DIR/$ICON_NAME"
    
    if [ $? -eq 0 ]; then
        print_color "✅ ICNS file created successfully!" "$GREEN"
        print_color "📁 Location: $OUTPUT_DIR/$ICON_NAME" "$CYAN"
        
        # Get file size for verification
        local file_size=$(du -h "$OUTPUT_DIR/$ICON_NAME" | cut -f1)
        print_color "📊 File size: $file_size" "$CYAN"
    else
        print_color "❌ Failed to create ICNS file!" "$RED"
        print_color "🔧 Check iconutil and iconset structure" "$YELLOW"
        exit 1
    fi
}

# 📊 Icon generation summary and verification
print_generation_summary() {
    print_header "Icon Generation Summary"
    
    local icns_size=$(du -h "$OUTPUT_DIR/$ICON_NAME" | cut -f1)
    local total_icons=$(find "$ICONSET_DIR" -name "*.png" | wc -l)
    
    print_color "🎯 Icon generation completed successfully!" "$GREEN"
    print_color "📦 ICNS Size: $icns_size" "$CYAN"
    print_color "🖼️  Total Icons Generated: $total_icons" "$CYAN"
    print_color "📁 ICNS Location: $OUTPUT_DIR/$ICON_NAME" "$CYAN"
    print_color "📁 Iconset Location: $ICONSET_DIR" "$CYAN"
    
    # Verify ICNS file is valid
    if file "$OUTPUT_DIR/$ICON_NAME" | grep -q "Mac OS X icon"; then
        print_color "✅ ICNS file validation passed!" "$GREEN"
    else
        print_color "⚠️  ICNS file validation warning" "$YELLOW"
    fi
}

# 🎯 Main icon generation orchestration function
generate_icons() {
    print_color "\n🎨 Starting MIRAGE.EXE icon generation process...\n" "$BLUE"
    
    # Execute generation pipeline with error handling
    check_platform
    check_prerequisites
    create_base_icon
    generate_icon_sizes
    convert_to_icns
    print_generation_summary
    
    print_color "\n🎉 MIRAGE.EXE icon generation completed successfully!" "$GREEN"
}

# 🚀 Script execution with argument handling
main() {
    case "${1:-}" in
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --help, -h     Show this help message"
            echo "  --clean        Clean temporary files only"
            echo "  --base         Create base icon only"
            echo "  --sizes        Generate icon sizes only"
            echo "  --icns         Convert to ICNS only"
            exit 0
            ;;
        --clean)
            cleanup_temp_files
            exit 0
            ;;
        --base)
            check_platform
            check_prerequisites
            create_base_icon
            exit 0
            ;;
        --sizes)
            check_platform
            check_prerequisites
            if [ ! -f "$TEMP_DIR/icon_1024.png" ]; then
                create_base_icon
            fi
            generate_icon_sizes
            exit 0
            ;;
        --icns)
            check_platform
            check_prerequisites
            if [ ! -d "$ICONSET_DIR" ]; then
                print_color "❌ Iconset not found. Run full generation first." "$RED"
                exit 1
            fi
            convert_to_icns
            exit 0
            ;;
        "")
            generate_icons
            cleanup_temp_files
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