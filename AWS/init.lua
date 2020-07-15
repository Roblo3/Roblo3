local serviceResources = {}

for _, child in pairs(script["Service Resources"]:GetDescendants()) do
    if child:IsA("ModuleScript") and child.Name ~= "Authentication" then
        local temp = require(child)
        serviceResources[string.lower(child.Name)] = temp
    end
end

local function resource(resourceName, accessKeyId, secretKeyId, kwargs)
    local service = serviceResources[resourceName]
    if not service then error("Service `"..resourceName.."` not found") end
    if type(kwargs) ~= "table" or type(kwargs) == "nil" then error("kwargs must be a table") end
    local regionName = kwargs["regionName"]
    local resource = service.serviceResource(accessKeyId, secretKeyId, regionName)
    return resource
end

local function client(resourceName, accessKeyId, secretKeyId, kwargs)
    error("`client` not currently implemented. Please use `resource` instead.")
end

return {resource = resource, client = client}