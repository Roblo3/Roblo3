local auth = require(script.Parent.Utilities.Authentication)
local requester = require(script.Parent.Utilities.Requester)

local request = requester.request
local toJson = requester.toJson
local toTable = requester.toTable
local toDdbJson = requester.toDdbJson
local fromDdbJson = requester.fromDdbJson

local function get_timezone_offset(ts)
	local utcdate   = os.date("!*t", ts)
	local localdate = os.date("*t", ts)
	localdate.isdst = false -- this is the trick
	return os.difftime(os.time(localdate), os.time(utcdate))
end

local function requestTime()
    local requestTime = os.time() - get_timezone_offset()
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
        if tableName == nil then error("`tableName` is a required parameter", 2) end

        self.ddbTable = {}
        local ddbTable = self.ddbTable
        ddbTable.Name = tableName
        
        function ddbTable:DeleteItem(kwargs)
            if self ~= ddbTable then error("`DeleteItem` must be called with `:`, not `.`", 2) end
            if type(kwargs) ~= "table" then error("`kwargs` must be a table", 2) end
            local ddbJson = {}
            ddbJson["Key"] = {}
            toDdbJson(kwargs["Key"], ddbJson["Key"])
            ddbJson["TableName"] = ddbTable.Name
            ddbJson["ConditionExpression"] = kwargs["ConditionExpression"]
            ddbJson["ExpressionAttributeNames"] = kwargs["ExpressionAttributeNames"]
            if kwargs["ExpressionAttributeValues"] ~= nil then
                ddbJson["ExpressionAttributeValues"] = {}
                toDdbJson(kwargs["ExpressionAttributeValues"], ddbJson["ExpressionAttributeValues"])
            end
            ddbJson["ReturnConsumedCapacity"] = kwargs["ReturnConsumedCapacity"] or "TOTAL"
            ddbJson["ReturnItemCollectionMetrics"] = kwargs["ReturnItemCollectionMetrics"]
            ddbJson["ReturnValues"] = kwargs["ReturnValues"]

            local datestamp, amzdate = requestTime()

            local method = "POST"
            local query = {}
            local payload = toJson(ddbJson)
            local path = ""
            local headers = {
                ["Host"] = "dynamodb."..ddb.region..".amazonaws.com",
                ["x-amz-date"] = amzdate,
                ["x-amz-target"] = "DynamoDB_20120810.DeleteItem",
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
                local responseDataRaw = response.Response
                local body = responseDataRaw.Body
                local bodyData = toTable(body)
                local responseData = {}
                if bodyData.Attributes ~= nil then 
                    responseData["Attributes"] = {}
                    fromDdbJson(bodyData.Attributes, responseData["Attributes"])
                end
                if bodyData.ItemCollectionMetrics ~= nil then
                    responseData["ItemCollectionMetrics"] = {}
                    responseData["ItemCollectionMetrics"]["ItemCollectionKey"] = {}
                    responseData["ItemCollectionMetrics"]["SizeEstimateRangeGB"] = bodyData["ItemCollectionMetrics"]["SizeEstimateRangeGB"]
                    fromDdbJson(bodyData["ItemCollectionMetrics"]["ItemCollectionKey"], responseData["ItemCollectionMetrics"]["ItemCollectionKey"])
                end
                if bodyData.ConsumedCapacity ~= nil then
                    responseData["ConsumedCapacity"] = bodyData.ConsumedCapacity
                end
                if responseData == {} then responseData = nil end
                return responseData, bodyData, response
            else
                error(response.ErrorType..": "..response.ErrorMessage, 2)
            end
        end

        function ddbTable:GetItem(kwargs)
            if self ~= ddbTable then error("`GetItem` must be called with `:`, not `.`", 2) end
            if type(kwargs["Key"]) ~= "table" then error("`kwargs` must be a table", 2) end
            local ddbJson = {}
            ddbJson["Key"] = {}
            toDdbJson(kwargs["Key"], ddbJson["Key"])
            ddbJson["TableName"] = ddbTable.Name
            ddbJson["ConsistentRead"] = kwargs["ConsistentRead"] or false
            ddbJson["ReturnConsumedCapacity"] = kwargs["ReturnConsumedCapacity"] or "TOTAL"
            ddbJson["ExpressionAttributeNames"] = kwargs["ExpressionAttributeNames"]
            ddbJson["ProjectionExpression"] = kwargs["ProjectionExpression"]

            local datestamp, amzdate = requestTime()

            local method = "POST"
            local query = {}
            local payload = toJson(ddbJson)
            local path = ""
            local headers = {
                ["Host"] = "dynamodb."..ddb.region..".amazonaws.com",
                ["x-amz-date"] = amzdate,
                ["x-amz-target"] = "DynamoDB_20120810.GetItem",
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
                local responseDataRaw = response.Response
                local body = responseDataRaw.Body
                local bodyData = toTable(body)
                local item = {}
                if bodyData.Item ~= nil then
                    fromDdbJson(bodyData.Item, item)
                else
                    item = nil
                end
                return item, bodyData, response
            else
                error(response.ErrorType..": "..response.ErrorMessage, 2)
            end
        end

        function ddbTable:GetTableInfo()
            if self ~= ddbTable then error("`UpdateItem` must be called with `:`, not `.`", 2) end
            local datestamp, amzdate = requestTime()

            local method = "POST"
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

        function ddbTable:PutItem(kwargs)
            if self ~= ddbTable then error("`PutItem` must be called with `:`, not `.`", 2) end
            if type(kwargs) ~= "table" then error("`kwargs` must be a table", 2) end
            local ddbJson = {}
            ddbJson["Item"] = {}
            toDdbJson(kwargs["Item"], ddbJson["Item"])
            ddbJson["TableName"] = ddbTable.Name
            ddbJson["ConditionExpression"] = kwargs["ConditionExpression"]
            ddbJson["ExpressionAttributeNames"] = kwargs["ExpressionAttributeNames"]
            if kwargs["ExpressionAttributeValues"] ~= nil then
                ddbJson["ExpressionAttributeValues"] = {}
                toDdbJson(kwargs["ExpressionAttributeValues"], ddbJson["ExpressionAttributeValues"])
            end
            ddbJson["ReturnConsumedCapacity"] = kwargs["ReturnConsumedCapacity"] or "TOTAL"
            ddbJson["ReturnItemCollectionMetrics"] = kwargs["ReturnItemCollectionMetrics"]
            ddbJson["ReturnValues"] = kwargs["ReturnValues"]

            local datestamp, amzdate = requestTime()

            local method = "POST"
            local query = {}
            local payload = toJson(ddbJson)
            local path = ""
            local headers = {
                ["Host"] = "dynamodb."..ddb.region..".amazonaws.com",
                ["x-amz-date"] = amzdate,
                ["x-amz-target"] = "DynamoDB_20120810.PutItem",
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
                local responseDataRaw = response.Response
                local body = responseDataRaw.Body
                local bodyData = toTable(body)
                local responseData = {}
                if bodyData.Attributes ~= nil then 
                    responseData["Attributes"] = {}
                    fromDdbJson(bodyData.Attributes, responseData["Attributes"])
                end
                if bodyData.ItemCollectionMetrics ~= nil then
                    responseData["ItemCollectionMetrics"] = {}
                    responseData["ItemCollectionMetrics"]["ItemCollectionKey"] = {}
                    responseData["ItemCollectionMetrics"]["SizeEstimateRangeGB"] = bodyData["ItemCollectionMetrics"]["SizeEstimateRangeGB"]
                    fromDdbJson(bodyData["ItemCollectionMetrics"]["ItemCollectionKey"], responseData["ItemCollectionMetrics"]["ItemCollectionKey"])
                end
                if bodyData.ConsumedCapacity ~= nil then
                    responseData["ConsumedCapacity"] = bodyData.ConsumedCapacity
                end
                if responseData == {} then responseData = nil end
                return responseData, bodyData, response
            else
                error(response.ErrorType..": "..response.ErrorMessage, 2)
            end
        end
            
        function ddbTable:UpdateItem(kwargs)
            if self ~= ddbTable then error("`UpdateItem` must be called with `:`, not `.`", 2) end
            if type(kwargs) ~= "table" then error("`kwargs` must be a table", 2) end
            local ddbJson = {}
            ddbJson["Key"] = {}
            toDdbJson(kwargs["Key"], ddbJson["Key"])
            ddbJson["TableName"] = ddbTable.Name
            ddbJson["ConditionExpression"] = kwargs["ConditionExpression"]
            ddbJson["ExpressionAttributeNames"] = kwargs["ExpressionAttributeNames"]
            if kwargs["ExpressionAttributeValues"] ~= nil then
                ddbJson["ExpressionAttributeValues"] = {}
                toDdbJson(kwargs["ExpressionAttributeValues"], ddbJson["ExpressionAttributeValues"])
            end
            ddbJson["ReturnConsumedCapacity"] = kwargs["ReturnConsumedCapacity"] or "TOTAL"
            ddbJson["ReturnItemCollectionMetrics"] = kwargs["ReturnItemCollectionMetrics"]
            ddbJson["ReturnValues"] = kwargs["ReturnValues"]
            ddbJson["UpdateExpression"] = kwargs["UpdateExpression"]

            local datestamp, amzdate = requestTime()

            local method = "POST"
            local query = {}
            local payload = toJson(ddbJson)
            local path = ""
            local headers = {
                ["Host"] = "dynamodb."..ddb.region..".amazonaws.com",
                ["x-amz-date"] = amzdate,
                ["x-amz-target"] = "DynamoDB_20120810.UpdateItem",
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
                local responseDataRaw = response.Response
                local body = responseDataRaw.Body
                local bodyData = toTable(body)
                local responseData = {}
                if bodyData.Attributes ~= nil then 
                    responseData["Attributes"] = {}
                    fromDdbJson(bodyData.Attributes, responseData["Attributes"])
                end
                if bodyData.ItemCollectionMetrics ~= nil then
                    responseData["ItemCollectionMetrics"] = {}
                    responseData["ItemCollectionMetrics"]["ItemCollectionKey"] = {}
                    responseData["ItemCollectionMetrics"]["SizeEstimateRangeGB"] = bodyData["ItemCollectionMetrics"]["SizeEstimateRangeGB"]
                    fromDdbJson(bodyData["ItemCollectionMetrics"]["ItemCollectionKey"], responseData["ItemCollectionMetrics"]["ItemCollectionKey"])
                end
                if bodyData.ConsumedCapacity ~= nil then
                    responseData["ConsumedCapacity"] = bodyData.ConsumedCapacity
                end
                if responseData == {} then responseData = nil end
                return responseData, bodyData, response
            else
                error(response.ErrorType..": "..response.ErrorMessage, 2)
            end
        end

        return ddbTable
    end

    return ddb
end

return { serviceResource = serviceResource }