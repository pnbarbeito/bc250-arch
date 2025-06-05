# BC-250 Arch - AMD BC-250 enable hardware acceleration for Arch-based Linux

This repository contains an automated installation script to enable hardware acceleration and gaming capabilities for the AMD BC-250 Bitcoin mining blade on Arch-based Linux distributions (Manjaro, EndeavourOS, Garuda, etc.).

## 🎯 Purpose

The AMD BC-250 is a Bitcoin mining blade manufactured by ASRock, featuring a cut-down PS5 Oberon APU (6 cores and 24 CUs instead of the PS5's 8 cores and 36 CUs). This script automates the conversion process to repurpose these mining blades for gaming and general computing with full graphics acceleration.

- Installation of the latest Mesa-git drivers from AUR
- AMD GPU-specific optimizations (RADV_DEBUG configuration)
- GPU governor installation for better power management
- Kernel module configuration for proper hardware detection
- Bootloader configuration cleanup (GRUB and systemd-boot support)

## 📋 Prerequisites

- **Operating System**: Arch-based Linux distributions (Manjaro, EndeavourOS, Garuda, etc.)
- **Package Manager**: pacman (Arch Linux package manager)
- **Hardware**: AMD BC-250 Bitcoin mining blade (ASRock manufactured)
- **Privileges**: Root/sudo access
- **Internet Connection**: Required for downloading packages and dependencies
- **Storage**: At least 2GB free space for Mesa compilation

## 📁 Project Structure

```
bc250-arch/
├── oberon_install.sh    # Main installation script
├── README.md           # This documentation
└── LICENSE            # MIT License file
```

## 🚀 Script Features

### Intelligent Detection
- **Distribution Detection**: Automatically detects Arch-based distributions
- **Version Checking**: Smart Mesa version comparison to avoid unnecessary mesa-git installation
- **AUR Helper Discovery**: Finds and uses existing AUR helpers (yay, paru, pikaur) or installs yay
- **Initramfs Tool Detection**: Supports both mkinitcpio and dracut
- **Bootloader Detection**: Automatically detects and handles GRUB or systemd-boot

### Smart Installation Process
- **Conditional Mesa-git**: Only installs mesa-git if Mesa version is below 25.1
- **Dependency Management**: Automatically handles all build dependencies
- **Service Verification**: Checks if services exist before enabling them
- **Configuration Validation**: Prevents duplicate configuration entries

## 🔧 Installation

### Quick Installation

1. **Download the script:**
   ```bash
   curl -O https://raw.githubusercontent.com/pbarbeito/bc250-arch/main/oberon_install.sh
   ```

2. **Make it executable:**
   ```bash
   chmod +x oberon_install.sh
   ```

3. **Run the installer:**
   ```bash
   ./oberon_install.sh
   ```

### Manual Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/pbarbeito/bc250-arch.git
   cd bc250-arch
   ```

2. **Run the installation script:**
   ```bash
   chmod +x oberon_install.sh
   ./oberon_install.sh
   ```

## ⚙️ What the Script Does

### 1. System Preparation
- Verifies Arch-based Linux compatibility (pacman package manager)
- Detects and installs AUR helper (yay, paru, or pikaur) if not present
- Updates the system packages
- Detects initramfs tool (mkinitcpio or dracut)

### 2. Mesa-git Installation
- Checks current Mesa version and compares with Mesa 25.1+
- Offers option to skip if Mesa 25.1+ is already installed (native Oberon support)
- Installs all required build dependencies
- Compiles and installs mesa-git with Oberon APU support (if needed)
- Provides latest OpenGL and Vulkan drivers

### 3. AMD BC-250 APU Optimizations
- **RADV_DEBUG Configuration**: Sets `RADV_DEBUG=nocompute` for better gaming compatibility
- **Module Parameters**: Configures `amdgpu sg_display=0` for optimal display handling
- **Sensor Support**: Enables nct6683 module for hardware monitoring

### 4. APU Governor Installation
- Downloads and compiles [oberon-governor](https://gitlab.com/mothenjoyer69/oberon-governor)
- Enables APU power management and monitoring 
- Creates systemd service to manage the governor

### 5. System Configuration
- Regenerates initramfs with new module configurations
- Cleans up bootloader configuration from conflicting parameters (GRUB/systemd-boot)
- Updates bootloader configuration

## 🖥️ Verification

After installation and reboot, verify your setup:

### Check Mesa Version
```bash
glxinfo | grep "OpenGL renderer"
glxinfo | grep "OpenGL version"
```

### Verify Hardware Acceleration
```bash
# Check if hardware acceleration is working
glxinfo | grep "direct rendering"

# Test Vulkan support
vulkaninfo | grep "deviceName"
```

### Monitor GPU Status
```bash
# Check if APU is properly detected
lspci | grep -i amd

# Monitor APU governor status
systemctl status oberon-governor.service

# Monitor mining blade sensors (if available)
sensors
```

## 🔍 Troubleshooting

### Recovery Options

#### Revert to Stable Mesa
```bash
yay -S mesa
sudo pacman -R mesa-git
```

#### Restore Bootloader Configuration

**For GRUB:**
```bash
sudo cp /etc/default/grub.backup /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**For systemd-boot:**
```bash
# Restore individual boot entries
sudo cp /boot/loader/entries/*.conf.backup /boot/loader/entries/
# Remove .backup extension from restored files
for file in /boot/loader/entries/*.backup; do
    sudo mv "$file" "${file%.backup}"
done
```

## 🔧 Advanced Setup (Optional)

### Custom BIOS Installation
If you want to adjust the RAM/VRAM allocation ratio. The best results are obtained with 512MB dedicated to VRAM.

⚠️ **CRITICAL WARNING**: BIOS flashing carries risks. Please carefully read the **[kenavru](https://github.com/kenavru/BC-250)** guide to flash from USB storage or use an external programmer.

1. **Check the [BC-250 BIOS repository](https://gitlab.com/TuxThePenguin0/bc250-bios/)** for compatible BIOS versions
2. **Use the [guide](https://github.com/kenavru/BC-250)** for safe flashing from USB storage or an external programmer
3. **Follow the comprehensive guides** in the [BC-250 documentation](https://github.com/mothenjoyer69/bc250-documentation)


## ⚠️ Important Notes

- **Compilation Time**: Initial Mesa installation (if needed) takes 30-60 minutes depending on your system ram assignation
- **System Restart**: A reboot is required for all changes to take effect
- **Arch-based Compatibility**: Works with Manjaro, EndeavourOS, Garuda and other Arch derivatives 
- **Backup Recommended**: The script creates automatic backups, but consider creating a system snapshot before installing

## 🤝 Contributing

Contributions are welcome! Please feel free to:

- Report bugs or issues with BC-250 installation
- Suggest improvements for gaming optimization
- Submit pull requests
- Share your BC-250 gaming performance results and benchmarks

### Reporting Issues

When reporting issues, please include:

- Linux distribution and version (e.g., `cat /etc/os-release`)
- Kernel version (`uname -r`)
- APU detection output (`lspci | grep -i amd`)
- Mesa version (`glxinfo | grep "OpenGL version"` or `pacman -Q mesa mesa-git`)
- Error messages or logs from the script execution


## 🙏 Acknowledgments

### BC-250 Community Contributors
- **[@mothenjoyer69](https://github.com/mothenjoyer69)**: Creator of [oberon-governor](https://gitlab.com/mothenjoyer69/oberon-governor) and maintainer of the comprehensive [BC-250 documentation](https://github.com/mothenjoyer69/bc250-documentation)
- **[@TuxThePenguin0](https://gitlab.com/TuxThePenguin0)**: Developer of the [modified BC-250 BIOS](https://gitlab.com/TuxThePenguin0/bc250-bios/) for enhanced functionality
- **[@kenavru](https://github.com/kenavru)**: For the [tools and documentation](https://github.com/kenavru/BC-250)

### Open Source Projects
- **Mesa Project**: For the excellent open-source graphics drivers and Oberon APU support
- **Arch Linux Community**: For the robust package management and AUR system
- **AUR Contributors**: For maintaining the mesa-git and related packages

## 📚 Additional Resources

### BC-250 Specific Resources
- **[BC-250 Documentation](https://github.com/mothenjoyer69/bc250-documentation)**: Comprehensive documentation and guides for BC-250
- **[BC-250 Modified BIOS](https://gitlab.com/TuxThePenguin0/bc250-bios/)**: Custom BIOS firmware for enhanced BC-250 functionality
- **[BC-250 USB BIOS Flasher](https://github.com/kenavru/BC-250)**: Tools and manual for flashing BIOS from USB storage

### General Resources
- [Mesa Project Documentation](https://docs.mesa3d.org/)
- [AMD GPU Driver Documentation](https://wiki.archlinux.org/title/AMDGPU)
- [Manjaro Wiki](https://wiki.manjaro.org/)

---

**⭐ If this script helped you convert your BC-250 mining blade into a gaming system, please consider starring this repository and sharing your gaming benchmarks with the community!**