#!/bin/bash

# MIRAGE.EXE Deployment Script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print with color
print_color() {
    echo -e "${2}${1}${NC}"
}

# Check if rojo is installed
if ! command -v rojo &> /dev/null; then
    print_color "Error: rojo is not installed. Please install it first." "$RED"
    print_color "Installation instructions: https://rojo.space/docs/installation/" "$YELLOW"
    exit 1
fi

# Create build directory if it doesn't exist
if [ ! -d "build" ]; then
    mkdir build
fi

# Build the project
print_color "Building MIRAGE.EXE..." "$YELLOW"
rojo build -o build/MIRAGE.rbxm

# Check if build was successful
if [ $? -eq 0 ]; then
    print_color "Build successful!" "$GREEN"
    print_color "Output file: build/MIRAGE.rbxm" "$GREEN"
else
    print_color "Build failed!" "$RED"
    exit 1
fi

# Create deployment package
print_color "Creating deployment package..." "$YELLOW"
cd build
zip -r MIRAGE.zip MIRAGE.rbxm
cd ..

# Check if zip was successful
if [ $? -eq 0 ]; then
    print_color "Deployment package created successfully!" "$GREEN"
    print_color "Package location: build/MIRAGE.zip" "$GREEN"
else
    print_color "Failed to create deployment package!" "$RED"
    exit 1
fi

# Print deployment instructions
print_color "\nDeployment Instructions:" "$YELLOW"
print_color "1. Upload build/MIRAGE.rbxm to Roblox Studio" "$NC"
print_color "2. Place the following scripts in their respective locations:" "$NC"
print_color "   - deploy.server.lua -> ServerScriptService" "$NC"
print_color "   - deploy.client.lua -> StarterPlayerScripts" "$NC"
print_color "   - deploy.config.lua -> ServerStorage" "$NC"
print_color "3. Ensure all modules are in ReplicatedStorage/MIRAGE_MODULES" "$NC"
print_color "4. Test the deployment in Studio before publishing" "$NC"

print_color "\nDeployment complete!" "$GREEN" 