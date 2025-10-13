# ==========================================================
# reset_windsurf_IDE-v1.1.ps1
# Safely resets Windsurf IDE telemetry IDs (app-level only)
# Does NOT change Windows Machine ID or system info.
# ==========================================================

# Ensure running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as Administrator." -ForegroundColor Yellow
    Write-Host "Right-click PowerShell → 'Run as Administrator' and re-run this file."
    Pause
    exit
}

# Path to Windsurf config
$storagePath = "$env:APPDATA\Windsurf\User\globalStorage\storage.json"

if (-not (Test-Path $storagePath)) {
    Write-Host "Error: Windsurf storage.json not found at: $storagePath" -ForegroundColor Red
    Pause
    exit
}

# --- Backup original file ---
try {
    $backupPath = "$storagePath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $storagePath $backupPath -Force
    Write-Host "Backup created at: $backupPath" -ForegroundColor Cyan
}
catch {
    Write-Host "Failed to create backup: $_" -ForegroundColor Red
    Pause
    exit
}

# --- Load and modify JSON safely ---
try {
    # Load JSON as PSCustomObject (compatible with PowerShell 5.1+)
    $config = Get-Content -Raw -Path $storagePath | ConvertFrom-Json

    # Ensure telemetry object exists
    if (-not ($config.PSObject.Properties.Name -contains 'telemetry')) {
        $config | Add-Member -MemberType NoteProperty -Name 'telemetry' -Value ([PSCustomObject]@{})
    }

    # Generate new IDs
    $newMachineId    = [guid]::NewGuid().ToString()
    $newMacMachineId = [guid]::NewGuid().ToString()
    $newDevDeviceId  = [guid]::NewGuid().ToString()

    # Add or update telemetry properties (Force will overwrite if exists)
    $config.telemetry | Add-Member -MemberType NoteProperty -Name 'machineId' -Value $newMachineId -Force
    $config.telemetry | Add-Member -MemberType NoteProperty -Name 'macMachineId' -Value $newMacMachineId -Force
    $config.telemetry | Add-Member -MemberType NoteProperty -Name 'devDeviceId' -Value $newDevDeviceId -Force

    # Write back to JSON
    $config | ConvertTo-Json -Depth 10 | Set-Content -Path $storagePath -Encoding UTF8

    # Show success
    Write-Host "`nWindsurf device identifiers have been reset successfully!" -ForegroundColor Green
    Write-Host "`nNew Identifiers:" -ForegroundColor Yellow
    Write-Host "   telemetry.machineId    : $newMachineId"
    Write-Host "   telemetry.macMachineId : $newMacMachineId"
    Write-Host "   telemetry.devDeviceId  : $newDevDeviceId"
    Write-Host "`nBackup file location: $backupPath" -ForegroundColor Cyan
    Write-Host "`nDone! You can now restart Windsurf IDE."
    Pause
}
catch {
    Write-Host "Error while updating configuration: $_" -ForegroundColor Red
    Pause
}