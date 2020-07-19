local auth = require(script.Parent.Utilities.Authentication)
local requester = require(script.Parent.Utilities.Requester)

local request = requester.request
local toJson = requester.toJson
local toTable = requester.toTable
local toDdbJson = requester.toDdbJson
local fromDdbJson = requester.fromDdbJson

local function requestTime()
    local requestTime = os.time()
    local datestamp = os.date("%Y%m%d", requestTime)
    local amzdate = os.date("%Y%m%dT%H%M%SZ", requestTime)
    return datestamp, amzdate
end

local function serviceResource(accessKeyId, secretAccessKey, region)
    local sqs = {}
    local secrets = {}

    secrets.secretAccessKey = secretAccessKey
    secrets.accessKeyId = accessKeyId

    sqs.algorithm = "AWS4-HMAC-SHA256"
    sqs.region = region
    sqs.service = "dynamodb"
    sqs.endpoint = "https://sqs."..sqs.region..".amazonaws.com"


    function sqs:Queue(queueUrl)
        if self ~= sqs then error("Queue must be called with `:`, not `.`", 2) end
        if queueUrl == nil then error("`queueUrl` is a required parameter", 2) end

        self.sqsQueue = {}
        local sqsQueue = self.sqsQueue
        sqsQueue.Url = queueUrl

        function sqsQueue:SendMessage()

        end

        return sqsQueue
    end

    return sqs
end