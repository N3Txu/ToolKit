# IT Support Toolkit

> **Professional PowerShell 7 automation for Windows system diagnostics and maintenance**

**English | [Español](README.md)**

A comprehensive, safety-first toolkit designed for IT support professionals to automate routine troubleshooting and system maintenance tasks on Windows systems.

---

## 🎯 Purpose

This is a **personal project** created to streamline common IT support workflows with a focus on:

- **Safety First** - Detects admin privileges and remote sessions to prevent disruptive actions
- **Professional Logging** - Color-coded console output + persistent file logging
- **Structured Reporting** - Export results to JSON for documentation and analysis
- **Zero Dependencies** - Uses only native Windows commands and .NET
- **Dual Modes** - Interactive menu for on-site work, CLI parameters for automation

---

## ✨ Features

### 📊 System Triage (System Inventory)
Comprehensive system inventory including hardware info, Windows version, uptime, network configuration, and **automatic detection of all disks and partitions** with detailed information for each one (size, free space, usage percentage).

### ⚡ Performance Maintenance
Calculate and clean temporary files (user + system), with optional System File Checker execution.

### 🌐 Network Diagnostics
Auto-detect gateway, test connectivity (gateway, Google DNS, custom DNS), flush/register DNS cache.

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
Google DNS:     OK
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

**Safety Rule:** Potentially disruptive network operations (like `ipconfig /release`) are **blocked** in RDP/Unknown sessions unless you explicitly use `-Force`.

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
| `-Force` | Switch | Override safety blocks for disruptive actions | `-Force` |

For complete parameter documentation, see [docs/Commands.md](docs/Commands.md).

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
**A:** Yes! The toolkit detects RDP sessions and blocks potentially disruptive operations by default. Use `-Force` to override if needed.

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

## 📜 License

This is a **personal project** provided as-is without warranty. Use at your own risk.

You are free to:
- Use this toolkit for personal or professional IT support
- Modify and customize for your environment
- Share with colleagues

**Disclaimer:** Always test in non-production environments first. The author is not responsible for any system changes or issues arising from use of this toolkit.

---

## 🤝 Contributing

This is a personal learning project. If you have suggestions or find issues:
1. Test your changes thoroughly
2. Document any new features
3. Ensure compatibility with PowerShell 7+ and Windows 10/11

---

## 📚 Additional Resources

- **Detailed Command Reference:** [docs/Commands.md](docs/Commands.md)
- **PowerShell 7 Documentation:** https://docs.microsoft.com/powershell/
- **Windows CIM/WMI Classes:** https://docs.microsoft.com/windows/win32/cimwin32prov/

---

## 📌 Version

**Current Version:** 1.0.0  
**Release Date:** March 3, 2026  
**PowerShell Required:** 7.0+  
**Platform:** Windows 10/11, Windows Server 2016+
