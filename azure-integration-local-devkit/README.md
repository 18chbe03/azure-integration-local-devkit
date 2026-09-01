# azure-integration-local-devkit

Local development and test environment for Azure integration projects.

This repo is intended to help developers run and test Azure integration flows locally before deploying to Azure.

## Includes

- Azurite for local Blob, Queue and Table Storage
- Azure Service Bus Emulator for local queues/topics/subscriptions
- Azure Event Hubs Emulator for local Event Hub producer/consumer tests
- Local SFTP server for integrations that read/write files over SFTP
- WireMock for mocked external APIs
- Optional YARP-based APIM mock/proxy
- Example local settings for Azure Functions and Logic Apps Standard

## Prerequisites

Install these first:

- Docker Desktop
- .NET 8 SDK
- Azure Functions Core Tools v4
- Visual Studio or Visual Studio Code
- Azure Logic Apps Standard VS Code extension
- Optional: FileZilla for browsing the local SFTP server
- Optional: QueueExplorer for browsing the local Service Bus Emulator

## Quick start

```bash
# Start local infrastructure
docker compose up -d

# Check  containers
docker ps

# Check Service Bus emulator health
curl http://localhost:5300/health

# Check mock API
curl http://localhost:8081/health
```

Restart the environment after changing emulator configuration:

```powershell
docker compose down
docker compose up -d
```

## Local endpoints

| Service | URL / Connection |
|---|---|
| Azurite Blob | http://localhost:10000 |
| Azurite Queue | http://localhost:10001 |
| Azurite Table | http://localhost:10002 |
| WireMock | http://localhost:8081 |
| Local SFTP | `sftp://localhost:2222` |
| Service Bus Emulator health/admin | http://localhost:5300 |
| Service Bus Emulator AMQP | `localhost:5672` |
| Event Hubs Emulator health | http://localhost:5301/health |
| Event Hubs Emulator AMQP | `localhost:5673` |
| Event Hubs Emulator Kafka | `localhost:9092` |
| APIM Mock / YARP | http://localhost:8080 |

## Local connection strings

### Storage

Use this in local Function App or Logic App settings:

```text
UseDevelopmentStorage=true
```

### Service Bus

Use this for normal queue/topic send and receive:

```text
Endpoint=sb://localhost;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;
```

The Service Bus used locally is the Microsoft Azure Service Bus Emulator running in Docker.

```text
Local Function App
        |
        v
Azure.Messaging.ServiceBus
        |
        v
Local Service Bus Emulator
```

No messages are sent to the real Azure Service Bus while the Function App is configured with the local emulator connection string.

The same Azure SDK is still used, which means send/receive behavior can be tested locally without requiring Azure resources.

> Managed Identity, Azure RBAC and other Azure-specific authentication behavior must still be tested in Dev/UAT.

## Service Bus entities

Queues, topics and subscriptions are configured in:

```text
servicebus/Config.json
```

Use the same entity names locally as the real integration where possible.

Example:

```json
{
  "Name": "sbt-int1177-salesprice",
  "Subscriptions": [
    {
      "Name": "sbts-int1177-salesprice-intershop"
    }
  ]
}
```

After changing `Config.json`, restart the emulator:

```powershell
docker compose down
docker compose up -d
```

The Service Bus Emulator loads the configuration when it starts.

## Inspect Service Bus messages with QueueExplorer

QueueExplorer can be used to inspect local queues, topics, subscriptions and messages.

Download QueueExplorer:

https://www.cogin.com/mq/

Create a new Azure Service Bus connection and select:

```text
Connection type: Emulator

Host:        localhost
AMQP port:   5672
Admin port:  5300
Transport:   AMQP
```

Then select:

```text
Save & Connect
```

You should now be able to browse entities such as:

```text
Topics
└── sbt-int1177-salesprice
    └── sbts-int1177-salesprice-intershop
```

When inspecting test messages, use **Peek** where possible instead of Receive/Delete so the message remains available.

Example:

```text
Local SFTP
    |
    v
INT1177
    |
    v
sbt-int1177-salesprice
    |
    v
sbts-int1177-salesprice-intershop
    |
    v
QueueExplorer
```

In QueueExplorer you can inspect the message body and properties such as:

```text
ContentType
CorrelationId
Subject
FileName
PriceType
Destination
```

### Verify Service Bus ports

If QueueExplorer cannot connect, verify the Docker port mappings:

```powershell
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

Expected Service Bus output:

```text
servicebus-emulator   0.0.0.0:5300->5300/tcp, 0.0.0.0:5672->5672/tcp
```

If different host ports are configured in `docker-compose.yml`, use those ports in QueueExplorer instead.

## Local SFTP

The devkit contains a local SFTP server for integrations that normally read or write files using SFTP.

Default connection:

```text
Host:     localhost
Protocol: SFTP
Port:     2222
Username: local
Password: local
```

### FileZilla

When using FileZilla, use:

```text
Host:     sftp://localhost
Username: local
Password: local
Port:     2222
```

Make sure the host starts with:

```text
sftp://
```

Otherwise FileZilla may try to connect using normal FTP instead of SFTP.

Example SFTP folders:

```text
/upload/salesprice
/upload/rategroup
```

These map to folders in the devkit repository:

```text
sftp/
├── salesprice/
└── rategroup/
```

Example Function App settings:

```json
{
  "Sftp__Host": "localhost",
  "Sftp__Port": "2222",
  "Sftp__Username": "local",
  "Sftp__Password": "local",
  "SalesPrice__Path": "/upload/salesprice",
  "RateGroupPrice__Path": "/upload/rategroup"
}
```

You can also inspect the SFTP container directly:

```powershell
docker exec local-sftp ls -la /home/local/upload
```

SalesPrice:

```powershell
docker exec local-sftp ls -la /home/local/upload/salesprice
```

RateGroup:

```powershell
docker exec local-sftp ls -la /home/local/upload/rategroup
```

## Testing an SFTP -> Service Bus integration

A typical local integration test looks like this:

```text
Test XML file
      |
      v
Local SFTP
localhost:2222
      |
      v
Azure Function running locally
      |
      v
Service Bus Emulator
localhost:5672
      |
      v
Topic / Queue / Subscription
      |
      v
QueueExplorer
```

Example workflow:

1. Start the local infrastructure.

```powershell
docker compose up -d
```

2. Verify that the containers are running.

```powershell
docker ps
```

3. Start the Azure Function locally.

4. Upload a test file using FileZilla.

Example:

```text
/upload/salesprice/TestSalesPrice.xml
```

5. Wait for the Function trigger or timer to process the file.

6. Check the Function console for successful processing.

7. Open QueueExplorer.

8. Browse to the target queue or topic subscription.

Example:

```text
Topics
└── sbt-int1177-salesprice
    └── sbts-int1177-salesprice-intershop
```

9. Peek the message.

10. Verify:

- XML body
- Correlation ID
- Subject
- Application properties
- Destination/routing properties

This verifies that the integration can:

```text
Read SFTP
    ->
Deserialize/process the message
    ->
Send using Azure.Messaging.ServiceBus
    ->
Store the message in the local Service Bus Emulator
```

without using real Azure infrastructure.

## Example INT1177 local setup

Example `local.settings.json` values:

```json
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",

    "AzureWebJobsStorage": "UseDevelopmentStorage=true",

    "AZURE_FUNCTIONS_ENVIRONMENT": "Development",
    "DOTNET_ENVIRONMENT": "Development",
    "ASPNETCORE_ENVIRONMENT": "Development",
    "MEKO_LOCAL_MODE": "true",

    "ServiceBus__ConnectionString": "Endpoint=sb://localhost;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;",

    "SalesPrice__TopicName": "sbt-int1177-salesprice",
    "RateGroupPrice__TopicName": "sbt-int1177-rategroup",

    "Sftp__Host": "localhost",
    "Sftp__Port": "2222",
    "Sftp__Username": "local",
    "Sftp__Password": "local",

    "SalesPrice__Path": "/upload/salesprice",
    "RateGroupPrice__Path": "/upload/rategroup",

    "TimerSchedule": "*/30 * * * * *"
  }
}
```

The local INT1177 flow becomes:

```text
FileZilla
   |
   v
Local SFTP
   |
   v
INT1177 Function App
   |
   +--> sbt-int1177-salesprice
   |
   └--> sbt-int1177-rategroup
             |
             v
      Service Bus Emulator
             |
             v
        QueueExplorer
```

## Where to start

1. Start `docker compose up -d`.
2. Verify the containers with `docker ps`.
3. Verify WireMock and Service Bus health.
4. Verify local SFTP if the integration uses SFTP.
5. Copy `examples/function-app/local.settings.example.json` to the Function App as `local.settings.json`.
6. Add the required queues/topics/subscriptions to `servicebus/Config.json`.
7. Restart Docker after changing Service Bus configuration.
8. Point external API URLs to `http://localhost:8081` when WireMock should be used.
9. Start the Function App locally.
10. Use FileZilla, QueueExplorer and Azurite tooling to inspect the complete flow.

## Recommended workflow

For daily development:

```text
SFTP / Function App
        |
        v
Service Bus Emulator
        |
        +--> WireMock
        |
        +--> Azurite
```

For real Azure configuration validation:

```text
APIM Developer
      |
      v
Function App Dev
      |
      v
Service Bus Dev
      |
      v
Storage Dev
      |
      v
Key Vault Dev
```

## Run real integrations locally

Start all local dependencies:

```powershell
.\scripts\start-local.ps1
.\scripts\Test-LocalEnvironment.ps1
```

Generate local settings for a Function App:

```powershell
.\scripts\Install-LocalSettings.ps1 `
  -Integration INT1185 `
  -FunctionAppPath "C:\Dev\INT1185\src\INT1185.Functions"
```

Initialize Azurite containers/tables/queues if the integration needs them:

```powershell
.\storage\init-storage.ps1
```

More details:

```text
docs/running-real-integrations.md
```
