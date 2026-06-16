Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

function Test-Http($Name, $Url) {
    Write-Host "Testing $Name -> $Url"
    try {
        $result = Invoke-RestMethod $Url -TimeoutSec 5
        Write-Host "  OK" -ForegroundColor Green
        if ($result) { $result | ConvertTo-Json -Depth 5 }
    }
    catch {
        Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "Docker containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""

Test-Http "WireMock" "http://localhost:8081/health"
Test-Http "Service Bus Emulator" "http://localhost:5300/health"
Test-Http "Event Hubs Emulator" "http://localhost:5301/health"

Write-Host ""
Write-Host "Expected local endpoints:"
Write-Host "  Azurite Blob:        http://127.0.0.1:10000/devstoreaccount1"
Write-Host "  Azurite Queue:       http://127.0.0.1:10001/devstoreaccount1"
Write-Host "  Azurite Table:       http://127.0.0.1:10002/devstoreaccount1"
Write-Host "  Service Bus AMQP:    localhost:5672"
Write-Host "  Event Hubs AMQP:     localhost:5673"
Write-Host "  Event Hubs Kafka:    localhost:9092"
Write-Host "  WireMock:            http://localhost:8081"
