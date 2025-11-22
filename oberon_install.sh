#!/bin/bash

# Mesa-git installation script for Arch-based Linux distributions
# Compatible with: Manjaro, EndeavourOS, Garuda, ArcoLinux, Artix, etc.
# Author: Automated installation script
# Date: $(date +%Y-%m-%d)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_NAME="$NAME"
        DISTRO_ID="$ID"
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO_NAME="$DISTRIB_DESCRIPTION"
        DISTRO_ID="$DISTRIB_ID"
    else
        DISTRO_NAME="Unknown"
        DISTRO_ID="unknown"
    fi
    
    print_status "Detected distribution: $DISTRO_NAME"
}

# Check if we're on an Arch-based system
check_arch_based() {
    if ! command -v pacman &> /dev/null; then
        print_error "This script requires pacman (Arch Linux package manager)"
        exit 1
    fi
    
    print_success "Arch-based system detected"
}

# Cleanup function
cleanup() {
    print_status "Cleaning up temporary files..."
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        cd ~
        rm -rf "$TEMP_DIR"
        print_status "Temporary directory cleaned up"
    fi
    # Clean package cache if needed
    if [ -n "$AUR_HELPER" ]; then
        $AUR_HELPER -Scc --noconfirm 2>/dev/null || true
    fi
}

# Detect init system and initramfs tool
detect_init_system() {
    # Detect initramfs tool
    if command -v dracut &> /dev/null; then
        INITRAMFS_TOOL="dracut"
        print_status "Detected initramfs tool: dracut"
    elif command -v mkinitcpio &> /dev/null; then
        INITRAMFS_TOOL="mkinitcpio"
        print_status "Detected initramfs tool: mkinitcpio"
    else
        print_warning "No supported initramfs tool detected"
        INITRAMFS_TOOL="none"
    fi
}

# Check current Mesa version
check_mesa_version() {
    print_status "Checking current Mesa version..."
    
    if pacman -Qi mesa &> /dev/null 2>&1; then
        CURRENT_MESA=$(pacman -Qi mesa | grep "Vers" | cut -d: -f3 | xargs | cut -d- -f1)
        print_status "Current Mesa version: $CURRENT_MESA"
        
        # Compare version with 25.1
        if command -v python3 &> /dev/null; then
            # Install python-packaging if needed for version comparison
            if ! python3 -c "import packaging" &> /dev/null; then
                print_status "Installing python-packaging for version comparison..."
                sudo pacman -S --needed --noconfirm python-packaging
            fi
            
            SHOULD_SKIP=$(python3 -c "
import sys
from packaging import version
try:
    current_ver = version.parse('$CURRENT_MESA')
    target_ver = version.parse('25.1')
    print('true' if current_ver >= target_ver else 'false')
except Exception as e:
    print('false')
" 2>/dev/null || echo "false")
            
            if [ "$SHOULD_SKIP" = "true" ]; then
                print_warning "Mesa version $CURRENT_MESA is >= 25.1"
                echo "You may not need mesa-git anymore."
                echo
                echo "Options:"
                echo "1) Continue with mesa-git installation anyway"
                echo "2) Skip mesa-git installation"
                echo "3) Exit script"
                echo
                while true; do
                    read -p "Choose an option (1/2/3): " -n 1 -r
                    echo
                    case $REPLY in
                        1|y|Y)
                            print_status "Continuing with mesa-git installation..."
                            return 0
                            ;;
                        2|n|N)
                            print_status "Skipping mesa-git installation..."
                            return 1
                            ;;
                        3|q|Q)
                            print_status "Exiting script..."
                            exit 0
                            ;;
                        *)
                            print_error "Invalid option. Please choose 1, 2, or 3"
                            ;;
                    esac
                done
            fi
        else
            print_warning "Cannot compare versions (python3 not available)"
        fi
    else
        print_status "Mesa not currently installed"
    fi
    
    return 0
}

# Check if AUR helper is installed
check_aur_helper() {
    if command -v yay &> /dev/null; then
        AUR_HELPER="yay"
        print_success "yay is already installed"
    elif command -v paru &> /dev/null; then
        AUR_HELPER="paru"
        print_success "paru is already installed"
    elif command -v pikaur &> /dev/null; then
        AUR_HELPER="pikaur"
        print_success "pikaur is already installed"
    else
        print_status "No AUR helper found. Installing yay..."
        install_yay
        AUR_HELPER="yay"
    fi
}

# Install yay
install_yay() {
    print_status "Updating repositories..."
    sudo pacman -Sy --noconfirm
    
    print_status "Installing dependencies for yay..."
    sudo pacman -S --needed --noconfirm git base-devel go
    
    print_status "Cloning yay from AUR..."
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    if ! git clone https://aur.archlinux.org/yay.git; then
        print_error "Failed to clone yay repository"
        cd ~
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    cd yay
    
    print_status "Building and installing yay..."
    if ! makepkg -si --noconfirm; then
        print_error "Failed to build yay"
        cd ~
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    cd ~
    rm -rf "$TEMP_DIR"
    
    print_success "yay installed successfully"
}

# Update system
update_system() {
    print_status "Updating system..."
    $AUR_HELPER -Syu --noconfirm
    print_success "System updated"
}

# Install mesa-git
install_mesa_git() {
    print_status "Installing mesa-git from AUR..."
    print_warning "This installation may take a long time (30-60 minutes)"
    print_warning "mesa-git requires full Mesa compilation"
    print_warning "mesa-git will replace your current mesa package automatically"
    
    # Check if mesa is currently installed
    if pacman -Q mesa &>/dev/null; then
        print_status "Current mesa package will be replaced with mesa-git"
    fi
    
    # Ask user if they want to continue
    read -p "Do you want to continue with mesa-git installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Skipping mesa-git installation"
        return 1
    fi
    
    # Install build dependencies
    print_status "Installing build dependencies..."
    $AUR_HELPER -S --needed --noconfirm \
        python-mako \
        libxml2 \
        libx11 \
        xorgproto \
        libdrm \
        libxshmfence \
        libxxf86vm \
        libxdamage \
        libvdpau \
        libva \
        wayland \
        wayland-protocols \
        elfutils \
        llvm \
        libomxil-bellagio \
        libclc \
        clang \
        vulkan-icd-loader \
        glslang
    
    # Install mesa-git (handle conflicts automatically)
    print_status "Starting mesa-git installation..."
    print_warning "This will replace the existing mesa package with mesa-git"
    
    # Install mesa-git with conflict resolution parameters
    if [[ "$AUR_HELPER" == "yay" ]]; then
        if ! $AUR_HELPER -S --answerclean All --answerdiff None --overwrite "*" mesa-git; then
            print_error "Failed to install mesa-git with yay"
            print_error "Manual recovery: sudo pacman -S mesa (to restore stable mesa)"
            print_error "Then try: yay -S mesa-git manually"
            return 1
        fi
    elif [[ "$AUR_HELPER" == "paru" ]]; then
        if ! $AUR_HELPER -S --noconfirm --overwrite "*" mesa-git; then
            print_error "Failed to install mesa-git with paru"
            print_error "Manual recovery: sudo pacman -S mesa (to restore stable mesa)"
            print_error "Then try: paru -S mesa-git manually"
            return 1
        fi
    else
        # For pikaur or other helpers
        if ! $AUR_HELPER -S --noconfirm mesa-git; then
            print_error "Failed to install mesa-git with $AUR_HELPER"
            print_error "Manual recovery: sudo pacman -S mesa (to restore stable mesa)"
            print_error "Then try: $AUR_HELPER -S mesa-git manually"
            return 1
        fi
    fi
    
    print_success "mesa-git installed successfully"
}

# Configure AMD GPU optimizations
configure_amd_optimizations() {
    print_status "Configuring AMD GPU optimizations..."
    
    # Set RADV_DEBUG option in environment
    print_status "Setting RADV_DEBUG option..."
    
    # Check if the variable already exists
    if ! grep -q "RADV_DEBUG" /etc/environment 2>/dev/null; then
        echo 'RADV_DEBUG=nocompute' | sudo tee -a /etc/environment > /dev/null
        print_success "RADV_DEBUG option added"
    else
        print_status "RADV_DEBUG already configured"
    fi
    
    # Install GPU governor dependencies and build
    print_status "Installing GPU governor..."
    $AUR_HELPER -S --needed --noconfirm base-devel cmake git libdrm
    
    # Clone and build oberon-governor
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    if ! git clone https://gitlab.com/mothenjoyer69/oberon-governor.git; then
        print_error "Failed to clone oberon-governor repository"
        cd ~
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    cd oberon-governor
    
    if ! cmake .; then
        print_error "CMake configuration failed"
        cd ~
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    if ! make; then
        print_error "Build failed"
        cd ~
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    if ! sudo make install; then
        print_error "Installation failed"
        cd ~
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    # Enable the service only if it exists
    if systemctl list-unit-files | grep -q oberon-governor.service; then
        sudo systemctl enable oberon-governor.service
        print_success "GPU governor service enabled"
    else
        print_warning "oberon-governor service not found, may need manual configuration"
    fi
    
    # Configure AMD GPU module options
    print_status "Setting amdgpu module options..."
    echo 'options amdgpu sg_display=0' | sudo tee /etc/modprobe.d/options-amdgpu.conf > /dev/null
    
    # Configure sensor modules
    print_status "Setting sensor module options..."
    echo 'nct6683' | sudo tee /etc/modules-load.d/99-sensors.conf > /dev/null
    echo 'options nct6683 force=true' | sudo tee /etc/modprobe.d/options-sensors.conf > /dev/null
    
    print_success "Module options configured"
    
    # Regenerate initramfs based on detected tool
    regenerate_initramfs
    
    # Clean up temporary files
    cd ~
    rm -rf "$TEMP_DIR"
}

# Regenerate initramfs based on system
regenerate_initramfs() {
    print_status "Regenerating initramfs (this may take a while)..."
    
    case $INITRAMFS_TOOL in
        "dracut")
            print_status "Using dracut to regenerate initramfs..."
            if ! sudo dracut-rebuild; then
                print_error "Failed to regenerate initramfs with dracut"
                return 1
            fi
            ;;
        "mkinitcpio")
            print_status "Using mkinitcpio to regenerate initramfs..."
            if ! sudo mkinitcpio -P; then
                print_error "Failed to regenerate initramfs with mkinitcpio"
                return 1
            fi
            ;;
        "none")
            print_warning "No initramfs tool detected, skipping regeneration"
            return 0
            ;;
    esac
    
    print_success "Initramfs regenerated successfully"
}

# Detect bootloader type
detect_bootloader() {
    if [ -d /sys/firmware/efi ]; then
        # System is UEFI, check for systemd-boot
        if [ -d /boot/loader/entries ] || [ -f /boot/loader/loader.conf ]; then
            BOOTLOADER="systemd-boot"
            print_status "Detected bootloader: systemd-boot"
        elif [ -f /etc/default/grub ] || [ -d /boot/grub ]; then
            BOOTLOADER="grub"
            print_status "Detected bootloader: GRUB (UEFI)"
        else
            BOOTLOADER="unknown"
            print_warning "Unknown UEFI bootloader detected"
        fi
    else
        # System is BIOS, likely GRUB
        if [ -f /etc/default/grub ] || [ -d /boot/grub ]; then
            BOOTLOADER="grub"
            print_status "Detected bootloader: GRUB (BIOS)"
        else
            BOOTLOADER="unknown"
            print_warning "Unknown BIOS bootloader detected"
        fi
    fi
}

# Fix systemd-boot configuration
fix_systemd_boot_config() {
    print_status "Fixing systemd-boot configuration..."
    
    # Find boot entries directory
    if [ -d /boot/loader/entries ]; then
        ENTRIES_DIR="/boot/loader/entries"
    elif [ -d /efi/loader/entries ]; then
        ENTRIES_DIR="/efi/loader/entries"
    else
        print_warning "systemd-boot entries directory not found"
        return
    fi
    
    print_status "Found systemd-boot entries in: $ENTRIES_DIR"
    
    # Process all .conf files in entries directory
    for entry_file in "$ENTRIES_DIR"/*.conf; do
        if [ -f "$entry_file" ]; then
            print_status "Processing boot entry: $(basename "$entry_file")"
            
            # Create backup
            sudo cp "$entry_file" "$entry_file.backup"
            
            # Remove problematic kernel parameters
            sudo sed -i 's/\bnomodeset\b//g' "$entry_file"
            sudo sed -i 's/\bamdgpu\.sg_display=0\b//g' "$entry_file"
            
            # Clean up extra spaces
            sudo sed -i 's/  \+/ /g' "$entry_file"
            sudo sed -i 's/ $//' "$entry_file"
            
            print_status "Cleaned up boot entry: $(basename "$entry_file")"
        fi
    done
    
    print_success "systemd-boot configuration updated"
}

# Fix GRUB configuration
fix_grub_config() {
    print_status "Fixing GRUB configuration..."
    
    # Check if GRUB config exists
    if [ ! -f /etc/default/grub ]; then
        print_warning "GRUB configuration not found"
        return
    fi
    
    # Create backup of GRUB config
    sudo cp /etc/default/grub /etc/default/grub.backup
    print_status "GRUB config backed up to /etc/default/grub.backup"
    
    # Remove nomodeset and amdgpu.sg_display=0 from GRUB config
    sudo sed -i 's/nomodeset//g' /etc/default/grub
    sudo sed -i 's/amdgpu\.sg_display=0//g' /etc/default/grub
    
    # Clean up any double spaces left by the removal
    sudo sed -i 's/  / /g' /etc/default/grub
    
    # Update GRUB config (try different commands based on availability)
    print_status "Updating GRUB configuration..."
    if command -v grub-mkconfig &> /dev/null; then
        sudo grub-mkconfig -o /boot/grub/grub.cfg
    elif command -v grub2-mkconfig &> /dev/null; then
        sudo grub2-mkconfig -o /boot/grub/grub.cfg
    else
        print_warning "No GRUB config generator found"
        return
    fi
    
    print_success "GRUB configuration updated"
}

# Fix bootloader configuration based on detected type
fix_bootloader_config() {
    detect_bootloader
    
    case $BOOTLOADER in
        "grub")
            fix_grub_config
            ;;
        "systemd-boot")
            fix_systemd_boot_config
            ;;
        "unknown")
            print_warning "Unknown bootloader - skipping bootloader configuration"
            print_warning "You may need to manually remove 'nomodeset' from kernel parameters"
            ;;
    esac
}

# Verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    if pacman -Qi mesa-git &> /dev/null; then
        print_success "mesa-git is installed"
        
        # Show version information
        MESA_VERSION=$(pacman -Qi mesa | grep "Vers" | cut -d: -f3 | xargs | cut -d- -f1)
        print_status "Installed version: $MESA_VERSION"
        
        # Check drivers
        if command -v glxinfo &> /dev/null; then
            print_status "OpenGL driver information:"
            glxinfo | grep "OpenGL renderer"
            glxinfo | grep "OpenGL version"
        else
            print_warning "glxinfo not available. Install mesa-utils for more information"
        fi
    else
        print_error "mesa-git doesn't appear to be installed correctly"
        exit 1
    fi
}

# Show post-installation information
show_post_install_info() {
    print_success "Installation completed!"
    echo
    print_status "Important information:"
    echo "  • mesa-git provides the latest development graphics drivers"
    echo "  • AMD GPU optimizations have been applied (RADV_DEBUG, module options)"
    echo "  • GPU governor (oberon-governor) has been installed and enabled"
    echo "  • Bootloader configuration has been cleaned up ($BOOTLOADER)"
    echo "  • Initramfs has been regenerated using $INITRAMFS_TOOL"
    echo "  • It's recommended to restart the system to apply all changes"
    echo "  • To check your graphics setup use: glxinfo | grep render"
    echo "  • If you have issues, you can return to stable mesa with: $AUR_HELPER -S mesa"
    echo
    print_warning "NOTE: mesa-git may be unstable as it's a development version"
    
    read -p "Do you want to restart now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Restarting system..."
        sudo reboot
    fi
}

# Main function
main() {
    echo "============================================"
    echo "  Mesa-git Installer for Arch-based Linux  "
    echo "============================================"
    echo
    
    detect_distro
    check_arch_based
    detect_init_system
    check_aur_helper
    update_system
    
    # Check Mesa version and potentially skip installation
    if check_mesa_version; then
        install_mesa_git
    else
        print_status "Skipping mesa-git installation as requested"
    fi
    
    configure_amd_optimizations
    fix_bootloader_config
    
    # Only verify if mesa-git was installed
    if pacman -Qi mesa-git &> /dev/null; then
        verify_installation
    fi
    
    show_post_install_info
}

# Handle interruptions (Ctrl+C)
trap 'print_error "Installation interrupted by user"; cleanup; exit 1' INT TERM

# Execute main function
main "$@"