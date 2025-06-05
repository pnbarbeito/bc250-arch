# BC-250 Arch - Habilitar aceleración de hardware AMD BC-250 para Linux basado en Arch

Este repositorio contiene un script de instalación automatizado para habilitar aceleración de hardware y capacidades gaming para la blade de minería Bitcoin AMD BC-250 en distribuciones Linux basadas en Arch (Manjaro, EndeavourOS, Garuda, ArcoLinux, Artix, etc.).

## 🎯 Propósito

La AMD BC-250 es una blade de minería Bitcoin fabricada por ASRock, que presenta una APU PS5 Oberon recortada (6 núcleos y 24 CUs en lugar de los 8 núcleos y 36 CUs de la PS5). Este script automatiza el proceso de conversión para reutilizar estas blades de minería para gaming y computación general con aceleración gráfica.

- Instalación de los últimos drivers Mesa-git desde AUR
- Optimizaciones específicas para GPU AMD (configuración RADV_DEBUG)
- Instalación de governor GPU para mejor gestión de energía
- Configuración de módulos del kernel para detección adecuada de hardware
- Limpieza de configuración del bootloader (soporte GRUB y systemd-boot)

## 🚀 Características

- **Instalación Automatizada de Mesa-git**: Instala drivers de desarrollo Mesa con soporte APU Oberon (se omite automáticamente si se detecta Mesa 25.1+)
- **Detección Inteligente de Versión**: Verifica la versión actual de Mesa y solo instala mesa-git si es necesario
- **Optimizaciones Específicas de APU**: Configura RADV_DEBUG y parámetros de módulos para rendimiento
- **Soporte Multi-AUR Helper**: Soporta helpers AUR yay, paru y pikaur
- **Governor GPU**: Instala y habilita oberon-governor para gestión avanzada de energía APU


## 📋 Prerrequisitos

- **Sistema Operativo**: Distribuciones Linux basadas en Arch (Manjaro, EndeavourOS, Garuda, ArcoLinux, Artix, etc.)
- **Gestor de Paquetes**: pacman (gestor de paquetes de Arch Linux)
- **Hardware**: Blade de minería Bitcoin AMD BC-250 (fabricada por ASRock)
- **Privilegios**: Acceso root/sudo
- **Conexión a Internet**: Requerida para descargar paquetes y dependencias
- **Almacenamiento**: Al menos 2GB de espacio libre para compilación de Mesa

## 📁 Estructura del Proyecto

```
bc250-arch/
├── oberon_install.sh    # Script principal de instalación
├── README.md           # Documentación en inglés
├── README_ES.md     # Esta documentación en español
└── LICENSE            # Archivo de licencia
```

## 🔧 Instalación

### Instalación Rápida

1. **Descargar el script:**
   ```bash
   curl -O https://raw.githubusercontent.com/pbarbeito/bc250-arch/main/oberon_install.sh
   ```

2. **Hacerlo ejecutable:**
   ```bash
   chmod +x oberon_install.sh
   ```

3. **Ejecutar el instalador:**
   ```bash
   ./oberon_install.sh
   ```

### Instalación Manual

1. **Clonar este repositorio:**
   ```bash
   git clone https://github.com/pbarbeito/bc250-arch.git
   cd bc250-arch
   ```

2. **Ejecutar el script de instalación:**
   ```bash
   chmod +x oberon_install.sh
   ./oberon_install.sh
   ```

## ⚙️ Lo que Hace el Script

### 1. Preparación del Sistema
- Verifica compatibilidad con Linux basado en Arch (gestor de paquetes pacman)
- Detecta e instala helper AUR (yay, paru, o pikaur) si no está presente
- Actualiza los paquetes del sistema
- Detecta herramienta initramfs (mkinitcpio o dracut)

### 2. Instalación de Mesa-git
- Verifica la versión actual de Mesa y compara con Mesa 25.1+
- Ofrece opción para omitir si Mesa 25.1+ ya está instalado (soporte nativo Oberon)
- Instala todas las dependencias de compilación requeridas
- Compila e instala mesa-git con soporte APU Oberon (si es necesario)
- Proporciona los últimos drivers OpenGL y Vulkan

### 3. Optimizaciones APU AMD BC-250
- **Configuración RADV_DEBUG**: Establece `RADV_DEBUG=nocompute` para mejor compatibilidad
- **Parámetros de Módulo**: Configura `amdgpu sg_display=0` para manejo de display
- **Soporte de Sensores**: Habilita módulo nct6683 para monitoreo de hardware

### 4. Instalación del Governor APU
- Descarga y compila [oberon-governor](https://gitlab.com/mothenjoyer69/oberon-governor)
- Habilita gestión de energía APU y monitoreo
- Crea servicio systemd para gestionar el governor

### 5. Configuración del Sistema
- Regenera initramfs con nuevas configuraciones de módulos
- Limpia configuración del bootloader de parámetros conflictivos (GRUB/systemd-boot)
- Actualiza configuración del bootloader

## 🖥️ Verificación

Después de la instalación y reinicio, verifica tu configuración:

### Verificar Versión de Mesa
```bash
glxinfo | grep "OpenGL renderer"
glxinfo | grep "OpenGL version"
```

### Verificar Aceleración de Hardware
```bash
# Verificar si la aceleración de hardware está funcionando
glxinfo | grep "direct rendering"

# Probar soporte Vulkan
vulkaninfo | grep "deviceName"
```

### Monitorear Estado de GPU
```bash
# Verificar si la APU es detectada correctamente
lspci | grep -i amd

# Monitorear estado del governor APU
systemctl status oberon-governor.service

# Monitorear sensores de la blade de minería (si están disponibles)
sensors
```

## 🔍 Solución de Problemas

### Opciones de Recuperación

#### Revertir a Mesa Estable
```bash
yay -S mesa
sudo pacman -R mesa-git
```

#### Restaurar Configuración del Bootloader

**Para GRUB:**
```bash
sudo cp /etc/default/grub.backup /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**Para systemd-boot:**
```bash
# Restaurar entradas de arranque individuales
sudo cp /boot/loader/entries/*.conf.backup /boot/loader/entries/
# Remover extensión .backup de archivos restaurados
for file in /boot/loader/entries/*.backup; do
    sudo mv "$file" "${file%.backup}"
done
```

## 🔧 Configuración Avanzada (Opcional)

### Instalación de BIOS Personalizada
Si quieres ajustar la relación de asignación RAM/VRAM. Los mejores resultados se obtienen con 512MB dedicados a la VRAM.

⚠️ **ADVERTENCIA CRÍTICA**: El flasheo de BIOS conlleva riesgos. Por favor lee cuidadosamente la guía de **[kenavru](https://github.com/kenavru/BC-250)** para flashear desde almacenamiento USB o usar un programador externo.

1. **Revisa el [repositorio BIOS BC-250](https://gitlab.com/TuxThePenguin0/bc250-bios/)** para obtener la BIOS modificada
2. **Usa la [guía](https://github.com/kenavru/BC-250)** para flasheo seguro desde almacenamiento USB o un programador externo
3. **Sigue las guías completas** en la [documentación BC-250](https://github.com/mothenjoyer69/bc250-documentation)

## ⚠️ Notas Importantes

- **Tiempo de Compilación**: La instalación inicial de Mesa (si es necesaria) toma 30-60 minutos dependiendo de la asignación de RAM de tu sistema
- **Reinicio del Sistema**: Se requiere un reinicio para que todos los cambios tomen efecto
- **Compatibilidad Basada en Arch**: Funciona con Manjaro, EndeavourOS, Garuda, ArcoLinux, Artix y otros derivados de Arch
- **Respaldo Recomendado**: El script crea respaldos automáticos, pero considera crear una instantánea del sistema antes de instalar

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Por favor siéntete libre de:

- Reportar bugs o problemas con la instalación BC-250
- Sugerir mejoras para optimización gaming
- Enviar pull requests
- Compartir tus resultados de rendimiento gaming BC-250 y benchmarks

### Reportar Problemas

Cuando reportes problemas, por favor incluye:

- Distribución Linux y versión (ej. `cat /etc/os-release`)
- Versión del kernel (`uname -r`)
- Salida de detección APU (`lspci | grep -i amd`)
- Versión Mesa (`glxinfo | grep "OpenGL version"` o `pacman -Q mesa mesa-git`)
- Mensajes de error o logs de la ejecución del script

## 🙏 Reconocimientos

### Contribuidores de la Comunidad BC-250
- **[@mothenjoyer69](https://github.com/mothenjoyer69)**: Creador de [oberon-governor](https://gitlab.com/mothenjoyer69/oberon-governor) y mantenedor de la completa [documentación BC-250](https://github.com/mothenjoyer69/bc250-documentation)
- **[@TuxThePenguin0](https://gitlab.com/TuxThePenguin0)**: Desarrollador de la [BIOS modificada BC-250](https://gitlab.com/TuxThePenguin0/bc250-bios/) para funcionalidad mejorada
- **[@kenavru](https://github.com/kenavru)**: Por las [herramientas y documentación](https://github.com/kenavru/BC-250)

### Proyectos de Código Abierto
- **Proyecto Mesa**: Por los excelentes drivers gráficos de código abierto y soporte APU Oberon
- **Comunidad Arch Linux**: Por la gestión robusta de paquetes y sistema AUR
- **Contribuidores AUR**: Por mantener mesa-git y paquetes relacionados

## 📚 Recursos Adicionales

### Recursos Específicos BC-250
- **[Documentación BC-250](https://github.com/mothenjoyer69/bc250-documentation)**: Documentación completa y guías para BC-250
- **[BIOS Modificada BC-250](https://gitlab.com/TuxThePenguin0/bc250-bios/)**: Firmware BIOS personalizado para funcionalidad mejorada BC-250
- **[Flasheador BIOS USB BC-250](https://github.com/kenavru/BC-250)**: Herramientas y manual para flashear BIOS desde almacenamiento USB

### Recursos Generales
- [Documentación Proyecto Mesa](https://docs.mesa3d.org/)
- [Documentación Driver GPU AMD](https://wiki.archlinux.org/title/AMDGPU)
- [Wiki Manjaro](https://wiki.manjaro.org/)

---

**⭐ ¡Si este script te ayudó a convertir tu blade de minería BC-250 en un sistema gaming, por favor considera darle una estrella a este repositorio y compartir tus benchmarks gaming con la comunidad!**
