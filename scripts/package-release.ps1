param(
    [Parameter(Mandatory = $true)]
    [string]$OutputRoot,

    [Parameter(Mandatory = $true)]
    [string]$Version,

    [Parameter(Mandatory = $true)]
    [ValidateSet("stable", "preview")]
    [string]$Channel
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$packageName = "RuVoyah_{0}_{1}" -f $Version, $Channel
$packageRoot = Join-Path $OutputRoot $packageName
$overlayRoot = Join-Path $packageRoot "overlay apk"
$archivePath = Join-Path $OutputRoot ($packageName + ".zip")

$apkFiles = @(
    "source code\ruvoyahoverlaybluetoothphone\app\build\outputs\apk\debug\ru.voyah.overlay.bluetoothphone.apk",
    "source code\ruvoyahoverlaydvr\app\build\outputs\apk\debug\ru.voyah.overlay.dvr.apk",
    "source code\ruvoyahoverlayhiboard\app\build\outputs\apk\debug\ru.voyah.overlay.hiboard.apk",
    "source code\ruvoyahoverlaylauncher\app\build\outputs\apk\debug\ru.voyah.overlay.launcher.apk",
    "source code\ruvoyahoverlaysetting\app\build\outputs\apk\debug\ru.voyah.overlay.setting.apk",
    "source code\ruvoyahoverlayvehicle\app\build\outputs\apk\debug\ru.voyah.overlay.vehicle.apk",
    "source code\ruvoyahoverlayvehiclesetting\app\build\outputs\apk\debug\ru.voyah.overlay.vehiclesetting.apk"
)

$rootFiles = @(
    "adb",
    "adb.exe",
    "AdbWinApi.dll",
    "AdbWinUsbApi.dll",
    "install_win.bat",
    "install_mac.sh",
    "uninstall_win.bat",
    "uninstall_mac.sh",
    "disable-verity_win.bat",
    "disable-verity_mac.sh",
    "license.txt",
    "version.txt"
)

if (Test-Path $packageRoot) {
    Remove-Item -LiteralPath $packageRoot -Recurse -Force
}

if (Test-Path $archivePath) {
    Remove-Item -LiteralPath $archivePath -Force
}

New-Item -ItemType Directory -Path $packageRoot -Force | Out-Null
New-Item -ItemType Directory -Path $overlayRoot -Force | Out-Null

foreach ($file in $rootFiles) {
    Copy-Item -LiteralPath (Join-Path $repoRoot $file) -Destination $packageRoot -Force
}

foreach ($relativeApk in $apkFiles) {
    $apkPath = Join-Path $repoRoot $relativeApk
    if (-not (Test-Path $apkPath)) {
        throw "Missing built APK: $apkPath"
    }

    Copy-Item -LiteralPath $apkPath -Destination $overlayRoot -Force
}

$readmeText = @"
RuVoyah package: $Channel
Version: $Version

1. Connect the vehicle over adb.
2. Run disable-verity if required by your firmware.
3. Run install_win.bat on Windows or install_mac.sh on macOS.
4. To remove overlays, run uninstall_win.bat or uninstall_mac.sh.
"@

Set-Content -LiteralPath (Join-Path $packageRoot "README.txt") -Value $readmeText -Encoding UTF8

Compress-Archive -Path (Join-Path $packageRoot "*") -DestinationPath $archivePath -Force

Write-Host "Created package: $archivePath"
