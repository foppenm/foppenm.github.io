---
layout: post
date:   2021-05-02 15:28:29 +0100
categories: blogs
short_text: "Adding policies to Azure API Management in C#"
author: "Mark"
tags: ["Azure", "API", "Policies", "Azure API Management"]
cover: "/assets/blogs/2021-05-02/cover.png"

# SEO
title: "Adding C# to policies in Azure API Management"
description: "Embedding C# to Azure API management policies"
image: "/assets/blogs/2021-05-02/cover.png"
locale: "en_US"
---

Using Azure API management has some great advantages like not having to manage your own proxy to aggregate all your API's or microservices into one endpoint. If you have used Azure API management before then you know there is an option to edit policies to change the incoming or outgoing requests.

## What are policies?
With policies, you have full control over how your API calls travel through your API management to the backend. You can set policies on one specific API call or the entire API. Adding a policy is mainly done in XML but before we go there, here are some examples of what you can do:
* Access restrictions to block IP addresses, limit call rate and validate JWT tokens
* Advance policies to mock responses (for testing) and retries
* Caching policies to store and retrieve data from a cache
* Transformations for JSON to XML or vice versa

If you want extended information please take a look [here](https://docs.microsoft.com/en-us/azure/api-management/api-management-policies).

## Adding a policy
Now that we know a little about what policies can do, let's add a new policy to an Azure API management instance. I am going to assume you already have an API created or like me using the default echo API. Go to that API and click on a specific API call. You will see something similar to this:

![Api](/assets/blogs/2021-05-02/api.png)

Now click on </> in the "Inbound processing" to enter the policy window. Here you can add all the different types of policies like only allowing a certain IP address range like this:

![xmlpolicyiprange](/assets/blogs/2021-05-02/xmlpolicyiprange.png)

This specific call will be limited to only allow a specific range of IP addresses. The same can be done for a rate limit policy which can be used to protect a backend service from receiving too many requests. For other policies, you can also go to the snippet window in the top right corner to select a policy

![snippet](/assets/blogs/2021-05-02/snippet.png)

## Adding C# to a policy
We now know what policies are and what they can do but what about more advanced scenarios? What if I have an API that is receiving documents with metadata in JSON format and I only want to save the document in blob storage and not the metadata. This is because the metadata is handled by a different backend than the document processing. 

```json
{
    "fileName" : "filename.ext",
    "meta": "more meta data here",
    "doc": "base64string of the document"
}
```

The JSON is pretty basic with some metadata properties. We now only want to select the property "doc" which contains the document. This can be done by using C# in the policy and a total overview of the policy is also provided later. First, we need to extract the incoming body from the request and save it to a variable and also save a random filename so that the blob can be saved.

```xml
<set-variable name="body" value="@((string)context.Request.Body.As<string>(preserveContent: true))" />
<set-variable name="fileGuid" value="@(Guid.NewGuid().ToString())" />
```

As you can see in the value property which begins with '@(' you can write plain C# after that. If you want multi-line you can use "@{}". API management provides some default variables like "context" which contains the body of the incoming request. After that, you can access the rest of the body and save it as variables. 

Next, we need to start creating a send-request to blob storage and that can be done like below where we also concatenate a string that represents the URL of where the blob will be saved. In that URL, we are again using C#. Also, notice the headers that we are setting here to generate a valid request to an Azure storage account.

```xml
<send-request mode="new" timeout="300" response-variable-name="blobdata" ignore-error="false">
    <set-url>@("https://myblobstorage.blob.core.windows.net/yourdocscontainer/" + context.Variables.GetValueOrDefault<string>("fileGuid"))</set-url>
    <set-method>PUT</set-method>
    <set-header name="x-ms-version" exists-action="override">
        <value>2019-07-07</value>
    </set-header>
    <set-header name="x-ms-blob-type" exists-action="override">
        <value>BlockBlob</value>
    </set-header>
    <set-body>
        <!-- See below -->
    </set-body>
    <authentication-managed-identity resource="https://storage.azure.com" />
</send-request>
```

The last thing we need to do is setting the body of the request to an array of bytes that can be saved to blob storage. Retrieving the "doc" property from the incoming request and converting the base64 string to bytes can be done like this

```xml
<set-body>
    @{
        var body = (string)context.Variables.GetValueOrDefault<string>("body");
        var jsonObject = JObject.Parse(body);
        var base64String = (string)jsonObject["doc"] ;
        var bytes = Convert.FromBase64String(base64String); 
        return bytes;          
    }
</set-body>
```

No this is not the cleanest or shortest code but I wanted to keep it as simple and readable as possible and not putting everything in a single line. Below is the full policy that contains all the parts until now.

```xml
<policies>
    <inbound>
        <set-variable name="body" value="@((string)context.Request.Body.As<string>(preserveContent: true))" />
        <set-variable name="fileGuid" value="@(Guid.NewGuid().ToString())" />
        <send-request mode="new" timeout="300" response-variable-name="blobdata" ignore-error="false">
            <set-url>@("https://myblobstorage.blob.core.windows.net/yourdocscontainer/" + context.Variables.GetValueOrDefault<string>("fileGuid"))</set-url>
            <set-method>PUT</set-method>
            <set-header name="x-ms-version" exists-action="override">
                <value>2019-07-07</value>
            </set-header>
            <set-header name="x-ms-blob-type" exists-action="override">
                <value>BlockBlob</value>
            </set-header>
            <set-body>
                @{
                    var body = (string)context.Variables.GetValueOrDefault<string>("body");
                    var jsonObject = JObject.Parse(body);
                    var base64String = (string)jsonObject["doc"] ;
                    var bytes = Convert.FromBase64String(base64String); 
                    return bytes;          
                }
            </set-body>
            <authentication-managed-identity resource="https://storage.azure.com" />
        </send-request>
        <choose>
            <!-- Return an error to the caller of the api when storing in blob is failed -->
            <when condition="@(((IResponse)context.Variables.GetValueOrDefault<IResponse>("blobdata")).StatusCode != 201)">
                <return-response>
                    <set-status code="400" reason="@(((IResponse)context.Variables.GetValueOrDefault<IResponse>("blobdata")).StatusReason)" />
                    <set-header name="ErrorReason" exists-action="override">
                        <value>@(((IResponse)context.Variables.GetValueOrDefault<IResponse>("blobdata")).StatusReason)</value>
                    </set-header>
                </return-response>
            </when>
        </choose>
        <!-- Add your backend call here if you only want it to be called on a successful storage call-->
        <base />
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
        <base />
    </outbound>
    <on-error>
        <base />
    </on-error>
</policies>
```

With this, we completed including C# into Azure API management policies. This is all for now, if you have any questions feel free to post a message in the discussion on GitHub [here](https://github.com/foppenm/foppenm.github.io/discussions/9). Thanks for reading!