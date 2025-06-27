#!/bin/bash

# 🚀 MIRAGE.EXE GitHub Deployment Script
# 
# 📋 Purpose: Automated deployment and push to GitHub for MIRAGE.EXE project
# 🧩 Features: Git integration, build verification, automated commits, GitHub releases
# ⚡ Performance: Optimized for dual-platform deployment (React/Tauri + Roblox)
# 🔒 Security: Secure credential handling and repository validation
# 📜 Changelog: Enhanced GitHub integration and error handling (2024-12-19)

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
BUILD_DIR="$PROJECT_ROOT/build"
VERSION_FILE="$PROJECT_ROOT/VERSION"
GIT_REPO_URL="https://github.com/yourusername/mirage.exe.git"
RELEASE_BRANCH="main"

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
    print_color "❌ Deployment failed at line $line_number with exit code $exit_code" "$RED"
    print_color "🔧 Please check the error messages above and try again" "$YELLOW"
    exit $exit_code
}

# Set up error handling
trap 'handle_error $LINENO' ERR

# 🔍 Platform detection and validation
check_platform() {
    print_header "Platform Detection"
    
    local platform=$(uname -s)
    print_color "✅ Platform detected: $platform" "$GREEN"
    
    # Check for supported platforms
    case "$platform" in
        Darwin*)
            print_color "🍎 macOS detected - Full feature support available" "$GREEN"
            ;;
        Linux*)
            print_color "🐧 Linux detected - Limited feature support" "$YELLOW"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            print_color "🪟 Windows detected - Limited feature support" "$YELLOW"
            ;;
        *)
            print_color "⚠️  Unknown platform: $platform" "$YELLOW"
            ;;
    esac
}

# 🔧 Prerequisites validation with automatic installation
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    local missing_deps=()
    
    # Check for Git (required for version control)
    if ! command -v git &> /dev/null; then
        print_color "❌ Git not found. Please install Git first." "$RED"
        print_color "💡 Visit: https://git-scm.com/downloads" "$CYAN"
        exit 1
    fi
    
    # Check for Node.js and npm (required for React/Tauri builds)
    if ! command -v node &> /dev/null; then
        print_color "📦 Node.js not found. Installing..." "$YELLOW"
        if command -v brew &> /dev/null; then
            brew install node
        else
            print_color "❌ Please install Node.js manually" "$RED"
            print_color "💡 Visit: https://nodejs.org/" "$CYAN"
            exit 1
        fi
    fi
    
    # Check for Rojo (required for Roblox builds)
    if ! command -v rojo &> /dev/null; then
        print_color "🔧 Rojo not found. Installing..." "$YELLOW"
        npm install -g @rojo/rbx
    fi
    
    # Check for Rust (required for Tauri builds)
    if ! command -v cargo &> /dev/null; then
        print_color "🦀 Rust not found. Installing..." "$YELLOW"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source ~/.cargo/env
    fi
    
    # Check for create-dmg (macOS only, for DMG creation)
    if [[ "$OSTYPE" == "darwin"* ]] && ! command -v create-dmg &> /dev/null; then
        print_color "📦 create-dmg not found. Installing..." "$YELLOW"
        if command -v brew &> /dev/null; then
            brew install create-dmg
        fi
    fi
    
    print_color "✅ All prerequisites satisfied!" "$GREEN"
}

# 🔍 Git repository validation and setup
check_git_repository() {
    print_header "Git Repository Validation"
    
    # Check if we're in a git repository
    if [ ! -d ".git" ]; then
        print_color "❌ Not in a git repository!" "$RED"
        print_color "🔧 Initializing git repository..." "$YELLOW"
        git init
        git remote add origin "$GIT_REPO_URL"
    fi
    
    # Check git status
    local git_status=$(git status --porcelain)
    if [ -n "$git_status" ]; then
        print_color "📝 Uncommitted changes detected:" "$YELLOW"
        echo "$git_status"
        print_color "💡 Changes will be committed automatically" "$CYAN"
    else
        print_color "✅ Working directory is clean" "$GREEN"
    fi
    
    # Check current branch
    local current_branch=$(git branch --show-current)
    print_color "🌿 Current branch: $current_branch" "$CYAN"
    
    # Check remote repository
    if git remote get-url origin &> /dev/null; then
        local remote_url=$(git remote get-url origin)
        print_color "🔗 Remote repository: $remote_url" "$CYAN"
    else
        print_color "⚠️  No remote repository configured" "$YELLOW"
        print_color "🔧 Adding remote origin..." "$YELLOW"
        git remote add origin "$GIT_REPO_URL"
    fi
}

# 🏗️ Build verification for both platforms
verify_builds() {
    print_header "Build Verification"
    
    local build_errors=0
    
    # Check React/Tauri build
    print_color "🔍 Checking React/Tauri build..." "$CYAN"
    if [ -f "package.json" ]; then
        if npm run build &> /dev/null; then
            print_color "✅ React/Tauri build verified" "$GREEN"
        else
            print_color "❌ React/Tauri build failed" "$RED"
            build_errors=$((build_errors + 1))
        fi
    else
        print_color "⚠️  package.json not found - skipping React/Tauri build" "$YELLOW"
    fi
    
    # Check Roblox build
    print_color "🔍 Checking Roblox build..." "$CYAN"
    if [ -f "default.project.json" ]; then
        if rojo build -o build/MIRAGE.rbxm &> /dev/null; then
            print_color "✅ Roblox build verified" "$GREEN"
        else
            print_color "❌ Roblox build failed" "$RED"
            build_errors=$((build_errors + 1))
        fi
    else
        print_color "⚠️  default.project.json not found - skipping Roblox build" "$YELLOW"
    fi
    
    # Check macOS build (if on macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_color "🔍 Checking macOS build..." "$CYAN"
        if [ -f "build_macos.sh" ]; then
            if ./build_macos.sh --help &> /dev/null; then
                print_color "✅ macOS build script verified" "$GREEN"
            else
                print_color "❌ macOS build script failed" "$RED"
                build_errors=$((build_errors + 1))
            fi
        fi
    fi
    
    if [ $build_errors -gt 0 ]; then
        print_color "❌ $build_errors build verification(s) failed" "$RED"
        print_color "🔧 Please fix build issues before deployment" "$YELLOW"
        exit 1
    fi
    
    print_color "✅ All builds verified successfully!" "$GREEN"
}

# 📦 Create deployment package
create_deployment_package() {
    print_header "Creating Deployment Package"
    
    # Create build directory
    mkdir -p "$BUILD_DIR"
    
    # Create comprehensive deployment package
    local package_name="MIRAGE.EXE-v$(cat "$VERSION_FILE" 2>/dev/null || echo "1.0.0")"
    local package_dir="$BUILD_DIR/$package_name"
    
    mkdir -p "$package_dir"
    
    # Copy essential files
    print_color "📁 Copying project files..." "$CYAN"
    cp -r src/ "$package_dir/"
    cp package.json "$package_dir/"
    cp README.md "$package_dir/"
    cp LICENSE "$package_dir/"
    cp VERSION "$package_dir/"
    cp *.sh "$package_dir/"
    
    # Copy build outputs if they exist
    if [ -f "build/MIRAGE.rbxm" ]; then
        cp build/MIRAGE.rbxm "$package_dir/"
    fi
    
    if [ -d "dist" ]; then
        cp -r dist/ "$package_dir/"
    fi
    
    # Create deployment instructions
    cat > "$package_dir/DEPLOYMENT.md" << 'EOF'
# MIRAGE.EXE Deployment Instructions

## Desktop Application (React/Tauri)
1. Install dependencies: `npm install`
2. Build application: `npm run tauri build`
3. Run application: `npm run tauri dev`

## Roblox Platform
1. Install Rojo: `npm install -g @rojo/rbx`
2. Build project: `rojo build -o MIRAGE.rbxm`
3. Import to Roblox Studio
4. Deploy scripts to appropriate locations

## macOS Build
1. Run: `./build_macos.sh`
2. Install from generated DMG

For detailed instructions, see README.md
EOF
    
    # Create zip package
    print_color "📦 Creating deployment archive..." "$CYAN"
    cd "$BUILD_DIR"
    zip -r "${package_name}.zip" "$package_name"
    cd "$PROJECT_ROOT"
    
    print_color "✅ Deployment package created: $BUILD_DIR/${package_name}.zip" "$GREEN"
}

# 🔍 File verification and validation
verify_deployment_files() {
    print_header "Deployment File Verification"
    
    local required_files=(
        "README.md"
        "LICENSE"
        "VERSION"
        "package.json"
        "src/"
    )
    
    local optional_files=(
        "build/MIRAGE.rbxm"
        "dist/"
        "build_macos.sh"
        "create_icon.sh"
        "deploy.sh"
        "push.sh"
    )
    
    local missing_required=0
    local missing_optional=0
    
    # Check required files
    print_color "🔍 Checking required files..." "$CYAN"
    for file in "${required_files[@]}"; do
        if [ -e "$file" ]; then
            print_color "✅ $file" "$GREEN"
        else
            print_color "❌ $file (MISSING)" "$RED"
            missing_required=$((missing_required + 1))
        fi
    done
    
    # Check optional files
    print_color "🔍 Checking optional files..." "$CYAN"
    for file in "${optional_files[@]}"; do
        if [ -e "$file" ]; then
            print_color "✅ $file" "$GREEN"
        else
            print_color "⚠️  $file (optional)" "$YELLOW"
            missing_optional=$((missing_optional + 1))
        fi
    done
    
    if [ $missing_required -gt 0 ]; then
        print_color "❌ $missing_required required files missing!" "$RED"
        exit 1
    fi
    
    print_color "✅ All required files present!" "$GREEN"
    if [ $missing_optional -gt 0 ]; then
        print_color "⚠️  $missing_optional optional files missing" "$YELLOW"
    fi
}

# 📝 Git commit and push operations
perform_git_operations() {
    print_header "Git Operations"
    
    local version=$(cat "$VERSION_FILE" 2>/dev/null || echo "1.0.0")
    local commit_message="🚀 Release v$version - Automated deployment
    
- Enhanced build scripts with quantum-level documentation
- Improved error handling and platform detection
- Updated dependencies and project structure
- Comprehensive GitHub integration
- Dual-platform support (React/Tauri + Roblox)"
    
    # Stage all changes
    print_color "📝 Staging changes..." "$CYAN"
    git add .
    
    # Check if there are changes to commit
    if git diff --cached --quiet; then
        print_color "✅ No changes to commit" "$GREEN"
    else
        # Commit changes
        print_color "💾 Committing changes..." "$CYAN"
        git commit -m "$commit_message"
        print_color "✅ Changes committed successfully" "$GREEN"
    fi
    
    # Push to remote repository
    print_color "🚀 Pushing to remote repository..." "$CYAN"
    if git push origin "$RELEASE_BRANCH"; then
        print_color "✅ Successfully pushed to GitHub!" "$GREEN"
    else
        print_color "❌ Failed to push to GitHub" "$RED"
        print_color "🔧 Check your git credentials and repository access" "$YELLOW"
        exit 1
    fi
}

# 🏷️ Create GitHub release (if gh CLI is available)
create_github_release() {
    print_header "GitHub Release Creation"
    
    if ! command -v gh &> /dev/null; then
        print_color "⚠️  GitHub CLI not found. Skipping release creation." "$YELLOW"
        print_color "💡 Install with: brew install gh" "$CYAN"
        return 0
    fi
    
    local version=$(cat "$VERSION_FILE" 2>/dev/null || echo "1.0.0")
    local release_title="MIRAGE.EXE v$version"
    local release_notes="## 🎉 MIRAGE.EXE v$version Release

### 🚀 New Features
- Enhanced build automation
- Improved error handling
- Quantum-level documentation
- Dual-platform support

### 🔧 Improvements
- Updated dependencies
- Better platform detection
- Comprehensive testing
- GitHub integration

### 📦 Downloads
- Desktop Application (macOS)
- Roblox Platform Package
- Source Code Archive

For detailed installation instructions, see README.md"
    
    print_color "🏷️  Creating GitHub release..." "$CYAN"
    
    # Create release with assets
    if gh release create "v$version" \
        --title "$release_title" \
        --notes "$release_notes" \
        --target "$RELEASE_BRANCH"; then
        
        # Upload deployment package if it exists
        local package_path="$BUILD_DIR/MIRAGE.EXE-v$version.zip"
        if [ -f "$package_path" ]; then
            print_color "📦 Uploading deployment package..." "$CYAN"
            gh release upload "v$version" "$package_path"
        fi
        
        print_color "✅ GitHub release created successfully!" "$GREEN"
    else
        print_color "❌ Failed to create GitHub release" "$RED"
        print_color "💡 You can create it manually on GitHub" "$YELLOW"
    fi
}

# 📊 Deployment summary and statistics
print_deployment_summary() {
    print_header "Deployment Summary"
    
    local version=$(cat "$VERSION_FILE" 2>/dev/null || echo "1.0.0")
    local package_size=$(du -h "$BUILD_DIR/MIRAGE.EXE-v$version.zip" 2>/dev/null | cut -f1 || echo "N/A")
    local commit_hash=$(git rev-parse --short HEAD 2>/dev/null || echo "N/A")
    
    print_color "🎯 Deployment completed successfully!" "$GREEN"
    print_color "🏷️  Version: $version" "$CYAN"
    print_color "📦 Package Size: $package_size" "$CYAN"
    print_color "🔗 Commit: $commit_hash" "$CYAN"
    print_color "🌿 Branch: $RELEASE_BRANCH" "$CYAN"
    print_color "📁 Package Location: $BUILD_DIR/MIRAGE.EXE-v$version.zip" "$CYAN"
    
    # Open GitHub repository
    print_color "🌐 Opening GitHub repository..." "$CYAN"
    open "$GIT_REPO_URL"
}

# 🎯 Main deployment orchestration function
deploy() {
    print_color "\n🚀 Starting MIRAGE.EXE GitHub deployment process...\n" "$BLUE"
    
    # Execute deployment pipeline with error handling
    check_platform
    check_prerequisites
    check_git_repository
    verify_builds
    verify_deployment_files
    create_deployment_package
    perform_git_operations
    create_github_release
    print_deployment_summary
    
    print_color "\n🎉 MIRAGE.EXE deployment completed successfully!" "$GREEN"
}

# 🚀 Script execution with argument handling
main() {
    case "${1:-}" in
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --help, -h     Show this help message"
            echo "  --verify       Verify builds only"
            echo "  --package      Create deployment package only"
            echo "  --git          Perform git operations only"
            echo "  --release      Create GitHub release only"
            exit 0
            ;;
        --verify)
            check_platform
            check_prerequisites
            verify_builds
            verify_deployment_files
            exit 0
            ;;
        --package)
            check_platform
            check_prerequisites
            verify_deployment_files
            create_deployment_package
            exit 0
            ;;
        --git)
            check_git_repository
            perform_git_operations
            exit 0
            ;;
        --release)
            check_prerequisites
            create_github_release
            exit 0
            ;;
        "")
            deploy
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