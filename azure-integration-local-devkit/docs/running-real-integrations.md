# Running real integrations locally

The devkit is intended to run real Azure integration projects locally with minimal code and template changes.

## Target architecture

```text
Function App / Logic App Standard
  -> Azurite for Blob/Queue/Table
  -> Service Bus Emulator for queues/topics/subscriptions
  -> Event Hubs Emulator for Event Hub producer/consumer tests
  -> WireMock for external HTTP APIs
```

## Main rule

Keep the same app setting names as Azure, but override the values in `local.settings.json`.

Azure deployment templates should keep managed identity/RBAC settings.
Local testers should use connection strings to local emulators.

## Storage

For Function runtime storage:

```json
"AzureWebJobsStorage": "UseDevelopmentStorage=true"
```

For BlobTrigger bindings that use identity in Azure, use a local connection string setting with the same connection name:

```json
"StocklevelsTrigger": "UseDevelopmentStorage=true"
```

For custom Blob SDK clients, prefer this pattern:

```json
"Stocklevels__ConnectionString": "UseDevelopmentStorage=true",
"Stocklevels__BlobServiceUri": "http://127.0.0.1:10000/devstoreaccount1"
```

Code can use `ConnectionString` locally and `BlobServiceUri + DefaultAzureCredential` in Azure.

## Service Bus

For ServiceBusTrigger and sender/receiver clients:

```json
"ServiceBusConnection": "Endpoint=sb://localhost;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;"
```

For administration client operations:

```json
"ServiceBusAdminConnection": "Endpoint=sb://localhost:5300;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;"
```

Queues/topics/subscriptions are declared in `servicebus/Config.json`.
Restart Docker after changing it.

## Event Hubs

This devkit runs Event Hubs Emulator on host port `5673` to avoid conflict with Service Bus on `5672`.

```json
"EventHubConnection": "Endpoint=sb://localhost:5673;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;"
```

For Nodinite/EventHub logging, add this local-only value if the logger supports connection strings:

```json
"NodiniteConfiguration__EventHubSettings__ConnectionString": "Endpoint=sb://localhost:5673;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;"
```

If the logger only supports `FullyQualifiedNamespace + DefaultAzureCredential`, either disable Nodinite locally or add a small fallback to use the local connection string.

## Logic Apps Standard

Logic Apps Standard can use the same local settings pattern:

```json
"AzureWebJobsStorage": "UseDevelopmentStorage=true",
"ServiceBusConnection": "Endpoint=sb://localhost;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;",
"EventHubConnection": "Endpoint=sb://localhost:5673;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;"
```

Managed connectors may still require Azure connections. Built-in connectors are better for local testing.
