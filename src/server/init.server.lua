local aws = require(script.aws)

local authHeader = aws.dynamodb("A123", "S123", "us-east-1")

print(authHeader)