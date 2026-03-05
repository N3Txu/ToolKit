# IT Support Toolkit - Cheat Sheet L1

**[English](Commands.EN.md) | Español**

> **Referencia rápida** para técnicos de nivel L1/L2. Proyecto personal de aprendizaje - úsalo como guía, no como verdad absoluta.

---

## 🚀 Quick Start

```powershell
# Modo interactivo (menú)
pwsh -File .\src\Unified-Toolkit.ps1

# Diagnóstico rápido
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action Triage

# Suite completa
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action All
```

---

## 📋 Parámetros Principales

| Parámetro | Tipo | Valores | Default | Descripción |
|-----------|------|---------|---------|-------------|
| `-Mode` | String | `Menu`, `Run` | `Menu` | Interactivo vs CLI directo |
| `-Action` | String | Ver tabla abajo | N/A | Qué módulo ejecutar (requerido con `-Mode Run`) |
| `-DryRun` | Switch | N/A | `$false` | Solo calcular (Performance), no borrar |
| `-InternalDns` | String | IP o hostname | N/A | DNS interno para probar (Network) |
| `-OutPath` | String | Ruta válida | `C:\IT-Reports` | Dónde guardar reportes JSON |
| `-Force` | Switch | N/A | `$false` | Ejecutar operaciones de red en RDP |

---

## 🛠️ Acciones (Módulos)

| Action | Qué hace | Requiere Admin | Útil para |
|--------|----------|----------------|-----------|
| `Triage` | Inventario del sistema (HW, OS, red, discos) | No | Casos nuevos, documentación inicial |
| `Performance` | Limpia temp files (user + Windows) | Parcial* | Espacio en disco bajo, slow performance |
| `Network` | Prueba gateway, 8.8.8.8, DNS interno; flush/register DNS | No | "No internet", DNS issues, conectividad |
| `Services` | Reinicia Print Spooler, Audio, Windows Update | Sí | Impresora no funciona, no sale audio, Windows Update stuck |
| `Admin` | Abre Task Manager, Services, msconfig | No | Acceso rápido a herramientas |
| `Report` | Exporta resultados previos a JSON | No | Documentación, escalamiento, evidencia |
| `All` | Ejecuta Triage + Performance + Network + Services + Report | Sí | Chequeo completo, mantenimiento rutinario |

**\*Performance:** User temp no requiere admin, Windows temp sí.

---

## 💡 Casos de Uso Comunes

### 📞 "La PC está lenta"
```powershell
# 1. Diagnóstico inicial
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Triage

# 2. Ver espacio en disco (output de Triage)
# Si espacio bajo en C: o disco de usuario...

# 3. Dry-run para calcular cuánto se liberará
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Performance -DryRun

# 4. Si >2GB y el usuario aprueba, ejecutar limpieza
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Performance
```

### 🌐 "No tengo internet"
```powershell
# Diagnóstico completo de red
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Network

# Con DNS interno corporativo
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Network -InternalDns 10.0.0.1
```

**Interpretar output:**
- `Gateway: OK` + `Ping Google: FAIL` → Problema ISP, firewall, o router bloqueando ICMP (normal en casa)
- `Gateway: FAIL` → Problema de red local (cable, switch, NIC)
- `Internal DNS: Not Reachable` → Problema VPN, DNS server down, o firewall

### 🖨️ "No puedo imprimir"
```powershell
# Reiniciar Print Spooler + otros servicios críticos
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Services
```

### 📋 Mantenimiento rutinario (ticket cerrado)
```powershell
# Suite completa con reporte automático
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action All

# Archivo generado: C:\IT-Reports\SupportToolkit-Report-YYYYMMDD-HHMMSS.json
# Adjuntar a ticket para documentación
```

---

## 🔒 Validaciones de Seguridad

### Detección de Admin
- **Performance (Windows Temp):** Requiere admin, se salta si no
- **Services:** Requiere admin, falla si no
- **Todo lo demás:** Funciona sin admin

### Detección de RDP
- **Network flush/register DNS:** Muestra warning de seguridad en RDP por defecto (puede desconectar sesión)
- **Override:** Usar `-Force` para suprimir el warning y ejecutar de todas formas

```powershell
# En sesión RDP, esto mostrará un warning de seguridad
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Network

# Suprimir warning y forzar ejecución (ten backup plan para reconectar)
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Network -Force
```

---

## 📊 Estructura del JSON Report

```json
{
  "Metadata": {
    "Timestamp": "2026-03-05T14:23:11",
    "Hostname": "WORKSTATION01",
    "Username": "jdoe",
    "IsAdmin": true,
    "RemoteSessionState": "Local",
    "ToolkitVersion": "1.0.1"
  },
  "Results": {
    "Triage": { /* inventario completo */ },
    "Performance": { /* MB liberados */ },
    "Network": { /* resultados de conectividad */ },
    "Services": [ /* estado de cada servicio */ ]
  }
}
```

**Campos útiles:**
- `Triage.Disks[]`: Array de todos los discos (Drive, Size_GB, Free_GB, PercentFree)
- `Performance.TotalCalculated_MB`: Espacio limpiado
- `Network.PingGoogle`: `true`/`false` (ping a 8.8.8.8)
- `Services[].Status`: "Running" / "Stopped"

---

## 🧪 Dry-Run Best Practice

**Siempre** dry-run Performance antes de ejecutar:
```powershell
# 1. Calcular
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Performance -DryRun

# Output mostrará:
# User Temp:      1234.56 MB
# Windows Temp:   5678.90 MB
# Total:          6913.46 MB

# 2. Si es razonable (<50% disco o <20GB), ejecutar real
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Performance
```

---

## 📝 Logging

**Ubicación:** `%TEMP%\SupportToolkit.log` (típicamente `C:\Users\<user>\AppData\Local\Temp\`)

**Formato:**
```
2026-03-05 14:23:11 | INFO | IT Support Toolkit v1.0.1 Started
2026-03-05 14:23:12 | OK | Triage completed successfully
2026-03-05 14:23:45 | WARN | Not running as admin - skipping Windows Temp
2026-03-05 14:24:10 | ERROR | Failed to restart service: Spooler
```

**Niveles:**
- `INFO`: Eventos normales
- `OK`: Operaciones exitosas
- `WARN`: No crítico pero notable
- `ERROR`: Fallos que requieren atención

**Limpiar log:**
```powershell
Remove-Item $env:TEMP\SupportToolkit.log
```

---

## ⚠️ Troubleshooting Común

### "Running scripts is disabled on this system"
**Fix:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "This script requires PowerShell 7+"
**Fix:** Instalar pwsh: https://github.com/PowerShell/PowerShell/releases  
Verificar: `pwsh -Version`

### Performance no libera mucho espacio
**Razones:**
- Solo limpia temp files (no Downloads, no Recycle Bin, no browser cache)
- User Temp: `C:\Users\<user>\AppData\Local\Temp`
- Windows Temp: `C:\Windows\Temp` (requiere admin)

**Alternativas para más espacio:**
- Disk Cleanup (cleanmgr.exe)
- Storage Sense (Settings → System → Storage)
- Manual: Vaciar papelera, borrar Downloads viejos

### Ping a Google (8.8.8.8) siempre falla
**Normal en:**
- Casa: Router o firewall bloqueando ICMP saliente
- Corporativo: Firewall corporativo o proxy

**Verificar:** Si navegación web funciona, red is OK. ICMP != HTTP.

### BIOS Serial muestra "Default string"
**Normal en:** PCs custom build o ensamblados (ASUS, Gigabyte, MSI placas base)  
**Reason:** OEM no programó serial en BIOS

---

## 🗺️ Version y Roadmap

**Actual:** v1.0.1 (March 5, 2026)

### v1.x - Actual
- Diagnóstico básico (inventario, red, servicios)
- Mantenimiento seguro (limpieza temp con validaciones)
- Reportes JSON

### v2.x - Planeado (Q2/Q3 2026)
- Recolección de eventos críticos de Windows (crashes, errores de app)
- Reportes HTML con charts
- Comparación histórica

### v3.x - Security posture / signals (Visión)
- Checks básicos de seguridad (Defender, Firewall, Updates)
- Recolección best-effort de señales (failed logins, cambios de cuentas)
- **NO es EDR/detección** - solo observación para aprendizaje

---

## 📜 Changelog

### v1.0.1 (2026-03-05)
- **Fix:** Todos los MB/GB valores redondeados a 2 decimales
- **Mejora:** Service Status ahora muestra texto ("Running"/"Stopped") en JSON
- **Cambio:** Campo `GoogleDNS` renombrado a `PingGoogle`

### v1.0.0 (2026-03-03)
- Release inicial
- 6 módulos core + reporteo JSON
- Safety-first design (detección admin/RDP)
- Multi-disk detection

---

## 🎓 Sobre Este Proyecto

**Es:** Proyecto personal de aprendizaje para estandarizar rutinas de soporte L1/L2  
**No es:** Solución enterprise, herramienta certificada, o reemplazo de RMM  

**Aprender más:** [README.md](../README.md)

---

**Disclaimer:** Proyecto de aprendizaje. Probar en no-prod primero. Sin garantías. Usar bajo tu propio criterio.
