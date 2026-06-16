Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$account = "devstoreaccount1"
$key = "Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw=="
$connectionString = "DefaultEndpointsProtocol=http;AccountName=$account;AccountKey=$key;BlobEndpoint=http://127.0.0.1:10000/$account;QueueEndpoint=http://127.0.0.1:10001/$account;TableEndpoint=http://127.0.0.1:10002/$account;"

function Ensure-AzCli {
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        throw "Azure CLI was not found. Install Azure CLI or create containers manually in Azure Storage Explorer."
    }
}

Ensure-AzCli

$root = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Creating Azurite blob containers..."
Get-Content (Join-Path $root "containers.txt") | Where-Object { $_ -and -not $_.StartsWith("#") } | ForEach-Object {
    az storage container create --name $_ --connection-string $connectionString --only-show-errors | Out-Null
    Write-Host "  container: $_"
}

Write-Host "Creating Azurite storage queues..."
Get-Content (Join-Path $root "queues.txt") | Where-Object { $_ -and -not $_.StartsWith("#") } | ForEach-Object {
    az storage queue create --name $_ --connection-string $connectionString --only-show-errors | Out-Null
    Write-Host "  queue: $_"
}

Write-Host "Creating Azurite tables..."
Get-Content (Join-Path $root "tables.txt") | Where-Object { $_ -and -not $_.StartsWith("#") } | ForEach-Object {
    az storage table create --name $_ --connection-string $connectionString --only-show-errors | Out-Null
    Write-Host "  table: $_"
}

Write-Host "Azurite storage init done."
