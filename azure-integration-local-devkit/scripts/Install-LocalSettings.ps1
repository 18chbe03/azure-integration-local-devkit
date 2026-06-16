param(
    [Parameter(Mandatory = $true)]
    [string]$FunctionAppPath,

    [string]$Integration = "default",

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$template = Join-Path $repoRoot "config/local-settings/$Integration.local.settings.template.json"
if (-not (Test-Path $template)) {
    $template = Join-Path $repoRoot "config/local-settings/default.local.settings.template.json"
}

if (-not (Test-Path $FunctionAppPath)) {
    throw "FunctionAppPath does not exist: $FunctionAppPath"
}

$target = Join-Path $FunctionAppPath "local.settings.json"
if ((Test-Path $target) -and -not $Force) {
    $backup = "$target.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $target $backup
    Write-Host "Existing local.settings.json backed up to $backup"
}

Copy-Item $template $target -Force
Write-Host "Copied $template to $target"
Write-Host "Review local.settings.json before starting the Function App."
