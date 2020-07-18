import boto3
import json

dynamodb = boto3.resource("dynamodb", region_name="us-west-2")

TestTable = dynamodb.Table("TestTable")

response = TestTable.get_item(
    Key={
        "Id": "helloworld"
    },
    ReturnConsumedCapacity="alsdkjf"
)

print(response)