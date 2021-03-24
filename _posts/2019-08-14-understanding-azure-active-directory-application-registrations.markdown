---
layout: post
title: Understanding Azure Active Directory Application Registrations
permalink: /understanding-azure-active-directory-application-registrations/
date:   2019-08-14 15:28:29 +0100
categories: blogs
short_text: "Why should you care about Azure Active Directory (AAD) Application Registrations as a global administrator or any other role that can approve them in your organization? In many Azure Active Directories (AAD) there"
author: "Mark"
tags: ["Azure", "Active Directory"]
cover: "/assets/blogs/2019-08-14/cover.jpg"
---

Why should you care about Azure Active Directory (AAD) Application Registrations as a global administrator or any other role that can approve them in your organization? In many Azure Active Directories (AAD) there are registered applications. These applications could all have security permissions and maybe even admin consents to access data across your organization. Do you know which one has which permissions and can access what data and resources? Do you know who has the client secrets that give access to this data? Let's take a look at a non-technical approach to AAD Application Registrations.

# What is an Application Registration
The application registration in your tenant enables you and others to authenticate against your Azure Active Directory. Another option is to authentication through an application secret. A default application registration on its own cannot do much more than validating that the user has valid login credentials. This can be your Active Directory or in case of a multi-tenant application the directory where the user is originated from. It is also possible to let users login with their @outlook.com and @live.com accounts if you configure this.

If you go to your AAD in the [Azure portal](https://portal.azure.com) you can view all the registered applications in your tenant.

![Registrations-1](/content/images/2019/07/Registrations-1.png)

So what other benefits would an application registration have? First, let's think of a scenario where we would need one. 

> **Scenario:** The customer wants a single web page where users sign-in with their AD account and view their profile information. This is done by using the Microsoft Graph API to retrieve the profile data.

The developers of the application implement the requirements and when they start testing it is failing on retrieving the information from the Microsoft Graph API. Something similar to this is what they will see:

![error](/content/images/2019/07/error.png)

In the application registration, you have the option to specify which permissions the application has. Each permission gives access to a part of your resources or users within your Azure tenant. For this scenario the permission *User.Read* would be enough to read basic profile information. What other kinds of permissions can we expect? We will talk about that in a moment.

If you want to see how you can configure a new application registration in your tenant then you can have a look at my previous blog [here](https://www.re-mark-able.net/how-to-access-data-from-the-beta-channel-of-graph-api/) (technical) on how to register a new application. Of course for extended details, you can always take a look at the official Microsoft documentation [here](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app).

## Different Types of Permissions

There are hundreds of permissions you can give an application. You first need to choose which API and then select the permissions you want. To give an impression:

![permissions](/content/images/2019/07/permissions.gif)

As you may have seen there are 2 types of permissions you can choose:

* Delegated
* Application

**Delegated** permissions are used when you want to authenticate to an API or other services with the currently logged-on user. This typically involves a physical user and a user interface.

> A delegated permission will never give the user more permissions then they already have within this AD.

If an application registration has the permission **Directory.ReadWrite.All** and a normal user without any privileged roles logged in into the application. The user will not be able to write to the current directory. When for example a Global Administrator logs in, he will have the ability to write to the directory.

**Application** permission are used when there is no user present. Mostly used for API to another API calls. This is also used for background services. Unlike delegated permissions, application permissions, however, uses the app id and secret to login and always has the given permissions of the application.

> Application permissions (almost) always require admin consent since it can give users more permission then their account.

Be very careful what permissions are given to an app registration that uses *Application* permissions. There is literally only one secret needed to access the application because the app id is often publicly known. Since there is no Multi-Factor Authentication (MFA) available, because this authentication is based on no user interaction, generate the secrets with an expiry time or rotate them on a scheduled basis. This is however not supported by the Azure Portal at the moment. In my opinion, this should be taken into consideration when the application is designed.

Before an application can be used with any privileged permissions there is, as stated above, an admin consent required. Let's find out what consent is and what types are available.

## Giving Consent

What are the types of consent that can be given? There are three at the moment. User consent, admin consent and admin consent across the entire organization. The last two can, as the name indicates, only be given by a Global Administrator of that tenant.

**User Consent**
* User authorizes that their data can be used (image)
* Limited to only permissions that the user can consent to
* The Graph API i.e. published a list of all the permissions with an indicator if admin consent is required. You can find the list [here](https://docs.microsoft.com/en-us/graph/permissions-reference)

![UserConsent](/content/images/2019/07/UserConsent.png)

**Admin Consent**

* Can only be given by a Global Administrator
* Often for permissions that can make alterations to other objects than the current user
* When admin consent is needed, your users will get a message like this:

![adminconsent-1](/content/images/2019/08/adminconsent-1.png)

**Admin Consent on behalf of Organization**

* Give consent for the entire tenant
* Users do not get a permission consent screen anymore
* Users don't see which data is used from them
* **CAUTION** if you consent here, you give the entire organization permissions on this application. 

If you don't want everyone in the organization to have access to this app you can block that by setting *User assignment is required* to Yes in the Enterprise application. More on this in the next part.

![orgConsent](/content/images/2019/08/orgConsent.png)

This can also be done in the Azure portal by going to the application page in de AAD and clicking the *Grant Admin Consent* as you can see below

![grandconsent](/content/images/2019/08/grandconsent.png)

> Any user can add **Admin** permissions to their application registration although the permission are not active until granted by an actual Global Administrator.

If you want to go more in-depth you can visit the docs at Microsoft [here](https://docs.microsoft.com/bs-cyrl-ba/azure/active-directory/develop/application-consent-experience)

## Managing Enterprise Applications
When you create an application through application registration there is also an enterprise application created in your AAD once the first user has logged on. This is used to manage how the registration behaves in your organization. This could be in the same tenant as you created the application registration in. For a multi-tenant app, there would only exist an Enterprise Application. Enterprise applications can be found under your AAD in the Azure portal

![enterpriseapplications](/content/images/2019/08/enterpriseapplications.png)

In the enterprise application, you cannot change permissions, but you can manage your or an external (3rd party) application from here. This is what you can do:

* Enable or disable the ability for users to log in
* Change the Application icon
* User assignment is required - When turned to Yes user cannot log in into the application without first being added by the owner of the app or by some with a privileged role like a global admin.
* Visible to Users - Show or Hide the application in the office.com top left launcher menu (at the bottom).
* Delete the application

It will look something like this

![EnterpriseApplicationProperties](/content/images/2019/07/EnterpriseApplicationProperties.png)

## Why care about these applications?
At the moment, if you don't have a clear process for application registrations, it is very unclear what permissions are assigned to all the applications. But more importantly who has access. Over time an Azure tenant can have lots of applications. Most of them are harmless and just read the users profile to show a name or use the email address. But then some applications only use an application secret to get access.

What happens when this secret gets committed to a git repository by accident. Sending this secret to other developers is also not a good idea. Although these examples shouldn't happen that often, they do so be careful with this.

On the other side, we always assume a security breach comes from external sources or mistakes from employees. What about internal breaches? How often does this happen? Take a look at a few sources:

* [75% are insider threats](https://securityintelligence.com/news/insider-threats-account-for-nearly-75-percent-of-security-breach-incidents/)
* [Even partners attack you](https://www.theregister.co.uk/2018/04/10/verizon_dbir/)

# What can happen?
Any of the previous examples can result in a data breach or other malicious actions. Depending on what permissions the application has of course. In my opinion, for *delegated* permissions the chance of malicious action is very low, especially when MFA is enabled. For *application* type permissions this is a whole other world. When someone gets a hold of that secret they can do what the permissions allow them to. 

Possibilities:
* Read all your users
* Alter Azure resources
* Add and delete users
* etc, etc, almost anything you can do in the Azure portal

There is no way of linking it back to a user and it will not show up in any of the Microsofts Security products since it looks like a legit use of the application registration.

Then there are is also something that is called an illicit consent grant. The attacker tricks the user into consenting an application on their website or by injecting malicious code into an existing website. This allows the hacker to access your data without you knowing. Microsoft already acknowledged this kind of attack and made a *Detect* and *Remediation* guide for it [here](https://docs.microsoft.com/en-us/office365/securitycompliance/detect-and-remediate-illicit-consent-grants).  

With all the things that could happen is it wise to check the application registrations in your tenant and act on them. Let's see if we can get an overview of the application registrations in your tenant

# Getting the overview
Now we know what can happen, how can we get an overview of these applications? The Azure portal shows all the applications but it takes a lot of time to go into every application and check the permissions. This would be a major time sink. Unfortunately for the *application* type permissions, there is no other way at the moment. For *delegated* permissions there is a better way.

What you can do is go the Microsoft Cloud App Security (MCAS) portal an see all the applications in your tenant with a permission level. This way you can focus on the high permissions applications first. 

![mcas2](/content/images/2019/08/mcas2.png)

In this portal, you can also see if there is a consent given for all the users in this organization

![orgconsent2](/content/images/2019/08/orgconsent2.png)
# Making it more secure

Now that you have a basic understanding of Azure AD Application Registrations there are a few things you can do:
* Initiate an onboarding procedure for adding new Apps that have/need admin consent.
* Refresh secrets on a scheduled basis (custom implementation needed)
* Use Managed Identities where possible instead of connection strings
* Double check if the permissions are needed, i.e. don't set Directory.ReadWrite.All *application* permissions when you just want to read AD groups. Use the specific Group.Read.All permission for this.

We now know how to see what applications we have within a tenant and how to see what permissions they have assigned. What you can do now is up to you. Of course, it is totally legit to have all these applications with the permissions, but now you can at least set up a process to guide this. Contact the owners if the application is still used and why those permissions are needed. 

Although it still is re[mark]able how much effort it cost to get an overview of *application* type permissions. I will look into this for a next blog.

Thanks for reading!
