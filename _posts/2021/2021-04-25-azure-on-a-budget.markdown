---
layout: post
date:   2021-04-25 15:28:29 +0100
categories: blogs
short_text: "Azure on a budget, forecasting your spending"
author: "Mark"
tags: ["Azure", "Cost", "Budgets"]
cover: "/assets/blogs/2021-04-25/cover.png"

# SEO
title: "Azure on a budget, forecasting your spending"
description: "Using azure budgets to taking control of your spending"
image: "/assets/blogs/2021-04-25/cover.png"
locale: "en_US"
---

When developing software and deploying it to Microsoft Azure you will most likely encounter some form of cost management. Also questions on: What is this going to cost me or how much is this every month? Let's look into Azure Cost analysis and Budgets.

## Calculating your cost
For every Azure resource, there is a pricing calculator, which you can find [here](https://azure.microsoft.com/en-us/pricing/calculator). You can make calculations for the resource types you want. Let take for example the Application Gateway and assume there is a Products API that returns some product information in JSON. I am going to use the Application Gateway to access the API within a VNET. The usage with the current API is 1.000 users which generate 30.000 API calls per month. Let's put that into the pricing calculator

![appgatewaypricing](/assets/blogs/2021-04-25/appgatewaypricing.png)

Probably not the only one here but I have actually no clue how much Data processing or Outbound data transfer that is because it has never mattered before. Although the API is returning JSON there is some uncertainty. Since the costs are very low per GB I am taking the gamble and setting it up. Let's see what the costs are after a week of usage.

## Cost analysis
For every resource group within Azure, you can get a Cost analysis. This also includes a forecast of the current month. You can find it by going to a resource group and scroll down in the left menu (like in the screenshot below). Here you will have an overview of the current cost (dark green) and the forecasting (light green). 

![resourcegroupcost](/assets/blogs/2021-04-25/resourcegroupcost.png)

Now that you know where to find this cost is must state a small fact: This does not work for CSP subscriptions, these costs are hidden at the time of writing. As you can see in the previous image there was already a Budget set on this resource group. The last thing I want to do with my time is to look at the cost of Azure all day.

## Budgets
In the same menu on the left, you will find budgets. Budgets lets you set an alert on a resource group or a specific resource within that group. This allows you to react to overspending or even when the forecast is indicating that you will exceed your budget at the end of the month.

By creating a budget you can set your desired budget details like the renewal period and the budget amount. Just as important is the budget scoping. Here you can set filters on what resources you want to be included in the budget. By default, it will take the entire resource group. When you just created the resource group and the resources the forecast will be empty for a few hours.

![resourcegroupcost](/assets/blogs/2021-04-25/createbudget.png)

You can set the alert conditions to the actual cost or the forecasted cost.

![resourcegroupcost](/assets/blogs/2021-04-25/alerttype.png)

After setting your alert conditions you have the option to set an action group. These are the same action groups you can set on Azure alerts and alerts on Log Analytics. Within an account group, you can also trigger Azure Logic apps for example. This enables you to alter your resources when certain budgets are exceeding the limits. 

![resourcegroupcost](/assets/blogs/2021-04-25/actiongroup.png)

Nou that we have saved everything the Azure portal will also show you the progress of that budget.

![resourcegroupcost](/assets/blogs/2021-04-25/forecast.png)

This is all for now, if you have any questions feel free to post a message in the discussion on GitHub [here](https://github.com/foppenm/foppenm.github.io/discussions/7). Thanks for reading!