<#
.SYNOPSIS
    IT Support Toolkit - Automated system diagnostics and maintenance for Windows
.DESCRIPTION
    Professional PowerShell 7 script for IT support tasks with safety-first approach,
    robust logging, and JSON reporting.
.PARAMETER Mode
    Execution mode: Menu (interactive) or Run (non-interactive). Default: Menu
.PARAMETER Action
    Action to execute in Run mode: Triage|Performance|Network|Services|Admin|Report|All
.PARAMETER DryRun
    Performance module only - calculate cleanup size without deleting files
.PARAMETER InternalDns
    Optional internal DNS server IP/hostname to test (Network module)
.PARAMETER OutPath
    Optional custom path for report output (Report module)
.PARAMETER Force
    Enable potentially disruptive actions (e.g., network operations in RDP sessions)
.EXAMPLE
    .\Unified-Toolkit.ps1
    Starts interactive menu mode
.EXAMPLE
    .\Unified-Toolkit.ps1 -Mode Run -Action Triage
    Runs system triage in non-interactive mode
.EXAMPLE
    .\Unified-Toolkit.ps1 -Mode Run -Action Performance -DryRun
    Calculates cleanup size without deleting files
.EXAMPLE
    .\Unified-Toolkit.ps1 -Mode Run -Action Network -InternalDns 10.0.0.1
    Runs network diagnostics including internal DNS test
.EXAMPLE
    .\Unified-Toolkit.ps1 -Mode Run -Action All
    Executes all diagnostic modules
.NOTES
    Version: 1.0.1
    Author: IT Support Team
    Requires: PowerShell 7+ (pwsh)
    Platform: Windows only
#>

#Requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('Menu', 'Run')]
    [string]$Mode = 'Menu',

    [Parameter()]
    [ValidateSet('Triage', 'Performance', 'Network', 'Services', 'Admin', 'Report', 'All')]
    [string]$Action,

    [Parameter()]
    [switch]$DryRun,

    [Parameter()]
    [string]$InternalDns,

    [Parameter()]
    [string]$OutPath,

    [Parameter()]
    [switch]$Force
)

# ============================================================================
# GLOBAL VARIABLES
# ============================================================================
$script:ToolkitVersion = "1.0.1"
$script:LogFile = Join-Path $env:TEMP "SupportToolkit.log"
$script:SessionResults = @{}

# ============================================================================
# LOGGING FUNCTION
# ============================================================================
function Write-Log {
    <#
    .SYNOPSIS
        Write log messages to console (colored) and log file
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [Parameter()]
        [ValidateSet('OK', 'INFO', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp | $Level | $Message"

    # Console output with colors
    $color = switch ($Level) {
        'OK'    { 'Green' }
        'WARN'  { 'Yellow' }
        'ERROR' { 'Red' }
        'INFO'  { 'Cyan' }
    }
    Write-Host $logEntry -ForegroundColor $color

    # File output
    try {
        Add-Content -Path $script:LogFile -Value $logEntry -ErrorAction Stop
    }
    catch {
        Write-Host "WARNING: Could not write to log file: $_" -ForegroundColor Yellow
    }
}

# ============================================================================
# ENVIRONMENT DETECTION FUNCTIONS
# ============================================================================
function Test-IsAdmin {
    <#
    .SYNOPSIS
        Check if current session has administrator privileges
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param()

    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = [Security.Principal.WindowsPrincipal]$identity
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch {
        Write-Log "Failed to determine admin status: $_" -Level WARN
        return $false
    }
}

function Get-RemoteSessionState {
    <#
    .SYNOPSIS
        Detect if running in local or remote (RDP) session
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()

    try {
        # Method 1: Check environment variables
        if ($env:SESSIONNAME -match '^RDP-') {
            return 'RDP'
        }

        # Method 2: Check for RDP-specific environment variables
        if ($env:CLIENTNAME) {
            return 'RDP'
        }

        # Method 3: Check SessionName
        if ($env:SESSIONNAME -eq 'Console') {
            return 'Local'
        }

        # Method 4: Use WMI to check session type
        $session = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction SilentlyContinue
        if ($session -and $session.UserName) {
            # Check current process session
            $processSession = Get-Process -Id $PID | Select-Object -ExpandProperty SessionId
            if ($processSession -eq 0) {
                return 'Local'
            }
            # Session ID > 0 typically indicates RDP
            if ($processSession -gt 1) {
                return 'RDP'
            }
        }

        # Default to Local if no RDP indicators found
        return 'Local'
    }
    catch {
        Write-Log "Failed to determine session type: $_" -Level WARN
        return 'Unknown'
    }
}

# ============================================================================
# MODULE 1: SYSTEM TRIAGE
# ============================================================================
function Invoke-Triage {
    <#
    .SYNOPSIS
        System Inventory - Collect comprehensive system information
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    Write-Log "=== Starting System Triage ===" -Level INFO

    $result = [PSCustomObject]@{
        Hostname        = $env:COMPUTERNAME
        Username        = $env:USERNAME
        Manufacturer    = 'Unknown'
        Model           = 'Unknown'
        SerialNumber    = 'Unknown'
        WindowsVersion  = 'Unknown'
        Build           = 'Unknown'
        Uptime          = 'Unknown'
        IPv4Addresses   = @()
        Disks           = @()
        Status          = 'Success'
        ErrorDetails    = $null
    }

    try {
        # Computer System Info
        $cs = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        $result.Manufacturer = $cs.Manufacturer
        $result.Model = $cs.Model

        # BIOS Info
        $bios = Get-CimInstance -ClassName Win32_BIOS -ErrorAction Stop
        $result.SerialNumber = $bios.SerialNumber

        # OS Info
        $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
        $result.WindowsVersion = $os.Caption
        $result.Build = $os.BuildNumber
        
        # Uptime
        $bootTime = $os.LastBootUpTime
        $uptime = (Get-Date) - $bootTime
        $result.Uptime = "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes

        # Network - Get active IPv4 addresses
        $adapters = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -ErrorAction Stop |
                    Where-Object { $_.IPEnabled -eq $true }
        foreach ($adapter in $adapters) {
            if ($adapter.IPAddress) {
                $ipv4 = $adapter.IPAddress | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' }
                $result.IPv4Addresses += $ipv4
            }
        }

        # Disk Space - All logical disks (fixed drives only)
        $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction Stop
        foreach ($disk in $disks) {
            $diskInfo = [PSCustomObject]@{
                Drive       = $disk.DeviceID
                Label       = if ($disk.VolumeName) { $disk.VolumeName } else { 'No Label' }
                FileSystem  = $disk.FileSystem
                Size_GB     = [math]::Round($disk.Size / 1GB, 2)
                Free_GB     = [math]::Round($disk.FreeSpace / 1GB, 2)
                Used_GB     = [math]::Round(($disk.Size - $disk.FreeSpace) / 1GB, 2)
                PercentFree = if ($disk.Size -gt 0) { [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 1) } else { 0 }
            }
            $result.Disks += $diskInfo
            Write-Log "Disk $($disk.DeviceID): $($diskInfo.Free_GB) GB free of $($diskInfo.Size_GB) GB" -Level INFO
        }

        Write-Log "Triage completed successfully" -Level OK
    }
    catch {
        $result.Status = 'Failed'
        $result.ErrorDetails = $_.Exception.Message
        Write-Log "Triage encountered error: $_" -Level ERROR
    }

    # Display summary
    Write-Host "`n--- System Triage Summary ---" -ForegroundColor Cyan
    Write-Host "Hostname:       $($result.Hostname)"
    Write-Host "User:           $($result.Username)"
    Write-Host "Manufacturer:   $($result.Manufacturer)"
    Write-Host "Model:          $($result.Model)"
    Write-Host "Serial:         $($result.SerialNumber)"
    Write-Host "Windows:        $($result.WindowsVersion)"
    Write-Host "Build:          $($result.Build)"
    Write-Host "Uptime:         $($result.Uptime)"
    Write-Host "IPv4:           $($result.IPv4Addresses -join ', ')"
    Write-Host ""
    Write-Host "Disks:" -ForegroundColor Yellow
    foreach ($disk in $result.Disks) {
        $percentColor = if ($disk.PercentFree -lt 10) { 'Red' } 
                    elseif ($disk.PercentFree -lt 20) { 'Yellow' }
                    else { 'Green' }
        Write-Host "  $($disk.Drive) [$($disk.Label)]" -NoNewline
        Write-Host " - $($disk.FileSystem) - " -NoNewline
        Write-Host "$($disk.Free_GB) GB" -ForegroundColor $percentColor -NoNewline
        Write-Host " free of $($disk.Size_GB) GB ($($disk.PercentFree)% free)"
    }
    Write-Host "-----------------------------`n"

    return $result
}

# ============================================================================
# MODULE 2: PERFORMANCE / MAINTENANCE
# ============================================================================
function Invoke-Performance {
    <#
    .SYNOPSIS
        System Maintenance - Clean temp files and optionally run SFC
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter()]
        [switch]$DryRun,

        [Parameter()]
        [switch]$Interactive
    )

    Write-Log "=== Starting Performance Maintenance ===" -Level INFO

    $result = [PSCustomObject]@{
        TempUser_MB       = 0
        TempWindows_MB    = 0
        TotalCalculated_MB = 0
        Freed_MB          = 0
        SFCExecuted       = $false
        SFCStatus         = 'Not Run'
        Status            = 'Success'
        ErrorDetails      = $null
    }

    # Calculate User Temp
    try {
        $userTempPath = $env:TEMP
        if (Test-Path $userTempPath) {
            $userTempSize = (Get-ChildItem -Path $userTempPath -Recurse -File -ErrorAction SilentlyContinue |
                            Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            $result.TempUser_MB = [math]::Round($userTempSize / 1MB, 2)
            Write-Log "User Temp size: $($result.TempUser_MB) MB" -Level INFO
        }
    }
    catch {
        Write-Log "Error calculating user temp size: $_" -Level WARN
    }

    # Calculate Windows Temp (requires admin)
    $isAdmin = Test-IsAdmin
    if ($isAdmin) {
        try {
            $winTempPath = "C:\Windows\Temp"
            if (Test-Path $winTempPath) {
                $winTempSize = (Get-ChildItem -Path $winTempPath -Recurse -File -ErrorAction SilentlyContinue |
                            Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                $result.TempWindows_MB = [math]::Round($winTempSize / 1MB, 2)
                Write-Log "Windows Temp size: $($result.TempWindows_MB) MB" -Level INFO
            }
        }
        catch {
            Write-Log "Error calculating Windows temp size: $_" -Level WARN
        }
    }
    else {
        Write-Log "Not running as admin - skipping Windows Temp" -Level WARN
    }

    $result.TotalCalculated_MB = [math]::Round($result.TempUser_MB + $result.TempWindows_MB, 2)

    # DryRun mode
    if ($DryRun) {
        Write-Log "DRY RUN: Would free approximately $($result.TotalCalculated_MB) MB" -Level INFO
        Write-Host "`n--- Performance Report (Dry Run) ---" -ForegroundColor Cyan
        Write-Host "User Temp:      $($result.TempUser_MB) MB"
        Write-Host "Windows Temp:   $($result.TempWindows_MB) MB"
        Write-Host "Total:          $($result.TotalCalculated_MB) MB"
        Write-Host "------------------------------------`n"
        return $result
    }

    # Actual cleanup
    $freedSize = 0

    # Clean User Temp
    try {
        $userTempPath = $env:TEMP
        $items = Get-ChildItem -Path $userTempPath -ErrorAction SilentlyContinue
        foreach ($item in $items) {
            try {
                $size = 0
                if ($item.PSIsContainer) {
                    $size = (Get-ChildItem -Path $item.FullName -Recurse -File -ErrorAction SilentlyContinue |
                            Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                    Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction Stop
                }
                else {
                    $size = $item.Length
                    Remove-Item -Path $item.FullName -Force -ErrorAction Stop
                }
                $freedSize += $size
            }
            catch {
                # Silently continue on locked files
            }
        }
        Write-Log "User Temp cleaned" -Level OK
    }
    catch {
        Write-Log "Error cleaning user temp: $_" -Level WARN
    }

    # Clean Windows Temp (if admin)
    if ($isAdmin) {
        try {
            $winTempPath = "C:\Windows\Temp"
            $items = Get-ChildItem -Path $winTempPath -ErrorAction SilentlyContinue
            foreach ($item in $items) {
                try {
                    $size = 0
                    if ($item.PSIsContainer) {
                        $size = (Get-ChildItem -Path $item.FullName -Recurse -File -ErrorAction SilentlyContinue |
                                Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                        Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction Stop
                    }
                    else {
                        $size = $item.Length
                        Remove-Item -Path $item.FullName -Force -ErrorAction Stop
                    }
                    $freedSize += $size
                }
                catch {
                    # Silently continue on locked files
                }
            }
            Write-Log "Windows Temp cleaned" -Level OK
        }
        catch {
            Write-Log "Error cleaning Windows temp: $_" -Level WARN
        }
    }

    $result.Freed_MB = [math]::Round($freedSize / 1MB, 2)
    Write-Log "Total freed: $($result.Freed_MB) MB" -Level OK

    # SFC prompt (interactive mode only)
    if ($Interactive) {
        Write-Host "`nWould you like to run 'sfc /scannow'? (Can take ~15 minutes)" -ForegroundColor Yellow
        Write-Host "[Y] Yes  [N] No (default): " -NoNewline -ForegroundColor Yellow
        $sfcChoice = Read-Host
        
        if ($sfcChoice -eq 'Y' -or $sfcChoice -eq 'y') {
            if ($isAdmin) {
                Write-Log "Starting SFC scan..." -Level INFO
                try {
                    $sfcProcess = Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -NoNewWindow -Wait -PassThru
                    $result.SFCExecuted = $true
                    $result.SFCStatus = if ($sfcProcess.ExitCode -eq 0) { "Completed" } else { "Completed with errors" }
                    Write-Log "SFC scan completed (Exit Code: $($sfcProcess.ExitCode))" -Level OK
                }
                catch {
                    $result.SFCStatus = "Failed: $_"
                    Write-Log "SFC scan failed: $_" -Level ERROR
                }
            }
            else {
                Write-Log "SFC requires administrator privileges" -Level WARN
                $result.SFCStatus = "Skipped - Not Admin"
            }
        }
        else {
            Write-Log "SFC scan skipped by user" -Level INFO
        }
    }

    # Display summary
    Write-Host "`n--- Performance Report ---" -ForegroundColor Cyan
    Write-Host "Calculated:     $($result.TotalCalculated_MB) MB"
    Write-Host "Freed:          $($result.Freed_MB) MB"
    Write-Host "SFC:            $($result.SFCStatus)"
    Write-Host "--------------------------`n"

    return $result
}

# ============================================================================
# MODULE 3: NETWORK DIAGNOSTICS
# ============================================================================
function Invoke-Network {
    <#
    .SYNOPSIS
        Network Diagnostics - Test connectivity and refresh DNS
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter()]
        [string]$InternalDns,

        [Parameter()]
        [switch]$Force
    )

    Write-Log "=== Starting Network Diagnostics ===" -Level INFO

    $result = [PSCustomObject]@{
        DefaultGateway     = 'Unknown'
        GatewayReachable   = $false
        PingGoogle         = $false
        InternalDns        = $null
        InternalDnsResult  = 'Not Tested'
        FlushDNS           = 'Failed'
        RegisterDNS        = 'Failed'
        Status             = 'Success'
        ErrorDetails       = $null
    }

    # Get Default Gateway
    try {
        $gateway = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction Stop |
                Select-Object -First 1 -ExpandProperty NextHop
        if ($gateway) {
            $result.DefaultGateway = $gateway
            Write-Log "Default Gateway: $gateway" -Level INFO
        }
    }
    catch {
        Write-Log "Failed to get default gateway: $_" -Level WARN
    }

    # Test Gateway connectivity
    if ($result.DefaultGateway -ne 'Unknown') {
        try {
            $pingResult = Test-Connection -ComputerName $result.DefaultGateway -Count 2 -Quiet -ErrorAction Stop
            $result.GatewayReachable = $pingResult
            if ($pingResult) {
                Write-Log "Gateway is reachable" -Level OK
            }
            else {
                Write-Log "Gateway is NOT reachable" -Level WARN
            }
        }
        catch {
            Write-Log "Failed to ping gateway: $_" -Level WARN
        }
    }

    # Test Google DNS (8.8.8.8)
    try {
        $googlePing = Test-Connection -ComputerName "8.8.8.8" -Count 2 -Quiet -ErrorAction Stop
        $result.PingGoogle = $googlePing
        if ($googlePing) {
            Write-Log "Google DNS (8.8.8.8) is reachable" -Level OK
        }
        else {
            Write-Log "Google DNS (8.8.8.8) is NOT reachable" -Level WARN
        }
    }
    catch {
        Write-Log "Failed to ping Google DNS: $_" -Level WARN
    }

    # Test Internal DNS (if provided)
    if ($InternalDns) {
        $result.InternalDns = $InternalDns
        try {
            $internalPing = Test-Connection -ComputerName $InternalDns -Count 2 -Quiet -ErrorAction Stop
            $result.InternalDnsResult = if ($internalPing) { "Reachable" } else { "Not Reachable" }
            Write-Log "Internal DNS ($InternalDns): $($result.InternalDnsResult)" -Level INFO
        }
        catch {
            $result.InternalDnsResult = "Failed: $_"
            Write-Log "Failed to test Internal DNS: $_" -Level WARN
        }
    }

    # Flush DNS
    try {
        $flushOutput = & ipconfig /flushdns 2>&1
        $result.FlushDNS = 'Success'
        Write-Log "DNS cache flushed" -Level OK
    }
    catch {
        $result.FlushDNS = "Failed: $_"
        Write-Log "Failed to flush DNS: $_" -Level WARN
    }

    # Register DNS
    try {
        $registerOutput = & ipconfig /registerdns 2>&1
        $result.RegisterDNS = 'Success'
        Write-Log "DNS registration started" -Level OK
    }
    catch {
        $result.RegisterDNS = "Failed: $_"
        Write-Log "Failed to register DNS: $_" -Level WARN
    }

    # Safety check for disruptive actions
    $sessionState = Get-RemoteSessionState
    if (($sessionState -eq 'RDP' -or $sessionState -eq 'Unknown') -and -not $Force) {
        Write-Log "Detected $sessionState session - disruptive network actions blocked (use -Force to override)" -Level WARN
    }

    # Display summary
    Write-Host "`n--- Network Diagnostics ---" -ForegroundColor Cyan
    Write-Host "Gateway:        $($result.DefaultGateway) - $(if($result.GatewayReachable){'OK'}else{'FAIL'})"
    Write-Host "Ping Google:    $(if($result.PingGoogle){'OK'}else{'FAIL'})"
    if ($InternalDns) {
        Write-Host "Internal DNS:   $($result.InternalDnsResult)"
    }
    Write-Host "Flush DNS:      $($result.FlushDNS)"
    Write-Host "Register DNS:   $($result.RegisterDNS)"
    Write-Host "---------------------------`n"

    return $result
}

# ============================================================================
# MODULE 4: SERVICE HEALER
# ============================================================================
function Invoke-ServiceHealer {
    <#
    .SYNOPSIS
        Critical Service Reset - Restart key Windows services
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    Write-Log "=== Starting Service Healer ===" -Level INFO

    $servicesToRestart = @('Spooler', 'Audiosrv', 'wuauserv')
    $results = @()

    foreach ($serviceName in $servicesToRestart) {
        $serviceResult = [PSCustomObject]@{
            ServiceName  = $serviceName
            Status       = 'Unknown'
            Action       = 'None'
            ErrorDetails = $null
        }

        try {
            $service = Get-Service -Name $serviceName -ErrorAction Stop
            $serviceResult.Status = $service.Status.ToString()

            if ($service.Status -eq 'Running') {
                Write-Log "Restarting service: $serviceName" -Level INFO
                Restart-Service -Name $serviceName -Force -ErrorAction Stop
                $serviceResult.Action = 'Restarted'
                Write-Log "Service $serviceName restarted successfully" -Level OK
            }
            elseif ($service.Status -eq 'Stopped') {
                Write-Log "Starting service: $serviceName" -Level INFO
                Start-Service -Name $serviceName -ErrorAction Stop
                $serviceResult.Action = 'Started'
                Write-Log "Service $serviceName started successfully" -Level OK
            }
            else {
                Write-Log "Service $serviceName in state: $($service.Status)" -Level WARN
                $serviceResult.Action = 'No Action'
            }
        }
        catch {
            $serviceResult.Action = 'Failed'
            $serviceResult.ErrorDetails = $_.Exception.Message
            Write-Log "Failed to process service $serviceName : $_" -Level ERROR
        }

        $results += $serviceResult
    }

    # Display summary
    Write-Host "`n--- Service Healer Results ---" -ForegroundColor Cyan
    foreach ($res in $results) {
        $statusColor = if ($res.Action -match 'Started|Restarted') { 'Green' } 
                    elseif ($res.Action -eq 'Failed') { 'Red' }
                    else { 'Yellow' }
        Write-Host "$($res.ServiceName): $($res.Action)" -ForegroundColor $statusColor
    }
    Write-Host "------------------------------`n"

    return $results
}

# ============================================================================
# MODULE 5: ADMIN SHORTCUTS
# ============================================================================
function Invoke-AdminShortcuts {
    <#
    .SYNOPSIS
        Admin Tools Launcher - Open common administrative tools
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    Write-Log "=== Starting Admin Shortcuts ===" -Level INFO

    $tools = @(
        @{ Name = 'Task Manager'; Command = 'taskmgr.exe' }
        @{ Name = 'Services'; Command = 'services.msc' }
        @{ Name = 'System Configuration'; Command = 'msconfig.exe' }
    )

    $results = @()

    foreach ($tool in $tools) {
        $toolResult = [PSCustomObject]@{
            ToolName     = $tool.Name
            Status       = 'Success'
            ErrorDetails = $null
        }

        try {
            Write-Log "Launching: $($tool.Name)" -Level INFO
            Start-Process -FilePath $tool.Command -ErrorAction Stop
            Write-Log "$($tool.Name) launched successfully" -Level OK
        }
        catch {
            $toolResult.Status = 'Failed'
            $toolResult.ErrorDetails = $_.Exception.Message
            Write-Log "Failed to launch $($tool.Name): $_" -Level ERROR
        }

        $results += $toolResult
    }

    # Display summary
    Write-Host "`n--- Admin Tools Launched ---" -ForegroundColor Cyan
    foreach ($res in $results) {
        $statusColor = if ($res.Status -eq 'Success') { 'Green' } else { 'Red' }
        Write-Host "$($res.ToolName): $($res.Status)" -ForegroundColor $statusColor
    }
    Write-Host "----------------------------`n"

    return $results
}

# ============================================================================
# MODULE 6: EXPORT REPORT
# ============================================================================
function Export-Report {
    <#
    .SYNOPSIS
        Export consolidated report to JSON file
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter()]
        [string]$OutPath,

        [Parameter()]
        [hashtable]$Results
    )

    Write-Log "=== Exporting Report ===" -Level INFO

    # Determine output path
    if (-not $OutPath) {
        $OutPath = "C:\IT-Reports"
        # Create directory if it doesn't exist
        if (-not (Test-Path $OutPath)) {
            try {
                New-Item -Path $OutPath -ItemType Directory -Force -ErrorAction Stop | Out-Null
                Write-Log "Created report directory: $OutPath" -Level INFO
            }
            catch {
                Write-Log "Failed to create directory, using TEMP instead: $_" -Level WARN
                $OutPath = $env:TEMP
            }
        }
    }

    # Create filename
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $fileName = "SupportToolkit-Report-$timestamp.json"
    $fullPath = Join-Path $OutPath $fileName

    # Build report object
    $report = [PSCustomObject]@{
        Metadata = @{
            Timestamp          = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
            Hostname           = $env:COMPUTERNAME
            Username           = $env:USERNAME
            IsAdmin            = Test-IsAdmin
            RemoteSessionState = Get-RemoteSessionState
            ToolkitVersion     = $script:ToolkitVersion
        }
        Results  = $Results
    }

    # Export to JSON
    try {
        $report | ConvertTo-Json -Depth 10 | Out-File -FilePath $fullPath -Encoding UTF8 -ErrorAction Stop
        Write-Log "Report exported successfully to: $fullPath" -Level OK
        Write-Host "`nReport saved: $fullPath" -ForegroundColor Green
        return $fullPath
    }
    catch {
        Write-Log "Failed to export report: $_" -Level ERROR
        Write-Host "`nERROR: Failed to save report - $_" -ForegroundColor Red
        return $null
    }
}

# ============================================================================
# INTERACTIVE MENU
# ============================================================================
function Show-Menu {
    <#
    .SYNOPSIS
        Display interactive menu for toolkit operations
    #>
    [CmdletBinding()]
    param()

    do {
        Clear-Host
        Write-Host ""
        # Top spacing - centering the logo vertically with the art
        Write-Host "                                                               " -NoNewline
        Write-Host "⠀⠀⠀⠀⠀⢸⠓⢄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" -ForegroundColor Magenta
        Write-Host "                                                               " -NoNewline
        Write-Host "⠀⠀⠀⠀⠀⢸⠀⠀⠑⢤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" -ForegroundColor Magenta
        Write-Host "                                                               " -NoNewline
        Write-Host "⠀⠀⠀⠀⠀⢸⡆⠀⠀⠀⠙⢤⡷⣤⣦⣀⠤⠖⠚⡿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀" -ForegroundColor Magenta
        # Logo centered vertically
        Write-Host "@@@@@@@   @@@@@@    @@@@@@   @@@       @@@  @@@  @@@  @@@@@@@  " -ForegroundColor Cyan -NoNewline
        Write-Host "⣠⡿⠢⢄⡀⠀⡇⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠸⠷⣶⠂⠀⠀⠀⣀⣀⠀⠀⠀" -ForegroundColor Magenta
        Write-Host "@@@@@@@  @@@@@@@@  @@@@@@@@  @@@       @@@  @@@  @@@  @@@@@@@  " -ForegroundColor Cyan -NoNewline
        Write-Host "⢸⣃⠀⠀⠉⠳⣷⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠉⠉⠉⢉⡭⠋" -ForegroundColor Magenta
        Write-Host "  @@!    @@!  @@@  @@!  @@@  @@!       @@!  !@@  @@!    @@!    " -ForegroundColor Cyan -NoNewline
        Write-Host "⠀⠘⣆⠀⠀⠀⠁⠀⢀⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠋⠀⠀" -ForegroundColor Magenta
        Write-Host "  !@!    !@!  @!@  !@!  @!@  !@!       !@!  @!!  !@!    !@!    " -ForegroundColor Cyan -NoNewline
        Write-Host "⠀⠀⠘⣦⠆⠀⠀⢀⡎⢹⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⡀⣠⠔⠋⠀⠀" -ForegroundColor Magenta
        Write-Host "  @!!    @!@  !@!  @!@  !@!  @!!       @!@@!@!   !!@    @!!    " -ForegroundColor Cyan -NoNewline
        Write-Host "⠀⠀⠀⡏⠀⠀⣆⠘⣄⠸⢧⠀⠀⠀⠀⠀⢀⣠⠖⢻⠀⠀⠀⣿⢥⣄⣀⣀⣀⠀" -ForegroundColor Magenta
        Write-Host "  !!!    !@!  !!!  !@!  !!!  !!!       !!@!!!    !!!    !!!    " -ForegroundColor Cyan -NoNewline
        Write-Host "⠀⠀⢸⠁⠀⠀⡏⢣⣌⠙⠚⠀⠀⠠⣖⡛⠀⣠⠏⠀⠀⠀⠇⠀⠀⠀⠀⠀⢙⣣⠄" -ForegroundColor Magenta
        Write-Host "  !!:    !!:  !!!  !!:  !!!  !!:       !!: :!!   !!:    !!:    " -ForegroundColor Cyan -NoNewline
        Write-Host "⠀⠀⢸⡀⠀⠀⠳⡞⠈⢻⠶⠤⣄⣀⣈⣉⣉⣡⡔⠀⠀⢀⠀⠀⣀⡤⠖⠚⠀⠀" -ForegroundColor Magenta
        Write-Host "  :!:    :!:  !:!  :!:  !:!   :!:      :!:  !:!  :!:    :!:    " -ForegroundColor Cyan -NoNewline
        Write-Host "⠀⠀⡼⣇⠀⠀⠀⠙⠦⣞⡀⠀⢀⡏⠀⢸⣣⠞⠀⠀⠀⡼⠚⠋⠁⠀⠀⠀⠀⠀" -ForegroundColor Magenta
        Write-Host "   ::    ::::: ::  ::::: ::   :: ::::   ::  :::   ::     ::    " -ForegroundColor Cyan -NoNewline
        Write-Host "⠀⢰⡇⠙⠀⠀⠀⠀⠀⠀⠉⠙⠚⠒⠚⠉⠀⠀⠀⠀⡼⠁⠀⠀⠀⠀⠀⠀⠀⠀" -ForegroundColor Magenta
        Write-Host "   :      : :  :    : :  :   : :: : :   :   :::  :       :     " -ForegroundColor Cyan -NoNewline
        Write-Host "⠀⠀⢧⡀⠀⢠⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀" -ForegroundColor Magenta
        # Bottom spacing - completing the art
        Write-Host "                                                               " -NoNewline
        Write-Host "⠀⠀⠀⠙⣶⣶⣿⠢⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" -ForegroundColor Magenta
        Write-Host "                                                               " -NoNewline
        Write-Host "⠀⠀⠀⠀⠀⠉⠀⠀⠀⠙⢿⣳⠞⠳⡄⠀⠀⠀⢀⡞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" -ForegroundColor Magenta
        Write-Host "                                                               " -NoNewline
        Write-Host "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠹⣄⣀⡤⠋⠀⠀⠀" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "                            v$($script:ToolkitVersion)         " -ForegroundColor Gray
        Write-Host ""
        Write-Host "Computer: " -ForegroundColor Cyan -NoNewline
        Write-Host "$env:COMPUTERNAME" -ForegroundColor Green -NoNewline
        Write-Host " | User: " -ForegroundColor Cyan -NoNewline
        Write-Host "$env:USERNAME" -ForegroundColor Green
        Write-Host "Admin: " -ForegroundColor Gray -NoNewline
        Write-Host "$(if(Test-IsAdmin){'YES'}else{'NO'})" -ForegroundColor $(if(Test-IsAdmin){'Green'}else{'Red'}) -NoNewline
        Write-Host " | Session: " -ForegroundColor Gray -NoNewline
        Write-Host "$(Get-RemoteSessionState)" -ForegroundColor $(if((Get-RemoteSessionState) -eq 'Local'){'Green'}else{'Yellow'})
        Write-Host ""
        Write-Host "  [1] System Triage (Inventory)" -ForegroundColor White
        Write-Host "  [2] Performance Maintenance" -ForegroundColor White
        Write-Host "  [3] Network Diagnostics" -ForegroundColor White
        Write-Host "  [4] Service Healer" -ForegroundColor White
        Write-Host "  [5] Admin Shortcuts" -ForegroundColor White
        Write-Host "  [6] Run All (Triage + Performance + Network + Services)" -ForegroundColor Yellow
        Write-Host "  [7] Export Report" -ForegroundColor White
        Write-Host "  [0] Exit" -ForegroundColor Red
        Write-Host ""
        Write-Host "Select option: " -NoNewline -ForegroundColor Cyan
        $choice = Read-Host

        switch ($choice) {
            '1' {
                $script:SessionResults['Triage'] = Invoke-Triage
                Pause
            }
            '2' {
                $script:SessionResults['Performance'] = Invoke-Performance -Interactive
                Pause
            }
            '3' {
                Write-Host "`nEnter Internal DNS IP/Host (or press Enter to skip): " -NoNewline
                $dnsInput = Read-Host
                $script:SessionResults['Network'] = Invoke-Network -InternalDns $dnsInput
                Pause
            }
            '4' {
                $script:SessionResults['Services'] = Invoke-ServiceHealer
                Pause
            }
            '5' {
                $script:SessionResults['Admin'] = Invoke-AdminShortcuts
                Pause
            }
            '6' {
                Write-Host "`n=== Running All Modules ===" -ForegroundColor Yellow
                $script:SessionResults['Triage'] = Invoke-Triage
                $script:SessionResults['Performance'] = Invoke-Performance -Interactive
                $script:SessionResults['Network'] = Invoke-Network
                $script:SessionResults['Services'] = Invoke-ServiceHealer
                Write-Log "All modules completed" -Level OK
                Pause
            }
            '7' {
                if ($script:SessionResults.Count -eq 0) {
                    Write-Host "`nNo results to export. Run some diagnostics first." -ForegroundColor Yellow
                }
                else {
                    Export-Report -Results $script:SessionResults
                }
                Pause
            }
            '0' {
                Write-Log "User exited toolkit" -Level INFO
                return
            }
            default {
                Write-Host "`nInvalid option. Please try again." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }

        if ($choice -ne '0' -and $choice -match '^[1-7]$') {
            Write-Host "`nReturn to menu? [Y] Yes (default)  [N] No: " -NoNewline -ForegroundColor Yellow
            $continue = Read-Host
            if ($continue -eq 'N' -or $continue -eq 'n') {
                Write-Log "User chose to exit after operation" -Level INFO
                return
            }
        }

    } while ($true)
}

# ============================================================================
# MAIN SCRIPT EXECUTION
# ============================================================================
function Invoke-Main {
    <#
    .SYNOPSIS
        Main entry point for the toolkit
    #>
    [CmdletBinding()]
    param()

    # Start transcript
    $transcriptPath = Join-Path $env:TEMP "SupportToolkit-Transcript-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    try {
        Start-Transcript -Path $transcriptPath -ErrorAction Stop | Out-Null
        Write-Log "Transcript started: $transcriptPath" -Level INFO
    }
    catch {
        Write-Log "Failed to start transcript: $_" -Level WARN
    }

    # Log session start
    Write-Log "============================================" -Level INFO
    Write-Log "IT Support Toolkit v$script:ToolkitVersion Started" -Level INFO
    Write-Log "Hostname: $env:COMPUTERNAME" -Level INFO
    Write-Log "Username: $env:USERNAME" -Level INFO
    Write-Log "IsAdmin: $(Test-IsAdmin)" -Level INFO
    Write-Log "Session: $(Get-RemoteSessionState)" -Level INFO
    Write-Log "============================================" -Level INFO

    # Mode: Menu (Interactive)
    if ($Mode -eq 'Menu') {
        Show-Menu
    }
    # Mode: Run (Non-Interactive)
    elseif ($Mode -eq 'Run') {
        if (-not $Action) {
            Write-Host "ERROR: -Action parameter is required in Run mode" -ForegroundColor Red
            Write-Host "Valid actions: Triage, Performance, Network, Services, Admin, Report, All" -ForegroundColor Yellow
            exit 1
        }

        switch ($Action) {
            'Triage' {
                $script:SessionResults['Triage'] = Invoke-Triage
            }
            'Performance' {
                $script:SessionResults['Performance'] = Invoke-Performance -DryRun:$DryRun
            }
            'Network' {
                $script:SessionResults['Network'] = Invoke-Network -InternalDns $InternalDns -Force:$Force
            }
            'Services' {
                $script:SessionResults['Services'] = Invoke-ServiceHealer
            }
            'Admin' {
                $script:SessionResults['Admin'] = Invoke-AdminShortcuts
            }
            'Report' {
                if ($script:SessionResults.Count -eq 0) {
                    Write-Host "WARNING: No results to export. Run diagnostics first." -ForegroundColor Yellow
                }
                else {
                    Export-Report -Results $script:SessionResults -OutPath $OutPath
                }
            }
            'All' {
                $script:SessionResults['Triage'] = Invoke-Triage
                $script:SessionResults['Performance'] = Invoke-Performance -DryRun:$DryRun
                $script:SessionResults['Network'] = Invoke-Network -InternalDns $InternalDns -Force:$Force
                $script:SessionResults['Services'] = Invoke-ServiceHealer
                Write-Log "All modules completed" -Level OK
                
                # Auto-export report when running All
                Export-Report -Results $script:SessionResults -OutPath $OutPath
            }
        }
    }

    # Log session end
    Write-Log "============================================" -Level INFO
    Write-Log "IT Support Toolkit Session Completed" -Level INFO
    Write-Log "============================================" -Level INFO

    # Stop transcript
    try {
        Stop-Transcript -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Log "Failed to stop transcript: $_" -Level WARN
    }
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================
function Pause {
    Write-Host "`nPress any key to continue..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
}

# Execute main function
Invoke-Main
