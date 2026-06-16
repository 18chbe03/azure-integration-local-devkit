# azure-integration-local-devkit

Local development and test environment for Azure integration projects.

This repo is intended to help developers run and test Azure integration flows locally before deploying to Azure.

## Includes

- Azurite for local Blob, Queue and Table Storage
- Azure Service Bus Emulator for local queues/topics/subscriptions
- Azure Event Hubs Emulator for local Event Hub producer/consumer tests
- Azurite for Blob/Queue/Table Storage
- WireMock for mocked external APIs
- Optional YARP-based APIM mock/proxy
- Example local settings for Azure Functions and Logic Apps Standard

## Prerequisites

Install these first:

- Docker Desktop
- .NET 8 SDK
- Azure Functions Core Tools v4
- Visual Studio Code
- Azure Logic Apps Standard VS Code extension

## Quick start

```bash
# Start local infrastructure
docker compose up -d

# Check containers
docker ps

# Check Service Bus emulator health
curl http://localhost:5300/health

# Check mock API
curl http://localhost:8081/health
```

## Local endpoints

| Service | URL / Connection |
|---|---|
| Azurite Blob | http://localhost:10000 |
| Azurite Queue | http://localhost:10001 |
| Azurite Table | http://localhost:10002 |
| WireMock | http://localhost:8081 |
| Service Bus Emulator health | http://localhost:5300/health |
| Service Bus Emulator AMQP | localhost:5672 |
| Event Hubs Emulator health | http://localhost:5301/health |
| Event Hubs Emulator AMQP | localhost:5673 |
| Event Hubs Emulator Kafka | localhost:9092 |
| APIM Mock / YARP | http://localhost:8080 |

## Local connection strings

### Storage

Use this in local Function App or Logic App settings:

```text
UseDevelopmentStorage=true
```

### Service Bus runtime

Use this for normal queue/topic send/receive:

```text
Endpoint=sb://localhost;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;
```

### Service Bus management/admin

Use this if code uses `ServiceBusAdministrationClient`:

```text
Endpoint=sb://localhost:5300;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;
```

## Where to start

1. Start `docker compose up -d`.
2. Verify WireMock and Service Bus health.
3. Copy `examples/function-app/local.settings.example.json` to your Function App as `local.settings.json`.
4. Replace queue names in `servicebus/Config.json` with your real integration queue names.
5. Point your Function App external API base URLs to `http://localhost:8081`.
6. Only after that, add APIM mock/proxy if you need APIM-like routes locally.

## Recommended workflow

For daily development, test code locally:

```text
Function App -> Service Bus Emulator -> Mock API -> Azurite
```

For real Azure configuration validation, test in dev/UAT:

```text
APIM Developer -> Function App Dev -> Service Bus Dev -> Storage Dev -> Key Vault Dev
```


## Run real integrations locally

Start all local dependencies:

```powershell
.\scripts\start-local.ps1
.\scripts\Test-LocalEnvironment.ps1
```

Generate local settings for a Function App:

```powershell
.\scripts\Install-LocalSettings.ps1 -Integration INT1185 -FunctionAppPath "C:\Dev\INT1185\src\INT1185.Functions"
```

Initialize Azurite containers/tables/queues if your integration needs them:

```powershell
.\storage\init-storage.ps1
```

More details: `docs/running-real-integrations.md`.
