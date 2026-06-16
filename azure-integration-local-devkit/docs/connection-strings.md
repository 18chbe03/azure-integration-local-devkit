# Connection strings

## Azurite

Use this for most local .NET/Azure SDK scenarios:

```text
UseDevelopmentStorage=true
```

Ports:

```text
Blob  = http://localhost:10000
Queue = http://localhost:10001
Table = http://localhost:10002
```

## Service Bus Emulator

Runtime operations:

```text
Endpoint=sb://localhost;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;
```

Management/admin operations:

```text
Endpoint=sb://localhost:5300;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=SAS_KEY_VALUE;UseDevelopmentEmulator=true;
```

## Mock external API

```text
http://localhost:8081
```

Example:

```bash
curl http://localhost:8081/customers/123
```

## APIM mock / YARP

```text
http://localhost:8080
```

Example:

```bash
curl -H "Ocp-Apim-Subscription-Key: local" http://localhost:8080/mock/health
```
