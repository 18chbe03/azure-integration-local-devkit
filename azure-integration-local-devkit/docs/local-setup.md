# Local setup

## 1. Clone repo

```bash
git clone https://github.com/18chbe03/azure-integration-local-devkit.git
cd azure-integration-local-devkit
```

## 2. Add starter files

Copy the starter files into the repo root.

## 3. Start infrastructure

```bash
docker compose up -d
```

## 4. Verify

```bash
curl http://localhost:8081/health
curl http://localhost:5300/health
```

## 5. Connect a Function App

Copy `examples/function-app/local.settings.example.json` into your Function App project as `local.settings.json`.

Change queue names and API base URLs to match your integration.

## 6. Run Function App

```bash
cd path/to/your/function-app
func start --port 7071
```

## 7. Optional APIM mock

```bash
cd apim-mock/yarp
dotnet run --urls http://localhost:8080
```

Call through the mock APIM proxy:

```bash
curl -H "Ocp-Apim-Subscription-Key: local" http://localhost:8080/api/health
```
