local auth = require(script.Parent.Utilities.Authentication)
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

local function client(accessKeyId, secretAccessKey, region)
    local cwl = {}
    local secrets = {}

    secrets.secretAccessKey = secretAccessKey
    secrets.accessKeyId = accessKeyId

    cwl.algorithm = "AWS4-HMAC-SHA256"
    cwl.region = region
    cwl.service = "logs"
    cwl.endpoint = "https://logs."..cwl.region..".amazonaws.com"

    function cwl:PutLogEvents(kwargs)
        if self ~= cwl then error("`PutLogEvents` must be called with `:`, not `.`", 2) end
        if type(kwargs) ~= "table" then error("`kwargs` must be a table", 2) end
        if kwargs["logGroupName"] == nil then error("`logGroupName` must be specified in `kwargs`", 2) end
        if kwargs["logStreamName"] == nil then error("`logStreamName` must be specified in `kwargs`", 2) end
        if kwargs["logEvents"] == nil then error("`logEvents` must be specified in `kwargs`", 2) end

        local method = "POST"
        local query = {}
        local payload = toJson(kwargs)
        local path = ""
        local headers = {
            ["Host"] = "logs."..self.region..".amazonaws.com",
            ["x-amz-date"] = amzdate,
            ["x-amz-target"] = "Logs_20140328.PutLogEvents",
            ["Content-Type"] = "application/x-amz-json-1.0"
        }

        local authItems = {
            ["method"] = method,
            ["algorithm"] = self.algorithm,
            ["datestamp"] = datestamp,
            ["amzdate"] = amzdate,
            ["region"] = self.region,
            ["service"] = self.service,
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

        local url = self.endpoint .. path
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
            local nextSequenceToken = nil
            if bodyData["nextSequenceToken"] ~= nil then
                nextSequenceToken = bodyData["nextSequenceToken"]
            end
            return nextSequenceToken, bodyData, response
        else
            error(response.ErrorType..": "..response.ErrorMessage, 2)
        end

    end

    return cwl
end