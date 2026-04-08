$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$projects = @(
    "ruvoyahoverlaybluetoothphone",
    "ruvoyahoverlaydvr",
    "ruvoyahoverlayhiboard",
    "ruvoyahoverlaylauncher",
    "ruvoyahoverlaysetting",
    "ruvoyahoverlayvehicle",
    "ruvoyahoverlayvehiclesetting"
)

foreach ($project in $projects) {
    $projectRoot = Join-Path $repoRoot "source code\$project"
    Write-Host "Building $project..."

    Push-Location $projectRoot
    try {
        & .\gradlew.bat clean assembleDebug --no-daemon
        if ($LASTEXITCODE -ne 0) {
            throw "Build failed for $project"
        }
    }
    finally {
        Pop-Location
    }
}

Write-Host "All overlay projects built successfully."
