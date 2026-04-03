#
# Syntax: test.ps1
# Options:
#   -c (Optional) Clean test_result folders.
#   -h (Optional) Display help and exit.
#

[CmdletBinding()] param(
    [switch]$c,
    [switch]$h
)

if ($h.IsPresent) {
    Write-Output "Syntax: test.ps1 [Options]"
    Write-Output "Options:"
    Write-Output "  -c (Optional) Clean test_result folders and exit."
    Write-Output "  -h (Optional) Display this help and exit."
    exit 0
}

if ($c.IsPresent) {
    Write-Host " =====[ CLEANING TEST RESULTS DIRS ]===== " -ForegroundColor Black -BackgroundColor Magenta
    git clean -dxf -e ".godot" -e "build" -e "artifact"
    Write-Host "[ DONE ]" -ForegroundColor Magenta
    exit 0
}

$projectName = "AIKIOPA"

$repositoryPath = $PSScriptRoot
$artifactDirectory = Join-Path -Path $repositoryPath -ChildPath "test_results"

Write-Host " =====[ GODOT PROJECT REPOSITORY INFORMATION ]===== " -ForegroundColor Black -BackgroundColor Yellow
Write-Host "- Repository path: $repositoryPath" -ForegroundColor Yellow
Write-Host "- Artifact path: $artifactDirectory" -ForegroundColor Yellow

Write-Host " =====[ RUNNING PROJECT TESTS ]===== " -ForegroundColor Black -BackgroundColor Magenta

Write-Host "Importing project..." -ForegroundColor Yellow
godot --headless --import --path $repositoryPath --quit | Out-Default

Write-Host "Running tests..." -ForegroundColor Magenta
if (-not (Test-Path -Path $artifactDirectory)) {
    New-Item -ItemType Directory -Path $artifactDirectory | Out-Null
}
godot --headless --debug --path $repositoryPath --script addons/gut/gut_cmdln.gd | Out-Default

Write-Host "[ DONE ]" -ForegroundColor Black -BackgroundColor Magenta
