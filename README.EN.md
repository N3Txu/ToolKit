# IT Support Toolkit

> **Personal learning project: Automating IT support routines with PowerShell 7**

**English | [Español](README.md)**

A toolkit developed as an MVP to standardize my diagnostic and maintenance routines on Windows systems during my L1/L2 IT support learning journey.

---

## 🎯 About This Project

This is a **personal learning project** created to:

- **Standardize** my workflow for repetitive IT support tasks
- **Practice** professional scripting with PowerShell 7
- **Document** my processes for future reference
- **Minimize errors** through automation and validations

**Not an enterprise solution** - it's an honest tool I use to improve my efficiency and learn best practices while working on real support cases.

---

## 🎓 Design Decisions

### Why PowerShell 7?
- **Structured objects**: Cleaner data handling than text parsing
- **Native JSON**: `ConvertTo-Json` for structured reports
- **Cross-platform**: Though this toolkit is Windows-only, pwsh is portable

### Why zero external dependencies?
- **Portability**: Can copy script to USB or run in remote sessions
- **Simplicity**: No module management, versions, or installers
- **Learning**: Forces use of native cmdlets and CIM/WMI classes

### Why "safety-first"?
- **Human errors**: Detect admin/RDP before dangerous actions
- **Dry-run mode**: Calculate impact before deleting files
- **Logging**: Audit trail of all actions for troubleshooting

---

## 📏 Project Scope

### ✅ What it does (v1.x)
- Basic system diagnostics (inventory, network, services)
- Safe maintenance (temp file cleanup with validations)
- Structured JSON reports for documentation

### ⏳ Planned (v2.x)
- Optional collection of critical Windows events (Application, System)
- Reporting improvements (HTML, historical report comparison)
- Stability troubleshooting (crashes, freezes, blue screens)

### 🔮 Vision (v3.x - Security posture / signals)
- Basic security posture checks (Windows Defender, Firewall, Updates)
- Best-effort collection of basic signals for analysis (failed logins, account changes)
- **NOT detection/EDR**: Only observation and collection for learning

### ❌ Out of scope
- Automatic malware remediation
- Deep forensic analysis
- Active Directory management
- System deployment or new system configuration

---

## ✨ Features

### 📊 System Triage (System Inventory)
Comprehensive system inventory including hardware info, Windows version, uptime, network configuration, and **automatic detection of all disks and partitions** with detailed information for each one (size, free space, usage percentage).

### ⚡ Performance Maintenance
Calculate and clean temporary files (user + system), with optional System File Checker execution.

### 🌐 Network Diagnostics
Auto-detect gateway, test connectivity (gateway, 8.8.8.8, custom DNS), flush/register DNS cache.

### 🔧 Service Healer
Automatically restart critical Windows services (Print Spooler, Audio, Windows Update).

### 🛠️ Admin Shortcuts
Quick launcher for Task Manager, Services, and System Configuration utilities.

### 📄 JSON Reporting
Export all diagnostic results with metadata (timestamp, hostname, user, session type) to structured JSON files at **C:\IT-Reports** (professional location not synced with OneDrive).

---

## 🚀 Quick Start

### Prerequisites
- **Windows 10/11** or **Windows Server 2016+**
- **PowerShell 7+** (`pwsh.exe`) - [Download here](https://github.com/PowerShell/PowerShell/releases)
- Some features require **Administrator privileges**

### Installation
1. Download or clone this repository
2. Navigate to the project folder
3. Run the script with PowerShell 7

### Basic Usage

#### Interactive Mode (Default)
```powershell
pwsh -File .\src\Unified-Toolkit.ps1
```

This launches a menu where you can select operations interactively.

#### Non-Interactive Mode
```powershell
# Run specific action
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action Triage

# Run all diagnostics
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action All
```

---

## 📖 Usage Examples

### Example 1: Interactive Menu
```powershell
pwsh -File .\src\Unified-Toolkit.ps1
```
Navigate through the menu, select options, and follow prompts.

---

### Example 2: Quick System Inventory
```powershell
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action Triage
```
**Output:**
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
  D: [Data] - NTFS - 850.20 GB free of 2000.00 GB (42.5% free)
-----------------------------
```

---

### Example 3: Temp File Cleanup (Dry Run)
```powershell
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action Performance -DryRun
```
**Output:**
```
--- Performance Report (Dry Run) ---
User Temp:      342.50 MB
Windows Temp:   1024.75 MB
Total:          1367.25 MB
------------------------------------
```

---

### Example 4: Network Diagnostics with Custom DNS
```powershell
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action Network -InternalDns 10.0.0.1
```
**Output:**
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

### Example 5: Complete Diagnostic Suite
```powershell
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action All
```
Executes all modules sequentially and exports a consolidated JSON report to `C:\IT-Reports\`.

---

### Example 6: Service Recovery
```powershell
pwsh -File .\src\Unified-Toolkit.ps1 -Mode Run -Action Services
```
**Output:**
```
--- Service Healer Results ---
Spooler: Restarted
Audiosrv: Started
wuauserv: Restarted
------------------------------
```

---

## 🛡️ Safety Features

### Administrator Detection
The toolkit automatically detects whether it's running with elevated privileges:
- Logs admin status on startup
- Restricts certain operations when non-admin
- Displays admin status in interactive menu with **dynamic colors** (green for YES, red for NO)

### Remote Session Detection
Identifies if the session is:
- **Local** - Direct console access (green)
- **RDP** - Remote Desktop connection (yellow)
- **Unknown** - Cannot determine

**Safety Rule:** Potentially disruptive network operations (like `ipconfig /release`) **show a safety warning** in RDP/Unknown sessions. Use `-Force` explicitly to suppress the warning and execute anyway.

### Error Handling
- Comprehensive try/catch blocks around all operations
- Continues on non-fatal errors
- All errors logged for troubleshooting

### File Deletion Safety
- Handles locked files gracefully
- Skips files that cannot be deleted (in use)
- Reports actual space freed (not just estimated)

---

## 📁 Project Structure

```
IT-Support-Toolkit/
│
├── src/
│   └── Unified-Toolkit.ps1       # Main script (all modules included)
│
├── docs/
│   └── Commands.md                # Detailed command reference
│
└── README.md                      # This file
```

---

## 🔧 Available Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `-Mode` | String | `Menu` (default) or `Run` | `-Mode Run` |
| `-Action` | String | Module to execute: `Triage`, `Performance`, `Network`, `Services`, `Admin`, `Report`, `All` | `-Action Triage` |
| `-DryRun` | Switch | Performance: calculate cleanup size without deleting | `-DryRun` |
| `-InternalDns` | String | Network: custom DNS server to test | `-InternalDns 10.0.0.1` |
| `-OutPath` | String | Report: custom output directory (default: C:\IT-Reports) | `-OutPath "C:\Reports"` |
| `-Force` | Switch | Network: suppress safety warnings in RDP for disruptive actions | `-Force` |

For complete parameter documentation, see [docs/Commands.EN.md](docs/Commands.EN.md).

---

## 📊 Output & Logging

### Console Output
Enhanced color-coding for quick visual scanning:
- 🟢 **Green (OK)** - Successful operations
- 🔵 **Cyan (INFO)** - Informational messages, field labels
- 🟡 **Yellow (WARN)** - Warnings, non-critical issues, variable values
- 🔴 **Red (ERROR)** - Errors, failed operations

**Interface Enhancement:** In the interactive menu, system information uses differentiated colors:
- Labels (Computer, User) in **Cyan**
- Variable values in **Yellow**
- Admin status with dynamic color (Green/Red)
- Session type with dynamic color (Green/Yellow)

### Log File
**Location:** `%TEMP%\SupportToolkit.log`

**Format:**
```
YYYY-MM-DD HH:mm:ss | LEVEL | Message
```

**Persistence:** Appends to existing log (doesn't overwrite)

### Transcript
**Location:** `%TEMP%\SupportToolkit-Transcript-YYYYMMDD-HHMMSS.txt`

Complete PowerShell session capture (if supported by environment).

### JSON Report
**Location:** `C:\IT-Reports` (default) or custom `-OutPath`

**Filename:** `SupportToolkit-Report-YYYYMMDD-HHMMSS.json`

**Advantages of C:\IT-Reports:**
- ✅ Not synced with OneDrive (faster, no conflicts)
- ✅ Professional standard location for IT support
- ✅ Easy to find on any corporate PC
- ✅ Not deleted with temp folder cleanups
- ✅ Automatic folder creation if it doesn't exist

**Structure:**
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

---

## 🎓 Use Cases

### Help Desk Technician
```powershell
# Quick system check during a support call
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Triage
```

### System Administrator
```powershell
# Scheduled maintenance automation
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Performance
```

### Network Troubleshooting
```powershell
# Diagnose connectivity issues
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Network -InternalDns dc01.domain.local
```

### Pre-Change Documentation
```powershell
# Capture system state before changes
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action All -OutPath "\\fileserver\Pre-Change-Docs"
```

### Service Recovery
```powershell
# Fix common service failures
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action Services
```

---

## ⚙️ Advanced Usage

### Remote Execution (WinRM/PSSession)
```powershell
Invoke-Command -ComputerName REMOTE-PC -FilePath .\src\Unified-Toolkit.ps1 -ArgumentList '-Mode', 'Run', '-Action', 'Triage'
```

### Scheduled Task
Create a scheduled task to run maintenance weekly:
```powershell
$action = New-ScheduledTaskAction -Execute 'pwsh.exe' -Argument '-File "C:\Scripts\Unified-Toolkit.ps1" -Mode Run -Action Performance'
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am
Register-ScheduledTask -TaskName "Weekly Maintenance" -Action $action -Trigger $trigger -RunLevel Highest
```

### Custom Logging Directory (via environment variable)
```powershell
# Modify $env:TEMP before running to change log location
$env:TEMP = "C:\CustomLogs"
pwsh .\src\Unified-Toolkit.ps1 -Mode Run -Action All
```

---

## ❓ FAQ

### Q: Do I need Administrator privileges?
**A:** Not for all features. Triage, Network (basic), and Admin Shortcuts work without admin. Performance (Windows Temp cleanup) and some Service operations require admin.

### Q: Can I run this on a remote session?
**A:** Yes! The toolkit detects RDP sessions and shows warnings for potentially disruptive operations by default. Use `-Force` to suppress the warning if needed.

### Q: What if `-DryRun` shows less space than expected?
**A:** Some files may be locked or hidden. The script calculates based on accessible files only.

### Q: Why does the transcript sometimes fail?
**A:** Some environments (restricted sessions, specific PS configurations) don't support transcripts. The toolkit logs a warning and continues.

### Q: Can I add custom modules?
**A:** Yes! The script structure is modular. Add new `Invoke-*` functions and integrate them into the menu/parameter logic.

### Q: Does this work on PowerShell 5.1?
**A:** No. This toolkit requires **PowerShell 7+** (`pwsh.exe`). Many features rely on cross-platform cmdlets and modern syntax.

### Q: Why does the BIOS serial show "Default string"?
**A:** This is **normal on custom builds or assembled PCs**. Motherboard manufacturers (ASUS, Gigabyte, MSI) leave placeholder values that OEMs should program. On corporate brand PCs (Dell, HP, Lenovo) you'll see real serials.

### Q: Why does the ping to Google DNS (8.8.8.8) fail?
**A:** In **home environments**, Windows Firewall or your router may block outbound ping (ICMP) for security. In **corporate environments**, there may be corporate firewall or proxy. If your web browsing works, your connectivity is OK.

---

## ⚠️ Known Limitations & Non-goals

### 🚫 Out of Scope (By Design)
- **Automatic malware remediation**: Not a security tool
- **Deep forensic analysis**: Only basic system diagnostics
- **Active Directory management**: Doesn't touch domain policies
- **System deployment**: Not a provisioning tool
- **Aggressive disk cleanup**: Only temp files, not Downloads/Recycle/Browser cache

### 🚧 Current Limitations (v1.x)

**Performance/Cleanup:**
- Only cleans temporary files (User Temp + Windows Temp)
- Doesn't clean: Downloads, Recycle Bin, browser caches, Windows Update backup
- Files in use are skipped (no forced deletion)
- No pre-cleanup integrity check (uses SFC optionally post-cleanup)

**Network Diagnostics:**
- Ping to 8.8.8.8 may fail in firewall environments (normal, not an error)
- Doesn't diagnose proxy configuration
- Doesn't validate SSL/TLS certificates
- Doesn't test specific ports (ICMP only)

**Service Healer:**
- Hardcoded service list (Spooler, Audio, Windows Update)
- Doesn't detect custom/third-party services
- Doesn't validate service dependencies
- Simple restart (no root cause troubleshooting)

**Reporting:**
- JSON only (no HTML, no CSV)
- No historical comparison (each report is independent)
- No automatic sending (email, webhook, etc.)

**Environment:**
- Windows 10/11 and Server 2016+ only (no legacy)
- Requires PowerShell 7+ (not compatible with 5.1)
- Native WMI/CIM only (no third-party modules)
- No localization (output in English, docs in EN/ES)

### 📚 Why These Limitations

**Philosophy:** This toolkit is an **educational MVP**, not a commercial product. Limitations are **intentional** to:

1. **Maintain simplicity**: Readable code for learning
2. **Zero dependencies**: Portability without installation
3. **Safety first**: Avoid dangerous over-automation
4. **Controlled scope**: Finish v1.x before complicating

**Roadmap:** Some limitations will be addressed in v2.x (HTML reports, event collection), others are permanent by design.

---

## 🛠️ Troubleshooting

### "Running scripts is disabled on this system"
**Solution:** Adjust execution policy (as admin):
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "This script requires PowerShell 7+"
**Solution:** Install PowerShell 7: https://github.com/PowerShell/PowerShell/releases

### "Failed to start transcript"
**Expected:** Transcripts may fail in some environments. The toolkit logs a warning and continues normally.

### Log file is huge
**Solution:** The log file appends indefinitely. Manually delete `%TEMP%\SupportToolkit.log` periodically, or implement log rotation.

---

## 📜 License and Disclaimer

This is a **personal learning project** provided "as-is" without warranties.

**Freedoms:**
- ✅ Use for personal learning or professional work
- ✅ Modify and adapt to your environment
- ✅ Share with colleagues or the community

**Responsibility:**
- ⚠️ **Test in non-production environments first**
- ⚠️ Review code before running with admin privileges
- ⚠️ Author is not responsible for unwanted system changes

**Philosophy:** This toolkit reflects my ongoing learning. It may have bugs, suboptimal decisions, or uncovered edge cases. **Use as reference, not as enterprise solution.**

---

## 🤝 Contributions

As a learning project, I appreciate:
- 🐛 Bug reports with context (OS, PowerShell version, output)
- 💡 Best practice suggestions (especially from seniors)
- 📖 Documentation improvements
- ⚠️ Pointing out antipatterns or unsafe patterns

**Don't expect:** 24/7 support, frequent releases, or backward compatibility. It's public learning.

---

## 📚 Additional Resources

- **Detailed Command Reference:** [docs/Commands.EN.md](docs/Commands.EN.md)
- **PowerShell 7 Documentation:** https://docs.microsoft.com/powershell/
- **Windows CIM/WMI Classes:** https://docs.microsoft.com/windows/win32/cimwin32prov/

---

## 📌 Version and Roadmap

**Current Version:** 1.0.1  
**Release Date:** March 5, 2026  
**PowerShell Required:** 7.0+  
**Platform:** Windows 10/11, Windows Server 2016+

### 🗺️ Roadmap

#### v1.x - Foundation (Current)
- ✅ Basic system diagnostics
- ✅ Safe temporary file maintenance
- ✅ Network diagnostics
- ✅ Critical service healer
- ✅ Structured JSON reports

#### v2.x - Advanced Troubleshooting (Planned)
- 📋 Collection of critical Windows events (crashes, application errors)
- 📊 HTML reports with basic charts
- 🔄 Historical report comparison
- 🧹 Disk usage analysis (large folders, duplicates)

#### v3.x - Security posture / signals (Vision)
- 🛡️ Basic posture checks (Defender, Firewall, Updates)
- 🔐 Best-effort signal collection (login attempts, user changes)
- 📝 Basic compliance reporting
- ⚠️ **Note**: Only observation/reporting, NOT active detection or EDR

### 📜 Changelog

#### v1.0.1 (2026-03-05)
- **Precision improvements**: All MB/GB values rounded to 2 decimal places
- **Enhanced JSON format**: Service Status now displays text (Running/Stopped) instead of numeric codes (1/4)
- **Field rename**: `GoogleDNS` → `PingGoogle` for better clarity in Network Diagnostics
- **Fix**: Corrected floating-point precision issues in `TotalCalculated_MB`

#### v1.0.0 (2026-03-03)
- Initial release
- 6 main modules (Triage, Performance, Network, Services, Admin, Report)
- Interactive and non-interactive modes
- Safety-first design with RDP detection
- Professional logging and JSON reporting
- Multi-disk detection with detailed information
- Professional report location (C:\IT-Reports)

---

## 🙏 Learning Notes

This project has taught me:
- PowerShell CLI design (parameters, validation, help)
- PowerShell object handling vs text parsing
- Importance of logging and error handling in production scripts
- Safety patterns for destructive operations
- Technical documentation for end users

**Happy troubleshooting!** 🚀
