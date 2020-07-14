local HttpService = game:GetService("HttpService")

local function uriEncode(string, doubleEncodeEquals)
    local baseUrl = HttpService:UrlEncode(string)
    local urlWithHyphens = string.gsub(baseUrl, "%%2D", "-")
    local urlWithPeriods = string.gsub(urlWithHyphens,"%%2E", ".")
    local urlWithUnderscores = string.gsub(urlWithPeriods, "%%5F", "_")
    local encodedUrl = string.gsub(urlWithUnderscores, "%%7E", "~")
    if doubleEncodeEquals then
        local urlWithDoubleEncodedEquals = string.gsub(encodedUrl, "%%3D", "%253D")
        return urlWithDoubleEncodedEquals
    end
    return encodedUrl
end

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

local function sortTable(table)
    local tempTable = {}
    for key, value in pairs(table) do
        table.insert(tempTable, {key, value})
    end
    table.sort(tempTable, function(a,b) return a[1] < b[1] end)
    local sortedTable = {}
    for i = 1, #tempTable do
        for key, value in pairs(tempTable[i]) do
            sortedTable[key] = value
        end
    end
    return sortedTable
end

local function formCanonicalRequest(method, path, query, headers, payload)
    local canonicalMethod = string.upper(method) .. "\n"
    local canonicalUri = "/"
    local pathSegments = split(path, "/")
    for k, v in pairs(pathSegments) do
        canonicalUri = canonicalUri .. uriEncode(uriEncode(v))
    end
    canonicalUri = canonicalUri .. "\n"
    canonicalQueryString = ""
    for k, v in pairs(sortTable(query)) do
        canonicalQueryString = canonicalQueryString .. k .. "=" .. uriEncode(v, true) .. "&"
    end
    canonicalQueryString = string.sub(canonicalQueryString, 1, #canonicalQueryString - 1) .. "\n"
    local canonicalHeaders = ""
    local signedHeaders = ""
    for k, v in pairs(sortTable(headers)) do
        canonicalHeaders = canonicalHeaders .. string.lower(k) .. ":" .. v .. "\n"
        signedHeaders = signedHeaders .. k .. ";"
    end
    local payloadHash = "" --hash the given payload
    local canonicalRequest = canonicalMethod .. canonicalUri .. canonicalQueryString .. canonicalHeaders .. payloadHash
    return canonicalRequest
end

local function formCredentialScope(datestamp, region, service)
    credentialScope = datestamp .. "/" .. region .. "/" .. service .. "/" .. "aws4_request"
    return credentialScope
end

local function formStringToSign(requestDateTime, credentialScope, canonicalRequest)
    local algorithm = "AWS4-HMAC-SHA256"
    local canonicalRequestHash = "" --hash the canonical request
    local stringToSign = algorithm .. "\n" .. requestDateTime .. "\n" .. credentialScope .. "\n" .. canonicalRequestHash
end

local function dynamodb(accessKeyId, secretAccesskey)
    local this = {}

    this.secretAccesskey = secretAccesskey
    this.accessKeyId = accessKeyId

    function GetAsync(key)
        local method = "GET"
    end

    return this
end

return { urlEncode = urlEncode }