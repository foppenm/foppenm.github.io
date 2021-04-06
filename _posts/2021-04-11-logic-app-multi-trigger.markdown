---
layout: post
date:   2021-04-11 15:28:29 +0100
categories: blogs
short_text: "Logic apps normally have 1 trigger, let's see how we can change this using the Azure portal"
author: "Mark"
tags: ["Azure", "Logic Apps"]
cover: "/assets/blogs/2021-04-07/cover.png"

# SEO
title: "How to do multi-trigger Azure Logic Apps"
description: "Logic apps normally have 1 trigger, let's see how we can change this using the Azure portal"
image: "/assets/blogs/2021-04-07/cover.png"
locale: "en_US"
---

When developing solutions with Azure Logic Apps you often run into limitations in comparison to developing with C# & .NET. But it is also much much simpler to connect business applications with the few hundred connectors available today. One of the limitations is that the designer does not support multiple start triggers at this time. However multiple start trigger is possible. Let's see how we can do this.

## Creating a logic app
Start by creating a new Logic App and added the step "When a HTTP request is received". You can save the logic app and it will create a URL where you can post data to.

![EmptyLogicApp](/assets/blogs/2021-04-07/emptylogicapp.png)

When we see the code view behind this logic app it will be similar to the one below. We can now post to the URL the designer view is giving you.

```json
{
    "definition": {
        "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
        "actions": {},
        "contentVersion": "1.0.0.0",
        "outputs": {},
        "parameters": {},
        "triggers": {
            "manual": {
                "inputs": {},
                "kind": "Http",
                "type": "Request"
            }
        }
    },
    "parameters": {}
}

```

## Adding the second trigger
Now we can add a second trigger but before we do that there is one nasty caveat with this approach.. You will lose the designer view. Even when this is the case it still can be useful in advanced scenarios where you can not create resources yourself in Azure due to company policies (and it took you 3 weeks to create this above logic app.. it happens). Or maybe you just want multiple recurrence triggers. On the latter, let's add a recurrence trigger as the second trigger.

```json
{
    "definition": {
        "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
        "actions": {},
        "contentVersion": "1.0.0.0",
        "outputs": {},
        "parameters": {},
        "triggers": {
            "Recurrence": {
                "recurrence": {
                    "frequency": "Minute",
                    "interval": 1
                },
                "type": "Recurrence"
            },
            "manual": {
                "inputs": {},
                "kind": "Http",
                "type": "Request"
            }
        }
    },
    "parameters": {}
}

```

As you can see the property 'triggers' is already plural and should support multiple triggers. By adding the recurrence trigger you can have multiple triggers. As documented in the Microsoft docs [here](https://docs.microsoft.com/en-us/azure/logic-apps/logic-apps-limits-and-config), you can have up to 10 triggers.

## Downside
Now that we have 2 triggers the Logic App will fire when called by an HTTP request but also every minute. As stated earlier the downside is that you cannot use the designer anymore. Not for the run history and not for updating the Logic App.

![EmptyLogicApp](/assets/blogs/2021-04-07/runhistory.png)

## Should you use this?
TLDR: No. This should only be used when you have no other option since the designer and run history views are what is making Logic Apps great. Since creating Logic Apps does not bring any extra costs you should just create multiple Logic Apps. Each of them with the specific trigger you want. Then all Logic Apps with the triggers call the one logic that will execute the trigger. 

TIP: Pay attention to the 'Retry policy' setting when calling other Logic Apps. It can cause some unwanted retries.

This is all for now, if you have any questions feel free to open a discussion on GitHub [here](https://github.com/foppenm/foppenm.github.io/discussions/4). Thanks for reading!