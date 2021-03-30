---
layout: post
title: "Can a Azure Static Website really be this cheap?"
permalink: /can-a-azure-static-website-really-be-this-cheap/
date:   2019-03-09 15:28:29 +0100
categories: blogs
short_text: "Here is why you should consider switching to Azure Static Websites if your requirements allow it."
author: "Mark"
tags: ["Azure Static Website", "Serverless", "Azure"]
cover: "/content/images/2019/03/logo-2.png"
---


So why should I change to Azure Static Websites? If this is a lot cheaper there are limitations right? Lets put it to the test.

## What is it?
A while ago Microsoft announced the general availability of Azure Static Websites. This means that you can host your website files in a blob storage and host your website from there. You can read all about it here: [Microsoft Announcement](https://azure.microsoft.com/nl-nl/blog/static-websites-on-azure-storage-now-generally-available/)

## What am I doing?
For this test we need an actual website that we are able to load and produce some page views with. I got a free template from [Colorlib](https://colorlib.com/wp/template/appy/) called Appy. You can browse to it by going to https://azurestaticweb.z6.web.core.windows.net/ or by looking at the demo at Colorlib.

![page](https://thepracticaldev.s3.amazonaws.com/i/2rnxbk1pxzhd4d607x1f.png)

Since I didn't want to invest a lot of time into making a new website I deployed this template just "as is" into my blob storage account. This can be done by simply copying all the files into the blob folder called "$web". It should already be there since it is auto-created after enabling the static web site feature in the storage account. Next up is generating a load on the page.

## Lets produce some page views
In order to get a sense about the cost of the way we are hosting, we are going to produce some page views. To do this a setup a simple Selenium test that does the following:
* Start a new Firefox window with zero caching
* Browse to https://azurestaticweb.z6.web.core.windows.net/
* Click on "Blog"
* Click on "Contact"

The other menu options will be left out since that are all single page navigation items that produce no load at all. This sequence produces three page views. What we really want to know is how many files are we getting from the blob storage since that. The Firefox network monitor reports that one page view is equal to requesting getting 54 files. Of course, this depends on how your website is built.

![requests](https://www.re-mark-able.net/content/images/2019/03/network.png)

After this initial call, I put the selenium test in a loop and let it run for over 3 days in a row.

## How is the performance?
All of the above is great but how does this perform on heavier loads? Let's look at the graphs below that I got from application insights.

**Number of page views over the last 3 days**
![requests](https://www.re-mark-able.net/content/images/2019/03/pageviews-1.png)

**Number of transactions on the blob storage over the last 3 days**
![requests](https://www.re-mark-able.net/content/images/2019/03/transactions-1.png)

**Avarage load times for the entire page (loaded all the 54 files)**
![requests](https://www.re-mark-able.net/content/images/2019/03/Avg-responsetime-all-files-1.png)

As you may have noticed there is a huge spike in the beginning. This was a typo in my selenium test which caused it to produce 700 page views every minute. While most page views were under 1 second load time, with that many page views it sometimes happened that there was a spike up to 2 seconds. 

## What can we do to improve this?
From a storage point of view, I think it is re[mark]able how well it can handle all the page views. Especially since this is data that is not cached. We have a couple of options to speed up while keeping the costs low:
* Redis Cache
* Cloudflare Cache
* Azure Blob Storage CDN
* Azure Front Door

The first two options seem nice at first but Redis cache starts at 16 dollars/month which kinda defeats the purpose of low-cost hosting. While Cloudflare is free but requires a purchased custom domain.

With the third option, it is possible to replace all your files with versions in the CDN. While I think this is possible to automate it just isn't that straight forward. 

The last and in my opinion probably the best option is the Azure Front Door. Although it is still in preview it works really well! The pricing in the preview is 8 cents per GB. For more details, you can have a look [here](https://azure.microsoft.com/nl-nl/pricing/details/frontdoor/). As you can see in the test results above 20k page views is about 1gb for this template website.

## Using Azure Front Door
First you need to create the Azure Front Door resource. While adding the resource there is a configuration step like below

![frontdoordesigner](https://www.re-mark-able.net/content/images/2019/03/frontdoordesigner.png)

There are three steps:

**Frontend URLs**
This is the URL your users are browsing to. There is an option to use a custom domain here.

**Backend pools**
In the backend pools, you can specify the resources where a frontend URL is pointing to. You can add multiple resources in a pool. The load balancer will switch between them. This makes it possible to create multiple storage accounts in different geo regions and the Front Door load balancer will automatically route you to the nearest resource to reduce loading time.

![backends](https://www.re-mark-able.net/content/images/2019/03/backends.png)

**Routing rules**
Routing rules are the glue between the frontend URL and the backend pool. The routing rules include lots of settings and one of them is caching. This will reduce the load on your blob storage.

![routingrule](https://www.re-mark-able.net/content/images/2019/03/routingrule.png)

After you did these steps your static website will be available within a few minutes on the new *.azurefd.net domain. For me this was [https://azurestaticweb.azurefd.net/](https://azurestaticweb.azurefd.net/). Keep in mind that the Azure Static Website is already pretty fast and that Azure Front Door is just an option to either reduce the load time or to scale your application. For now, let's continue on the Azure Static Website feature.

## What are the limitations?
There is no server running your code so it is **not** possible to:
* Install something like Node.js
* Deploy your ASP.net web app

What **is** possible:
* Using Html, CSS and Javascript
* Use ReactJs or Angular
* Use WebAssembly
* Using Azure Functions as your server-side / backend

## Finally, What does this 20k page views, 1gig transferred and almost 2 million transactions cost?
Well since it is really only the blob storage costs you will see something like this. 

![costs](https://www.re-mark-able.net/content/images/2019/03/cost.png)

Notice that the Application insights is "really expensive" in comparison to the Azure Static Web host. But in all fairness, 3 cents (3.12 cents if dollars) is very cheap! This hosting solution is very cheap while still offering a lot of possibilities. As such you can use Azure Functions as your backend e.g. to connect to a database.

Thanks for reading!