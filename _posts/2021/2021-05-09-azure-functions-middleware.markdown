---
layout: post
date:   2021-05-09 15:28:29 +0100
categories: blogs
short_text: "How to use middleware with Azure Functions on .NET 5 and C#"
author: "Mark"
tags: ["Azure", "Azure Functions", "Middleware", ".NET 5"]
cover: "/assets/blogs/2021-05-09/cover.png"

# SEO
title: "How to use middleware with Azure Functions"
description: "How to use middleware with Azure Functions on .NET 5 and C#"
image: "/assets/blogs/2021-05-09/cover.png"
locale: "en_US"
---

Lately, I was hearing more and more about middleware with DotNet Core and now again with the release of .NET 5 in combination with Azure functions. As it turns out it is only a few steps to create a middleware for an Azure Function.

**If you want to add a middleware to Azure functions, all you have to do is register it in your HostBuilder and create a new class that inherits from IFunctionsWorkerMiddleware.**

Let's take a look at what middleware is, why you should use it, and how we get it up and running in .NET 5.

## What is middleware
Middleware is a piece of code that sits before and after the execution of your function in a so-called pipeline. The image below will demonstrate this. The initial request arrives at your function app and then travels through all the middlewares until it reaches your function. It is important to note that the middlewares are executed in the order they are registered.

![pipeline](/assets/blogs/2021-05-09/pipeline.png/)

Each middleware has a "before" and "after" part. Everything before the "next()" is executed before your function is executed. Likewise everything after the "next()" will be executed after the execution of your function.

The use of middleware will allow you to react to incoming requests but also to change the outgoing response before they leave your function app. Let's take a look at the possibilities and what you can use this for.

## Why and when to use middleware
There are certain situations where you are repeatedly copying the same code. For example, when you build Azure Functions as an external API you don't want to expose any information about the inner workings in a response. This happens when a exception is thrown and you don't catch it. Therefore you need to wrap everything in a try-catch and handle the exceptions. Of course, you can make a fancy wrapper for that but you would still be copying the wrapper everywhere. With middleware, you can wrap the "next()" method in a try-catch and handle it in one place.

Other use cases for middleware are:
* Authentication
* Performance and tracing monitoring
* Logging
* Encrypt/Decrypt incoming requests and outgoing responses
* Custom Caching

## The considerations of using middleware
When using multiple middlewares it can become very confusing when and in what order everything is executed. That's why I would recommend, that in the program.cs where your HostBuilder is, you document why one middleware should execute before the other. 

The other downside is that the middleware is executed on every incoming call for the entire function app. Every middleware needs to decide on its own if it is applicable for this incoming request. So quick if this then that checks are great to do but if you are going to query a database for information keep an eye on the performance.

The last con is that middleware in combination with Azure Functions does not have the ability to change the outgoing response or terminate the pipeline.. yet... There is an open issue at the time of writing [here](https://github.com/Azure/azure-functions-dotnet-worker/issues/340). As stated in the issue it will come but it will probably take some time. For now, let's create a middleware for Azure Functions in .NET 5 and see what we can do.

## How to use middleware with Azure Functions
First, we have to create a middleware class. Let's call it "ExceptionLoggingMiddleware". The main responsibility for this middleware is to log every exception that is occurring within the function app as a warning. It does not matter where you create the class as long as it is in your Function App project. 

Now that we have a middleware class we still need to make it a middleware. We do this by inheriting from the IFunctionsWorkerMiddleware interface and implementing the interface. Your code should be like this:

```csharp
public class ExceptionLoggingMiddleware : IFunctionsWorkerMiddleware
{
    public async Task Invoke(FunctionContext context, FunctionExecutionDelegate next)
    {
        await next(context);
    }
}
```

Now, let's give this middleware some code so that it actually does something. We are going to add a try-catch and get a logger instance from the provided context by Azure Functions runtime. 

```csharp
public class ExceptionLoggingMiddleware : IFunctionsWorkerMiddleware
{
    public async Task Invoke(FunctionContext context, FunctionExecutionDelegate next)
    {
        try
        {
            // Code before function execution here
            await next(context);
            // Code after function execution here
        }
        catch (Exception ex)
        {
            var log = context.GetLogger<ExceptionLoggingMiddleware>();
            log.LogWarning(ex, string.Empty);
        }
    }
}
```

This should be enough to log every exception as a warning. If we run the function project you will see that the middleware is not called. This is because we didn't register it yet in the program.cs where you initialize your host builder. Program.cs is the default startup class but it can be named differently in your project. The best is to search for where "HostBuilder" is used.

```csharp
public class Program
{
    static Task Main()
    {
        var host = new HostBuilder()
            .ConfigureFunctionsWorkerDefaults(
                builder =>
                {
                    builder.UseMiddleware<ExceptionLoggingMiddleware>();
                }
            )
            .Build();

        return host.RunAsync();
    }
}
```

So now when we call a function that has the code provided below you will see that it logs the warning to your console window and if you have Application Insights configured it will be logged to there. 

```csharp
[Function("MyFunction")]
public async Task<HttpResponseData> MyFunction(
[HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "myfunction")] HttpRequestData req)
{
    throw new Exception("Ooops");
}
```

This is all for now, if you have any questions feel free to post a message in the discussion on GitHub [here](https://github.com/foppenm/foppenm.github.io/discussions/11). Thanks for reading!
