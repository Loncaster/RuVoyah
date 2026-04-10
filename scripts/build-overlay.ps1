param(
    [Parameter(Mandatory = $true)]
    [string]$App
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot "translation-tools.ps1")

$context = Get-OverlayBuildContext -RepoRoot $repoRoot -App $App
Sync-TranslationResources -RepoRoot $repoRoot -App $App

Write-Host "Building $App ($($context.Project))..."

Push-Location $context.ProjectRoot
try {
    & .\gradlew.bat clean assembleDebug --no-daemon
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed for $App"
    }
}
finally {
    Pop-Location
}

Write-Host "Built APK: $($context.ApkPath)"
