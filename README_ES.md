# BC-250 Setup Script

Script para instalar oberon-governor y mesa-git en placas AMD BC-250 con Arch Linux.

## Qué hace

- Instala mesa-git si tu versión de Mesa es antigua, si tu version de mesa >= 25.1, te permite decidir si quieres conservarla
- Instala oberon-governor para gestión de energía
- Configura algunos parámetros del kernel
- Limpia la configuración del bootloader

## Uso

```bash
curl -O https://raw.githubusercontent.com/pbarbeito/bc250-arch/main/oberon_install.sh
chmod +x oberon_install.sh
./oberon_install.sh
```

Reinicia cuando termine.

## Requisitos

- Arch Linux o derivados con pacman y systemd (Manjaro, EndeavourOS, Garuda, etc.)
- Placa AMD BC-250
- Acceso sudo
- Conexión a internet

## Problemas conocidos

Si algo sale mal, puedes desinstalar mesa-git:
```bash
sudo pacman -R mesa-git
sudo pacman -S mesa
```

## Notas

- La compilacion de mesa-git puede tardar 20-40 minutos
- Compatible con distribuciones systemd únicamente
- Soporta gestores de arranque grub y systemd-boot
- Soporta dracut y mkinitcpio para initramfs
- Soporta yay, paru y pikaur para gestionar lis paquetes de AUR. Si ninguno esta instalado, se instalara yay.
---

**Créditos**: 
- [oberon-governor](https://gitlab.com/mothenjoyer69/oberon-governor) por @mothenjoyer69
- [BC-250 Documentation](https://github.com/mothenjoyer69/bc250-documentation) by @mothenjoyer69
- [BC-250 BIOS](https://gitlab.com/TuxThePenguin0/bc250-bios/) por @TuxThePenguin0
- [Guías BC-250](https://github.com/kenavru/BC-250) por @kenavru