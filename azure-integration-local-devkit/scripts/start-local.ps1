Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Starting local Azure integration devkit..."
docker compose up -d

Write-Host ""
Write-Host "Waiting a few seconds before health checks..."
Start-Sleep -Seconds 10

Write-Host "WireMock health:"
try { Invoke-RestMethod "http://localhost:8081/health" | ConvertTo-Json } catch { Write-Warning $_ }

Write-Host ""
Write-Host "Service Bus Emulator health:"
try { Invoke-RestMethod "http://localhost:5300/health" | ConvertTo-Json } catch { Write-Warning $_ }
