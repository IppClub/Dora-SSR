-- Trusted host provisioning only. Never accept this configuration from a game.
-- The caller must mount the project's exclusive persistent storage first.
local Session = require("Agent.Session")
local exports = {}

function exports.prepare(projectRoot, title)
	assert(type(projectRoot) == "string" and #projectRoot > 1 and #projectRoot <= 1024, "Invalid Agent project root")
	assert(projectRoot:sub(1, 1) == "/" and projectRoot:sub(-1) ~= "/", "Agent project root must be canonical")
	assert(not projectRoot:find("//", 1, true) and not projectRoot:find("\\", 1, true) and not projectRoot:find("%z"), "Invalid Agent project root")
	for part in projectRoot:gmatch("[^/]+") do
		assert(part ~= "." and part ~= "..", "Agent project root must be canonical")
	end
	assert(title == nil or (type(title) == "string" and #title <= 4096), "Invalid Agent session title")
	-- Original createSession already restores the latest main session for this
	-- exact root. Do not implement another session selection/database algorithm.
	local result = Session.createSession(projectRoot, title or "")
	assert(result.success, result.message or "Agent session initialization failed")
	local session = result.session
	assert(session and session.projectRoot == projectRoot and session.kind == "main"
		and session.rootSessionId == session.id, "Agent session project binding mismatch")
	return session
end

function exports.start(projectRoot, title)
	local session = exports.prepare(projectRoot, title)
	local bridge = require("AgentSessionBridge").open(session.id)
	local payload = require("Agent.Utils").safeJsonEncode({kind = "initialized", sessionId = session.id, projectRoot = projectRoot})
	local ok, delivered = pcall(function() return _studio_agent_emit(payload) end)
	if not ok or not delivered then bridge.close(); error("Agent host initialization delivery failed") end
	return bridge
end

-- JSON data from the trusted host snapshot, never an imported game manifest.
function exports.startConfigured(encoded)
	assert(type(encoded) == "string" and #encoded <= 16384, "Invalid Agent startup configuration")
	local config = require("Agent.Utils").safeJsonDecode(encoded)
	assert(type(config) == "table" and config.version == 1, "Invalid Agent startup configuration version")
	for key in pairs(config) do
		assert(key == "version" or key == "projectRoot" or key == "title", "Unexpected Agent startup configuration field")
	end
	assert(type(config.title) == "string", "Invalid Agent startup title")
	-- /game contains privileged host libraries, never author project content.
	-- /user is already isolated by the account/project storage namespace.
	assert(config.projectRoot == "/user/studio-project", "Invalid Studio author project root")
	local Content = require("Dora").Content
	assert(Content:exist(config.projectRoot) or Content:mkdir(config.projectRoot), "Cannot create Studio author project directory")
	return exports.start(config.projectRoot, config.title)
end

return exports
