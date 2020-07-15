local auth = require(script.Parent.Authentication)
local hashLib = require(script.Parent.Parent.HashLib)
local requester = require(script.Parent.Requester)

local function serviceResource(accessKeyId, secretAccesskey, region)
    local ddb = {}

    if not region then region = "us-east-1" end

    ddb.algorithm = "AWS4-HMAC-SHA256"
    ddb.secretAccessKey = secretAccesskey
    ddb.accessKeyId = accessKeyId
    ddb.region = region
    ddb.service = "dynamodb"
    ddb.endpoint = "https://dynamodb."..ddb.region..".amazonaws.com"

    function ddb:Table(tableName)
        if self ~= ddb then error("Table must be called with `:`, not `.`") end

        self.ddbTable = {}
        local ddbTable = self.ddbTable
        ddbTable.Name = tableName

        function ddbTable:DescribeTable()
            print(ddb.algorithm)
        end

        -- local method = "POST"
        -- local algorithm = "AWS4-HMAC-SHA256"
        -- local requestTime = os.time()
        -- local datestamp = os.date("%Y%m%d", requestTime)
        -- local amzdate = os.date("%Y%m%dT%H%M%SZ", requestTime)

        -- local query = {}
        -- local payload = "{}"
        -- local path = ""
        -- local headers = {
        --     ["Host"] = "dynamodb."..self.region..".amazonaws.com",
        --     ["x-amz-date"] = amzdate,
        --     ["x-amz-target"] = "DynamoDB_20120810.ListTables",
        --     ["Content-Type"] = "application/x-amz-json-1.0"
        -- }

        -- local authItems = {
        --     ["method"] = method,
        --     ["algorithm"] = ddb.algorithm,
        --     ["datestamp"] = datestamp,
        --     ["amzdate"] = amzdate,
        --     ["region"] = ddb.region,
        --     ["service"] = ddb.service,
        --     ["secretAccessKey"] = ddb.secretAccessKey,
        --     ["accessKeyId"] = ddb.accessKeyId,
        --     ["payload"] = payload,
        --     ["path"] = path,
        --     ["headers"] = headers,
        --     ["query"] = query
        -- }

        -- local authHeader, canonicalQueryString = auth.formAuthenticationHeader(authItems)

        -- headers["Authorization"] = authHeader
 
        -- local url = self.endpoint .. path
        -- if canonicalQueryString ~= "" then url = url .. "?" .. canonicalQueryString end
        
        return ddbTable
    end

    return ddb
end

return { serviceResource = serviceResource }