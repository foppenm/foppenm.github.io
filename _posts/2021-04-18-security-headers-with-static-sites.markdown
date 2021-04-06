---
layout: post
date:   2021-04-18 15:28:29 +0100
categories: blogs
short_text: "Using premium cdn to add headers to you static site hosted on Azure"
author: "Mark"
tags: ["Azure", "Static Website", "Verizon CDN"]
cover: "/assets/blogs/2021-04-18/cover.png"

# SEO
title: "Security headers with Azure static websites"
description: "Using premium CDN to add headers to your static site hosted on Azure"
image: "/assets/blogs/2021-04-18/cover.png"
locale: "en_US"
---

When creating a static website by using a storage account (not the new Azure Static WebApp) you have no say about what security headers are sent to the end-users. This can be easily solved by using a premium CDN like Verizon. First, let's explain a little about what security headers are and why you should care.

## Security headers?
According to [OWASP](https://owasp.org/www-community/Security_Headers), you should not divulge any information about the server or its configuration to the end-user as this can be used by hackers to exploit a vulnerability. But what are security headers?

Security headers are sent between the server and the client for every request that is made, like loading HTML, images, or API calls. These headers indicate if some options are possible in the client and are sent in a simple form of key and value. Let's take an easy one like 'X-Frame-Options: Deny'. If this header is present it prevents the current page from being loaded into an iframe on another page or website.

If you want to look at the security headers yourself you can open de developers tools of your browser (F12 for Edge) and go to the network tab. Then browse to https://www.google.com and your result will look like the screenshot below. As you can see, Google only allows this specific resource to be in an iframe of the origin is the same as google.com.

![googleheaders](/assets/blogs/2021-04-18/googleheaders.png)

If you want to do this with Azure Static website by using a storage account then you are out of luck. There is no option to enable or change the headers. Instead, let's see what a Premium Verizon CDN brings us. Ouch sounds expensive...

## Setup Premium CDN
Within a storage account, you have the option to configure a Azure CDN (in the menu). A CDN is designed to deliver static content like images, audio, and video faster to the end-user because it will locate the nearest datacenter and retrieve the file from there. You can create a Verzion CDN like this

![verizoncdn create](/assets/blogs/2021-04-18/verizoncdncreate.png)

Make sure to select the Static website and not the blob container. When this is done you will have multiple new resources in your resource group. You will have a new CDN Profile and an Endpoint resource. If you look closely you will see that these resources are created a global location and not a specific region. Now, let's look into the created 'CDN Profile' resource which will be your Verizon CDN.

![verizoncdn create](/assets/blogs/2021-04-18/verizoncdn.png)

It can take some time to get it into a running state. In the top right corner, you can see that this is a Premium Verizon CDN. You can access the Verizon page by clicking 'Manage' at the top. For me, the authentication didn't work flawlessly in the beginning. Looks like Verizon needs time to set everything up on their side, so give it some time.

To be able to add security headers we need to go to the Rule Engine. This can be done by opening the HTTP Large menu

![rulesengine](/assets/blogs/2021-04-18/rulesengine.png)

When you open the rules engine there is an option to create a draft rule. Rules in this rules engine go through multiple stages: Draft > Staging > Production. When in production they are live and actively used. 

The rules engine is very easy and will allow you to manage all your headers. Using the action 'Overwrite' will allow you to update and if they do not exists add the headers like X-Frame-Options. If you want to remove the headers of Microsoft then you can also do that with the 'Delete' action as seen below.

![securityheadres](/assets/blogs/2021-04-18/securityheaders.png)

If you save these changes and push it to production you can browse to your static website and see that the headers are applied. This is all good, but what does it cost? I mean it's a Premium Verizon CDN.

## What does it cost?
With a Verizon CDN, you do not pay per transaction. You pay for the data transferred and there are no upfront costs. In this example, we calculate with a high traffic website that has transferred 50GB of data on static files. 

![costs](/assets/blogs/2021-04-18/costs.png)

As you can see it's only ~$14 a month for this solution. The other options are using a Azure Frontdoor or an Application Gateway which are both much much more expensive. 

This is all for now, if you have any questions feel free to post a message in the discussion on GitHub [here](https://github.com/foppenm/foppenm.github.io/discussions/5). Thanks for reading!