# Roblo3 - Unofficial AWS SDK for Roblox Lua

Roblo3 is an unofficial Software (Game) Development Kit allowing for integration of Amazon Web Services with Roblox games. It aims to be easy to use and develop with, easing the integration of AWS into Roblox games.

Roblo3 is named in homage to the [AWS Boto3 SDK](https://github.com/boto/boto3) for Python; additionally, Roblo3 is an object oriented SDK with a similar structure to that of Boto3.

Roblo3 handles signing requests to AWS, and conforms to the Signature Version 4 required by all modern AWS Services (Signature Version 4 is supported by all AWS Services with the exception of Amazon SimpleDB, which has been largely deprecated and superseded by Amazon DynamoDB; due to this, Roblo3 does **not** support Amazon SimpleDB). Roblo3 also handles transmitting requests to AWS, then receiving, parsing, and translating requests into standard lua format (tables, strings, booleans, etc.).

# Documentation
Documentation for the Roblo3 SDK is available at https://roblo3.netlify.app/

# Quick Start
First, Insert the Roblo3 SDK model file into your game. Place it into either `ServerScriptService` or `ServerStorage`.

Second, call require on your path to the SDK. For this example, the SDK has been placed in `ServerScriptService`.

```lua
local ServerScriptService = game:GetService("ServerScriptService")
local roblo3 = require(ServerScriptService.Roblo3)
```

Next, setup a table with your preferred AWS service region (i.e., `us-east-1 (N. Virginia)` or `us-west-2 (Oregon)`), your AWS Access Key ID, and your AWS Secret Access Key, each assigned to keys within the table named `regionName`, `accessKeyId`, and `secretAccessKey`, respectively.

```lua
local awsArgs = {
    ["regionName"] = "us-west-2",
    ["accessKeyId"] = "YOUR_ACCESS_KEY_ID",
    ["secretAccessKey"] = "YOUR_SECRET_ACCESS_KEY"
}
```

Now, call the `resource` function from the SDK and pass in name of the resource you want (this must be lowercase; for this example, DynamoDB will be used) as well as the table setup in the previous step.

```lua
local dynamodb = roblo3.resource("dynamodb", awsArgs)
```

Then, call the `Table` function from DynamoDB and pass in the name of the table you want (for this, `TestTable` will be used).

```lua
local TestTable = dynamodb.Table("TestTable")
```

Finally, we can get information about the table by calling `GetTableInfo` on the table, then print the Amazon Resource Name returned by the function.

```lua
local tableInfo = TestTable.GetTableInfo()

print(tableInfo.TableArn)

-- Prints something like:
-- arn:aws:dynamodb:us-west-2:123456789012:table/TestTable
```

# Submitting Bug Reports and Feature Requests
Before submitting a bug report, remember to check via the AWS Management Console (the AWS CLI or official SDKs may also work) that your access keys/IAM User have access the resource you're attempting to use, and that the resource you're attempting to access has been configured properly and as you expected. 

Additionally, remember that the Roblo3 SDK function's cannot be tested in regular Studio test mode, as you will receive `InvalidSignatureException`s unless you set your computer timezone to Universal Coordinated Time (aka UTC; this is also normally the same as Greenwich Mean Time), or you are in a timezone aligned with Universal Coordinated Time.

If you've done all the above steps and your bug persists, then submit an issue describing your bug and steps to reproduce it (ideally with code samples; AWS security credentials removed, of course). 

If you'd like to submit a feature request, simply describe the feature you'd like added and some sample use cases. Note that the SDK only handles signing, transmitting, receiving, parsing, and translating requests and responses from AWS; extraneous functions that are not offered by the AWS APIs are limited to only those that are critical in the five aforementioned actions for handling requests to AWS and responses from AWS.

# Building the Model from 'Scratch'
1. To build the model from scratch, ensure the latest version of Rojo in installed on both you computer and Roblox Studio. (Rojo Version 6 was used to build the model, however version 0.5 should also work.)
2. Clone the repository to your computer and open Roblox Studio.
3. Open the cloned repository to its root directory, then run `rojo serve` and connect the Rojo plugin. The SDK should appear in `ServerScriptService`.

# Contributing to the Project
If you'd like to contribute to the project, simply fork the repository, edit/add to the codebase, and submit a pull request. As best as possible, your code will be reviewed for security vulnerabilities and functionality of any resources that were changed. Assuming your code passes both of these tests and a merge conflict does not occur, your pull request will likely be merged.

If you are a trusted member and have contributed to the project greatly, you may be invited to receive write access to the repository.