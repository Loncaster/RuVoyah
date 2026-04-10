$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot "translation-tools.ps1")

& (Join-Path $PSScriptRoot "sync-translations.ps1")

foreach ($app in Get-TranslationApps) {
    $context = Get-OverlayBuildContext -RepoRoot $repoRoot -App $app
    Write-Host "Building $($context.Project)..."

    Push-Location $context.ProjectRoot
    try {
        & .\gradlew.bat clean assembleDebug --no-daemon
        if ($LASTEXITCODE -ne 0) {
            throw "Build failed for $($context.Project)"
        }
    }
    finally {
        Pop-Location
    }
}

Write-Host "All overlay projects built successfully."
