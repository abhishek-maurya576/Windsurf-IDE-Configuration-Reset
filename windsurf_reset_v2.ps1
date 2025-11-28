<# 
reset_windsurf_IDE-deepreset.ps1
Purpose: Deep-clean Windsurf traces from a Windows machine so a fresh install behaves like "never installed".
Author: Abhishek Maurya | B for BCA (modified)
Run as Administrator. Test in VM/Sandbox before production use.
#>

Set-StrictMode -Version Latest

# ---------- Configuration ----------
$AppName            = "Windsurf"
$TimeStamp          = (Get-Date).ToString("yyyyMMdd_HHmmss")
$UserProfileRoot    = $env:SystemDrive + "\Users"
$BackupRoot         = Join-Path $env:USERPROFILE "Windsurf_Reset_Backup_$TimeStamp"
$LogFile            = Join-Path $BackupRoot "reset_log_$TimeStamp.txt"
$StorageFile        = Join-Path $env:APPDATA "$AppName\User\globalStorage\storage.json"
$KeepBackupsDays    = 14   # old backup cleanup policy (not auto-delete here)
# Registry locations to search explicitly (optimized for speed)
$RegistryTargets = @(
    "HKCU:\Software\$AppName",
    "HKLM:\SOFTWARE\$AppName",
    "HKLM:\SOFTWARE\WOW6432Node\$AppName",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

# ProgramData/Installer locations to check
$ProgramDataTargets = @(
    "C:\ProgramData\Package Cache",
    "C:\ProgramData\Microsoft\Windows\AppRepository",
    "C:\ProgramData\Windsurf",
    "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
)

# ---------- Helpers ----------
function Log {
    param([string]$msg, [string]$level = "INFO")
    $ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $line = "[$ts][$level] $msg"
    Write-Host $line
    try {
        if (-not (Test-Path $BackupRoot)) { New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null }
        $line | Out-File -FilePath $LogFile -Append -Encoding UTF8
    } catch {}
}

function Ensure-Admin {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "ERROR: Please run this script as Administrator." -ForegroundColor Red
        exit 1
    }
}

function SafeCopy {
    param([string]$src, [string]$dst)
    try {
        $dstDir = Split-Path -Parent $dst
        if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
        Copy-Item -Path $src -Destination $dst -Force -ErrorAction Stop
        Log "Copied: $src -> $dst"
    } catch {
        Log "Failed to copy $src -> $dst : $($_)" "WARN"
    }
}

function Backup-FileIfExists {
    param([string]$path)
    if (Test-Path $path) {
        $dst = Join-Path $BackupRoot ("files\" + (Split-Path $path -Leaf) + "_$TimeStamp")
        SafeCopy -src $path -dst $dst
        return $dst
    } else {
        Log "No file to backup at $path" "INFO"
        return $null
    }
}

function Export-RegistryKey {
    param([string]$regPath, [string]$outFile)
    try {
        # use reg.exe for export (works on 32/64-bit)
        $outDir = Split-Path -Parent $outFile
        if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Force -Path $outDir | Out-Null }
        reg.exe export "$regPath" "$outFile" /y | Out-Null
        Log "Exported registry: $regPath -> $outFile"
        return $true
    } catch {
        Log "Registry export failed for $regPath : $($_)" "WARN"
        return $false
    }
}

function Remove-RegistryKeyWithBackup {
    param([string]$regPath)
    try {
        $safeName = ($regPath -replace '[\\:]', '_')
        $exportFile = Join-Path $BackupRoot ("reg_exports\$safeName`_$TimeStamp.reg")
        if (Export-RegistryKey -regPath $regPath -outFile $exportFile) {
            # Remove the key now
            Remove-Item -Path $regPath -Recurse -Force -ErrorAction Stop
            Log "Removed registry key: $regPath"
            return $exportFile
        } else {
            Log "Skipping removal of $regPath (export failed)" "WARN"
            return $null
        }
    } catch {
        Log "Failed to remove registry key $regPath : $($_)" "WARN"
        return $null
    }
}

function Find-RegistryKeysByName {
    param([string[]]$hives, [string]$pattern)
    [System.Collections.ArrayList]$found = @()
    $totalHives = $hives.Count
    $currentHive = 0
    
    foreach ($h in $hives) {
        $currentHive++
        Write-Progress -Activity "Searching Registry for $AppName keys" -Status "Checking $h" -PercentComplete (($currentHive / $totalHives) * 100)
        
        try {
            # Direct path check (for specific Windsurf paths)
            if (Test-Path $h) {
                $kPath = $h -replace "Microsoft.PowerShell.Core\\Registry::",""
                if ($kPath -match $pattern) {
                    $found += $kPath
                }
            }
            
            # Recursive search for Uninstall keys only
            if ($h -match "Uninstall") {
                $keys = Get-ChildItem -Path $h -ErrorAction SilentlyContinue
                foreach ($k in $keys) {
                    $kPath = $k.PSPath -replace "Microsoft.PowerShell.Core\\Registry::",""
                    # check DisplayName property if present
                    try {
                        $props = Get-ItemProperty -Path $k.PSPath -ErrorAction SilentlyContinue
                        if ($props -and $props.PSObject.Properties.Name -contains 'DisplayName') {
                            if ($props.DisplayName -and $props.DisplayName -match $pattern) {
                                $found += $kPath
                            }
                        }
                    } catch {}
                }
            }
        } catch {
            Log "Registry search under $h failed: $($_)" "WARN"
        }
    }
    Write-Progress -Activity "Searching Registry" -Completed
    return ($found | Sort-Object -Unique)
}

function Remove-ProgramDataMatches {
    param([string[]]$paths, [string]$pattern)
    [System.Collections.ArrayList]$deleted = @()
    foreach ($p in $paths) {
        if (Test-Path $p) {
            try {
                $matches = Get-ChildItem -Path $p -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.Name -match $pattern -or $_.FullName -match $pattern }
                foreach ($m in $matches) {
                    try {
                        $dest = Join-Path $BackupRoot ("files\" + ($m.FullName -replace '[:\\]','_') + "_$TimeStamp")
                        if ($m.PSIsContainer) {
                            Copy-Item -Path $m.FullName -Destination $dest -Recurse -Force -ErrorAction SilentlyContinue
                            Remove-Item -Path $m.FullName -Recurse -Force -ErrorAction SilentlyContinue
                        } else {
                            Copy-Item -Path $m.FullName -Destination $dest -Force -ErrorAction SilentlyContinue
                            Remove-Item -Path $m.FullName -Force -ErrorAction SilentlyContinue
                        }
                        $deleted += $m.FullName
                        Log "Removed ProgramData match: $($m.FullName)"
                    } catch {
                        Log "Failed remove $($m.FullName): $($_)" "WARN"
                    }
                }
            } catch {
                Log "Search in $p failed: $($_)" "WARN"
            }
        } else {
            Log "ProgramData path not present: $p" "INFO"
        }
    }
    return $deleted
}

function Find-PerUserWindsurfFiles {
    param()
    $userProfiles = Get-ChildItem -Path $UserProfileRoot -Directory -ErrorAction SilentlyContinue | Where-Object { Test-Path (Join-Path $_.FullName "AppData") }
    [System.Collections.ArrayList]$found = @()
    foreach ($u in $userProfiles) {
        $candidatePaths = @(
            (Join-Path $u.FullName "AppData\Roaming\$AppName")
            (Join-Path $u.FullName "AppData\Local\$AppName")
            (Join-Path $u.FullName "AppData\LocalLow\$AppName")
            (Join-Path $u.FullName "AppData\Local\Temp\$AppName")
            (Join-Path $u.FullName ".config\$AppName")
        )
        foreach ($cp in $candidatePaths) {
            if (Test-Path $cp) { [void]$found.Add($cp) }
        }
    }
    if ($found.Count -eq 0) { return @() }
    return ($found.ToArray() | Sort-Object -Unique)
}

# ---------- Start ----------
Ensure-Admin
New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
Log "Beginning deep reset for $AppName"
Log "Backup root: $BackupRoot"

# 1) Stop running app if present
try {
    $proc = Get-Process -Name $AppName -ErrorAction SilentlyContinue
    if ($proc) {
        Log "Detected running process: $($proc.Id) - attempting to stop"
        try {
            $proc | Stop-Process -Force -ErrorAction Stop
            Start-Sleep -Seconds 2
            Log "Stopped running process: $AppName"
        } catch {
            Log "Failed to stop process: $($_)" "WARN"
            Write-Host "Please close $AppName manually and re-run if required." -ForegroundColor Yellow
        }
    } else {
        Log "No running process detected."
    }
} catch {
    Log "Process check failed: $($_)" "WARN"
}

# 2) Backup and remove ALL storage.json files (machine ID tracking)
Log "Searching for storage.json files across all user profiles..."
$storageFiles = @()
$allUsers = Get-ChildItem -Path $UserProfileRoot -Directory -ErrorAction SilentlyContinue
foreach ($user in $allUsers) {
    $userStorage = Join-Path $user.FullName "AppData\Roaming\$AppName\User\globalStorage\storage.json"
    if (Test-Path $userStorage) {
        $storageFiles += $userStorage
    }
}

if ($storageFiles.Count -gt 0) {
    Log "Found $($storageFiles.Count) storage.json file(s) - backing up and removing..."
    foreach ($sf in $storageFiles) {
        $fileBackup = Backup-FileIfExists -path $sf
        if ($fileBackup) {
            Remove-Item -Path $sf -Force -ErrorAction SilentlyContinue
            Log "Removed storage.json: $sf"
        }
    }
} else {
    Log "No storage.json files found in any user profile" "INFO"
}

# 3) Find registry keys that mention Windsurf (optimized search)
$pattern = [regex]::Escape($AppName)
Log "Searching targeted registry paths for keys matching: $pattern"
Write-Host "Searching registry (optimized search - this will be quick)..." -ForegroundColor Cyan
$foundKeys = Find-RegistryKeysByName -hives $RegistryTargets -pattern $pattern

$foundKeys = @($foundKeys | Sort-Object -Unique)
if ($foundKeys.Count -eq 0) {
    Log "No registry keys explicitly mentioning $AppName were found in common hives."
} else {
    Log "Registry keys found that reference ${AppName}:"
    Log "  $($foundKeys -join "`n  ")"
    Write-Host ""
    Write-Host "These registry keys will be backed up before any action." -ForegroundColor Cyan
    Write-Host "Choose action:" -ForegroundColor Yellow
    Write-Host "  [E] Export Only - Backup without deletion (safe, for inspection)" -ForegroundColor White
    Write-Host "  [R] Remove - Backup AND delete (recommended for full reset)" -ForegroundColor White
    
    do {
        $do = Read-Host "`nYour choice [E/R]"
        if ($do -match '^[Ee]$') {
            foreach ($k in $foundKeys) {
                $exportPath = Join-Path $BackupRoot ("reg_exports\" + ($k -replace '[\\/: ]','_') + "_$TimeStamp.reg")
                Export-RegistryKey -regPath $k -outFile $exportPath | Out-Null
            }
            Log "Exported registry keys to $BackupRoot\reg_exports (no deletion)"
            Write-Host "Export complete. Keys preserved. Re-run script and choose [R] to remove them." -ForegroundColor Green
            break
        } elseif ($do -match '^[Rr]$') {
            foreach ($k in $foundKeys) {
                Remove-RegistryKeyWithBackup -regPath $k | Out-Null
            }
            Log "Registry keys backed up and removed successfully."
            Write-Host "Registry keys removed. Backups saved to $BackupRoot\reg_exports" -ForegroundColor Green
            break
        } else {
            Write-Host "Invalid choice. Please enter E or R." -ForegroundColor Red
        }
    } while ($true)
}

# 4) Clean ProgramData / Installer caches that commonly persist
Write-Host "`nNow searching ProgramData/installer locations for matches (Package Cache, AppRepository, ProgramData)."
$progRemoved = @(Remove-ProgramDataMatches -paths $ProgramDataTargets -pattern $pattern)
if ($progRemoved.Count -gt 0) {
    Log "Removed ProgramData matches: $($progRemoved.Count) items"
} else {
    Log "No ProgramData matches removed (or none found)."
}

# 5) Per-user cleanup (all profiles)
Write-Host "`nSearching per-user profiles for Windsurf folders (AppData Roaming/Local/.config)."
$userFound = @(Find-PerUserWindsurfFiles)
if ($userFound.Count -gt 0) {
    Log "Per-user Windsurf traces found:`n  $($userFound -join "`n  ")"
    Write-Host "These will be backed up and removed for each user." -ForegroundColor Cyan
    $confirmUsers = Read-Host "Proceed to backup & remove these per-user paths? [Y/N]"
    if ($confirmUsers -match '^[Yy]$') {
        foreach ($p in $userFound) {
            try {
                $dest = Join-Path $BackupRoot ("files\" + ($p -replace '[:\\]','_') + "_$TimeStamp")
                if (Test-Path $p) {
                    Copy-Item -Path $p -Destination $dest -Recurse -Force -ErrorAction SilentlyContinue
                    Log "Backed up user file/folder: $p -> $dest"
                    Remove-Item -Path $p -Recurse -Force -ErrorAction SilentlyContinue
                    Log "Removed user file/folder: $p"
                }
            } catch {
                Log "Error handling ${p}: $($_)" "WARN"
            }
        }
    } else {
        Log "User chose not to remove per-user traces." "INFO"
    }
} else {
    Log "No per-user Windsurf folders found."
}

# 6) Additional cleanup of Start Menu shortcuts
try {
    $startMenuMatches = Get-ChildItem -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -match $pattern -or $_.FullName -match $pattern }
    foreach ($s in $startMenuMatches) {
        $dest = Join-Path $BackupRoot ("files\" + ($s.FullName -replace '[:\\]','_') + "_$TimeStamp")
        if ($s.PSIsContainer) { Copy-Item -Path $s.FullName -Destination $dest -Recurse -Force -ErrorAction SilentlyContinue } else { Copy-Item -Path $s.FullName -Destination $dest -Force -ErrorAction SilentlyContinue }
        Remove-Item -Path $s.FullName -Force -Recurse -ErrorAction SilentlyContinue
        Log "Removed Start Menu match: $($s.FullName)"
    }
} catch {
    Log "Start menu cleanup failed: $($_)" "WARN"
}

# 7) Clear system caches (makes reboot optional)
Log "Clearing system caches..."
try {
    # Clear icon cache
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Remove-Item -Path "$env:LOCALAPPDATA\IconCache.db" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*" -Force -ErrorAction SilentlyContinue
    Start-Process explorer
    Log "System caches cleared"
} catch {
    Log "Cache clearing failed (non-critical): $($_)" "WARN"
}

# --- Additional System Cleanup Improvements (Safe Add-ons) ---

# 1) Remove scheduled tasks
function Remove-ScheduledTasksByPattern {
    param([string]$pattern)
    try {
        $tasks = Get-ScheduledTask -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -match $pattern -or $_.TaskPath -match $pattern }
        foreach ($t in $tasks) {
            Unregister-ScheduledTask -TaskName $t.TaskName -TaskPath $t.TaskPath -Confirm:$false -ErrorAction SilentlyContinue
            Log "Removed scheduled task: $($t.TaskPath)$($t.TaskName)"
        }
    } catch {
        Log "Scheduled task removal failed: $($_)" "WARN"
    }
}
Remove-ScheduledTasksByPattern -pattern $AppName

# 2) Remove Windows services
function Remove-ServicesByPattern {
    param([string]$pattern)
    try {
        $svcs = Get-WmiObject -Class Win32_Service -Filter "Name LIKE '%$pattern%' OR DisplayName LIKE '%$pattern%'" -ErrorAction SilentlyContinue
        foreach ($s in $svcs) {
            try {
                if ($s.State -ne 'Stopped') { sc.exe stop $s.Name | Out-Null; Start-Sleep -Seconds 1 }
                sc.exe delete $s.Name | Out-Null
                Log "Deleted service: $($s.Name) ($($s.DisplayName))"
            } catch {
                Log "Failed to delete service $($s.Name): $($_)" "WARN"
            }
        }
    } catch {
        Log "Service search failed: $($_)" "WARN"
    }
}
Remove-ServicesByPattern -pattern $AppName

# 3) Uninstall entries via DisplayName
function Uninstall-ByDisplayName {
    param([string]$pattern)
    $uninstallPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    )
    foreach ($p in $uninstallPaths) {
        try {
            Get-ChildItem -Path $p -ErrorAction SilentlyContinue | ForEach-Object {
                $props = Get-ItemProperty -Path $_.PSPath -ErrorAction SilentlyContinue
                if ($props -and $props.DisplayName -and ($props.DisplayName -match $pattern)) {
                    Log "Found installer entry: $($props.DisplayName) -> uninstall string: $($props.UninstallString)"
                    if ($props.UninstallString) {
                        try {
                            & cmd.exe /c "$($props.UninstallString) /quiet" 2>$null
                            Log "Triggered uninstall for $($props.DisplayName)"
                        } catch {
                            Log "Failed to run uninstall string for $($props.DisplayName): $($_)" "WARN"
                        }
                    }
                }
            }
        } catch {
            Log "Uninstall search failed under ${p}: $($_)" "WARN"
        }
    }
}
Uninstall-ByDisplayName -pattern $AppName

# 4) Clear related event logs
function Clear-RelatedEventLogs {
    param([string]$pattern)
    try {
        $logs = Get-EventLog -List | Where-Object { $_.Log -match $pattern -or $_.Source -match $pattern } -ErrorAction SilentlyContinue
        foreach ($l in $logs) {
            try {
                Clear-EventLog -LogName $l.Log
                Log "Cleared event log: $($l.Log)"
            } catch {
                Log "Failed to clear $($l.Log): $($_)" "WARN"
            }
        }
    } catch {}
}
Clear-RelatedEventLogs -pattern $AppName


# 8) Final advice and wrap-up
Log "Deep cleanup finished. Backup directory: $BackupRoot"
Write-Host "`n=== Cleanup Complete ===" -ForegroundColor Green
Write-Host "Reboot is RECOMMENDED (but not mandatory) for registry changes to fully apply." -ForegroundColor Yellow
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "  1. Reinstall Windsurf" -ForegroundColor White
Write-Host "  2. Try logging in with a new email" -ForegroundColor White
Write-Host "  3. If still detected, reboot and try again" -ForegroundColor White

Log "===== Completed deep reset run at $(Get-Date) ====="
Write-Host "`nLog and backups saved at:`n  $BackupRoot" -ForegroundColor Green
Pause
