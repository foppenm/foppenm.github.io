---
layout: post
title: Azure AD Application Registration Security with Graph API
permalink: /azure-ad-application-registration-security/
date:   2019-10-04 15:28:29 +0100
categories: blogs
short_text: "Retrieving Azure Active Directory Application Registrations with the Microsoft Graph API"
author: "Mark"
tags: ["Azure", "Active Directory", "Graph Api"]
cover: "/assets/blogs/2019-10-04/cover.jpg"
---

In many Azure Active Directories, there are registered applications. These applications all have security permissions. Do you know which one has which permissions and can access what data and resources? Do you know who has the secrets that give access to this data? Let's take a look at how we can achieve this.

In this blog, I will show you how to generate a list of applications and the permissions they have by using the beta version of the Microsoft Graph API. This will allow you to act on them. It is fine if some applications have a high permission level. At least after reading this blog you have the change retrieve them and to make sure the owners of the applications guard the secrets the best they can. Let's dive right into retrieving the applications.

Don't know what Azure Active Directory Application registrations are? Check out [this](https://www.re-mark-able.net/understanding-azure-active-directory-application-registrations/) earlier blog post. If you wanna know more about the Microsoft Graph API beta you can see [this](https://www.re-mark-able.net/how-to-access-data-from-the-beta-channel-of-graph-api/) blog on how to connect to it.

## Setup app registration with permissions
Before we can retrieve the applications from the Graph API, we need to authenticate it to the Azure Active Directory. This is done by adding an application registration. Yes, this is the same type of application we are trying to retrieve. In this case we are need to create a application registration with Directory.Read.All permission.

To create an application you can go to my GitHub [here](https://github.com/foppenm/Microsoft-Graph-Applications). There is a detailed guide in the readme on how to set this up. 

> After you are done retrieving the applications, make sure to disable or delete this application.

Now that you have created the application, you can get an access token. We do this in C# by using the MSAL library (Microsoft.Identity.Client). This allows you to generate the token we use later in this blog.

```csharp
var ccab = ConfidentialClientApplicationBuilder
    .Create(clientId)
    .WithClientSecret(clientSecret)
    .WithTenantId(tenantId)
    .Build();

var tokenResult = ccab.AcquireTokenForClient(new List<string> { "https://graph.microsoft.com/.default" });
var token = await tokenResult.ExecuteAsync();
return token.AccessToken;
```


The token we just retrieved is a JWT token that permits us to access the Graph API. Specifically in this case to retrieve the applications from an Azure tenant.

> If you ever wonder what permissions are associated with the current token. Go to [https://jwt.io/](https://jwt.io/) and paste in your token. 

## Retrieve Applications
To retrieve the applications we use the previous access token and make a GET call to https://graph.microsoft.com/beta/applications. Notice that we make use of the **beta** version of the Graph API. 

Below is the C# code:

```csharp
using (var request = new HttpRequestMessage(HttpMethod.Get, "https://graph.microsoft.com/beta/applications"))
{
    request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
    request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", "<Your Access Token Here>");

    using (var client = new HttpClient())
    using (var response = await client.SendAsync(request))
    {
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadAsStringAsync();
    }
}
```

Executing this code will return all the applications from the tenant.

> Each call to the Graph API will result in a maximum of 100 results. If there are more results, there will be a nextlink property with a URL to retrieve the next 100 results.

Below is an example of the JSON returned. I removed a lot of empty properties in this case. As you can see we have retrieved an application but the only readable data is the display name. What API's is this app giving permissions to? What permissions are assigned? Are these delegated or application permissions?

```json
{
    "id": "1deb4abb-fea2-401b-8881-0bf7f86dda12",
    "appId": "092424f2-09ba-49fb-bfd1-f4fd9c352e82",
    "createdDateTime": "2019-08-10T21:08:51Z",
    "displayName": "Data Engine",
    "appRoles": [],
    "keyCredentials": [],
    "passwordCredentials": [],
    "requiredResourceAccess": [
        {
            "resourceAppId": "00000003-0000-0000-c000-000000000000",
            "resourceAccess": [
                {
                    "id": "465a38f9-76ea-45b9-9f34-9e8b0d4b0b42",
                    "type": "Scope"
                },
                {
                    "id": "e1fe6dd8-ba31-4d61-89e7-88639da4683d",
                    "type": "Scope"
                },
                {
                    "id": "df021288-bdef-4463-88db-98f22de89214",
                    "type": "Role"
                }
            ]
        }
    ]
}
```

To make sense of al these guids we need to retrieve some extra data. By retrieving the service principle of each API we can link the guids to some actual text.

## Retrieve service principles
First, let's retrieve the service principles in the Azure tenant. We are doing the same call as before with a slight difference in the URL. Instead of calling the **/application** we now call **/servicePrincipals?filter=appId eq '00000003-0000-0000-c000-000000000000'**. This will retrieve the associated API.

```csharp
using (var request = new HttpRequestMessage(HttpMethod.Get, "/servicePrincipals?filter=appId eq '00000003-0000-0000-c000-000000000000'"))
{
    request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
    request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _accessToken);

    using (var client = new HttpClient())
    using (var response = await client.SendAsync(request))
    {
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadAsStringAsync();
    }
}
```

As you can see below it will return the information about the Microsoft Graph. Also for this response, I deleted a lot of properties to make it a little more readable. 

```json
{
    "id": "9a1be802-1792-48de-92e4-ea67cb2ec6e9",
    "appDisplayName": "Microsoft Graph",
    "appId": "00000003-0000-0000-c000-000000000000",
    "displayName": "Microsoft Graph",
    "publishedPermissionScopes": [
        {
            "adminConsentDescription": "Allows the app to read events in user calendars . ",
            "adminConsentDisplayName": "Read user calendars ",
            "id": "465a38f9-76ea-45b9-9f34-9e8b0d4b0b42",
            "isEnabled": true,
            "type": "User",
            "userConsentDescription": "Allows the app to read events in your calendars. ",
            "userConsentDisplayName": "Read your calendars ",
            "value": "Calendars.Read"
        },
        {
            "adminConsentDescription": "Allows users to sign-in to the app, and allows the app to read the profile of signed-in users. It also allows the app to read basic company information of signed-in users.",
            "adminConsentDisplayName": "Sign in and read user profile",
            "id": "e1fe6dd8-ba31-4d61-89e7-88639da4683d",
            "isEnabled": true,
            "type": "User",
            "userConsentDescription": "Allows you to sign in to the app with your organizational account and let the app read your profile. It also allows the app to read basic company information.",
            "userConsentDisplayName": "Sign you in and read your profile",
            "value": "User.Read"
        }
    ],
    "publisherName": "Microsoft Services",
    "appRoles": [
        {
            "allowedMemberTypes": [
                "Application"
            ],
            "description": "Allows the app to read user profiles without a signed in user.",
            "displayName": "Read all users' full profiles",
            "id": "df021288-bdef-4463-88db-98f22de89214",
            "isEnabled": true,
            "origin": "Application",
            "value": "User.Read.All"
        }
    ]
}
```

In the JSON result above you can also see that there are **published permission scopes** and **approles**. published permissions scopes are your delegated permissions and the approles are your application permissions. As you can see there is a lot of human-readable text instead of guids. Below is a simple overview of how each property links to another. 

![linkdata](/content/images/2019/10/Annotation-2019-10-02-111549.png)

Now that we have retrieved the application we also want to know who the owner is. In case we have questions or for governance purposes, you want to know who owns the applications. 

## Retrieve the owners
Retrieving the owners is again the same principle as the other calls. By supplying your app id in the URL you can retrieve the owners of that specific app. It can return multiple results.


```csharp
using (var request = new HttpRequestMessage(HttpMethod.Get, $"/applications/{AppId}/owners"))
{
    request.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
    request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _accessToken);

    using (var client = new HttpClient())
    using (var response = await client.SendAsync(request))
    {
        response.EnsureSuccessStatusCode();
        return await response.Content.ReadAsStringAsync();
    }
}
```


When the call is executed you will receive a JSON response similar to this

```json
{
    "@odata.type": "#microsoft.graph.user",
    "displayName": "Mark Foppen",
    "jobTitle": "Developer",
    "userPrincipalName": "test@re-mark-able.net"
}
```

## Output wrapped in web application
Now you know how to retrieve the applications from you Azure tenant, link all the properties together and retrieve the owners, it is time to make it a little more visible then JSON output. To do this I created a simple web app that shows the output of the call for your specific tenant. The source code can be downloaded from my GitHub [here](https://github.com/foppenm/Microsoft-Graph-Applications)

![Ui](/content/images/2019/09/Ui.png)


## Making it more secure
Now we know what applications we have and what permissions are assigned. We also retrieved who the owner is. Now it's up to you to at least retrieve all the applications from your tenant and put some sort of governance on them. Of course, it is okay to keep applications that have permission to access data but now you can at least compare en react on it. Contact the owners to check if the app is still used and discuss why those permissions are needed.

Thanks for reading and keep pushing to make things more secure!
