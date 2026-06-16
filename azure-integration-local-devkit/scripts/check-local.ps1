Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

Write-Host "Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

Write-Host ""
Write-Host "WireMock health:"
Invoke-RestMethod "http://localhost:8081/health"

Write-Host ""
Write-Host "Service Bus Emulator health:"
Invoke-RestMethod "http://localhost:5300/health"
