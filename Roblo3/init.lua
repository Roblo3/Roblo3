local __version = "1.0.0"

local services = {}

for _, child in pairs(script:GetDescendants()) do
    if child:IsA("ModuleScript") and not child:IsDescendantOf(script.Utilities) then
        local temp = require(child)
        services[string.lower(child.Name)] = temp
    end
end

local function resource(resourceName, kwargs)
    local env = getfenv()
    if kwargs ~= nil and kwargs["accessKeyId"] ~= nil then
        accessKeyId = kwargs["accessKeyId"]
    elseif env["accessKeyId"] ~= nil then
        accessKeyId = env["accessKeyId"]
    end
    if accessKeyId == nil then error("`accessKeyId` was not provided", 2) end
    if kwargs ~= nil and kwargs["secretAccessKey"] ~= nil then
        secretAccessKey = kwargs["secretAccessKey"]
    elseif env["secretAccessKey"] ~= nil then
        secretAccessKey = env["secretAccessKey"]
    end
    if secretAccessKey == nil then error("`secretAccessKey` was not provided", 2) end
    local service = services[resourceName]
    if not service then error("Service `"..resourceName.."` not found") end
    if type(kwargs) ~= "table" then error("kwargs must be a table") end
    local regionName = kwargs["regionName"]
    if not regionName then regionName = "us-east-1" end
    local resource = service.serviceResource(accessKeyId, secretAccessKey, regionName)
    return resource
end

local function client(resourceName, kwargs)
    local env = getfenv()
    if kwargs ~= nil and kwargs["accessKeyId"] ~= nil then
        accessKeyId = kwargs["accessKeyId"]
    elseif env["accessKeyId"] ~= nil then
        accessKeyId = env["accessKeyId"]
    end
    if accessKeyId == nil then error("`accessKeyId` was not provided", 2) end
    if kwargs ~= nil and kwargs["secretAccessKey"] ~= nil then
        secretAccessKey = kwargs["secretAccessKey"]
    elseif env["secretAccessKey"] ~= nil then
        secretAccessKey = env["secretAccessKey"]
    end
    if secretAccessKey == nil then error("`secretAccessKey` was not provided", 2) end
    local service = services[resourceName]
    if not service then error("Service `"..resourceName.."` not found") end
    if type(kwargs) ~= "table" then error("kwargs must be a table") end
    local regionName = kwargs["regionName"]
    if not regionName then regionName = "us-east-1" end
    local resource = service.client(accessKeyId, secretAccessKey, regionName)
    return resource
end

return {resource = resource, client = client}