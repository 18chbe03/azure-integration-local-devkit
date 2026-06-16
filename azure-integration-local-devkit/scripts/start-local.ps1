Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

Write-Host "Starting local Azure integration dependencies..."
docker compose up -d

Write-Host ""
Write-Host "Started. Run this to verify:"
Write-Host "  .\scripts\Test-LocalEnvironment.ps1"
