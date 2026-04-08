param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$tags = @(git tag --list)

$majorCandidates = foreach ($tag in $tags) {
    if ($tag -match '^major/(?<major>\d+)$') {
        [int]$Matches.major
    }
}

if (@($majorCandidates).Count -gt 0) {
    $currentMajor = ($majorCandidates | Measure-Object -Maximum).Maximum
}
else {
    $releaseMajorCandidates = foreach ($tag in $tags) {
        if ($tag -match '^v(?<major>\d+)\.(?<minor>\d+)(?:$|[.-])') {
            [int]$Matches.major
        }
    }

    if (@($releaseMajorCandidates).Count -gt 0) {
        $currentMajor = ($releaseMajorCandidates | Measure-Object -Maximum).Maximum
    }
    else {
        $currentMajor = 0
    }
}

$minorCandidates = foreach ($tag in $tags) {
    if ($tag -match ("^v{0}\.(?<minor>\d+)(?:$|[.-])" -f $currentMajor)) {
        [int]$Matches.minor
    }
}

if (@($minorCandidates).Count -gt 0) {
    $nextMinor = (($minorCandidates | Measure-Object -Maximum).Maximum) + 1
}
else {
    $nextMinor = 0
}

$version = "{0}.{1}" -f $currentMajor, $nextMinor
$releaseTag = "v{0}" -f $version
$releaseName = "RuVoyah {0}" -f $version
$majorTag = "major/{0}" -f $currentMajor

[PSCustomObject]@{
    major = $currentMajor
    minor = $nextMinor
    version = $version
    release_tag = $releaseTag
    release_name = $releaseName
    major_tag = $majorTag
} | ConvertTo-Json -Compress
