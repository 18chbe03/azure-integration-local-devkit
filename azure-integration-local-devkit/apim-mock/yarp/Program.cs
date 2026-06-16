var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

var app = builder.Build();

app.MapGet("/health", () => Results.Ok(new
{
    status = "ok",
    service = "apim-mock-yarp"
}));

app.MapReverseProxy(proxyPipeline =>
{
    proxyPipeline.Use(async (context, next) =>
    {
        // Very simple local APIM-like validation.
        // Replace this later with more realistic subscription key/JWT checks if needed.
        if (!context.Request.Headers.ContainsKey("Ocp-Apim-Subscription-Key"))
        {
            context.Response.StatusCode = StatusCodes.Status401Unauthorized;
            await context.Response.WriteAsync("Missing Ocp-Apim-Subscription-Key header");
            return;
        }

        await next();
    });
});

app.Run();
