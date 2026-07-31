

# 🌊 Utilidad de Restablecimiento de Windsurf IDE

<div align="center">

![Version](https://img.shields.io/badge/version-2.0-blue.svg)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**Una utilidad de PowerShell segura y confiable para restablecer los identificadores de telemetría de Windsurf IDE**

[Características](#-features) • [Instalación](#-installation) • [Uso](#-usage) • [Cómo Funciona](#-how-it-works) • [Preguntas Frecuentes](#-faq)

</div>

---

## ⚠️ AVISO LEGAL

> **IMPORTANTE:** Esta herramienta se proporciona con fines **educativos y de prueba únicamente**. 
> 
> - Utilice este script bajo su propio riesgo y responsabilidad
> - El autor no se hace responsable de ningún uso indebido o daño causado por esta herramienta
> - Asegúrese de comprender lo que hace este script antes de ejecutarlo
> - Mantenga siempre copias de seguridad de sus datos importantes
> - Esta herramienta está destinada únicamente a escenarios legítimos de prueba y desarrollo
> 
> Al utilizar este script, usted reconoce que ha leído y comprendido este aviso.

---

## 📋 Descripción General

Este script de PowerShell restablece de forma segura los identificadores de telemetría de Windsurf IDE (solo a nivel de aplicación) sin afectar el ID de máquina de Windows ni la información del sistema. Perfecto para desarrolladores que necesitan actualizar su instancia del IDE o solucionar problemas relacionados con la telemetría.

## ✨ Características

- 🔒 **Seguro y No Destructivo** - Crea automáticamente copias de seguridad con marca de tiempo antes de realizar cambios
- 🎯 **Restablecimiento Específico** - Solo modifica los IDs de telemetría a nivel de aplicación, no los identificadores del sistema
- 🛡️ **Verificación de Administrador** - Garantiza los permisos adecuados antes de la ejecución
- 📝 **Registros Detallados** - Salida de consola clara que muestra todos los cambios realizados
- 🔄 **Compatible con PowerShell 5.1+** - Funciona en todos los sistemas Windows modernos
- ✅ **Manejo de Errores** - Verificación robusta de errores y mensajes amigables para el usuario

## 🚀 Instalación

### Requisitos Previos

- Sistema operativo Windows
- PowerShell 5.1 o superior
- Windsurf IDE instalado
- Privilegios de administrador

### Método 1: Ejecutar directamente desde GitHub (Más fácil)

**Comando de una sola línea** - No requiere descarga:

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/abhishek-maurya576/Windsurf-IDE-Configuration-Reset/main/windsurf_reset_v2.ps1 | iex"
```

> ⚠️ **Nota:** Asegúrese de ejecutar PowerShell como Administrador para que este comando funcione correctamente.


### Descarga

1. Clone este repositorio o descarga el script directamente:
   ```powershell
   git clone https://github.com/abhishek-maurya576/windsurf-ide-reset.git
   ```

2. O descarga el archivo del script directamente:
   - [Descargar `reset_windsurf_IDE-v1.0.ps1`](https://github.com/abhishek-maurya576/Windsurf-IDE-Configuration-Reset/releases/download/v1.0/reset_windsurf_IDE-v1.0.ps1)

## 💻 Uso

### Paso 1: Ejecutar como Administrador

Haz clic derecho en **PowerShell** y selecciona **"Ejecutar como administrador"**

### Paso 2: Navega al directorio del script

```powershell
cd path\to\script\directory
```

### Paso 3: Ejecuta el script

```powershell
powershell -ExecutionPolicy Bypass -File .\reset_windsurf_IDE-v1.0.ps1
```

### Paso 4: Reinicia Windsurf IDE

Tras una ejecución exitosa, reinicia Windsurf IDE para aplicar los cambios.

## 🔧 Cómo Funciona

El script realiza las siguientes operaciones:

1. **Verificación de Permisos** - Verifica que el script se esté ejecutando con privilegios de Administrador
2. **Validación de Archivos** - Verifica si `storage.json` de Windsurf existe en:
   ```
   %APPDATA%\Windsurf\User\globalStorage\storage.json
   ```
3. **Creación de Copia de Seguridad** - Crea una copia de seguridad con marca de tiempo del archivo original
4. **Generación de IDs** - Genera tres GUIDs nuevos para:
   - `telemetry.machineId`
   - `telemetry.macMachineId`
   - `telemetry.devDeviceId`
5. **Actualización Segura** - Actualiza la configuración JSON mientras preserva todos los demás ajustes
6. **Verificación** - Muestra los nuevos identificadores y la ubicación de la copia de seguridad

### Qué se Modifica

El script **SOLO** modifica estos campos en `storage.json`:

```json
{
  "telemetry": {
    "machineId": "new-guid-here",
    "macMachineId": "new-guid-here",
    "devDeviceId": "new-guid-here"
  }
}
```

### Qué Permanece Inalterado

- ✅ ID de Máquina de Windows
- ✅ Información de hardware del sistema
- ✅ Todos los demás ajustes y preferencias de Windsurf
- ✅ Extensiones y configuraciones instaladas

## 📸 Ejemplo de Salida

```
Copia de seguridad creada en: C:\Users\YourName\AppData\Roaming\Windsurf\User\globalStorage\storage.json.backup_20241013_191530

¡Los identificadores de dispositivo de Windsurf han sido restablecidos correctamente!

Nuevos Identificadores:
   telemetry.machineId    : a1b2c3d4-e5f6-7890-abcd-ef1234567890
   telemetry.macMachineId : b2c3d4e5-f6a7-8901-bcde-f12345678901
   telemetry.devDeviceId  : c3d4e5f6-a7b8-9012-cdef-123456789012

Ubicación del archivo de copia de seguridad: C:\Users\YourName\AppData\Roaming\Windsurf\User\globalStorage\storage.json.backup_20241013_191530

¡Listo! Ahora puedes reiniciar Windsurf IDE.
```

## ❓ Preguntas Frecuentes

### ¿Es seguro utilizarlo?

¡Sí! El script crea copias de seguridad automáticas antes de realizar cualquier cambio. Siempre puedes restaurar desde la copia de seguridad si es necesario.

### ¿Esto afectará mi instalación de Windows?

No. Este script solo modifica los identificadores de telemetría a nivel de aplicación de Windsurf IDE, no los IDs a nivel de sistema.

### ¿Qué pasa si algo sale mal?

El script crea copias de seguridad con marca de tiempo. Simplemente copia el archivo de respaldo nuevamente a `storage.json` para restaurar tu configuración anterior.

### ¿Necesito desinstalar Windsurf?

No. Este script funciona con tu instalación existente de Windsurf sin necesidad de reinstalarlo.

### ¿Puedo ejecutarlo varias veces?

Sí. Cada ejecución crea una nueva copia de seguridad y genera identificadores nuevos.

## 🛠️ Solución de Problemas

### "Por favor, ejecuta este script como Administrador"

**Solución:** Haz clic derecho en PowerShell y selecciona "Ejecutar como administrador"

### "Windsurf storage.json no encontrado"

**Solución:** Asegúrate de que Windsurf IDE esté instalado y que se haya ejecutado al menos una vez

### Error de "Execution Policy" (Política de Ejecución)

**Solución:** Ejecuta este comando en PowerShell como Administrador:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 📦 Estructura de Archivos

```
Windsurf-IDE-Configuration-Reset/
├── reset_windsurf_IDE-v1.0.ps1    # Script principal de PowerShell
├── README.md                       # Documentación del proyecto
├── LICENSE                         # Licencia MIT
├── CONTRIBUTING.md                 # Directrices de contribución
├── SECURITY.md                     # Política de seguridad
├── CHANGELOG.md                    # Historial de versiones
└── .gitignore                      # Reglas de ignorar Git
```

## 🤝 Contribución

¡Las contribuciones, informes de problemas y solicitudes de funciones son bienvenidos!

1. Realiza un fork del repositorio
2. Crea tu rama de características (`git checkout -b feature/AmazingFeature`)
3. Confirma tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Publica en la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - siéntete libre de usarlo, modificarlo y distribuirlo según sea necesario.

## 👨‍💻 Autor

**Abhishek Maurya**

- 🎥 YouTube: [@bforbca](https://youtube.com/@bforbca)
- 💻 GitHub: [@abhishek-maurya576](https://github.com/abhishek-maurya576)

## ⭐ Muestra tu Apoyo

Si este proyecto te ayudó, ¡considera darle una ⭐ en GitHub!

## 📝 Registro de Cambios

### Versión 1.1
- Manejo mejorado de JSON para compatibilidad con PowerShell 5.1+
- Manejo de errores y retroalimentación al usuario mejorados
- Copia de seguridad automática con marcas de tiempo agregada
- Validación y verificaciones de seguridad mejoradas

### Versión 1.0
- Versión inicial
- Funcionalidad básica de restablecimiento de ID de telemetría

---

<div align="center">

**Hecho con ❤️ por Abhishek Maurya**

[⬆ Volver al Inicio](#-windsurf-ide-reset-utility)

</div>
