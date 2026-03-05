# IT Support Toolkit - Commands Reference

**English | [Español](Commands.md)**

## Overview
This document provides a comprehensive reference for all commands, parameters, and modules available in the IT Support Toolkit.

---

## Table of Contents
1. [Command-Line Parameters](#command-line-parameters)
2. [Execution Modes](#execution-modes)
3. [Module Descriptions](#module-descriptions)
4. [Usage Examples](#usage-examples)
5. [Safety Features](#safety-features)
6. [Output & Logging](#output--logging)

---

## Command-Line Parameters

### `-Mode` (String)
**Values:** `Menu` | `Run`  
**Default:** `Menu`  
**Description:** Determines the execution mode of the toolkit.

- `Menu` - Launches interactive menu interface
- `Run` - Executes specified action non-interactively

**Examples:**
```powershell
.\Unified-Toolkit.ps1 -Mode Menu
.\Unified-Toolkit.ps1 -Mode Run -Action Triage
```

---

### `-Action` (String)
**Values:** `Triage` | `Performance` | `Network` | `Services` | `Admin` | `Report` | `All`  
**Required when:** `-Mode Run`  
**Description:** Specifies which module to execute in Run mode.

| Action | Description |
|--------|-------------|
| `Triage` | System inventory and information gathering |
| `Performance` | Temp file cleanup and system maintenance |
| `Network` | Network connectivity diagnostics |
| `Services` | Critical Windows service restart |
| `Admin` | Launch administrative tools |
| `Report` | Export results to JSON file |
| `All` | Execute Triage + Performance + Network + Services and auto-export report |

**Examples:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action Triage
.\Unified-Toolkit.ps1 -Mode Run -Action All
```

---

### `-DryRun` (Switch)
**Applies to:** Performance module only  
**Description:** Calculate cleanup size without actually deleting files.

**Examples:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action Performance -DryRun
```

---

### `-InternalDns` (String)
**Applies to:** Network module only  
**Description:** Specify an internal DNS server IP or hostname to test connectivity.

**Examples:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action Network -InternalDns 10.0.0.1
.\Unified-Toolkit.ps1 -Mode Run -Action Network -InternalDns "dc01.domain.local"
```

---

### `-OutPath` (String)
**Applies to:** Report module  
**Default:** `C:\IT-Reports`  
**Description:** Custom directory path for report file output.

**Examples:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action Report -OutPath "C:\Reports"
.\Unified-Toolkit.ps1 -Mode Run -Action All -OutPath "D:\IT-Logs"
```

---

### `-Force` (Switch)
**Applies to:** Network module  
**Description:** Enable potentially disruptive network actions even in remote (RDP) sessions.

**Safety Note:** By default, disruptive operations are blocked when running in RDP or unknown session types to prevent accidental disconnection.

**Examples:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action Network -Force
```

---

## Execution Modes

### Interactive Mode (Menu)
The default mode presenting a numbered menu with the following options:

```
[1] System Triage (Inventory)
[2] Performance Maintenance
[3] Network Diagnostics
[4] Service Healer
[5] Admin Shortcuts
[6] Run All
[7] Export Report
[0] Exit
```

**Features:**
- User-friendly interface
- Prompts for additional parameters when needed
- Option to return to menu or exit after each operation
- Displays session context (hostname, user, admin status, session type)
- **Dynamic colors:** Admin in green/red, Session in green/yellow

**Launch:**
```powershell
.\Unified-Toolkit.ps1
# or explicitly
.\Unified-Toolkit.ps1 -Mode Menu
```

---

### Non-Interactive Mode (Run)
Execute specific actions directly via command-line parameters. Ideal for automation, scripting, or remote execution.

**Launch:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action <ActionName> [additional parameters]
```

---

## Module Descriptions

### 1. System Triage (Invoke-Triage)
**Purpose:** Comprehensive system inventory and information gathering.

**Collects:**
- Hostname and current username
- Hardware manufacturer, model, and serial number
- Windows version and build number
- System uptime (days, hours, minutes)
- Active IPv4 addresses
- **Detection of all fixed disks** with detailed information:
  - Drive letter (C:, D:, etc.)
  - Volume label
  - File system (NTFS, FAT32, etc.)
  - Total size (GB)
  - Free space (GB)
  - Used space (GB)
  - Percentage free
- **Visual alerts by color:**
  - Green: >20% free (optimal)
  - Yellow: 10-20% free (caution)
  - Red: <10% free (critical)

**Requirements:** None (works without admin privileges)

**Output:** PSCustomObject with all collected data

**Use Cases:**
- Initial troubleshooting
- System documentation
- Pre-change baseline

**Example:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action Triage
```

**Example output:**
```
Disks:
  C: [Windows] - NTFS - 125.43 GB free of 500.00 GB (25.1% free)
  D: [Data] - NTFS - 850.20 GB free of 2000.00 GB (42.5% free)
  E: [Backup] - NTFS - 50.45 GB free of 1000.00 GB (5.0% free)
```

---

### 2. Performance Maintenance (Invoke-Performance)
**Purpose:** Clean temporary files and optionally run System File Checker.

**Actions:**
- Calculate size of `%TEMP%` (user temp folder)
- Calculate size of `C:\Windows\Temp` (requires admin)
- Delete temp files (unless `-DryRun` specified)
- Optional: Run `sfc /scannow` (interactive mode only, requires admin)

**Parameters:**
- `-DryRun` - Calculate only, don't delete

**Safety Features:**
- Handles locked files gracefully (continues on error)
- SFC prompt warns about ~15 minute runtime

**Requirements:**
- Standard user: Can clean user temp only
- Administrator: Can clean both user and Windows temp

**Output:** PSCustomObject with MB calculated/freed and SFC status

**Examples:**
```powershell
# Dry run to see what would be cleaned
.\Unified-Toolkit.ps1 -Mode Run -Action Performance -DryRun

# Actually clean files
.\Unified-Toolkit.ps1 -Mode Run -Action Performance
```

---

### 3. Network Diagnostics (Invoke-Network)
**Purpose:** Test network connectivity and refresh DNS configuration.

**Actions:**
1. Auto-detect default gateway
2. Test connectivity to:
   - Default gateway
   - Google DNS (8.8.8.8)
   - Internal DNS (if `-InternalDns` provided)
3. Execute `ipconfig /flushdns`
4. Execute `ipconfig /registerdns`

**Parameters:**
- `-InternalDns <IP/Host>` - Additional DNS server to test
- `-Force` - Override safety blocks for disruptive operations

**Safety Features:**
- Detects RDP/Unknown sessions
- Blocks disruptive operations (like `/release`) without `-Force`
- Warns user about potential disconnection risks

**Requirements:** None (standard user can run)

**Output:** PSCustomObject with connectivity results and DNS operation status

**Important Note:** In home environments, the ping to Google DNS (8.8.8.8) may fail due to Windows Firewall or router blocking outbound ICMP. This is normal if web browsing works correctly.

**Examples:**
```powershell
# Basic network test
.\Unified-Toolkit.ps1 -Mode Run -Action Network

# Test with internal DNS
.\Unified-Toolkit.ps1 -Mode Run -Action Network -InternalDns 10.0.0.1

# Override safety (use cautiously in RDP)
.\Unified-Toolkit.ps1 -Mode Run -Action Network -Force
```

---

### 4. Service Healer (Invoke-ServiceHealer)
**Purpose:** Restart critical Windows services that commonly fail.

**Services Targeted:**
- **Spooler** - Print service
- **Audiosrv** - Windows Audio
- **wuauserv** - Windows Update

**Behavior:**
- If service is running → Restart it
- If service is stopped → Start it
- If service fails → Log error and continue

**Safety Features:**
- Handles service dependencies automatically
- Continues on error (doesn't stop entire process)

**Requirements:** May require admin for some services

**Output:** Array of PSCustomObjects (one per service) with status and action taken

**Example:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action Services
```

---

### 5. Admin Shortcuts (Invoke-AdminShortcuts)
**Purpose:** Quick launcher for common administrative tools.

**Tools Launched:**
- **Task Manager** (`taskmgr.exe`)
- **Services** (`services.msc`)
- **System Configuration** (`msconfig.exe`)

**Behavior:** Best-effort launch; continues on error

**Requirements:** None (tools may prompt for elevation if needed)

**Output:** Array of PSCustomObjects (one per tool) with launch status

**Example:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action Admin
```

---

### 6. Export Report (Export-Report)
**Purpose:** Export all collected results to a structured JSON file.

**Report Contents:**
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

**File Naming:** `SupportToolkit-Report-YYYYMMDD-HHMMSS.json`

**Default Location:** `C:\IT-Reports`

**Advantages of C:\IT-Reports:**
- ✅ Not synced with OneDrive (faster, no conflicts)
- ✅ Professional standard location for IT support
- ✅ Easy to find on any corporate PC
- ✅ Not deleted with temp folder cleanups
- ✅ Automatic folder creation if it doesn't exist

**Parameters:**
- `-OutPath <Path>` - Custom output directory

**Examples:**
```powershell
# Export to C:\IT-Reports (default)
.\Unified-Toolkit.ps1 -Mode Run -Action Report

# Custom location
.\Unified-Toolkit.ps1 -Mode Run -Action Report -OutPath "D:\Custom-Reports"
```

---

### 7. Run All
**Purpose:** Execute all diagnostic modules in sequence and auto-export report.

**Execution Order:**
1. System Triage
2. Performance Maintenance
3. Network Diagnostics
4. Service Healer
5. Auto-Export Report

**Note:** Does NOT include Admin Shortcuts (tool launching)

**Example:**
```powershell
.\Unified-Toolkit.ps1 -Mode Run -Action All
.\Unified-Toolkit.ps1 -Mode Run -Action All -DryRun -OutPath "C:\Reports"
```

---

## Usage Examples

### Basic Interactive Use
```powershell
# Start menu
.\Unified-Toolkit.ps1

# Follow prompts, select options 1-7
```

---

### Quick System Check
```powershell
# Get system info only
.\Unified-Toolkit.ps1 -Mode Run -Action Triage
```

---

### Pre-Maintenance Dry Run
```powershell
# See what would be cleaned without deleting
.\Unified-Toolkit.ps1 -Mode Run -Action Performance -DryRun
```

---

### Complete Diagnostic Suite
```powershell
# Run everything with custom DNS and output path
.\Unified-Toolkit.ps1 -Mode Run -Action All -InternalDns 10.0.0.1 -OutPath "D:\Reports"
```

---

### Network Troubleshooting
```powershell
# Basic network test
.\Unified-Toolkit.ps1 -Mode Run -Action Network

# With internal DNS
.\Unified-Toolkit.ps1 -Mode Run -Action Network -InternalDns 192.168.1.1
```

---

### Service Recovery
```powershell
# Restart critical services
.\Unified-Toolkit.ps1 -Mode Run -Action Services
```

---

### Automated Reporting
```powershell
# Run diagnostics and save report to network share
.\Unified-Toolkit.ps1 -Mode Run -Action All -OutPath "\\fileserver\IT-Reports"
```

---

## Safety Features

### Administrator Detection
- Automatically detects if running with admin privileges
- Logs admin status
- Restricts certain operations when non-admin

### Remote Session Detection
- Identifies if session is Local, RDP, or Unknown
- Blocks potentially disruptive network operations in RDP sessions
- Can be overridden with `-Force` parameter

### Error Handling
- Try/catch blocks around all critical operations
- Continues on non-fatal errors
- Logs all errors for troubleshooting

### File Deletion Safety
- Handles locked files gracefully
- Skips files that cannot be deleted
- Reports actual freed space (not just calculated)

---

## Output & Logging

### Console Output
Color-coded messages for quick visual scanning:
- **Green (OK)** - Successful operations
- **Cyan (INFO)** - Informational messages, field labels
- **Yellow (WARN)** - Warnings, non-critical issues, variable values
- **Red (ERROR)** - Errors, failed operations

**Interface Enhancement:** In the interactive menu, system information uses differentiated colors:
- Labels (Computer, User) in **Cyan**
- Variable values (hostname, username) in **Yellow**
- Admin status with **dynamic color** (Green for YES / Red for NO)
- Session type with **dynamic color** (Green for Local / Yellow for RDP)

### Log File
**Location:** `%TEMP%\SupportToolkit.log`

**Format:**
```
YYYY-MM-DD HH:mm:ss | LEVEL | Message
2026-03-05 00:07:15 | INFO | IT Support Toolkit v1.0.0 Started
2026-03-05 00:07:16 | OK | Triage completed successfully
2026-03-05 00:07:45 | WARN | Not running as admin - skipping Windows Temp
```

**Persistence:** Appends to existing log file (doesn't overwrite)

### Transcript
**Location:** `%TEMP%\SupportToolkit-Transcript-YYYYMMDD-HHMMSS.txt`

**Contents:** Complete PowerShell session output including all commands and results

**Note:** Transcript may fail in some environments; toolkit continues anyway

---

## Requirements

### System Requirements
- **OS:** Windows 10/11 or Windows Server 2016+
- **PowerShell:** Version 7.0 or higher (pwsh.exe)
- **Permissions:** Standard user (some features require admin)

### No External Dependencies
- Uses only built-in Windows commands
- Requires no additional modules or packages
- Portable - runs from any location

---

## Important Notes on Environment Differences

### Corporate vs. Personal Environments

The toolkit is primarily designed for corporate environments, but works on personal PCs with some expected differences:

#### **BIOS Serial "Default string"**
- **Normal on:** Custom builds, assembled PCs, generic motherboards (ASUS, Gigabyte, MSI)
- **Reason:** Manufacturers leave placeholder values that OEMs should program
- **In corporate:** Brand PCs (Dell, HP, Lenovo) have real programmed serials

#### **Google DNS Ping (8.8.8.8) Failure**
- **Normal on:** Home environments with Windows Firewall or router blocking outbound ICMP
- **Check:** If web browsing works, connectivity is OK
- **In corporate:** May have corporate firewall or proxy requirement

These differences are **completely normal** and do not indicate system or toolkit issues.

---

## Version History

### v1.0.0 (2026-03-03)
- Initial release
- 6 core modules (Triage, Performance, Network, Services, Admin, Report)
- Interactive menu and non-interactive modes
- Safety-first design with RDP detection
- Professional logging and JSON reporting
- Multi-disk detection and detailed information
- Professional report location (C:\IT-Reports)
- Dynamic colors in interface

---

## Support & Feedback
This is a personal project designed for IT support automation. Use at your own risk in production environments. Always test in non-production systems first.

For issues or suggestions, review the script source code in `src/Unified-Toolkit.ps1`.
