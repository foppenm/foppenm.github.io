---
layout: post
permalink: /azure-sentinel-taking-security-to-the-next-level/
date:   2019-05-03 15:28:29 +0100
categories: blogs
short_text: "Just learned about Azure Sentinel? What is Azure Sentinel? Is it taking as to the next level of security?"
author: "Mark"
tags: ["Azure Sentinel", "Security"]
cover: "/content/images/2019/07/philipp-katzenberger-iIJrUoeRoCQ-unsplash.jpg"

# SEO
title: "Azure Sentinel: Taking Security To The Next Level"
description: "Just learned about Azure Sentinel? What is Azure Sentinel? Is it taking as to the next level of security?"
image: "/content/images/2019/07/philipp-katzenberger-iIJrUoeRoCQ-unsplash.jpg"
locale: "en_US"
---

Just before the RSA 2019 conference, Microsoft announced a new cloud-native SIEM solution called Azure Sentinel. Sentinel is meant to be the extra pair of eyes to keep your enterprise even more secure than before. Threats are more eminent than ever before since more and more companies go to the cloud. Therefore, attackers have more ways to breach your cloud environment. To counter this you can use Sentinel that enables you to ‘Collect’ data across all your users, applications and resources both on-premise and in the cloud.  By using Sentinel you can ‘Detect’ threats using predefined use cases like any other SIEM or by using the build in AI. ‘Investigate’ and rapidly respond to threats manually or automatically.

![Blog-Azure-Sentinel-1-1024x723---Copy-1](/content/images/2019/07/Blog-Azure-Sentinel-1-1024x723---Copy-1.jpg)

## Why is this the next step?
Currently, there are a lot of different security providers and products within the Microsoft cloud. Think of Azure Security Center or Windows Defender Advanced Threat protection. When one of the security solutions detect a possible malicious activity a SecOps employee has to take a look at what is happening. The employee would then determine what type of alert it is and login into the specific solution portal. For Windows Defender ATP that would look something like below, where in this case the mimikatz tool was downloaded and extracted before windows defender on the specific machine could intervene.

![Blog-Sentinel-2](/content/images/2019/07/Blog-Sentinel-2.png)

What we miss here is all the information that other security solutions could have caught on possibly the same activity. Like how did it get downloaded in the first place (patient zero)? To solve this there should be one central place to get an overview of the entire malicious activity. This is where Sentinel comes in.

With Sentinel, you have a far more advanced overview (at time of writing not in public preview yet) of the activity. This would reduce the time spent on figuring out what is happening and instead is spend on solving it and making the affected customer safer.

![Blog-Sentinel-3](/content/images/2019/07/Blog-Sentinel-3.png)

## How can Azure Sentinel help?
The majority of the CISO who run a SOC (Security Operation Center) to monitor their On-premise IT are hesitant to move to the cloud. In the past, there was a lack of controls to monitor the cloud IT and this sentiment has stuck with the majority of the CISO that we meet. Historically the heart of a SOC is its SIEM (Security Information and Event Management) tool. A SIEM is hard to build and takes a lot of maintenance and time from the technical and security staff. Some key issues with an on-premise SIEM are in my opinion:

* Hard to set up, there is a steep learning curve and a lot of different data to collect and make sense of.
* The need for probes, to get the bigger picture you need to install probes and agents. It takes a long time and a lot of skill to configure these properly;
* Often limited to on-premise IT, while IT tens to migrate to the cloud there is a lack of integration of “cloud log-data”;
* No machine learning, all logic must come from the SIEM vendor and the data analytics skills of the SecOps team;
* Slow updates, the AI of the traditional SIEM is embedded in the vendor’s software so in case of a new attack the SIEM will only learn the detection algorithm after a vendor’s update;
* Not easy scalable, the hard and software requirements need to be planned upfront and are not so easy to change and evolve as the business needs;
* Expensive to own and operate, to set up and maintain a SIEM there is a need for time and highly skilled SecOps personnel which are both had to come by.

Microsoft reimagined the SIEM tool as a new cloud-native solution called Microsoft Azure Sentinel. Some of the key features of Azure Sentinel are:
* easy to collect security data
* hybrid IT organization
* devices
* users
* apps
* servers on any cloud

Sentinel integrates with all Microsoft (Security) alerts and logging and collaborates with many partners in the Microsoft Intelligent Security Association.

Eliminating the need to spend time on:
* setting up
* maintaining
* scaling infrastructure

Sentinel is already integrated into the Azure portal and comes with build in connectors. All scaling and maintenance (patching) is done automatically.

## Azure Sentinel
![Blog-Sentinel-4-1024x550](/content/images/2019/07/Blog-Sentinel-4-1024x550.png)

* Intelligent security analytics at cloud scale and speed, as one Azure tenant gets attacked with a new attack Microsoft’s SecOps investigates and builds new AI for Sentinel and the AI of Sentinel is updated as soon as Microsoft releases it to the cloud.
* Identifying threats with ML, Azure Sentinel uses state of the art, scalable machine learning algorithms to correlate millions of low-level anomalies to come up with a few high-level security incidents
* Supported by opensource detection queries, apart from the ML and IA you can set your own triggers and alerts in Sentinel. This can be done by running custom KQL queries. Microsoft has this GitHub for you to get started and share your own.

With Azure Sentinel there are no upfront costs, you pay for what you use. This way you can have your SOC in the cloud faster with less effort and costs. Microsoft will let you connect your Office365, Azure AD, Syslog, Azure Security Center, and 3rd party data for free so when the organization moves to the cloud with Sentinel you can still rely on your SOC with SIEM, with the added bonus of the power of the cloud.

## Taking it to the next level
In addition to everything an ‘ordinary’ SIEM is capable of, with Sentinel you can also enable “Sentinel Fusion”. Fusion is adding artificial intelligence with advanced machine learning models to your alert detection. Okay great! what does this mean and what does it do?

A lot of alerts from the different Microsoft security solutions and providers confront you with low or medium severity detections. With the machine learning models from Sentinel Fusion, you can automatically detect if these ‘not so important’ detections are worth looking into it. The AI will also try to correlate events from different providers through the use of entities. These can be configured in sentinel through something that is called ‘Entity types’. For now, these entities are Account, Host or IP address. As you can see below the use cases you create in Sentinel have the ability to link any column to the appropriate entity type.

![Blog-Sentinel-5](/content/images/2019/07/Blog-Sentinel-5.png)