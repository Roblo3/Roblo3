# AWS-SDK-for-Roblox-Lua

## About
This repository contains an **unofficial** implementation of an AWS Software Development Kit (based mostly on the [AWS Boto3 SDK for Python](https://github.com/boto/boto3)) that conforms to the implmentation of Lua on the [Roblox Platform](https://roblox.com). 

Due to limitations imposed by Roblox, there will be services that cannot be included, mainly due to lack of usable functionality (for instance, Amazon Simple Storage Service (S3) cannot be included due to a lack of filesystem manipulation commands).

## Security Considerations / Disclaimer
Because this AWS SDK is not maintained, nor managed or overseen by, any person at Amazon Web Services, Access Key ID and Secret Key security should be more of a concern. Namely, concerns regarding this SDK sending information regarding Access Key IDs and Secret Keys being sent to places away from the AWS Service APIs are very valid. This SDK does not make any web requests to the AWS Service APIs unless explicitly directed to by the developer, namely by invoking an SDK function. Additionally, this SDK does not make web requests to any place that could compromise AWS security credentials; only the AWS account the security credentials are assigned to are ever accessed. However, as always, *trust, but verify*; in other words, trust that this SDK does not make nefarious web requests, but verify that for yourself if able (or find someone else who's trusted and have them look over this).

It should be added that the use of this SDK puts the security of your security credentials into your hands. All (reasonable) attempts will be made at preventing security crednetials from being obtained through vulnerabilities in the SDK, however if credentials are accidentally exposed to a/many client(s), it is up to you to revoke those credentials and issue new ones.

Additionally, Roblox, as of July 15th, 2020, does *not* currently have a way of securely storing protected secrets, such as API keys, including your AWS Security credentials. Storing security credentials in a script is bad practice, but is one of only a few options; all of which are practically no more secure than this. 

----

By using this SDK, you agree that *you* are solely responsible for the security of AWS security credentials (AWS Access Key ID and AWS Secret Key).

## Included Services
* Amazon DynamoDB

## Cannot Include Services
* Amazon Simple Storage Service (S3) - Lack of usable funcationality (lack of filesystem commands)