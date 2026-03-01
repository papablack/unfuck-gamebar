# =====================================================================
#  Disable Game Bar, GameDVR and remove ms-gamebar/ms-gamingoverlay
#  Extremely verbose diagnostic version (parser-safe)
# =====================================================================

Write-Host "=== Starting Game Bar / GamingOverlay cleanup ===" -ForegroundColor Cyan

function Log-Step($msg) {
    Write-Host "[*] $msg" -ForegroundColor Yellow
}

function Log-OK($msg) {
    Write-Host "[OK] $msg" -ForegroundColor Green
}

function Log-ERR($msg) {
    Write-Host "[ERR] $msg" -ForegroundColor Red
}

# ---------------------------------------------------------------------
# Disable Game Bar settings
# ---------------------------------------------------------------------
Log-Step "Creating or opening HKCU:\Software\Microsoft\GameBar"

try {
    New-Item -Path "HKCU:\Software\Microsoft\GameBar" -Force | Out-Null
    Log-OK "GameBar key ensured"
} catch {
    Log-ERR ("Failed to create GameBar key: {0}" -f $_)
}

$gamebarSettings = @{
    "ShowStartupPanel" = 0
    "GamePanelStartupTipIndex" = 3
    "AllowAutoGameMode" = 0
    "AutoGameModeEnabled" = 0
}

foreach ($name in $gamebarSettings.Keys) {
    Log-Step ("Setting GameBar value '{0}' to {1}" -f $name, $gamebarSettings[$name])
    try {
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name $name -Value $gamebarSettings[$name] -Type DWord
        Log-OK ("Set {0}" -f $name)
    } catch {
        Log-ERR ("Failed to set {0}: {1}" -f $name, $_)
    }
}

# ---------------------------------------------------------------------
# Disable Game DVR
# ---------------------------------------------------------------------
Log-Step "Creating or opening HKCU:\System\GameConfigStore"

try {
    New-Item -Path "HKCU:\System\GameConfigStore" -Force | Out-Null
    Log-OK "GameConfigStore key ensured"
} catch {
    Log-ERR ("Failed to create GameConfigStore key: {0}" -f $_)
}

$gamedvrSettings = @{
    "GameDVR_Enabled" = 0
    "GameDVR_FSEBehaviorMode" = 2
    "GameDVR_HonorUserFSEBehaviorMode" = 1
}

foreach ($name in $gamedvrSettings.Keys) {
    Log-Step ("Setting GameDVR value '{0}' to {1}" -f $name, $gamedvrSettings[$name])
    try {
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name $name -Value $gamedvrSettings[$name] -Type DWord
        Log-OK ("Set {0}" -f $name)
    } catch {
        Log-ERR ("Failed to set {0}: {1}" -f $name, $_)
    }
}

# ---------------------------------------------------------------------
# Disable Game DVR via policy
# ---------------------------------------------------------------------
Log-Step "Creating or opening HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"

try {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Force | Out-Null
    Log-OK "GameDVR policy key ensured"
} catch {
    Log-ERR ("Failed to create GameDVR policy key: {0}" -f $_)
}

Log-Step "Setting AllowGameDVR policy to 0"
try {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Type DWord
    Log-OK "Policy applied"
} catch {
    Log-ERR ("Failed to set policy: {0}" -f $_)
}

# ---------------------------------------------------------------------
# Remove protocol handlers
# ---------------------------------------------------------------------
$protocols = @(
    "HKCR:\ms-gamebar",
    "HKCR:\ms-gamingoverlay",
    "HKCR:\ms-gamebarservices",
    "HKCR:\ms-gamebarservicesui"
)

foreach ($p in $protocols) {
    Log-Step ("Checking protocol: {0}" -f $p)
    if (Test-Path $p) {
        Log-Step ("Protocol exists, removing: {0}" -f $p)
        try {
            Remove-Item $p -Recurse -Force
            Log-OK ("Removed protocol: {0}" -f $p)
        } catch {
            Log-ERR ("Failed to remove {0}: {1}" -f $p, $_)
        }
    } else {
        Log-OK ("Protocol not present (already removed): {0}" -f $p)
    }
}

# ---------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------
Write-Host "`n=== Cleanup complete ===" -ForegroundColor Cyan
