#!/bin/bash

#####################################
# WakaTime Extensions Installer
# This script installs WakaTime plugins for VSCode and JetBrains IDEs
#####################################

echo "Starting WakaTime extensions installation..."

#####################################
# Utility Functions
#####################################

# Function to check if a command exists
# Args:
#   $1 - Command to check
# Returns: 0 if exists, 1 if not
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print colored output
# Args:
#   $1 - Color (green/red/yellow)
#   $2 - Message to print
print_status() {
    local color=$1
    local message=$2
    case $color in
        "green")  echo -e "\033[32m$message\033[0m" ;;
        "red")    echo -e "\033[31m$message\033[0m" ;;
        "yellow") echo -e "\033[33m$message\033[0m" ;;
    esac
}

#####################################
# VSCode Installation
#####################################

# Install WakaTime extension for VSCode
# Checks if VSCode is installed and installs the extension
install_vscode() {
    if command_exists code; then
        print_status "yellow" "Installing WakaTime for VSCode..."
        code --install-extension WakaTime.vscode-wakatime
        if [ $? -eq 0 ]; then
            print_status "green" "✓ WakaTime installed successfully for VSCode"
        else
            print_status "red" "✗ Failed to install WakaTime for VSCode"
        fi
    else
        print_status "yellow" "VSCode not found. Skipping VSCode extension installation."
    fi
}

#####################################
# JetBrains Installation
#####################################

# Install WakaTime plugin for JetBrains IDEs
# Detects installed JetBrains IDEs and installs the plugin
install_jetbrains() {
    print_status "yellow" "Installing WakaTime for JetBrains IDEs..."
    
    # List of supported JetBrains IDEs config directories
    declare -a ide_dirs=(
        ".IntelliJIdea"  # IntelliJ IDEA
        ".CLion"        # CLion
        ".PyCharm"      # PyCharm
        ".WebStorm"     # WebStorm
        ".PhpStorm"     # PhpStorm
        ".RubyMine"     # RubyMine
        ".GoLand"       # GoLand
        ".Rider"        # Rider
    )
    
    # Process each IDE
    for ide in "${ide_dirs[@]}"; do
        if [ -d "$HOME/$ide"* ]; then
            # Find the latest version directory
            config_dir=$(find "$HOME/$ide"* -maxdepth 0 -type d | sort -V | tail -n 1)
            
            if [ -n "$config_dir" ]; then
                plugin_dir="$config_dir/config/plugins"
                mkdir -p "$plugin_dir"
                
                # Download and install WakaTime plugin
                print_status "yellow" "Installing for $(basename "$config_dir")..."
                curl -fsSL -o "$plugin_dir/wakatime.zip" https://plugins.jetbrains.com/plugin/download?updateId=latest&pluginId=7425
                
                if [ $? -eq 0 ]; then
                    cd "$plugin_dir" && unzip -o wakatime.zip && rm wakatime.zip
                    print_status "green" "✓ WakaTime installed successfully for $(basename "$config_dir")"
                else
                    print_status "red" "✗ Failed to install WakaTime for $(basename "$config_dir")"
                fi
            fi
        fi
    done
}

#####################################
# WakaTime Configuration
#####################################

# Configure WakaTime settings
configure_wakatime() {
    print_status "yellow" "Configuring WakaTime settings..."
    
    # Get user's home directory and config path
    CONFIG_PATH="$HOME/.wakatime.cfg"
    
    # Check for required environment variables
    if [ -z "$QUACKATIME_API_KEY" ] || [ -z "$QUACKATIME_API_URL" ]; then
        print_status "red" "Error: QUACKATIME_API_KEY and QUACKATIME_API_URL environment variables must be set."
        return 1
    fi
    
    # Create or update WakaTime configuration
    cat > "$CONFIG_PATH" << EOL
[settings]
api_key = $QUACKATIME_API_KEY
api_url = $QUACKATIME_API_URL
EOL
    
    if [ $? -eq 0 ]; then
        print_status "green" "✓ WakaTime configuration has been updated successfully"
    else
        print_status "red" "✗ Failed to write WakaTime configuration file"
        return 1
    fi
}

#####################################
# Main Installation Process
#####################################

echo "=== WakaTime Extensions Installer ==="
echo

# Install extensions for each supported IDE
install_vscode
install_jetbrains

# Configure WakaTime settings
configure_wakatime

# Display completion message and next steps
echo ""
print_status "green" "Installation process completed!"
print_status "yellow" "Note: You may need to restart your IDEs for the changes to take effect."