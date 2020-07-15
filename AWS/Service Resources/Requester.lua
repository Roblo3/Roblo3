local HttpService = game:GetService("HttpService")

local function rawRequest(url, method, headers, body, maxRetries)
    local maxRetries = maxRetries or 5
    local currentTry = 0
    local response = {}
    repeat
        currentTry = currentTry + 1
        wait(2^currentTry * 0.1 * (math.random(1, 4) / 2))
        response = HttpService:RequestAsync(url, method, headers, body)
    until response.Success or (not response.Success and response.StatusCode) or (currentTry >= 5)
    if response.Success then
        return response
    else
        return error(response.StatusMessage, 0)
    end
end

local function request(url, method, headers, body)
    local success, result = pcall(rawRequest, url, method, headers, body)
    if success then
        return result
    else
        return nil
    end
end

return {request = request}