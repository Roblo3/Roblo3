local auth = require(script.Parent.Utilities.Authentication)
local hashLib = require(script.Parent.Utilities.HashLib)
local requester = require(script.Parent.Utilities.Requester)

local request = requester.request
local toJson = requester.toJson
local toTable = requester.toTable

local function requestTime()
    local requestTime = os.time()
    local datestamp = os.date("%Y%m%d", requestTime)
    local amzdate = os.date("%Y%m%dT%H%M%SZ", requestTime)
    return datestamp, amzdate
end

local function serviceResource(accessKeyId, secretAccessKey, region)
    local ddb = {}
    local secrets = {}

    secrets.secretAccessKey = secretAccessKey
    secrets.accessKeyId = accessKeyId

    ddb.algorithm = "AWS4-HMAC-SHA256"
    ddb.region = region
    ddb.service = "dynamodb"
    ddb.endpoint = "https://dynamodb."..ddb.region..".amazonaws.com"

    function ddb:Table(tableName)
        if self ~= ddb then error("Table must be called with `:`, not `.`", 2) end
        if table == nil then error("`tableName` is a required parameter", 2) end

        self.ddbTable = {}
        local ddbTable = self.ddbTable
        ddbTable.Name = tableName

        function ddbTable:GetTableInfo()
            local method = "POST"

            local datestamp, amzdate = requestTime()

            local query = {}
            local payload = '{"TableName": "'..self.Name..'"}'
            local path = ""
            local headers = {
                ["Host"] = "dynamodb."..ddb.region..".amazonaws.com",
                ["x-amz-date"] = amzdate,
                ["x-amz-target"] = "DynamoDB_20120810.DescribeTable",
                ["Content-Type"] = "application/x-amz-json-1.0"
            }

            local authItems = {
                ["method"] = method,
                ["algorithm"] = ddb.algorithm,
                ["datestamp"] = datestamp,
                ["amzdate"] = amzdate,
                ["region"] = ddb.region,
                ["service"] = ddb.service,
                ["secretAccessKey"] = secrets.secretAccessKey,
                ["accessKeyId"] = secrets.accessKeyId,
                ["payload"] = payload,
                ["path"] = path,
                ["headers"] = headers,
                ["query"] = query
            }

            local authHeader, canonicalQueryString = auth.formAuthenticationHeader(authItems)

            headers["Authorization"] = authHeader
            headers["Host"] = nil

            local url = ddb.endpoint .. path
            if canonicalQueryString ~= "" then url = url .. "?" .. canonicalQueryString end
            local requestParams = {
                ["Url"] = url,
                ["Method"] = method,
                ["Headers"] = headers,
                ["Body"] = payload
            }
            local response = request(requestParams)
            if response.Success then
                local responseData = response.Response
                local body = responseData.Body
                local data = toTable(body)
                return data.Table
            else
                error(response.ErrorType..": "..response.ErrorMessage, 2)
            end
        end

        --function ddbTable:
        
        return ddbTable
    end

    return ddb
end

return { serviceResource = serviceResource }