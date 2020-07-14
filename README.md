# AWS-SDK-for-Roblox-Lua

## About
This repository contains an **unofficial** implementation of an AWS Software Development Kit (partially on the [AWS Boto3 SDK for Python](https://github.com/boto/boto3)) that conforms to the implmentation of Lua on the [Roblox Platform](https://roblox.com). 

Due to limitations imposed by Roblox, there will be services that cannot be included, mainly due to lack of usable functionality (for instance, Amazon Simple Storage Service (S3) cannot be included due to a lack of filesystem manipulation commands).

## Included Services
* Amazon DynamoDB

## Cannot Include Services
* Amazon Simple Storage Service (S3) - Lack of usable funcationality (lack of filesystem commands)