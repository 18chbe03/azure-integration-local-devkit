using Azure.Identity;
using Azure.Messaging.EventHubs.Producer;
using Azure.Messaging.ServiceBus;
using Azure.Storage.Blobs;
using Microsoft.Extensions.Configuration;

namespace LocalDevkit.Configuration;

/// <summary>
/// Optional helper pattern for projects that use RBAC in Azure but connection strings locally.
/// Keep your Azure app settings/Bicep as-is. Add only local connection-string settings in local.settings.json.
/// </summary>
public static class AzureClientFactory
{
    public static BlobServiceClient CreateBlobServiceClient(IConfiguration configuration, string sectionName)
    {
        var connectionString = configuration[$"{sectionName}:ConnectionString"];
        if (!string.IsNullOrWhiteSpace(connectionString))
        {
            return new BlobServiceClient(connectionString);
        }

        var blobServiceUri = configuration[$"{sectionName}:BlobServiceUri"]
            ?? throw new InvalidOperationException($"Missing configuration '{sectionName}:BlobServiceUri'.");

        return new BlobServiceClient(new Uri(blobServiceUri), new DefaultAzureCredential());
    }

    public static ServiceBusClient CreateServiceBusClient(IConfiguration configuration, string connectionName = "ServiceBusConnection")
    {
        var connectionString = configuration[connectionName];
        if (!string.IsNullOrWhiteSpace(connectionString) && connectionString.Contains("Endpoint=sb://", StringComparison.OrdinalIgnoreCase))
        {
            return new ServiceBusClient(connectionString);
        }

        var fullyQualifiedNamespace = configuration[$"{connectionName}:fullyQualifiedNamespace"]
            ?? configuration[$"{connectionName}__fullyQualifiedNamespace"]
            ?? throw new InvalidOperationException($"Missing Service Bus namespace for '{connectionName}'.");

        return new ServiceBusClient(fullyQualifiedNamespace, new DefaultAzureCredential());
    }

    public static EventHubProducerClient CreateEventHubProducerClient(
        IConfiguration configuration,
        string sectionName = "NodiniteConfiguration:EventHubSettings")
    {
        var connectionString = configuration[$"{sectionName}:ConnectionString"];
        var eventHubName = configuration[$"{sectionName}:EventHubName"];

        if (!string.IsNullOrWhiteSpace(connectionString))
        {
            return string.IsNullOrWhiteSpace(eventHubName)
                ? new EventHubProducerClient(connectionString)
                : new EventHubProducerClient(connectionString, eventHubName);
        }

        var fullyQualifiedNamespace = configuration[$"{sectionName}:FullyQualifiedNamespace"]
            ?? throw new InvalidOperationException($"Missing Event Hub namespace for '{sectionName}'.");

        if (string.IsNullOrWhiteSpace(eventHubName))
        {
            throw new InvalidOperationException($"Missing Event Hub name for '{sectionName}'.");
        }

        return new EventHubProducerClient(fullyQualifiedNamespace, eventHubName, new DefaultAzureCredential());
    }
}
