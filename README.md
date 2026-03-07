# IT Support Toolkit

> **Proyecto personal de aprendizaje: Automatización de rutinas de soporte IT con PowerShell 7**

**[English](README.EN.md) | Español**

Toolkit desarrollado como MVP para estandarizar mis rutinas de diagnóstico y mantenimiento en sistemas Windows durante mi aprendizaje en soporte IT de nivel L1/L2.

---

## 🎯 Sobre Este Proyecto

Este es un **proyecto personal de aprendizaje** creado para:

- **Estandarizar** mi flujo de trabajo en tareas repetitivas de soporte IT
- **Practicar** scripting profesional con PowerShell 7
- **Documentar** mis procesos para referencia futura
- **Minimizar errores** mediante automatización y validaciones

**No es una solución empresarial** - es una herramienta honesta que uso para mejorar mi eficiencia y aprender mejores prácticas mientras trabajo en casos reales de soporte.

---

## 🎓 Decisiones de Diseño

### ¿Por qué PowerShell 7?
- **Objetos estructurados**: Manejo de datos más limpio que text parsing
- **JSON nativo**: `ConvertTo-Json` para reportes estructurados
- **Multiplataforma**: Aunque este toolkit es Windows-only, pwsh es portable

### ¿Por qué cero dependencias externas?
- **Portabilidad**: Puedo copiar el script a USB o ejecutar en sesiones remotas
- **Simplicidad**: Sin gestión de módulos, versiones, o instaladores
- **Aprendizaje**: Fuerza el uso de cmdlets nativos y clases CIM/WMI

### ¿Por qué "safety-first"?
- **Errores humanos**: Detectar admin/RDP antes de acciones peligrosas
- **Dry-run mode**: Calcular impacto antes de borrar archivos
- **Logging**: Auditoría de todas las acciones para troubleshooting

---

## 📏 Alcance del Proyecto

### ✅ Lo que hace (v1.x)
- Diagnóstico básico del sistema (inventario, red, servicios)
- Mantenimiento seguro (limpieza de archivos temporales con validaciones)
- Reportes estructurados en JSON para documentación

### ⏳ Planeado (v2.x)
- Recolección opcional de eventos críticos de Windows (Application, System)
- Mejoras en reporting (HTML, comparación de reportes históricos)
- Troubleshooting de estabilidad (crashes, freezes, blue screens)

### 🔮 Visión (v3.x - Security posture / signals)
- Checks básicos de postura de seguridad (Windows Defender, Firewall, Updates)
- Recolección best-effort de señales básicas para análisis (failed logins, cambios de cuentas)
- **NOT detección/EDR**: Solo observación y recolección para aprendizaje

### ❌ Fuera de alcance
- Remediación automática de malware
- Análisis forense profundo
- Gestión de Active Directory
- Deployment o configuración de sistemas nuevos

---

## ✨ Características

### 📊 System Triage (Inventario del Sistema)
Inventario completo del sistema incluyendo información de hardware, versión de Windows, uptime, configuración de red, y **detección automática de todos los discos y particiones** con información detallada de cada uno (tamaño, espacio libre, porcentaje de uso).

### ⚡ Performance Maintenance (Mantenimiento de Rendimiento)
Calcula y limpia archivos temporales (usuario + sistema), con ejecución opcional de System File Checker.

### 🌐 Network Diagnostics (Diagnóstico de Red)
Auto-detección de gateway, prueba de conectividad (gateway, 8.8.8.8, DNS personalizado), limpieza/registro de caché DNS.

### 🔧 Service Healer (Sanador de Servicios)
Reinicia automáticamente servicios críticos de Windows (Print Spooler, Audio, Windows Update).

### 🛠️ Admin Shortcuts (Accesos Directos de Administración)
Lanzador rápido para Task Manager, Services, y utilidades de System Configuration.

### 📄 JSON Reporting (Reportes JSON)
Exporta todos los resultados de diagnóstico con metadata (timestamp, hostname, usuario, tipo de sesión) a archivos JSON estructurados en **C:\IT-Reports** (ubicación profesional no sincronizada con OneDrive).

---

## 🚀 Inicio Rápido

### Requisitos Previos
- **Windows 10/11** o **Windows Server 2016+**
- **PowerShell 7+** (`pwsh.exe`) - [Descargar aquí](https://github.com/PowerShell/PowerShell/releases)
- Algunas funciones requieren **privilegios de Administrador**

### Instalación
1. Descarga o clona este repositorio
2. Navega a la carpeta del proyecto
3. Ejecuta el script con PowerShell 7

### Uso Básico

#### Modo Interactivo (Predeterminado)
```powershell
pwsh -File .\src\Unified-Toolkit.ps1
```

Esto lanza un menú donde puedes seleccionar operaciones de forma interactiva.

#### Modo No-Interactivo
```powershell
# Ejecutar acción específica
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action Triage

# Ejecutar todos los diagnósticos
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action All
```

---

## 📖 Ejemplos de Uso

### Ejemplo 1: Menú Interactivo
```powershell
pwsh -File .\src\Unified-Toolkit.ps1
```
Navega por el menú, selecciona opciones y sigue las instrucciones.

---

### Ejemplo 2: Inventario Rápido del Sistema
```powershell
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action Triage
```
**Salida:**
```
--- System Triage Summary ---
Hostname:       WORKSTATION01
User:           jdoe
Manufacturer:   Dell Inc.
Model:          OptiPlex 7090
Serial:         ABC123XYZ
Windows:        Microsoft Windows 11 Pro
Build:          22621
Uptime:         5d 3h 45m
IPv4:           192.168.1.100

Disks:
  C: [Windows] - NTFS - 125.43 GB free of 500.00 GB (25.1% free)
  D: [Datos] - NTFS - 850.20 GB free of 2000.00 GB (42.5% free)
-----------------------------
```

---

### Ejemplo 3: Limpieza de Archivos Temporales (Dry Run)
```powershell
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action Performance -DryRun
```
**Salida:**
```
--- Performance Report (Dry Run) ---
User Temp:      342.50 MB
Windows Temp:   1024.75 MB
Total:          1367.25 MB
------------------------------------
```

---

### Ejemplo 4: Diagnóstico de Red con DNS Personalizado
```powershell
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action Network -InternalDns 10.0.0.1
```
**Salida:**
```
--- Network Diagnostics ---
Gateway:        192.168.1.1 - OK
Ping Google:    OK
Internal DNS:   Reachable
Flush DNS:      Success
Register DNS:   Success
---------------------------
```

---

### Ejemplo 5: Suite Completa de Diagnóstico
```powershell
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action All
```
Ejecuta todos los módulos secuencialmente y exporta un reporte JSON consolidado a `C:\IT-Reports\`.

---

### Ejemplo 6: Recuperación de Servicios
```powershell
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action Services
```
**Salida:**
```
--- Service Healer Results ---
Spooler: Restarted
Audiosrv: Started
wuauserv: Restarted
------------------------------
```

---

## 🛡️ Características de Seguridad

### Detección de Privilegios de Administrador
El toolkit detecta automáticamente si se está ejecutando con privilegios elevados:
- Registra el estado de admin al inicio
- Restringe ciertas operaciones cuando no es admin
- Muestra el estado de admin en el menú interactivo con **colores dinámicos** (verde para YES, rojo para NO)

### Detección de Sesión Remota
Identifica si la sesión es:
- **Local** - Acceso directo por consola (verde)
- **RDP** - Conexión de Escritorio Remoto (amarillo)
- **Unknown** - No se puede determinar

**Regla de Seguridad:** Las operaciones de red potencialmente disruptivas (como `ipconfig /release`) **muestran un warning** en sesiones RDP/Unknown. Usa explicitamente `-Force` para suprimir el warning y ejecutar de todas formas.

### Manejo de Errores
- Bloques try/catch completos alrededor de todas las operaciones
- Continúa con errores no fatales
- Todos los errores se registran para troubleshooting

### Seguridad en Eliminación de Archivos
- Maneja archivos bloqueados con gracia
- Omite archivos que no pueden ser eliminados (en uso)
- Reporta espacio real liberado (no solo estimado)

---

## 📁 Estructura del Proyecto

```
IT-Support-Toolkit/
│
├── src/
│   └── Unified-Toolkit.ps1       # Script principal (todos los módulos incluidos)
│
├── docs/
│   └── Commands.md                # Referencia detallada de comandos
│
└── README.md                      # Este archivo
```

---

## 🔧 Parámetros Disponibles

| Parámetro | Tipo | Descripción | Ejemplo |
|-----------|------|-------------|---------|
| `-Mode` | String | `Menu` (predeterminado) o `Run` | `-Mode Run` |
| `-Action` | String | Módulo a ejecutar: `Triage`, `Performance`, `Network`, `Services`, `Admin`, `Report`, `All` | `-Action Triage` |
| `-DryRun` | Switch | Performance: calcula tamaño de limpieza sin eliminar | `-DryRun` |
| `-InternalDns` | String | Network: servidor DNS personalizado a probar | `-InternalDns 10.0.0.1` |
| `-OutPath` | String | Report: directorio de salida personalizado (predeterminado: C:\IT-Reports) | `-OutPath "C:\Reports"` |
| `-Force` | Switch | Network: suprimir warnings de seguridad en RDP para acciones disruptivas | `-Force` |

Para documentación completa de parámetros, ver [docs/Commands.md](docs/Commands.md).

---

## 📊 Salida y Registro

### Salida en Consola
Código de colores mejorado para escaneo visual rápido:
- 🟢 **Verde (OK)** - Operaciones exitosas
- 🔵 **Cyan (INFO)** - Mensajes informativos, etiquetas de campos
- 🟡 **Amarillo (WARN)** - Advertencias, problemas no críticos, valores variables
- 🔴 **Rojo (ERROR)** - Errores, operaciones fallidas

**Mejora de interfaz:** En el menú interactivo, la información del sistema usa colores diferenciados:
- Etiquetas (Computer, User) en **Cyan**
- Valores variables en **Amarillo**
- Estado de Admin con color dinámico (Verde/Rojo)
- Tipo de sesión con color dinámico (Verde/Amarillo)

### Archivo de Log
**Ubicación:** `%TEMP%\SupportToolkit.log`

**Formato:**
```
YYYY-MM-DD HH:mm:ss | LEVEL | Message
```

**Persistencia:** Se agrega al log existente (no sobrescribe)

### Transcript
**Ubicación:** `%TEMP%\SupportToolkit-Transcript-YYYYMMDD-HHMMSS.txt`

Captura completa de la sesión de PowerShell (si es soportada por el entorno).

### Reporte JSON
**Ubicación:** `C:\IT-Reports` (predeterminado) o `-OutPath` personalizado

**Nombre de archivo:** `SupportToolkit-Report-YYYYMMDD-HHMMSS.json`

**Ventajas de C:\IT-Reports:**
- ✅ No se sincroniza con OneDrive (más rápido, sin conflictos)
- ✅ Ubicación profesional estándar para soporte IT
- ✅ Fácil de encontrar en cualquier PC corporativo
- ✅ No se elimina con limpiezas de carpetas temporales
- ✅ Creación automática de carpeta si no existe

**Estructura:**
```json
{
  "Metadata": {
    "Timestamp": "2026-03-05 00:07:47",
    "Hostname": "WORKSTATION01",
    "Username": "jdoe",
    "IsAdmin": true,
    "RemoteSessionState": "Local",
    "ToolkitVersion": "1.0.1"
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
          "Label": "Datos",
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

---

## 🎓 Casos de Uso

### Técnico de Help Desk
```powershell
# Chequeo rápido del sistema durante una llamada de soporte
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Triage
```

### Administrador de Sistemas
```powershell
# Automatización de mantenimiento programado
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Performance
```

### Resolución de Problemas de Red
```powershell
# Diagnosticar problemas de conectividad
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Network -InternalDns dc01.domain.local
```

### Documentación Pre-Cambios
```powershell
# Capturar estado del sistema antes de cambios
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action All -OutPath "\\fileserver\Pre-Change-Docs"
```

### Recuperación de Servicios
```powershell
# Corregir fallos comunes de servicios
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Services
```

---

## ⚙️ Uso Avanzado

### Ejecución Remota (WinRM/PSSession)
```powershell
Invoke-Command -ComputerName REMOTE-PC -FilePath .\src\Unified-Toolkit.ps1 -ArgumentList '-Mode', 'Run', '-Action', 'Triage'
```

### Tarea Programada
Crear una tarea programada para ejecutar mantenimiento semanalmente:
```powershell
$action = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument '-File "C:\Scripts\Unified-Toolkit.ps1" -Mode Run -Action Performance'
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am
Register-ScheduledTask -TaskName "Mantenimiento Semanal" -Action $action -Trigger $trigger -RunLevel Highest
```

### Directorio de Logging Personalizado (vía variable de entorno)
```powershell
# Modificar $env:TEMP antes de ejecutar para cambiar ubicación del log
$env:TEMP = "C:\CustomLogs"
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action All
```

---

## ❓ Preguntas Frecuentes

### P: ¿Necesito privilegios de Administrador?
**R:** No para todas las funciones. Triage, Network (básico), y Admin Shortcuts funcionan sin admin. Performance (limpieza de Windows Temp) y algunas operaciones de Service requieren admin.

### P: ¿Puedo ejecutar esto en una sesión remota?
**R:** ¡Sí! El toolkit detecta sesiones RDP y muestra warnings para operaciones potencialmente disruptivas por defecto. Usa `-Force` para suprimir el warning si es necesario.

### P: ¿Por qué `-DryRun` muestra menos espacio del esperado?
**R:** Algunos archivos pueden estar bloqueados u ocultos. El script calcula basándose solo en archivos accesibles.

### P: ¿Por qué a veces falla el transcript?
**R:** Algunos entornos (sesiones restringidas, configuraciones específicas de PS) no soportan transcripts. El toolkit registra una advertencia y continúa.

### P: ¿Puedo agregar módulos personalizados?
**R:** ¡Sí! La estructura del script es modular. Agrega nuevas funciones `Invoke-*` e integralas en el menú/lógica de parámetros.

### P: ¿Funciona con PowerShell 5.1?
**R:** No. Este toolkit requiere **PowerShell 7+** (`pwsh.exe`). Muchas funciones dependen de cmdlets multiplataforma y sintaxis moderna.

### P: ¿Por qué el serial del BIOS muestra "Default string"?
**R:** Esto es **normal en PCs ensamblados o custom builds**. Los fabricantes de placas madre (ASUS, Gigabyte, MSI) dejan valores placeholder que el OEM debería programar. En PCs corporativos de marca (Dell, HP, Lenovo) verás serials reales.

### P: ¿Por qué falla el ping a Google DNS (8.8.8.8)?
**R:** En **entornos domésticos**, el firewall de Windows o el router pueden bloquear ping (ICMP) saliente por seguridad. En **entornos corporativos**, puede haber firewall corporativo o proxy. Si tu navegación web funciona, tu conectividad está OK.

---

## ⚠️ Limitaciones Conocidas & Non-goals

### 🚫 Fuera de Alcance (Por Diseño)
- **Remediación automática de malware**: No es una herramienta de seguridad
- **Análisis forense profundo**: Solo diagnóstico básico de sistema
- **Gestión de Active Directory**: No toca políticas de dominio
- **Deployment de sistemas**: No es herramienta de provisionamiento
- **Limpieza agresiva de disco**: Solo temp files, no Downloads/Recycle/Browser cache

### 🚧 Limitaciones Actuales (v1.x)

**Performance/Cleanup:**
- Solo limpia archivos temporales (User Temp + Windows Temp)
- No limpia: Downloads, Papelera, cachés de navegador, Windows Update backup
- Archivos en uso son omitidos (no forced deletion)
- No verifica integridad pre-cleanup (usa SFC opcionalmente post-cleanup)

**Network Diagnostics:**
- Ping a 8.8.8.8 puede fallar en entornos con firewall (normal, no es error)
- No diagnostica configuración de proxy
- No valida certificados SSL/TLS
- No prueba puertos específicos (solo ICMP)

**Service Healer:**
- Lista hardcoded de servicios (Spooler, Audio, Windows Update)
- No detecta servicios custom/third-party
- No valida dependencias de servicios
- Restart simple (no troubleshooting de causa raíz)

**Reporting:**
- Solo JSON (no HTML, no CSV)
- No comparación histórica (cada reporte es independiente)
- No envío automático (email, webhook, etc.)

**Environment:**
- Solo Windows 10/11 y Server 2016+ (no legacy)
- Requiere PowerShell 7+ (no compatible con 5.1)
- Solo WMI/CIM nativo (no módulos third-party)
- Sin localización (output en inglés, docs en EN/ES)

### 📚 Por Qué Estas Limitaciones

**Filosofía:** Este toolkit es un **MVP educacional**, no un producto comercial. Las limitaciones son **intencionales** para:

1. **Mantener simplicidad**: Código legible para aprendizaje
2. **Cero dependencias**: Portabilidad sin instalación
3. **Seguridad primero**: Evitar sobre-automatización peligrosa
4. **Scope controlado**: Terminar v1.x antes de complicar

**Roadmap:** Algunas limitaciones se abordarán en v2.x (HTML reports, event collection), otras son permanentes por diseño.

---

## 🛠️ Resolución de Problemas

### "La ejecución de scripts está deshabilitada en este sistema"
**Solución:** Ajustar la política de ejecución (como admin):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Este script requiere PowerShell 7+"
**Solución:** Instalar PowerShell 7: https://github.com/PowerShell/PowerShell/releases

### "Failed to start transcript"
**Esperado:** Los transcripts pueden fallar en algunos entornos. El toolkit registra una advertencia y continúa normalmente.

### El archivo de log es enorme
**Solución:** El archivo de log se agrega indefinidamente. Elimina manualmente `%TEMP%\SupportToolkit.log` periódicamente, o implementa rotación de logs.

---

## 📜 Licencia y Disclaimer

Este es un **proyecto personal de aprendizaje** proporcionado "as-is" sin garantías.

**Libertades:**
- ✅ Usar para aprendizaje personal o trabajo profesional
- ✅ Modificar y adaptar a tu entorno
- ✅ Compartir con colegas o la comunidad

**Responsabilidad:**
- ⚠️ **Probar en entornos no productivos primero**
- ⚠️ Revisar el código antes de ejecutar con privilegios de admin
- ⚠️ El autor no se responsabiliza por cambios no deseados en sistemas

**Filosofía:** Este toolkit refleja mi aprendizaje continuo. Puede tener errores, decisiones subóptimas, o casos edge no cubiertos. **Úsalo como referencia, no como solución enterprise.**

---

## 🤝 Contribuciones

Como proyecto de aprendizaje, agradezco:
- 🐛 Reportes de bugs con contexto (OS, PowerShell version, output)
- 💡 Sugerencias de mejores prácticas (especialmente de seniors)
- 📖 Mejoras de documentación
- ⚠️ Señalar patrones antipatrón o inseguros

**No esperes:** Soporte 24/7, releases frecuentes, o compatibilidad backward. Es aprendizaje público.

---

## 📚 Recursos Adicionales

- **Referencia Detallada de Comandos:** [docs/Commands.md](docs/Commands.md)
- **Documentación PowerShell 7:** https://docs.microsoft.com/powershell/
- **Clases Windows CIM/WMI:** https://docs.microsoft.com/windows/win32/cimwin32prov/

---

## 📌 Versión y Roadmap

**Versión Actual:** 1.0.1  
**Fecha de Release:** 5 de marzo, 2026  
**PowerShell Requerido:** 7.0+  
**Plataforma:** Windows 10/11, Windows Server 2016+

### 🗺️ Roadmap

#### v1.x - Fundación (Actual)
- ✅ Diagnóstico básico del sistema
- ✅ Mantenimiento seguro de archivos temporales
- ✅ Diagnósticos de red
- ✅ Sanador de servicios críticos
- ✅ Reportes JSON estructurados

#### v2.x - Troubleshooting Avanzado (Planeado)
- 📋 Recolección de eventos críticos de Windows (crashes, errores de aplicación)
- 📊 Reportes HTML con gráficos básicos
- 🔄 Comparación de reportes históricos
- 🧹 Análisis de uso de disco (carpetas grandes, duplicados)

#### v3.x - Security posture / signals (Visión)
- 🛡️ Checks de postura básica (Defender, Firewall, Updates)
- 🔐 Recolección best-effort de señales de seguridad (intentos de login, cambios de usuarios)
- 📝 Reportes de cumplimiento básico
- ⚠️ **Nota**: Solo observación/reporting, NO detección activa ni EDR

### 📜 Changelog

#### v1.0.1 (2026-03-05)
- **Mejoras de precisión**: Todos los valores MB/GB redondeados a 2 decimales
- **Formato JSON mejorado**: Service Status ahora muestra texto (Running/Stopped) en lugar de códigos numéricos (1/4)
- **Renombrado de campo**: `GoogleDNS` → `PingGoogle` para mayor claridad en Network Diagnostics
- **Fix**: Corrección de flotantes extraños en `TotalCalculated_MB`

#### v1.0.0 (2026-03-03)
- Lanzamiento inicial
- 6 módulos principales (Triage, Performance, Network, Services, Admin, Report)
- Modos interactivo y no-interactivo
- Diseño safety-first con detección de RDP
- Registro profesional y reporteo JSON
- Multi-disk detection con información detallada
- Ubicación profesional de reportes (C:\IT-Reports)

---

## 🙏 Notas de Aprendizaje

Este proyecto me ha enseñado:
- Diseño de CLI con PowerShell (parámetros, validación, help)
- Manejo de objetos PowerShell vs text parsing
- Importancia de logging y error handling en scripts de producción
- Safety patterns para operaciones destructivas
- Documentación técnica para usuarios finales

**Happy troubleshooting!** 🚀
