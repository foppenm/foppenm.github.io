---
layout: post
permalink: /how-to-develop-more-secure-solutions/
date:   2019-01-04 15:28:29 +0100
categories: blogs
short_text: "As developers, we are constantly trying to implement our solutions in the best way possible. Often we 'forget' to look for the vulnerabilities we introduce without really thinking about it"
author: "Mark"
tags: ["Development", "Security"]
cover: "/content/images/2019/01/blog-logo-1.png"

# SEO
title: "How to develop more secure solutions without the hassle"
description: "As developers, we are constantly trying to implement our solutions in the best way possible. Often we 'forget' to look for the vulnerabilities we introduce without really thinking about it"
image: "/content/images/2019/01/blog-logo-1.png"
locale: "en_US"
---


As developers, we are constantly trying to implement our solutions in the best way possible. Often we "forget" to look for the vulnerabilities we introduce without really thinking about it. This can happen under pressure of a superior or simply because you can't know every vulnerability out there. 

In order to improve this we want to know what is wrong but (I personally) don't want it to be enforced on every local build we do.. For this to improve I found 2 solutions that work really well without you being bothered all the time.

There are 2 different kinds of solutions we can use:
* Live information and tips during your development
* Vulnerabilities on added dependencies

## Security Code Scan
For the first problem, I wanted to be notified during my development in visual studio en visual studio code. This can be done by installing one of the following:

* Visual Studio -> SecurityCodeScan (**preferred!**) and/or DevSkim
* Visual Studio Code -> DevSkim

In this post, we will mainly be looking into Security Code Scan. In order to use this, you can get it either by installing the visual studio extension [Link](https://marketplace.visualstudio.com/items?itemName=JaroslavLobacevski.SecurityCodeScan) or by adding it as a nuget on the project you want to monitor. I have added it as an extension and therefore will get vulnerability warnings on every solution that is open.

After installing, make sure to check the "Enable full solution analysis" in Visual Studio > Tools > Text Editor > C# > Advanced, like in the screenshot below.
![vs-tools-setting](/content/images/2019/01/vs-tools-setting.png)

By now you will get warnings if something is detected. It can present itself in different ways.

![warning](/content/images/2019/01/warning.png)

You will also be able to fix it most of the time with the quickfix option.

![quickfix](/content/images/2019/01/quickfix.png)

Last but not least, you can also get an overview of all the warnings in the "Error list" view.

![error-list](/content/images/2019/01/error-list.png)

In this view, you also have the ability to open the issue in your browser to get additional information, how to fix it and why this is important. I mean you can always ignore it if you think this is not applicable in the current situation.

Solutions for vulnerabilities can be found at [Security Code Scan](https://security-code-scan.github.io) and it wil look like:

![solution-for-issue](/content/images/2019/01/solution-for-issue.png)

As a second solution, you can also use DevSkim which can be found [here](https://github.com/Microsoft/DevSkim) but in my opinion, this is less useful and it will produce errors on build time. DevSkim does catch some different possible issues like not secure URLs. Unfortunately, it does not support quick fixes or an explanation of why it is a vulnerability.

![unsecure-url](/content/images/2019/01/unsecure-url.png)

## Snyk
After I implemented a solution, it works and I am ready to deploy it there is a possibility to check it for used dependencies vulnerabilities. This can be done by using [Snyk](https://snyk.io/) which has a free tier for developers and unlimited tests (runs to check your solution) for public repositories. Keep in mind that for enterprises there are paid options.

First, you need to register a free account. This will give you access to your Dashboard. Now you have two options. You can configure a public repository or use a local (on your machine) project. The public repositories can be configured by going to the "Integrations" page where you can configure a lot of providers.

![snyk-integrations](/content/images/2019/01/snyk-integrations.png) 

In this example we are going to use a local project that is not in any repository since the local project is a little more difficult to setup.

So let's get right to it and install Snyk on your machine. To install Snyk I used npm with the following command
```
npm install -g snyk
```

After that you have to authenticate with your account.
```
snyk auth
```

Which will open the browser and you can login in with your Snyk account. Now you can use it to test your solution by going to project folder
```
cd c:\<your solution folder>
```

In my case, this was a solution with .NET project for an azure function. This is supported but not in the default way. Normally you can just run "sync test" and it will automatically check for a lot of different variations of package files in your current folder (see [docs](https://snyk.io/docs/using-snyk/)). For .NET projects you need to specify the solution file like this
```
snyk test --file=MySolution.sln
```

In the summary of your test, you can already see if there are vulnerabilities

![snyk-test](/content/images/2019/01/snyk-test.png)

To get it in your dashboard on snyk.io you need to run
```
snyk monitor --file=MySolution.sln
```
This will send the data to your Snyk account and you will be able to see it in the dashboard and browse through the found vulnerabilities by severity.

A nice added bonus to this monitoring is that it will keep your packages config and alert you when there are newly found vulnerabilities. This way you will get an email when this happened and you can respond to that. This can be set to check on a daily or weekly base. 

![snyk-dashboard](/content/images/2019/01/snyk-dashboard.png)

## Is This Usable?
I can only speak for my self but for me, these two steps are easy to implement in local and ci builds and require no hassle to use. An added bonus is that I can use the warnings to improve the solution but I don't have to. If you want it to take a step further you can always take a look into [BinSkim](https://github.com/Microsoft/BinSkim). This tool can analyze your DLL's and Executables for know vulnerabilities. 

All in all, I think it is really "remarkable" that all this is free to use while it can have real added value to the solutions we make!