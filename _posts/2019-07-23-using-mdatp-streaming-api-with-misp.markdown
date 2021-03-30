---
layout: post
title: Using MDATP Streaming API with Misp
permalink: /using-mdatp-streaming-api-with-misp/
date:   2019-07-23 15:28:29 +0100
categories: blogs
short_text: "Would it not be great if you can access all the data from the new Microsoft Defender Advanced Threat Protection? Let's dive into the new MDATP Streaming API"
author: "Mark"
tags: ["MDATP", "Threat Intelligence", "Azure"]
cover: "/content/images/2019/07/vanveenjf-6D1WRBQUdh0-unsplash.jpg"
---

Would it not be great if you can access all the data from the new Microsoft Defender Advanced Threat Protection (MDATP)? It would be great if you can just access all that data through an API. But I really do not want to develop another polling mechanism to pull in all the data. That is where the new MDATP Streaming API comes in which just got enabled for public preview. 

In this post, you will see how easy it is to configure the new Streaming API and how you can get access to the data. You will see how the new API can be attached to Azure Storage and Azure Event Hub.

Once we receive all the data we can check file hashes in a 3rd party threat intelligence provider like MISP. First, let's configure the MDATP streaming API.

## Configure MDATP Streaming
We start by going to the MDATP portal [here](https://securitycenter.windows.com) where you will see the default dashboard. To start configuring you need to go to the Data Export Settings page.

![DataExportSettings](/content/images/2019/07/DataExportSettings.gif)

In this page, you can add a total of 5 streaming connections. At the moment there are two types of Azure resources you can connect to:
* Azure Storage
* Event Hub

If you choose for the Azure Storage option then the MDATP stream will save all the events in a *.json file as blobs.

On each connection you can choose between 9 types of events:
* AlertEvents
* MachineInfo
* MachineNetworkInfo
* ProcessCreationEvents
* NetworkCommunicationEvents
* FileCreationEvents
* RegistryEvents
* LogonEvents
* ImageLoadEvents
* MiscEvents

For now, I am only going to focus on the connection between an Event Hub and MDATP for the **FileCreationEvents**. If you want to make sure that you catch all of the files and processes on every device you should also add the **ProcessCreationEvents**.

When you add a new connection you will get all the options I just mentioned. You can make a choice here and configure the connection how you like. I am going to configure it for an event hub to only receive file creation events from MDATP.

![AddEventHub](/content/images/2019/07/AddEventHub.gif)

Now that the Event hub is configured the data should start coming in and it will look something like this

![StreamingData](/content/images/2019/07/StreamingData.png)

**Tip**: Only enable the types of events you really want to have since the volume of messages can be very high. This is not an issue for Event Hub but could be very costly if you connect it to a logic app where you pay per execution.

For example 'NetworkCommunicationEvents' logs every connection made on every machine. I had to learn the hard way by wasting my entire worth of monthly Azure credits ($150) in 2 days because it was connected to a Logic app :| ...
![HighPeak](/content/images/2019/07/HighPeak.png)

As you can see below most of the costs are in the connection and the executed actions for the logic app and not in the Event Hub. So be cautious as to what you connect to the Event Hub. The high event hub costs are due to the enabled 'Capture' feature and the standard tier. Not because of the number of events.
![Costs](/content/images/2019/07/Costs.png)

This however triggered me to look into the actual costs of using the MDATP streaming API with Event Hub. To do that we first need to know how many events are sent. I created a new Event Hub namespace, connected it to MDATP streaming API and selected all available events. The next 24h I let it run to capture all the events. To give some context to this I have counted all the different types of events and the number of machines in my tenant. 

NetworkCommunicationEvents: **95,070**
ImageLoadEvents: **23,091**
MiscEvents: **57,444**
ProcessCreationEvents: **24,795**
RegistryEvents: **49,191**
MachineInfo: **2,213**
MachineNetworkInfo: **10,712**
FileCreationEvents: **39,487**
LogonEvents: **1,982**
AlertEvents: **4**

This leaves us with a total of **303.989** events on **83** different machines. The average size of one event is ~2.47 kilo byte and one machine gives ~3,662 events per day. On monthly costs, this would mean you have ~9 million events which will cost you around $0.25. 

## Consuming Eventhub with a Logic app

Sometimes there are use cases that require a third-party threat intelligence system to check for malware. For example, to detect Android APK's with malware in them. A good example you can see [here](https://mobile.twitter.com/Maler360/status/1138695308462870528). For this example, we will be using MISP also know as a Malware Information Sharing Platform and Threat Sharing. This is a free and community-driven threat intelligence platform. In this post, we will not cover how to set this up but you can see how this can be done on Kali Linux [here](https://www.inspark.nl/misp-threat-intelligence-azure-sentinel/) 

Here is a list of goals we want to achieve:
* Read the events from the event hub
* Check the file hashes against Misp
* Add the indicator to MDATP

Do note that this is an implementation in the most basic form you can think off without any error handling or what so ever. Let's take a look at the Logic App overview
![LogicAppOverview](/content/images/2019/07/LogicAppOverview.png)

First we receive the events through the Event Hub Logic App trigger which is connected to the MDATPStream hub as shown before. When you save the Logic App with only the trigger you will get a response like this:

![LogicAppEventHubMessage](/content/images/2019/07/LogicAppEventHubMessage.png)

Now that we receive events we can call the Misp API with the following parameters to check if that file is known as a possible indicator of compromise (IoC).

![LogicAppCallMisp-1](/content/images/2019/07/LogicAppCallMisp-1.png)

After this, we parse the response and check if there are any IoC's returned from Misp. If that is the case we have found a match. At this point, it is up to you what you do with this detection. The first thing you could do i.e. is, Posting an Alert directly to MDATP with the Windows Defender Advanced Threat Protection (WDATP) logic app connector.

The way to achieve alerting of the found IoC is through creating an alert with the WDATP connector. You can do this by adding it to your logic app and connect it with a global admin account. 

![AlertWDATP](/content/images/2019/07/AlertWDATP.png)

To create an alert, you need to set the machine id which can be found in the event hub message. For the other fields, you can set them as you like. To give meaning to the alert, you should call the Misp once again and retrieve the event from Misp. An event in Misp gives context to the found IoC and therefore also contains fields like title, severity, comments, etc.

## Possibilities? 
Although this post only describes one possible implementation of the MDATP streaming API there a lot more possibilities. To name a few:

* Save the MDATP data to a separate storage to retain it indefinitely
* Instead of polling your MDATP alerts from the graph API you can now respond to the alerts real-time
* Monitor network communication real-time
* Stream your data to a 3rd party that is handling your security
* Stream all the evens into your Security Information and Event Management (SIEM) solution
* Add your data to Azure Sentinel, since there is no connector yet. 

And a few others, just for fun or because you can
* Draw a world map and show all the unlock and logins in real-time by processing LogonEvents
* Respond to people that they shouldn't work during their holidays by using the LogonEvents, ProcessCreation en FileCreationEvents ;) 

It is re[mark]able how much data is inside the MDATP product and for now we only scratched the surface. This should give you a good indication of what is possible in real-time with the MDATP streaming API.

Thanks for reading!