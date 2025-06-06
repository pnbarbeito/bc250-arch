# BC-250 Setup Script

Script to enable hardware acceleration on AMD BC-250 mining blades for Arch Linux.

## What it does

- Installs mesa-git if your Mesa version is outdated
- Installs oberon-governor for power management
- Configures some kernel parameters
- Cleans up bootloader configuration

## Usage

```bash
curl -O https://raw.githubusercontent.com/pbarbeito/bc250-arch/main/oberon_install.sh
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

- Mesa-git installation can take 30-60 minutes
- Script creates automatic backups
- Compatible with systemd distributions only

---

**Credits**: 
- [oberon-governor](https://gitlab.com/mothenjoyer69/oberon-governor) by @mothenjoyer69
- [BC-250 Documentation](https://github.com/mothenjoyer69/bc250-documentation) by @mothenjoyer69
- [BC-250 BIOS](https://gitlab.com/TuxThePenguin0/bc250-bios/) by @TuxThePenguin0
- [Flash tool](https://github.com/kenavru/BC-250) by @kenavru