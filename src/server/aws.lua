local HttpService = game:GetService("HttpService")

local hashLib = require(script.Parent.HashLib)

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

local function sortTable(tab)
    local tempTable = {}
    for key, value in pairs(tab) do
        table.insert(tempTable, {key, value})
    end
    table.sort(tempTable, function(a,b) return a[1] < b[1] end)
	local sortedTable = {}
    for i = 1, #tempTable do
		sortedTable[tostring(tempTable[i][1])] = tempTable[i][2]
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
    local canonicalQueryString = ""
    for k, v in pairs(sortTable(query)) do
        canonicalQueryString = canonicalQueryString .. k .. "=" .. uriEncode(v, true) .. "&"
    end
    canonicalQueryString = string.sub(canonicalQueryString, 1, #canonicalQueryString - 1) .. "\n"
    local canonicalHeaders = ""
    local signedHeaders = ""
    for k, v in pairs(sortTable(headers)) do
        canonicalHeaders = canonicalHeaders .. string.lower(k) .. ":" .. v .. "\n"
        signedHeaders = signedHeaders .. string.lower(k) .. ";"
    end
    canonicalHeaders = canonicalHeaders .. "\n"
    signedHeaders = string.sub(signedHeaders, 1, #signedHeaders - 1)
    local payloadHash = hashLib.sha256(payload)
    local canonicalRequest = canonicalMethod .. canonicalUri .. canonicalQueryString .. canonicalHeaders ..  signedHeaders .. "\n" .. payloadHash
    return canonicalRequest, signedHeaders
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

local function dynamodb(accessKeyId, secretAccesskey, region)
    local this = {}

    if not region then region = "us-east-1" end

    this.secretAccessKey = secretAccesskey
    this.accessKeyId = accessKeyId
    this.region = region
    this.service = "dynamodb"

    function this:GetAsync(key)
        if self ~= this then error("GetAsync must be called with `:`, not `.`") end

        local method = "GET"
        local algorithm = "AWS4-HMAC-SHA256"
        local requestTime = os.time()
        local datestamp = os.date("%Y%m%d", requestTime)
        local amzdate = os.date("%Y%m%dT%H%M%SZ", requestTime)

        --Task 1: Calculate Canonical Request--

        local canonicalRequest, signedHeaders = formCanonicalRequest(
            method,
            "/",
            {
                ["Action"] = "DescribeRegions",
                ["Version"] = "2013-10-15"
            },
            {
                ["Host"] = "dynamodb.amazonaws.com",
                ["x-amz-date"] = amzdate
            },
            ""
        )

        --Task 2: Calculate String to Sign--
        local credentialScope = formCredentialScope(datestamp, self.region, self.service)
        local stringToSign = formStringToSign(algorithm, amzdate, credentialScope, canonicalRequest)

        --Task 3: Sign the String to Sign--
        local signingKey = generateSigningKey(self.secretAccessKey, datestamp, self.region, self.service)
        local signature = hashLib.hmac(hashLib.sha256, signingKey, stringToSign)

        --Task 4: Add Signing Info to Request--
        local authorizationHeader = algorithm .. " " .. "Credential=" .. self.accessKeyId .. "/" .. credentialScope .. ", SignedHeaders=" .. signedHeaders .. ", Signature=" .. signature

        --Task 5: Send request--

        --Task 6: Parse request; raise error if needed--

        return authorizationHeader
    end

    return this
end

return { dynamodb = dynamodb }