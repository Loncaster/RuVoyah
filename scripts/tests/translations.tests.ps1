Describe 'translation tools' {
    It 'returns the user-facing app to overlay mapping' {
        . "$PSScriptRoot/../translation-tools.ps1"

        $map = Get-TranslationProjectMap

        $map.Keys | Should Be @(
            'setting',
            'launcher',
            'vehicle',
            'vehiclesetting',
            'hiboard',
            'bluetoothphone',
            'dvr'
        )
        $map['setting'] | Should Be 'ruvoyahoverlaysetting'
        $map['vehiclesetting'] | Should Be 'ruvoyahoverlayvehiclesetting'
    }

    It 'copies a canonical strings.xml into all three destination folders' {
        . "$PSScriptRoot/../translation-tools.ps1"

        $tempRoot = Join-Path $env:TEMP ('ruvoyah-sync-test-' + [guid]::NewGuid().ToString('N'))
        $repoRoot = Join-Path $tempRoot 'repo'
        $translationsDir = Join-Path $repoRoot 'translations/setting'
        $overlayDir = Join-Path $repoRoot 'source code/ruvoyahoverlaysetting/app/src/main/res'

        try {
            New-Item -ItemType Directory -Force $translationsDir | Out-Null
            foreach ($folder in @('values', 'values-en', 'values-zh')) {
                New-Item -ItemType Directory -Force (Join-Path $overlayDir $folder) | Out-Null
            }

            $content = @'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Настройки</string>
</resources>
'@
            $sourcePath = Join-Path $translationsDir 'strings.xml'
            Set-Content -LiteralPath $sourcePath -Value $content -Encoding UTF8

            Sync-TranslationResources -RepoRoot $repoRoot -App 'setting'

            $expected = Get-Content -Raw $sourcePath
            foreach ($folder in @('values', 'values-en', 'values-zh')) {
                $target = Join-Path $overlayDir "$folder/strings.xml"
                (Get-Content -Raw $target) | Should Be $expected
            }
        }
        finally {
            if (Test-Path $tempRoot) {
                Remove-Item -LiteralPath $tempRoot -Recurse -Force
            }
        }
    }

    It 'creates missing destination folders before copying translations' {
        . "$PSScriptRoot/../translation-tools.ps1"

        $tempRoot = Join-Path $env:TEMP ('ruvoyah-sync-missing-dir-test-' + [guid]::NewGuid().ToString('N'))
        $repoRoot = Join-Path $tempRoot 'repo'
        $translationsDir = Join-Path $repoRoot 'translations/setting'
        $resourceRoot = Join-Path $repoRoot 'source code/ruvoyahoverlaysetting/app/src/main/res'

        try {
            New-Item -ItemType Directory -Force $translationsDir | Out-Null
            New-Item -ItemType Directory -Force $resourceRoot | Out-Null

            $content = @'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Настройки</string>
</resources>
'@
            Set-Content -LiteralPath (Join-Path $translationsDir 'strings.xml') -Value $content -Encoding UTF8

            Sync-TranslationResources -RepoRoot $repoRoot -App 'setting'

            foreach ($folder in @('values', 'values-en', 'values-zh')) {
                $target = Join-Path $resourceRoot "$folder/strings.xml"
                Test-Path -LiteralPath $target | Should Be $true
            }
        }
        finally {
            if (Test-Path $tempRoot) {
                Remove-Item -LiteralPath $tempRoot -Recurse -Force
            }
        }
    }

    It 'resolves every expected user-facing app name' {
        . "$PSScriptRoot/../translation-tools.ps1"

        foreach ($app in @('setting', 'launcher', 'vehicle', 'vehiclesetting', 'hiboard', 'bluetoothphone', 'dvr')) {
            { Get-TranslationProject -App $app } | Should Not Throw
        }
    }

    It 'returns the expected build context for a user-facing app' {
        . "$PSScriptRoot/../translation-tools.ps1"

        $context = Get-OverlayBuildContext -RepoRoot 'C:\Repo' -App 'setting'

        $context.ProjectRoot | Should Be 'C:\Repo\source code\ruvoyahoverlaysetting'
        $context.ApkPath | Should Be 'C:\Repo\source code\ruvoyahoverlaysetting\app\build\outputs\apk\debug\ru.voyah.overlay.setting.apk'
    }
}
