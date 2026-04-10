$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Get-TranslationProjectMap {
    return [ordered]@{
        setting = "ruvoyahoverlaysetting"
        launcher = "ruvoyahoverlaylauncher"
        vehicle = "ruvoyahoverlayvehicle"
        vehiclesetting = "ruvoyahoverlayvehiclesetting"
        hiboard = "ruvoyahoverlayhiboard"
        bluetoothphone = "ruvoyahoverlaybluetoothphone"
        dvr = "ruvoyahoverlaydvr"
    }
}

function Get-TranslationProject {
    param(
        [Parameter(Mandatory = $true)]
        [string]$App
    )

    $map = Get-TranslationProjectMap
    if (-not $map.Contains($App)) {
        $allowed = ($map.Keys -join ", ")
        throw "Unknown app '$App'. Allowed values: $allowed"
    }

    return [string]$map[$App]
}

function Get-TranslationApps {
    return [string[]](Get-TranslationProjectMap).Keys
}

function Get-OverlayBuildContext {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRoot,

        [Parameter(Mandatory = $true)]
        [string]$App
    )

    $project = Get-TranslationProject -App $App
    $projectRoot = Join-Path $RepoRoot "source code/$project"
    $apkPath = Join-Path $projectRoot "app/build/outputs/apk/debug/ru.voyah.overlay.$App.apk"

    return [pscustomobject]@{
        App = $App
        Project = $project
        ProjectRoot = $projectRoot
        ApkPath = $apkPath
    }
}

function Sync-TranslationResources {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepoRoot,

        [string]$App
    )

    $apps = if ($PSBoundParameters.ContainsKey("App")) {
        @($App)
    }
    else {
        Get-TranslationApps
    }

    foreach ($currentApp in $apps) {
        $context = Get-OverlayBuildContext -RepoRoot $RepoRoot -App $currentApp
        $sourcePath = Join-Path $RepoRoot "translations/$currentApp/strings.xml"
        if (-not (Test-Path -LiteralPath $sourcePath)) {
            throw "Missing canonical translation file: $sourcePath"
        }

        $resourceRoot = Join-Path $context.ProjectRoot "app/src/main/res"
        foreach ($folder in @("values", "values-en", "values-zh")) {
            $destinationDir = Join-Path $resourceRoot $folder
            New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null

            Copy-Item -LiteralPath $sourcePath -Destination (Join-Path $destinationDir "strings.xml") -Force
        }
    }
}
