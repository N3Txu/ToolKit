# IT Support Toolkit - L1 Cheat Sheet

**English | [Español](Commands.md)**

> **Quick reference** for L1/L2 technicians. Personal learning project - use as guide, not gospel.

---

## 🚀 Quick Start

```powershell
# Interactive mode (menu)
pwsh -File .\src\Unified-Toolkit.ps1

# Quick diagnostics
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action Triage

# Full suite
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action All
```

---

## 📋 Main Parameters

| Parameter | Type | Values | Default | Description |
|-----------|------|---------|---------|-------------|
| `-Mode` | String | `Menu`, `Run` | `Menu` | Interactive vs direct CLI |
| `-Action` | String | See table below | N/A | Which module to run (required with `-Mode Run`) |
| `-DryRun` | Switch | N/A | `$false` | Calculate only (Performance), don't delete |
| `-InternalDns` | String | IP or hostname | N/A | Internal DNS to test (Network) |
| `-OutPath` | String | Valid path | `C:\IT-Reports` | Where to save JSON reports |
| `-Force` | Switch | N/A | `$false` | Run network operations in RDP |

---

## 🛠️ Actions (Modules)

| Action | What it does | Requires Admin | Useful for |
|--------|--------------|----------------|------------|
| `Triage` | System inventory (HW, OS, network, disks) | No | New cases, initial documentation |
| `Performance` | Clean temp files (user + Windows) | Partial* | Low disk space, slow performance |
| `Network` | Test gateway, 8.8.8.8, internal DNS; flush/register DNS | No | "No internet", DNS issues, connectivity |
| `Services` | Restart Print Spooler, Audio, Windows Update | Yes | Printer not working, no audio, Windows Update stuck |
| `Admin` | Open Task Manager, Services, msconfig | No | Quick access to tools |
| `Report` | Export previous results to JSON | No | Documentation, escalation, evidence |
| `All` | Run Triage + Performance + Network + Services + Report | Yes | Full checkup, routine maintenance |

**\*Performance:** User temp doesn't require admin, Windows temp does.

---

## 💡 Common Use Cases

### 📞 "Computer is slow"
```powershell
# 1. Initial diagnostics
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Triage

# 2. Check disk space (Triage output)
# If low space on C: or user disk...

# 3. Dry-run to calculate how much will be freed
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Performance -DryRun

# 4. If >2GB and user approves, execute cleanup
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Performance
```

### 🌐 "No internet"
```powershell
# Full network diagnostics
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Network

# With corporate internal DNS
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Network -InternalDns 10.0.0.1
```

**Interpret output:**
- `Gateway: OK` + `Ping Google: FAIL` → ISP problem, firewall, or router blocking ICMP (normal at home)
- `Gateway: FAIL` → Local network problem (cable, switch, NIC)
- `Internal DNS: Not Reachable` → VPN problem, DNS server down, or firewall

### 🖨️ "Can't print"
```powershell
# Restart Print Spooler + other critical services
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Services
```

### 📋 Routine maintenance (ticket closing)
```powershell
# Full suite with automatic report
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action All

# File generated: C:\IT-Reports\SupportToolkit-Report-YYYYMMDD-HHMMSS.json
# Attach to ticket for documentation
```

---

## 🔒 Safety Validations

### Admin Detection
- **Performance (Windows Temp):** Requires admin, skips if not
- **Services:** Requires admin, fails if not
- **Everything else:** Works without admin

### RDP Detection
- **Network flush/register DNS:** Shows safety warning in RDP by default (can disconnect session)
- **Override:** Use `-Force` to suppress warning and execute anyway

```powershell
# In RDP session, this will show a safety warning
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Network

# Suppress warning and force execution (have backup plan to reconnect)
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Network -Force
```

---

## 📊 JSON Report Structure

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
    "Triage": { /* complete inventory */ },
    "Performance": { /* MB freed */ },
    "Network": { /* connectivity results */ },
    "Services": [ /* status of each service */ ]
  }
}
```

**Useful fields:**
- `Triage.Disks[]`: Array of all disks (Drive, Size_GB, Free_GB, PercentFree)
- `Performance.TotalCalculated_MB`: Space cleaned
- `Network.PingGoogle`: `true`/`false` (ping to 8.8.8.8)
- `Services[].Status`: "Running" / "Stopped"

---

## 🧪 Dry-Run Best Practice

**Always** dry-run Performance before executing:
```powershell
# 1. Calculate
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Performance -DryRun

# Output will show:
# User Temp:      1234.56 MB
# Windows Temp:   5678.90 MB
# Total:          6913.46 MB

# 2. If reasonable (<50% disk or <20GB), execute real
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Performance
```

---

## 📝 Logging

**Location:** `%TEMP%\SupportToolkit.log` (typically `C:\Users\<user>\AppData\Local\Temp\`)

**Format:**
```
2026-03-05 14:23:11 | INFO | IT Support Toolkit v1.0.1 Started
2026-03-05 14:23:12 | OK | Triage completed successfully
2026-03-05 14:23:45 | WARN | Not running as admin - skipping Windows Temp
2026-03-05 14:24:10 | ERROR | Failed to restart service: Spooler
```

**Levels:**
- `INFO`: Normal events
- `OK`: Successful operations
- `WARN`: Not critical but notable
- `ERROR`: Failures requiring attention

**Clear log:**
```powershell
Remove-Item $env:TEMP\SupportToolkit.log
```

---

## ⚠️ Common Troubleshooting

### "Running scripts is disabled on this system"
**Fix:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "This script requires PowerShell 7+"
**Fix:** Install pwsh: https://github.com/PowerShell/PowerShell/releases  
Verify: `pwsh -Version`

### Performance doesn't free much space
**Reasons:**
- Only cleans temp files (not Downloads, not Recycle Bin, not browser cache)
- User Temp: `C:\Users\<user>\AppData\Local\Temp`
- Windows Temp: `C:\Windows\Temp` (requires admin)

**Alternatives for more space:**
- Disk Cleanup (cleanmgr.exe)
- Storage Sense (Settings → System → Storage)
- Manual: Empty recycle bin, delete old Downloads

### Ping to Google (8.8.8.8) always fails
**Normal in:**
- Home: Router or firewall blocking outbound ICMP
- Corporate: Corporate firewall or proxy

**Verify:** If web browsing works, network is OK. ICMP != HTTP.

### BIOS Serial shows "Default string"
**Normal in:** Custom build or assembled PCs (ASUS, Gigabyte, MSI motherboards)  
**Reason:** OEM didn't program serial in BIOS

---

## 🗺️ Version and Roadmap

**Current:** v1.0.1 (March 5, 2026)

### v1.x - Current
- Basic diagnostics (inventory, network, services)
- Safe maintenance (temp cleanup with validations)
- JSON reports

### v2.x - Planned (Q2/Q3 2026)
- Collection of critical Windows events (crashes, app errors)
- HTML reports with charts
- Historical comparison

### v3.x - Security posture / signals (Vision)
- Basic security checks (Defender, Firewall, Updates)
- Best-effort signal collection (failed logins, account changes)
- **NOT EDR/detection** - only observation for learning

---

## 📜 Changelog

### v1.0.1 (2026-03-05)
- **Fix:** All MB/GB values rounded to 2 decimals
- **Improvement:** Service Status now shows text ("Running"/"Stopped") in JSON
- **Change:** Field `GoogleDNS` renamed to `PingGoogle`

### v1.0.0 (2026-03-03)
- Initial release
- 6 core modules + JSON reporting
- Safety-first design (admin/RDP detection)
- Multi-disk detection

---

## 🎓 About This Project

**Is:** Personal learning project to standardize L1/L2 support routines  
**Is not:** Enterprise solution, certified tool, or RMM replacement  

**Learn more:** [README.EN.md](../README.EN.md)

---

**Disclaimer:** Learning project. Test in non-prod first. No warranties. Use at your own discretion.
