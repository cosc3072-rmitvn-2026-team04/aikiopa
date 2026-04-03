#
# Syntax: build.ps1 [Options] -m <build-mode>
# Options:
#   -m Specify build mode. Accepted values are 'release' and 'debug'.
#   -c (Optional) Clean build folders.
#   -h (Optional) Display help and exit.
#

[CmdletBinding()] param(
    [string]$m,
    [switch]$c,
    [switch]$h
)

if ($h.IsPresent) {
    Write-Output "Syntax: build.ps1 [Options] -m <build-mode>"
    Write-Output "Options:"
    Write-Output "  -m Specify build mode. Accepted values are 'release' and 'debug'."
    Write-Output "  -c (Optional) Clean build folders."
    Write-Output "  -h (Optional) Display this help and exit."
    exit 0
}

if ($c.IsPresent) {
    Write-Host " =====[ CLEANING BUILD DIRS ]===== " -ForegroundColor Black -BackgroundColor Magenta
    git clean -dxf -e ".godot" -e "test_results"
    Write-Host "[ DONE ]" -ForegroundColor Magenta
}

$projectName = "AIKIOPA"

$repositoryPath = $PSScriptRoot
$archiveFolderPath = Join-Path -Path $repositoryPath -ChildPath "artifact"
switch ($m) {
    "" {
        Write-Host "Error: No build mode specified. Terminating." -ForegroundColor Yellow
        exit 0
    }
    "debug" {
        $archiveFolderPath = Join-Path -Path $repositoryPath -ChildPath "artifact/debug"
        $godotExportFlag = "--export-debug"
    }
    "release" {
        $archiveFolderPath = Join-Path -Path $repositoryPath -ChildPath "artifact/release"
        $godotExportFlag = "--export-release"
    }
    Default {
        Write-Host "Invalid build mode '$m'" -ForegroundColor Red
        exit 1
    }
}

Write-Host " =====[ GODOT PROJECT REPOSITORY INFORMATION ]===== " -ForegroundColor Black -BackgroundColor Yellow
Write-Host "- Repository path: $repositoryPath" -ForegroundColor Yellow
Write-Host "- Artifact path: $archiveFolderPath" -ForegroundColor Yellow

$buildModeText = $m.ToUpper()
Write-Host " =====[ EXPORTING PROJECT (MODE: $buildModeText) ]===== " -ForegroundColor Black -BackgroundColor Magenta

Write-Host "Importing project..." -ForegroundColor Yellow
godot --headless --import --path $repositoryPath --quit | Out-Default

Write-Host "Exporting project..." -ForegroundColor Yellow
$exportPresetsFile = Join-Path -Path $repositoryPath -ChildPath "export_presets.cfg"
$exportPresetsCfg = Get-Content -Path $exportPresetsFile -Raw
$exportPresets = ($exportPresetsCfg | Select-String -Pattern '\n\nname="(.*)"' -AllMatches).Matches | ForEach-Object {
    $_.Groups[1].Value
}
$exportPaths = ($exportPresetsCfg | Select-String -Pattern '\nexport_path="(.*)"' -AllMatches).Matches | ForEach-Object {
    $_.Groups[1].Value
}

foreach ($exportPreset in $exportPresets) {
    $exportPath = $exportPaths
    if ($exportPaths -is [System.Array]) {
        $exportPath = $exportPaths[$exportPresets.IndexOf($exportPreset)]
    }
    $absoluteExportPath = Join-Path -Path $repositoryPath -ChildPath $exportPath
    $exportDirectory = Split-Path -Path $absoluteExportPath -Parent
    if (-not (Test-Path -Path $exportDirectory)) {
        New-Item -ItemType Directory -Path $exportDirectory | Out-Null
    }

    Write-Host "Exporting $exportPreset ..." -ForegroundColor Yellow
    godot --headless --path $repositoryPath $godotExportFlag $exportPreset | Out-Default

    $zipFileName = "${projectName}_$exportPreset.zip"
    $zipFilePath = Join-Path -Path $archiveFolderPath -ChildPath $zipFileName
    if (-not (Test-Path -Path $archiveFolderPath)) {
        New-Item -ItemType Directory -Path $archiveFolderPath | Out-Null
    }
    if (Test-Path -Path $zipFilePath) {
        Remove-Item -Path $zipFilePath -Force
    }
    Write-Host "Archiving $exportPreset from $exportDirectory into $zipFilePath" -ForegroundColor Yellow
    Write-Host "- Source: $exportDirectory" -ForegroundColor Yellow
    Write-Host "- Target: $zipFilePath" -ForegroundColor Yellow
    Invoke-Expression -Command "zip -jr -0 '$zipFilePath' $exportDirectory"
}

Write-Host "[ DONE ]" -ForegroundColor Black -BackgroundColor Magenta
