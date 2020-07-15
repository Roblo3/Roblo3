local HttpService = game:GetService("HttpService")

local hashLib = require(script.Parent.Parent.HashLib)

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

local function sortTable(tab)
    local tempTable = {}
    for key, value in pairs(tab) do
        table.insert(tempTable, {key, value})
    end
    table.sort(tempTable, function(a,b) return a[1] < b[1] end)
    return tempTable
end

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

local function formCanonicalRequest(method, path, query, headers, payload)
    local canonicalMethod = string.upper(method) .. "\n"
    local canonicalUri = "/"
    local pathSegments = split(path, "/")
    for k, v in pairs(pathSegments) do
        canonicalUri = canonicalUri .. uriEncode(uriEncode(v))
    end
    canonicalUri = canonicalUri .. "\n"
    local canonicalQueryString = ""
    for k, v in ipairs(sortTable(query)) do
        canonicalQueryString = canonicalQueryString .. v[1] .. "=" .. uriEncode(v[2], true) .. "&"
    end
    canonicalQueryString = string.sub(canonicalQueryString, 1, #canonicalQueryString - 1)
    local canonicalHeaders = ""
    local signedHeaders = ""
    for k, v in ipairs(sortTable(headers)) do
        canonicalHeaders = canonicalHeaders .. string.lower(v[1]) .. ":" .. v[2] .. "\n"
        signedHeaders = signedHeaders .. string.lower(v[1]) .. ";"
    end
    canonicalHeaders = canonicalHeaders .. "\n"
    signedHeaders = string.sub(signedHeaders, 1, #signedHeaders - 1)
    local payloadHash = hashLib.sha256(payload)
    local canonicalRequest = canonicalMethod .. canonicalUri .. canonicalQueryString .. "\n" .. canonicalHeaders ..  signedHeaders .. "\n" .. payloadHash
    return canonicalRequest, signedHeaders, canonicalQueryString
end

local function formCredentialScope(datestamp, region, service)
    local credentialScope = datestamp .. "/" .. region .. "/" .. service .. "/" .. "aws4_request"
    return credentialScope
end

local function formStringToSign(algorithm, amzdate, credentialScope, canonicalRequest)
    local canonicalRequestHash = hashLib.sha256(canonicalRequest)
    local stringToSign = algorithm .. "\n" .. amzdate .. "\n" .. credentialScope .. "\n" .. canonicalRequestHash
    return stringToSign
end

local function sign(key, message)
    local signedMessage = hashLib.hmac(hashLib.sha256, key, message)
    local binarySignedMessage = hashLib.hex_to_bin(signedMessage)
    return binarySignedMessage
end

local function generateSigningKey(key, datestamp, region, service)
    local kDate = sign("AWS4"..key, datestamp)
    local kRegion = sign(kDate, region)
    local kService = sign(kRegion, service)
    local kSigning = sign(kService, 'aws4_request')
    return kSigning
end

local function formAuthenticationHeader(authItems)
    if type(authItems) ~= "table" then error("`authItems` must be a table", 2) end

    local method = authItems["method"]
    local path = authItems["path"]
    local query = authItems["query"]
    local headers = authItems["headers"]
    local payload = authItems["payload"]
    local datestamp = authItems["datestamp"]
    local region = authItems["region"]
    local service = authItems["service"]
    local secretAccessKey = authItems["secretAccessKey"]
    local accessKeyId = authItems["accessKeyId"]
    local amzdate = authItems["amzdate"]
    local algorithm = authItems["algorithm"]

    --Task 1: Calculate Canonical Request--

    local canonicalRequest, signedHeaders, canonicalQueryString = formCanonicalRequest(method, path, query, headers, payload)

    --Task 2: Calculate String to Sign--
    local credentialScope = formCredentialScope(datestamp, region, service)
    local stringToSign = formStringToSign(algorithm, amzdate, credentialScope, canonicalRequest)

    --Task 3: Sign the String to Sign--
    local signingKey = generateSigningKey(secretAccessKey, datestamp, region, service)
    local signature = hashLib.hmac(hashLib.sha256, signingKey, stringToSign)

    --Task 4: Add Signing Info to Request--
    local authorizationHeader = algorithm .. " " .. "Credential=" .. accessKeyId .. "/" .. credentialScope .. ", SignedHeaders=" .. signedHeaders .. ", Signature=" .. signature

    return authorizationHeader, canonicalQueryString
end

--[[
return { 
    uriEncode = uriEncode,
    formCanonicalRequest = formCanonicalRequest,
    formCredentialScope = formCredentialScope,
    formStringToSign = formStringToSign,
    generateSigningKey = generateSigningKey
}]]--

return { uriEncode = uriEncode, formAuthenticationHeader = formAuthenticationHeader}