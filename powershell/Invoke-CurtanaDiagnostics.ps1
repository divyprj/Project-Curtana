[CmdletBinding()]
param(
    [string]$OutputDirectory = "logs"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$modulePath = Join-Path $PSScriptRoot "CurtanaTools.psm1"
Import-Module $modulePath -Force

$root = Get-CurtanaRoot -StartPath (Get-Location).Path
$outputRoot = Join-Path $root $OutputDirectory
New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$reportPath = Join-Path $outputRoot "curtana-diagnostics-$timestamp.json"

$report = [ordered]@{
    generated_at = (Get-Date).ToUniversalTime().ToString("o")
    project = "Project-Curtana"
    root = $root
    adb = $null
    fastboot = $null
    notes = @(
        "Serials may appear in raw tool output. Sanitize before sharing publicly.",
        "Diagnostics are read-only."
    )
}

try {
    $report.adb = Get-CurtanaAdbDevice -Root $root
} catch {
    $report.adb = @{ error = $_.Exception.Message }
}

try {
    $report.fastboot = Get-CurtanaFastbootDevice -Root $root
} catch {
    $report.fastboot = @{ error = $_.Exception.Message }
}

$report | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $reportPath -Encoding UTF8
Write-Host "Wrote diagnostics report: $reportPath"

