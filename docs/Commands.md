# IT Support Toolkit - Referencia de Comandos

**[English](Commands.EN.md) | Español**

## Descripción General
Este documento proporciona una referencia completa de todos los comandos, parámetros y módulos disponibles en el IT Support Toolkit.

---

## Tabla de Contenidos
1. [Parámetros de Línea de Comandos](#parámetros-de-línea-de-comandos)
2. [Modos de Ejecución](#modos-de-ejecución)
3. [Descripción de Módulos](#descripción-de-módulos)
4. [Ejemplos de Uso](#ejemplos-de-uso)
5. [Características de Seguridad](#características-de-seguridad)
6. [Salida y Registro](#salida-y-registro)

---

## Parámetros de Línea de Comandos

### `-Mode` (String)
**Valores:** `Menu` | `Run`  
**Predeterminado:** `Menu`  
**Descripción:** Determina el modo de ejecución del toolkit.

- `Menu` - Lanza la interfaz de menú interactivo
- `Run` - Ejecuta la acción especificada de forma no interactiva

**Ejemplos:**
```powershell
.\Unified-Toolkit.ps1 -Mode Menu
.\Unified-Toolkit.ps1 -Mode Run -Action Triage
```

---

### `-Action` (String)
**Valores:** `Triage` | `Performance` | `Network` | `Services` | `Admin` | `Report` | `All`  
**Requerido cuando:** `-Mode Run`  
**Descripción:** Especifica qué módulo ejecutar en modo Run.

| Action | Descripción |
|--------|-------------|
| `Triage` | Inventario del sistema y recopilación de información |
| `Performance` | Limpieza de archivos temporales y mantenimiento del sistema |
| `Network` | Diagnóstico de conectividad de red |
| `Services` | Reinicio de servicios críticos de Windows |
| `Admin` | Lanzar herramientas administrativas |
| `Report` | Exportar resultados a archivo JSON |
| `All` | Ejecutar Triage + Performance + Network + Services y auto-exportar reporte |

**Ejemplos:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action Triage
.\Unified-Toolkit.ps1 -Mode Run -Action All
```

---

### `-DryRun` (Switch)
**Se aplica a:** Módulo Performance únicamente  
**Descripción:** Calcula el tamaño de limpieza sin eliminar archivos realmente.

**Ejemplos:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action Performance -DryRun
```

---

### `-InternalDns` (String)
**Se aplica a:** Módulo Network únicamente  
**Descripción:** Especifica una IP de servidor DNS interno o hostname para probar conectividad.

**Ejemplos:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action Network -InternalDns 10.0.0.1
.\Unified-Toolkit.ps1 -Mode Run -Action Network -InternalDns "dc01.domain.local"
```

---

### `-OutPath` (String)
**Se aplica a:** Módulo Report  
**Predeterminado:** `C:\IT-Reports`  
**Descripción:** Ruta de directorio personalizado para la salida del archivo de reporte.

**Ejemplos:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action Report -OutPath "C:\Reports"
.\Unified-Toolkit.ps1 -Mode Run -Action All -OutPath "D:\IT-Logs"
```

---

### `-Force` (Switch)
**Se aplica a:** Módulo Network  
**Descripción:** Habilita acciones de red potencialmente disruptivas incluso en sesiones remotas (RDP).

**Nota de Seguridad:** Por defecto, las operaciones disruptivas están bloqueadas cuando se ejecuta en RDP o tipos de sesión desconocidos para prevenir desconexión accidental.

**Ejemplos:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action Network -Force
```

---

## Modos de Ejecución

### Modo Interactivo (Menu)
El modo predeterminado que presenta un menú numerado con las siguientes opciones:

```
[1] System Triage (Inventario)
[2] Performance Maintenance (Mantenimiento)
[3] Network Diagnostics (Diagnóstico de Red)
[4] Service Healer (Sanador de Servicios)
[5] Admin Shortcuts (Accesos Directos Admin)
[6] Run All (Ejecutar Todo)
[7] Export Report (Exportar Reporte)
[0] Exit (Salir)
```

**Características:**
- Interfaz amigable para el usuario
- Solicita parámetros adicionales cuando es necesario
- Opción para regresar al menú o salir después de cada operación
- Muestra contexto de sesión (hostname, usuario, estado admin, tipo de sesión)
- **Colores dinámicos:** Admin en verde/rojo, Session en verde/amarillo

**Iniciar:**
```powershell
.\Unified-Toolkit.ps1
# o explícitamente
.\Unified-Toolkit.ps1 -Mode Menu
```

---

### Modo No-Interactivo (Run)
Ejecuta acciones específicas directamente vía parámetros de línea de comandos. Ideal para automatización, scripting o ejecución remota.

**Iniciar:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action <NombreAccion> [parámetros adicionales]
```

---

## Descripción de Módulos

### 1. System Triage (Invoke-Triage)
**Propósito:** Inventario completo del sistema y recopilación de información.

**Recopila:**
- Hostname y usuario actual
- Fabricante, modelo y número de serie del hardware
- Versión de Windows y número de build
- Uptime del sistema (días, horas, minutos)
- Direcciones IPv4 activas
- **Detección de todos los discos fijos** con información detallada:
  - Letra de unidad (C:, D:, etc.)
  - Etiqueta de volumen
  - Sistema de archivos (NTFS, FAT32, etc.)
  - Tamaño total (GB)
  - Espacio libre (GB)
  - Espacio usado (GB)
  - Porcentaje libre
- **Alertas visuales por color:**
  - Verde: >20% libre (óptimo)
  - Amarillo: 10-20% libre (precaución)
  - Rojo: <10% libre (crítico)

**Requisitos:** Ninguno (funciona sin privilegios de admin)

**Salida:** PSCustomObject con todos los datos recopilados

**Casos de Uso:**
- Troubleshooting inicial
- Documentación del sistema
- Línea base pre-cambios

**Ejemplo:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action Triage
```

**Salida de ejemplo:**
```
Disks:
  C: [Windows] - NTFS - 125.43 GB free of 500.00 GB (25.1% free)
  D: [Data] - NTFS - 850.20 GB free of 2000.00 GB (42.5% free)
  E: [Backup] - NTFS - 50.45 GB free of 1000.00 GB (5.0% free)
```

---

### 2. Performance Maintenance (Invoke-Performance)
**Propósito:** Limpiar archivos temporales y opcionalmente ejecutar System File Checker.

**Acciones:**
- Calcular tamaño de `%TEMP%` (carpeta temp del usuario)
- Calcular tamaño de `C:\Windows\Temp` (requiere admin)
- Eliminar archivos temporales (a menos que se especifique `-DryRun`)
- Opcional: Ejecutar `sfc /scannow` (solo modo interactivo, requiere admin)

**Parámetros:**
- `-DryRun` - Solo calcular, no eliminar

**Características de Seguridad:**
- Maneja archivos bloqueados con gracia (continúa al error)
- Aviso de SFC sobre ~15 minutos de tiempo de ejecución

**Requisitos:**
- Usuario estándar: Puede limpiar solo temp del usuario
- Administrador: Puede limpiar temp del usuario y de Windows

**Salida:** PSCustomObject con MB calculados/liberados y estado SFC

**Ejemplos:**
```powershell
# Dry run para ver qué se limpiaría
.\Unified-Toolkit.ps1 -Mode Run -Action Performance -DryRun

# Realmente limpiar archivos
.\Unified-Toolkit.ps1 -Mode Run -Action Performance
```

---

### 3. Network Diagnostics (Invoke-Network)
**Propósito:** Probar conectividad de red y refrescar configuración DNS.

**Acciones:**
1. Auto-detectar gateway predeterminado
2. Probar conectividad a:
   - Gateway predeterminado
   - Google DNS (8.8.8.8)
   - DNS Interno (si se proporciona `-InternalDns`)
3. Ejecutar `ipconfig /flushdns`
4. Ejecutar `ipconfig /registerdns`

**Parámetros:**
- `-InternalDns <IP/Host>` - Servidor DNS adicional para probar
- `-Force` - Anular bloqueos de seguridad para operaciones disruptivas

**Características de Seguridad:**
- Detecta sesiones RDP/Unknown
- Bloquea operaciones disruptivas (como `/release`) sin `-Force`
- Advierte al usuario sobre riesgos potenciales de desconexión

**Requisitos:** Ninguno (usuario estándar puede ejecutar)

**Salida:** PSCustomObject con resultados de conectividad y estado de operaciones DNS

**Nota Importante:** En entornos domésticos, el ping a Google DNS (8.8.8.8) puede fallar debido a firewall de Windows o router bloqueando ICMP saliente. Esto es normal si la navegación web funciona correctamente.

**Ejemplos:**
```powershell
# Prueba básica de red
.\Unified-Toolkit.ps1 -Mode Run -Action Network

# Probar con DNS interno
.\Unified-Toolkit.ps1 -Mode Run -Action Network -InternalDns 10.0.0.1

# Anular seguridad (usar con precaución en RDP)
.\Unified-Toolkit.ps1 -Mode Run -Action Network -Force
```

---

### 4. Service Healer (Invoke-ServiceHealer)
**Propósito:** Reiniciar servicios críticos de Windows que comúnmente fallan.

**Servicios Objetivo:**
- **Spooler** - Servicio de impresión
- **Audiosrv** - Audio de Windows
- **wuauserv** - Windows Update

**Comportamiento:**
- Si el servicio está corriendo → Reiniciarlo
- Si el servicio está detenido → Iniciarlo
- Si el servicio falla → Registrar error y continuar

**Características de Seguridad:**
- Maneja dependencias de servicios automáticamente
- Continúa en error (no detiene todo el proceso)

**Requisitos:** Puede requerir admin para algunos servicios

**Salida:** Array de PSCustomObjects (uno por servicio) con estado y acción tomada

**Ejemplo:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action Services
```

---

### 5. Admin Shortcuts (Invoke-AdminShortcuts)
**Propósito:** Lanzador rápido para herramientas administrativas comunes.

**Herramientas Lanzadas:**
- **Task Manager** (`taskmgr.exe`)
- **Services** (`services.msc`)
- **System Configuration** (`msconfig.exe`)

**Comportamiento:** Lanzamiento de mejor esfuerzo; continúa en error

**Requisitos:** Ninguno (las herramientas pueden solicitar elevación si es necesario)

**Salida:** Array de PSCustomObjects (uno por herramienta) con estado de lanzamiento

**Ejemplo:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action Admin
```

---

### 6. Export Report (Export-Report)
**Propósito:** Exportar todos los resultados recopilados a un archivo JSON estructurado.

**Contenidos del Reporte:**
```json
{
  "Metadata": {
    "Timestamp": "2026-03-05 00:07:47",
    "Hostname": "WORKSTATION01",
    "Username": "jdoe",
    "IsAdmin": true,
    "RemoteSessionState": "Local",
    "ToolkitVersion": "1.0.0"
  },
  "Results": {
    "Triage": {
      "Hostname": "WORKSTATION01",
      "Disks": [
        {
          "Drive": "C:",
          "Label": "Windows",
          "FileSystem": "NTFS",
          "Size_GB": 500.00,
          "Free_GB": 125.43,
          "Used_GB": 374.57,
          "PercentFree": 25.1
        },
        {
          "Drive": "D:",
          "Label": "Data",
          "FileSystem": "NTFS",
          "Size_GB": 2000.00,
          "Free_GB": 850.20,
          "Used_GB": 1149.80,
          "PercentFree": 42.5
        }
      ]
    },
    "Performance": { ... },
    "Network": { ... },
    "Services": [ ... ]
  }
}
```

**Nombre de Archivo:** `SupportToolkit-Report-YYYYMMDD-HHMMSS.json`

**Ubicación Predeterminada:** `C:\IT-Reports`

**Ventajas de C:\IT-Reports:**
- ✅ No sincronizado con OneDrive (más rápido, sin conflictos)
- ✅ Ubicación profesional estándar para soporte IT
- ✅ Fácil de encontrar en cualquier PC corporativo
- ✅ No eliminado con limpiezas de carpetas temporales
- ✅ Creación automática de carpeta si no existe

**Parámetros:**
- `-OutPath <Ruta>` - Directorio de salida personalizado

**Ejemplos:**
```powershell
# Exportar a C:\IT-Reports (predeterminado)
.\Unified-Toolkit.ps1 -Mode Run -Action Report

# Ubicación personalizada
.\Unified-Toolkit.ps1 -Mode Run -Action Report -OutPath "D:\Custom-Reports"
```

---

### 7. Run All (Ejecutar Todo)
**Propósito:** Ejecutar todos los módulos de diagnóstico en secuencia y auto-exportar reporte.

**Orden de Ejecución:**
1. System Triage
2. Performance Maintenance
3. Network Diagnostics
4. Service Healer
5. Auto-Exportar Reporte

**Nota:** NO incluye Admin Shortcuts (lanzamiento de herramientas)

**Ejemplo:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action All
.\Unified-Toolkit.ps1 -Mode Run -Action All -DryRun -OutPath "C:\Reports"
```

---

## Ejemplos de Uso

### Uso Interactivo Básico
```powershell
# Iniciar menú
.\Unified-Toolkit.ps1

# Seguir instrucciones, seleccionar opciones 1-7
```

---

### Chequeo Rápido del Sistema
```powershell
# Obtener información del sistema únicamente
.\Unified-Toolkit.ps1 -Mode Run -Action Triage
```

---

### Dry Run de Pre-Mantenimiento
```powershell
# Ver qué se limpiaría sin eliminar
.\Unified-Toolkit.ps1 -Mode Run -Action Performance -DryRun
```

---

### Suite Completa de Diagnóstico
```powershell
# Ejecutar todo con DNS personalizado y ruta de salida
.\Unified-Toolkit.ps1 -Mode Run -Action All -InternalDns 10.0.0.1 -OutPath "D:\Reports"
```

---

### Troubleshooting de Red
```powershell
# Prueba básica de red
.\Unified-Toolkit.ps1 -Mode Run -Action Network

# Con DNS interno
.\Unified-Toolkit.ps1 -Mode Run -Action Network -InternalDns 192.168.1.1
```

---

### Recuperación de Servicios
```powershell
# Reiniciar servicios críticos
.\Unified-Toolkit.ps1 -Mode Run -Action Services
```

---

### Reporteo Automatizado
```powershell
# Ejecutar diagnósticos y guardar reporte en recurso compartido de red
.\Unified-Toolkit.ps1 -Mode Run -Action All -OutPath "\\fileserver\IT-Reports"
```

---

## Características de Seguridad

### Detección de Administrador
- Detecta automáticamente si se ejecuta con privilegios de admin
- Registra el estado de admin
- Restringe ciertas operaciones cuando no es admin
- **Indicador visual con color dinámico en menú:** Verde para YES, Rojo para NO

### Detección de Sesión Remota
- Identifica si la sesión es Local, RDP o Unknown
- Bloquea operaciones de red potencialmente disruptivas en sesiones RDP
- Puede anularse con el parámetro `-Force`
- **Indicador visual con color dinámico en menú:** Verde para Local, Amarillo para RDP

### Manejo de Errores
- Bloques try/catch alrededor de todas las operaciones críticas
- Continúa con errores no fatales
- Registra todos los errores para troubleshooting

### Seguridad de Eliminación de Archivos
- Maneja archivos bloqueados con gracia
- Omite archivos que no pueden ser eliminados
- Reporta espacio real liberado (no solo calculado)

---

## Salida y Registro

### Salida en Consola
Mensajes codificados por color para escaneo visual rápido:
- **Verde (OK)** - Operaciones exitosas
- **Cyan (INFO)** - Mensajes informativos, etiquetas de campos
- **Amarillo (WARN)** - Advertencias, problemas no críticos, valores variables
- **Rojo (ERROR)** - Errores, operaciones fallidas

**Mejora de Interfaz:** En el menú interactivo, la información del sistema usa colores diferenciados:
- Etiquetas (Computer, User) en **Cyan**
- Valores variables (hostname, username) en **Amarillo**
- Estado de Admin con **color dinámico** (Verde para YES / Rojo para NO)
- Tipo de sesión con **color dinámico** (Verde para Local / Amarillo para RDP)

### Archivo de Log
**Ubicación:** `%TEMP%\SupportToolkit.log`

**Formato:**
```
YYYY-MM-DD HH:mm:ss | LEVEL | Message
2026-03-05 00:07:15 | INFO | IT Support Toolkit v1.0.0 Started
2026-03-05 00:07:16 | OK | Triage completed successfully
2026-03-05 00:07:45 | WARN | Not running as admin - skipping Windows Temp
```

**Persistencia:** Se agrega al archivo de log existente (no sobrescribe)

### Transcript
**Ubicación:** `%TEMP%\SupportToolkit-Transcript-YYYYMMDD-HHMMSS.txt`

**Contenidos:** Salida completa de la sesión de PowerShell incluyendo todos los comandos y resultados

**Nota:** El transcript puede fallar en algunos entornos; el toolkit continúa de todos modos

---

## Requisitos

### Requisitos del Sistema
- **SO:** Windows 10/11 o Windows Server 2016+
- **PowerShell:** Versión 7.0 o superior (pwsh.exe)
- **Permisos:** Usuario estándar (algunas funciones requieren admin)

### Sin Dependencias Externas
- Usa solo comandos integrados de Windows
- No requiere módulos o paquetes adicionales
- Portable - se ejecuta desde cualquier ubicación

---

## Notas Importantes sobre Diferencias de Entorno

### Entornos Corporativos vs. Personales

El toolkit está diseñado principalmente para entornos corporativos, pero funciona en PCs personales con algunas diferencias esperadas:

#### **Serial del BIOS "Default string"**
- **Normal en:** PCs ensamblados, custom builds, placas madre genéricas (ASUS, Gigabyte, MSI)
- **Reason:** Los fabricantes dejan valores placeholder que el OEM debería programar
- **En corporativo:** PCs de marca (Dell, HP, Lenovo) tienen seriales reales programados

#### **Fallo de Ping a Google DNS (8.8.8.8)**
- **Normal en:** Entornos domésticos con firewall de Windows o router bloqueando ICMP saliente
- **Verificación:** Si la navegación web funciona, la conectividad está OK
- **En corporativo:** Puede haber firewall corporativo o requisito de proxy

Estas diferencias son **completamente normales** y no indican problemas con el sistema o el toolkit.

---

## Historial de Versiones

### v1.0.0 (2026-03-03)
- Lanzamiento inicial
- 6 módulos principales (Triage, Performance, Network, Services, Admin, Report)
- Modos interactivo y no-interactivo
- Diseño con seguridad primero con detección de RDP
- Registro profesional y reporteo JSON
- Detección de múltiples discos y particiones
- Ubicación profesional de reportes (C:\IT-Reports)
- Colores dinámicos en interfaz

---

## Soporte y Retroalimentación
Este es un proyecto personal diseñado para automatización de soporte IT. Usar bajo tu propio riesgo en entornos de producción. Siempre probar en sistemas no productivos primero.

Para problemas o sugerencias, revisar el código fuente del script en `src/Unified-Toolkit.ps1`.
