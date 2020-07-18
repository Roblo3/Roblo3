local HttpService = game:GetService("HttpService")

local errorInfo = require(script.Parent.ErrorInfo)

local function split(inputString, separator) 
	local sep = separator or '%s'
	local t = {}
	for field, s in string.gmatch(inputString, "([^"..sep.."]*)("..sep.."?)") do 
		table.insert(t,field)
		if s == "" then
			return t
		end 
	end
end

local function between(num, numMin, numMax)
    return num >= numMin and num <= numMax
end

local function toJson(str)
    return HttpService:JSONEncode(str)
end

local function toTable(json)
    return HttpService:JSONDecode(json)
end

local function toDdbJson(originalTable, storeTable, topLevel)
    if topLevel == nil then topLevel = true end
    for key, value in pairs(originalTable) do
        local type = type(value)
        if type == "table" and not topLevel then
            storeTable[key] = {}
            if #value == 0 then --convert to map
                storeTable[key]["M"] = {}
                toDdbJson(value, storeTable[key]["M"], false)
            else --convert to list
                storeTable[key]["L"] = {}
                toDdbJson(value, storeTable[key]["L"], false)
            end
        elseif type == "table" then
            storeTable[key] = {}
            toDdbJson(value, storeTable[key], false)
        elseif type == "string" then
            storeTable[key] = {
                ["S"] = value
            }
        elseif type == "boolean" then
            storeTable[key] = {
                ["BOOL"] = tostring(value)
            }
        elseif type == "number" then
            storeTable[key] = {
                ["N"] = tostring(value)
            }
        end
    end
end

local function fromDdbJson(ddbJson, storeTable)
    for key, value in pairs(ddbJson) do
        storeTable[key] = {}
        for k, v in pairs(value) do
            if k == "M" then
                fromDdbJson(v, storeTable[key])
            elseif k == "L" then
                fromDdbJson(v, storeTable[key])
            elseif k == "S" then
                storeTable[key] = tostring(v)
            elseif k == "N" then
                storeTable[key] = tonumber(v)
            elseif k == "BOOL" then
                storeTable[key] = v
            end
        end
    end
end

local function handleResponse(response)
    local statusCode = response.StatusCode
    if between(statusCode, 200, 299) then
        --2XX request means the request succeeded; send it back to the user
        return {
            ["Success"] = true,
            ["Retry"] = false,
            ["Response"] = response,
            ["ErrorType"] = "None",
            ["ErrorMessage"] = "None"
        }
    elseif between(statusCode, 400, 499) then
        --4XX request means the request errored due to the client
        --Need to parse the response and retry if the error can be solved
        --with exponential backoff and retries
        local responseBody = response.Body
        local responseData = toTable(responseBody)
        local errorTypeData = split(responseData["__type"], "#")
        local errorMessage = responseData["message"] or responseData["Message"]
        local errorType = errorTypeData[2]
        local errorInfo = errorInfo[errorType]
        if not errorInfo then
            return {
                ["Success"] = false,
                ["Retry"] = true,
                ["Response"] = response,
                ["ErrorType"] = errorType,
                ["ErrorMessage"] = errorMessage
            }
        else
            return {
                ["Success"] = false,
                ["Retry"] = errorInfo["tryAgain"],
                ["Response"] = response,
                ["ErrorType"] = errorType,
                ["ErrorMessage"] = errorMessage
            }
        end
    elseif between(statusCode, 500, 599) then
        --5XX means the server errored; retry the request
        return {
            ["Success"] = false,
            ["Retry"] = true,
            ["Response"] = response,
            ["ErrorType"] = "Internal Server Error",
            ["ErrorMessage"] = "Internal Server Error"
        }
    end
end

local function request(requestArgs, maxTries)
    assert(type(requestArgs) == "table", "`requestArgs must be a table")
    local response = {}
    local maxTries = maxTries or 5
    local currentTries = 0
    local tryAgain = true
    repeat
        wait(((2^currentTries) * 0.1) + (math.random(100, 1001) / 1000))
        local success, err = pcall(function()
            response = HttpService:RequestAsync(requestArgs)
        end)
        if success then
            currentTries = currentTries + 1

            --check if the code is between [200, 299]; if not, then 
            --either throw and error or retry if necessary

            local requstSuccessInfo = handleResponse(response)
            if not requstSuccessInfo.Success then
                if not requstSuccessInfo.tryAgain then
                    return requstSuccessInfo
                end
            else
                return requstSuccessInfo
            end
        else
            tryAgain = false
        end
    until (not tryAgain) or (currentTries >= maxTries)
    if currentTries >= maxTries then
        --return something to the user if maxTries was exceeded

        return {
            ["Success"] = false,
            ["ErrorType"] = "Request Failed",
            ["ErrorMessage"] = "Request tries exceeded maximum"
        }

    end
end

return {request = request, toJson = toJson, toTable = toTable, toDdbJson = toDdbJson, fromDdbJson = fromDdbJson}