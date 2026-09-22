-- Trusted Studio host only. Do not load into a runtime executing project scripts.
-- Session behavior remains owned by the original Agent; this module only transports it.
local Session = require("Agent.Session")
local Events = require("Agent.Runtime.SessionEvents")
local Utils = require("Agent.Utils")
local FileCommits = require("Agent.Runtime.FileCommitEvents")

local STUDIO_AGENT_MAX_STEPS = 999
local exports = {}
function exports.open(sessionId)
	assert(type(_studio_agent_emit) == "function", "Studio Agent host callback is unavailable")
	assert(_studio_agent_request == nil, "Studio Agent request handler already installed")
	local closed, starting, unsubscribe = false, true, nil
	local entryModule = require("StudioAgentEntry")
	assert(package.loaded["Script.Dev.Entry"] == nil, "A game entry module entered the trusted Agent host")
	package.loaded["Script.Dev.Entry"] = entryModule
	local requestHandler
	local toolBegin, toolPoll, toolCancel
	local quiescence
	local pending = {}
	local promptReceipts = {}
	local toolRequests = {}
	local canceledTools, canceledOrder = {}, {}
	local nextToolId = 0
	local fileBatches, fileSeen, fileBytes, fileOverflow = {}, {}, 0, false
	local unsubscribeFiles
	local function close()
		if closed then return end
		closed = true
		pending = {}
		promptReceipts = {}
		toolRequests = {}
		canceledTools, canceledOrder = {}, {}
		if unsubscribe then unsubscribe(); unsubscribe = nil end
		if unsubscribeFiles then unsubscribeFiles(); unsubscribeFiles = nil end
		if _studio_agent_request == requestHandler then _studio_agent_request = nil end
		if _studio_agent_tool_begin == toolBegin then _studio_agent_tool_begin = nil end
		if _studio_agent_tool_poll == toolPoll then _studio_agent_tool_poll = nil end
		if _studio_agent_tool_cancel == toolCancel then _studio_agent_tool_cancel = nil end
		if package.loaded["Script.Dev.Entry"] == entryModule then package.loaded["Script.Dev.Entry"] = nil end
	end
	local function send(kind, payload, sequence, requestId)
		if closed then return false end
		local encoded = Utils.safeJsonEncode({kind = kind, sessionId = sessionId, payload = payload, sequence = sequence, requestId = requestId})
		local ok, delivered = pcall(function() return encoded and _studio_agent_emit(encoded) end)
		if not ok or not delivered then close(); error("Studio Agent event delivery failed") end
		return true
	end
	local function capture(lifecycle)
		return Events.captureSessionSnapshot(sessionId, function()
			local detail = Session.getSession(sessionId)
			assert(detail.success, "Studio Agent session is unavailable")
			if lifecycle then detail.studioQuiescence = lifecycle end
			-- Notifications are not a complete history or an author-save receipt.
			detail.studioFileCommits = {batches = fileBatches, overflowed = fileOverflow, reconciliationRequired = true}
			return Utils.safeJsonEncode(detail)
		end)
	end
	local ok, reason = pcall(function()
		local detail = Session.getSession(sessionId)
		assert(detail.success, "Studio Agent session is unavailable")
		unsubscribeFiles = FileCommits.subscribeFileCommits(detail.session.projectRoot, function(payload)
			if closed or fileOverflow then return end
			local batch = type(payload) == "string" and #payload <= 65536 and Utils.safeJsonDecode(payload) or nil
			local function positiveId(value) return type(value) == "number" and value > 0 and value <= 9007199254740991 and value % 1 == 0 end
			local valid = type(batch) == "table" and batch.version == 1 and positiveId(batch.checkpointId)
				and positiveId(batch.taskId) and positiveId(batch.checkpointSeq) and type(batch.changes) == "table" and #batch.changes > 0
			local previous = valid and fileSeen[batch.checkpointId] or nil
			if previous and previous == payload then return end
			if not valid or previous or #fileBatches >= 32 or fileBytes + #payload > 65536 then
				fileOverflow = true
				-- Fail closed to further task admission; original checkpoints retain history.
				if not quiescence then
					local acquired = Session.beginProjectTaskQuiescence(sessionId)
					if acquired.success then quiescence = acquired end
				end
				return
			end
			fileSeen[batch.checkpointId] = payload
			fileBytes = fileBytes + #payload
			fileBatches[#fileBatches + 1] = batch
		end)
		unsubscribe = Events.subscribeSessionPatches(sessionId, function(payload, sequence)
			if closed then return end
			if starting then
				if #pending >= 32 then close(); error("Studio Agent initial event buffer exceeded") end
				pending[#pending + 1] = {payload = payload, sequence = sequence}
			else
				send("patch", payload, sequence)
			end
		end)
		local snapshot = capture()
		assert(not closed, "Studio Agent bridge closed during initialization")
		send("snapshot", snapshot.payload, snapshot.sequence)
		starting = false
		for _, item in ipairs(pending) do
			if item.sequence > snapshot.sequence then send("patch", item.payload, item.sequence) end
		end
		pending = {}
	end)
	if not ok then close(); error(reason) end
	requestHandler = function(payload)
		if closed then return end
		local request = Utils.safeJsonDecode(payload)
		assert(type(request) == "table" and request.sessionId == sessionId, "Invalid Studio Agent request binding")
		assert(type(request.requestId) == "string" and #request.requestId > 0 and #request.requestId <= 128, "Invalid Studio Agent request ID")
		assert(request.operation == "snapshot" or request.operation == "quiesce" or request.operation == "prompt" or request.operation == "questionnaire-respond" or request.operation == "questionnaire-cancel" or request.operation == "stop" or request.operation == "resume" or request.operation == "tool-result", "Unsupported Studio Agent request")
		if request.operation == "tool-result" then
			if canceledTools[request.requestId] then canceledTools[request.requestId] = nil; return end
			local pendingTool = toolRequests[request.requestId]
			assert(pendingTool and pendingTool.result == nil, "Unknown or completed Studio Agent tool request")
			local result = request.result
			assert(type(result) == "table" and type(result.success) == "boolean", "Invalid Studio Agent tool result")
			if result.success then
				if pendingTool.operation == "transpile-ts" or pendingTool.operation == "build-script" then
					assert(type(result.luaCode) == "string" and #result.luaCode <= 1048576, "Invalid Studio Agent transpile output")
				else
					assert(type(result.resultJSON) == "string" and #result.resultJSON <= 262144, "Invalid Studio Agent Player result")
				end
			else
				assert(type(result.message) == "string" and #result.message <= 4096, "Invalid Studio Agent transpile diagnostic")
			end
			pendingTool.result = result
			return
		end
		if request.operation == "resume" then
			assert(not fileOverflow and quiescence and quiescence.success, "Studio Agent quiescence cannot be released")
			local lifecycle = quiescence.poll()
			assert(lifecycle.success and lifecycle.quiescent and #lifecycle.pending == 0, "Studio Agent tasks remain pending")
			quiescence.close(); quiescence = nil
			send("command", Utils.safeJsonEncode({success = true}), 0, request.requestId)
			return
		end
		if request.operation == "stop" then
			local result = Session.stopSessionTask(sessionId)
			send("command", Utils.safeJsonEncode(result), 0, request.requestId)
			return
		end
		if request.operation == "questionnaire-respond" or request.operation == "questionnaire-cancel" then
			assert(type(request.questionnaireId) == "number" and request.questionnaireId > 0 and request.questionnaireId % 1 == 0, "Invalid Studio Agent questionnaire")
			if request.operation == "questionnaire-respond" then assert(type(request.answers) == "table", "Invalid Studio Agent questionnaire answers") end
			local config = request.llmConfig
			assert(type(config) == "table" and config.studioGateway == true and config.apiKey == "studio-agent"
				and type(config.model) == "string" and #config.model > 0 and type(config.url) == "string"
				and config.url:match("^https://") and config.url:find("/agent-host/", 1, true)
				and config.url:find("/model/", 1, true), "Invalid Studio Agent model binding")
			local answerKey = request.operation == "questionnaire-respond" and Utils.safeJsonEncode(request.answers) or "dismissed"
			assert(type(answerKey) == "string" and #answerKey <= 65536, "Invalid Studio Agent questionnaire payload")
			local previous = promptReceipts[request.requestId]
			if previous then
				assert(previous.kind == request.operation and previous.questionnaireId == request.questionnaireId and previous.answerKey == answerKey and previous.url == config.url, "Studio Agent questionnaire request was rebound")
				send("command", Utils.safeJsonEncode(previous.result), 0, request.requestId)
				return
			end
			promptReceipts[request.requestId] = {kind = request.operation, questionnaireId = request.questionnaireId, answerKey = answerKey, url = config.url, result = {success = false, message = "questionnaire acknowledgement pending; inspect session"}}
			local result = request.operation == "questionnaire-respond"
				and Session.respondQuestionnaire(sessionId, request.questionnaireId, request.answers, nil, config)
				or Session.cancelQuestionnaire(sessionId, request.questionnaireId, nil, config)
			promptReceipts[request.requestId].result = result
			send("command", Utils.safeJsonEncode(result), 0, request.requestId)
			return
		end
		if request.operation == "prompt" then
			assert(type(request.prompt) == "string" and #request.prompt > 0 and #request.prompt <= 5000, "Invalid Studio Agent prompt")
			assert(request.workMode == "code" or request.workMode == "plan", "Invalid Studio Agent work mode")
			assert(type(request.disabledAgentTools) == "table" and #request.disabledAgentTools <= 2, "Invalid Studio Agent tool settings")
			local disabledSeen = {}
			for _, tool in ipairs(request.disabledAgentTools) do
				assert((tool == "fetch_url" or tool == "execute_command") and not disabledSeen[tool], "Invalid Studio Agent tool setting")
				disabledSeen[tool] = true
			end
			local config = request.llmConfig
			assert(type(config) == "table" and config.studioGateway == true and config.apiKey == "studio-agent"
				and type(config.model) == "string" and #config.model > 0 and type(config.url) == "string"
				and config.url:match("^https://") and config.url:find("/agent-host/", 1, true)
				and config.url:find("/model/", 1, true), "Invalid Studio Agent model binding")
			local previous = promptReceipts[request.requestId]
			if previous then
				assert(previous.kind == "prompt" and previous.prompt == request.prompt and previous.url == config.url
					and previous.workMode == request.workMode and previous.disabledKey == Utils.safeJsonEncode(request.disabledAgentTools), "Studio Agent prompt request was rebound")
				send("command", Utils.safeJsonEncode(previous.result), 0, request.requestId)
				return
			end
			-- Never let a duplicate command start another task in this live host.
			-- Restart/uncertain acknowledgement still requires session inspection.
			local disabledKey = Utils.safeJsonEncode(request.disabledAgentTools)
			assert(type(disabledKey) == "string", "Invalid Studio Agent tool settings")
			promptReceipts[request.requestId] = {kind = "prompt", prompt = request.prompt, url = config.url, workMode = request.workMode, disabledKey = disabledKey, result = {success = false, message = "prompt acknowledgement pending; inspect session"}}
			-- Keep Studio's task budget explicit instead of inheriting a mutable
			-- global default. A prompt may build, repair and validate repeatedly
			-- without forcing the user into artificial continuation rounds.
			local result = Session.sendPrompt(sessionId, request.prompt, request.disabledAgentTools, request.workMode, nil, config, STUDIO_AGENT_MAX_STEPS)
			promptReceipts[request.requestId].result = result
			send("command", Utils.safeJsonEncode(result), 0, request.requestId)
			return
		end
		local lifecycle
		if request.operation == "quiesce" then
			if not quiescence then
				local acquired = Session.beginProjectTaskQuiescence(sessionId)
				assert(acquired.success, "Studio Agent quiescence unavailable")
				quiescence = acquired
			end
			lifecycle = quiescence.poll()
			assert(lifecycle.success, "Studio Agent quiescence inspection failed")
		end
		local snapshot = capture(lifecycle)
		send("snapshot", snapshot.payload, snapshot.sequence, request.requestId)
	end
	_studio_agent_request = requestHandler
	toolBegin = function(operation, file, content, projectRoot)
		assert(not closed and (operation == "transpile-ts" or operation == "build-script" or operation == "preview-game" or operation == "execute-lua"), "Studio Agent tool unavailable")
		assert(type(file) == "string" and type(content) == "string" and type(projectRoot) == "string"
			and #content <= 524288 and #file <= 1024 and #projectRoot <= 1024, "Invalid Studio Agent tool input")
		local detail = Session.getSession(sessionId)
		assert(detail.success and detail.session.projectRoot == projectRoot, "Studio Agent tool project mismatch")
		assert(file:sub(1, #projectRoot + 1) == projectRoot .. "/" and not file:find("/../", 1, true)
			and not file:find("/./", 1, true) and file:sub(-3) ~= "/.." and file:sub(-2) ~= "/.", "Studio Agent tool escaped project")
		if operation == "build-script" then
			assert(file:sub(-3) == ".tl" or file:sub(-4) == ".lua" or file:sub(-5) == ".yarn" or file:sub(-4) == ".yue" or file:sub(-4) == ".xml", "Invalid Studio Agent script build entry")
		elseif operation == "preview-game" then
			assert(file:sub(-4) == ".lua" and #content <= 2048, "Invalid Studio Agent preview entry")
			local options = Utils.safeJsonDecode(content)
			assert(type(options) == "table" and type(options.entry) == "string" and #options.entry > 0
				and type(options.captureAtSeconds) == "table" and #options.captureAtSeconds >= 1
				and #options.captureAtSeconds <= 3, "Invalid Studio Agent preview options")
		elseif operation == "execute-lua" then
			assert(file:sub(-4) == ".lua" and #content <= 140000, "Invalid Studio Agent Lua command")
			local options = Utils.safeJsonDecode(content)
			assert(type(options) == "table" and type(options.code) == "string" and #options.code > 0 and #options.code <= 131072
				and type(options.timeoutSeconds) == "number" and options.timeoutSeconds >= 1 and options.timeoutSeconds <= 600
				and options.timeoutSeconds % 1 == 0, "Invalid Studio Agent Lua options")
		end
		local active = 0
		for _ in pairs(toolRequests) do active = active + 1 end
		assert(active < 1, "Studio Agent tool request already active")
		nextToolId = nextToolId + 1
		local id = "studio-tool-" .. sessionId .. "-" .. nextToolId
		local toolPayload = Utils.safeJsonEncode({operation = operation, file = file, content = content, projectRoot = projectRoot})
		assert(type(toolPayload) == "string" and #toolPayload <= 900000, "Studio Agent tool input exceeds transport")
		local envelope = Utils.safeJsonEncode({kind = "tool-request", sessionId = sessionId, payload = toolPayload, sequence = 0, requestId = id})
		assert(type(envelope) == "string" and #envelope <= 1048576, "Studio Agent tool input exceeds callback")
		toolRequests[id] = {operation = operation, result = nil}
		if operation == "build-script" and file:sub(-4) == ".yue" then
			-- Yue is already part of the original Web engine. Unlike the other
			-- browser compiler workers, the native Yue callback can run inside
			-- this dedicated Agent host without loading Script.Dev.WebServer.
			local started = pcall(function()
				local compiler = require("StudioAgentYueBuild")
				compiler.start(file, content, projectRoot, id,
					function() return not closed and toolRequests[id] ~= nil end,
					function(result)
						local pendingTool = toolRequests[id]
						if pendingTool and not pendingTool.result then pendingTool.result = result end
					end)
			end)
			if not started then toolRequests[id].result = {success = false, message = "Dora Yue compiler is unavailable"} end
		elseif operation == "build-script" and file:sub(-4) == ".xml" then
			-- XML conversion is synchronous in the original engine. Do not load
			-- WebServer just to obtain its method: it reconfigures IDE HTTP routes.
			local ok, result = pcall(function()
				return require("StudioAgentXmlBuild").run(file, content, projectRoot)
			end)
			toolRequests[id].result = ok and result or {success = false, message = "Dora XML compiler is unavailable"}
		else
			send("tool-request", toolPayload, 0, id)
		end
		return id
	end
	toolPoll = function(id)
		local pendingTool = toolRequests[id]
		if not pendingTool then return {success = false, message = "Studio Agent tool request is unavailable"} end
		if not pendingTool.result then return nil end
		toolRequests[id] = nil
		return pendingTool.result
	end
	toolCancel = function(id)
		if not toolRequests[id] then return end
		toolRequests[id] = nil
		canceledTools[id] = true
		canceledOrder[#canceledOrder + 1] = id
		if #canceledOrder > 256 then
			local old = table.remove(canceledOrder, 1)
			canceledTools[old] = nil
		end
		send("tool-cancel", "{}", 0, id)
	end
	_studio_agent_tool_begin = toolBegin
	_studio_agent_tool_poll = toolPoll
	_studio_agent_tool_cancel = toolCancel
	-- Transport failure must not reopen task admission. Only the trusted runtime
	-- owner may release the hold after persistence or an explicit resume decision.
	return {close = close, releaseQuiescence = function()
		if quiescence and quiescence.success then quiescence.close(); quiescence = nil end
	end}
end
return exports
