$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot "translation-tools.ps1")

Sync-TranslationResources -RepoRoot $repoRoot

Write-Host "Synchronized translations for all apps."
