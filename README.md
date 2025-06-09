# BC-250 Setup Script

Script to install oberon-governor and mesa-git on AMD BC-250 mining blades with Arch Linux.

## What it does

- Installs mesa-git if your Mesa version is outdated, if your mesa version >= 25.1, lets you decide if you want to keep it
- Installs oberon-governor for power management
- Configures some kernel parameters
- Cleans up bootloader configuration

## Usage

```bash
curl -O https://raw.githubusercontent.com/pnbarbeito/bc250-arch/refs/heads/main/oberon_install.sh
chmod +x oberon_install.sh
./oberon_install.sh
```

Reboot when finished.

## Requirements

- Arch Linux or derivatives with pacman and systemd (Manjaro, EndeavourOS, Garuda, etc.)
- AMD BC-250 mining blade
- Sudo access
- Internet connection

## Known issues

If something goes wrong, you can uninstall mesa-git:
```bash
sudo pacman -R mesa-git
sudo pacman -S mesa
```

## Notes

- Mesa-git compilation can take 20-40 minutes
- Compatible with systemd distributions only
- Supports grub and systemd-boot bootloaders
- Supports dracut and mkinitcpio for initramfs
- Supports yay, paru and pikaur for AUR package management. If none is installed, yay will be installed.

---

**Credits**: 
- [oberon-governor](https://gitlab.com/mothenjoyer69/oberon-governor) by @mothenjoyer69
- [BC-250 Documentation](https://github.com/mothenjoyer69/bc250-documentation) by @mothenjoyer69
- [BC-250 BIOS](https://gitlab.com/TuxThePenguin0/bc250-bios/) by @TuxThePenguin0
- [BC-250 Guides](https://github.com/kenavru/BC-250) by @kenavru
