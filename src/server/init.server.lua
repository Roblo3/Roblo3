local aws = require(script.aws)

local url = aws.urlEncode("https://aws.amazon.com/api-gateway/")

print(url)

local str = "hello\nworld"
print(str)