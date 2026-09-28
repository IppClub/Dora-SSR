-- [ts]: LocalAgent.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Director = ____Dora.Director -- 2
local Node = ____Dora.Node -- 2
local Path = ____Dora.Path -- 2
local Process = ____Dora.Process -- 2
local sleep = ____Dora.sleep -- 2
local ____Utils = require("Agent.Utils") -- 3
local safeJsonDecode = ____Utils.safeJsonDecode -- 3
local safeJsonEncode = ____Utils.safeJsonEncode -- 3
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 3
local CONFIG_TABLE = "LocalAgentConfig" -- 37
local SESSION_TABLE = "LocalAgentSession" -- 38
local SKILL_VERSION = 4 -- 39
local SKILL_MARKER = ("<!-- dora-managed-skill:v" .. tostring(SKILL_VERSION)) .. " -->"
local supportedPlatforms = {"Windows", "macOS", "Linux"} -- 41
local function encodeJson(value) -- 43
	local text = safeJsonEncode(value) -- 44
	return text or "" -- 45
end -- 43
local function quoteCommandArg(value) -- 48
	if App.platform == "Windows" then -- 49
		return ("'" .. table.concat(__TS__StringSplit(value, "'"), "''")) .. "'" -- 49
	end -- 49
	return ("'" .. table.concat(__TS__StringSplit(value, "'"), "'\"'\"'")) .. "'" -- 50
end -- 48
local function buildDoraCLICommand() -- 53
	local executablePath = App.executablePath -- 54
	local assetPath = Content.assetPath -- 55
	if executablePath == "" or assetPath == "" then -- 56
		return nil -- 56
	end -- 56
	local command = ((quoteCommandArg(executablePath) .. " --asset ") .. quoteCommandArg(assetPath)) .. " cli" -- 57
	return App.platform == "Windows" and "& " .. command or command -- 58
end -- 53
local function waitForProcess(handle, timeoutSeconds)
	local startedAt = App.runningTime
	while App.runningTime - startedAt < timeoutSeconds do
		local result = Process:read(handle)
		if not result.running then
			local exitCode = result.exit.exitCode
			Process:destroy(handle)
			return exitCode
		end
		sleep(0.02)
	end
	Process:stop(handle, "kill-tree")
	Process:destroy(handle)
	return nil
end
local function prepareDoraCommandEnvironment()
	local fallback = buildDoraCLICommand()
	if not fallback then return nil end
	local executablePath = App.executablePath
	local assetPath = Content.assetPath
	local shimDir = Path(Content.writablePath, ".agent", "local-agent-bin")
	if not Content:exist(shimDir) and not Content:mkdir(shimDir) then
		return {command = fallback, shim = false}
	end
	local windows = App.platform == "Windows"
	local shimPath = Path(shimDir, windows and "dora.cmd" or "dora")
	local shimContent
	if windows then
		shimContent = (("@echo off\r\n\"" .. table.concat(__TS__StringSplit(executablePath, "%"), "%%")) .. "\" --asset \"") .. table.concat(__TS__StringSplit(assetPath, "%"), "%%") .. "\" %*\r\n"
	else
		shimContent = (("#!/bin/sh\nexec " .. quoteCommandArg(executablePath)) .. " --asset ") .. quoteCommandArg(assetPath) .. " \"$@\"\n"
	end
	if not Content:save(shimPath, shimContent) then return {command = fallback, shim = false} end
	if not windows then
		local chmod = Process:spawn({program = "/bin/chmod", args = {"700", shimPath}})
		if chmod == nil or waitForProcess(chmod, 5) ~= 0 then return {command = fallback, shim = false} end
	end
	local inheritedPath = os.getenv("PATH") or ""
	local separator = windows and ";" or ":"
	return {
		command = "dora cli",
		shim = true,
		env = {
			PATH = inheritedPath == "" and shimDir or (shimDir .. separator) .. inheritedPath,
			DORA_EXECUTABLE_PATH = executablePath,
			DORA_ASSET_PATH = assetPath
		}
	}
end
local function buildSkillContent()
	return (("---\nname: dora-engine-coding\ndescription: Build and validate games for the Dora SSR engine using the local Dora CLI.\n---\n" .. SKILL_MARKER) .. [=[

# Dora Engine coding

Work inside the current Dora project. Dora games run in the Dora runtime, not a browser or Node.js: do not generate DOM, Canvas, browser-only, or Node-only runtime code.

- Dora injects a project-scoped `dora` command into this Agent process. Use `dora cli` directly; do not search for Dora, create aliases, or guess installation paths.
- Inspect the project before editing. The usual entry is `init.lua`, `init.ts`, `init.yue`, or another project entry selected by the user.
- Do not guess Dora APIs. Use `dora cli doc search <query>` and `dora cli doc read <name>` to verify them.
- Edit source files with your own file tools. TypeScript is transpiled to Lua by Dora; keep imports compatible with the Dora module declarations.
- Validate compilation with `dora cli build <path>`.
- Inspect the engine with `dora cli agent status -p <project>` and logs with `dora cli agent log -n 200`.
- Run a controlled game check with `dora cli agent preview -p <project> --entry init.lua --capture-at 0.5,2`. Preview requests are FIFO and can interrupt a user-run game because Agent validation has priority.
- Treat stdout from `dora cli agent` as one JSON result. stderr is diagnostic output.
- `dora cli agent` only accesses engine tools. It never starts Dora Agent or another third-party Agent; do not construct nested Agent scheduling.

Finish by reporting the files changed and the exact build/preview evidence you obtained.
]=])
end
local function ensureTables() -- 71
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. CONFIG_TABLE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tname TEXT NOT NULL,\n\t\tprovider TEXT NOT NULL,\n\t\texecutable TEXT NOT NULL,\n\t\textra_args TEXT NOT NULL DEFAULT '[]',\n\t\tverified_at INTEGER,\n\t\tverified_version TEXT NOT NULL DEFAULT '',\n\t\tverified_fingerprint TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t)") -- 72
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. SESSION_TABLE) .. "(\n\t\tdora_session_id INTEGER PRIMARY KEY,\n\t\tconfig_id INTEGER NOT NULL,\n\t\tprovider TEXT NOT NULL,\n\t\tresume_id TEXT NOT NULL DEFAULT '',\n\t\tgeneration INTEGER NOT NULL DEFAULT 1,\n\t\tabandoned_at INTEGER,\n\t\tupdated_at INTEGER NOT NULL\n\t)") -- 84
end -- 71
local function rowToConfig(row) -- 95
	local provider = tostring(row[3]) -- 96
	if provider ~= "opencode" and provider ~= "codex" and provider ~= "zcode" then -- 96
		return nil -- 97
	end -- 97
	local ____safeJsonDecode_2 = safeJsonDecode -- 98
	local ____tostring_1 = tostring -- 98
	local ____row__5_0 = row[5] -- 98
	if ____row__5_0 == nil then -- 98
		____row__5_0 = "[]" -- 98
	end -- 98
	local decoded = ____safeJsonDecode_2(____tostring_1(____row__5_0)) -- 98
	local extraArgs = __TS__ArrayIsArray(decoded) and __TS__ArrayFilter( -- 99
		decoded, -- 99
		function(____, value) return type(value) == "string" end -- 99
	) or ({}) -- 99
	local verifiedAt = tonumber(row[6]) -- 100
	local ____temp_7 = tonumber(row[1]) or 0 -- 102
	local ____tostring_result_8 = tostring(row[2]) -- 103
	local ____provider_9 = provider -- 104
	local ____tostring_result_10 = tostring(row[4]) -- 105
	local ____extraArgs_11 = extraArgs -- 106
	local ____temp_12 = verifiedAt and verifiedAt > 0 and verifiedAt or nil -- 107
	local ____tostring_4 = tostring -- 108
	local ____row__7_3 = row[7] -- 108
	if ____row__7_3 == nil then -- 108
		____row__7_3 = "" -- 108
	end -- 108
	local ____temp_13 = ____tostring_4(____row__7_3) or nil -- 108
	local ____tostring_6 = tostring -- 109
	local ____row__8_5 = row[8] -- 109
	if ____row__8_5 == nil then -- 109
		____row__8_5 = "" -- 109
	end -- 109
	return { -- 101
		id = ____temp_7, -- 102
		name = ____tostring_result_8, -- 103
		provider = ____provider_9, -- 104
		executable = ____tostring_result_10, -- 105
		extraArgs = ____extraArgs_11, -- 106
		verifiedAt = ____temp_12, -- 107
		verifiedVersion = ____temp_13, -- 108
		verifiedFingerprint = ____tostring_6(____row__8_5) or nil -- 109
	} -- 109
end -- 95
function ____exports.isLocalAgentSupported() -- 113
	return __TS__ArrayIncludes(supportedPlatforms, App.platform) -- 114
end -- 113
function ____exports.listConfigs() -- 117
	ensureTables() -- 118
	local rows = DB:query(("SELECT id,name,provider,executable,extra_args,verified_at,verified_version,verified_fingerprint FROM " .. CONFIG_TABLE) .. " ORDER BY id") or ({}) -- 119
	local result = {} -- 120
	do -- 120
		local i = 0 -- 121
		while i < #rows do -- 121
			local config = rowToConfig(rows[i + 1]) -- 122
			if config then -- 122
				result[#result + 1] = config -- 123
			end -- 123
			i = i + 1 -- 121
		end -- 121
	end -- 121
	return result -- 125
end -- 117
function ____exports.getConfig(id) -- 128
	local configId = tonumber(id) -- 129
	local ____configId_14 -- 130
	if configId then -- 130
		____configId_14 = __TS__ArrayFind( -- 130
			____exports.listConfigs(), -- 130
			function(____, item) return item.id == configId end -- 130
		) -- 130
	else -- 130
		____configId_14 = nil -- 130
	end -- 130
	return ____configId_14 -- 130
end -- 128
local function normalizeProvider(value) -- 133
	return (value == "opencode" or value == "codex" or value == "zcode") and value or nil -- 134
end -- 133
local function normalizeArgs(value) -- 137
	if not __TS__ArrayIsArray(value) then -- 137
		return {} -- 138
	end -- 138
	return __TS__ArrayMap( -- 139
		__TS__ArrayFilter( -- 139
			value, -- 139
			function(____, item) return type(item) == "string" end -- 139
		), -- 139
		function(____, item) return sanitizeUTF8(item) end -- 139
	) -- 139
end -- 137
function ____exports.saveConfig(input) -- 142
	ensureTables() -- 143
	local provider = normalizeProvider(input.provider) -- 144
	local name = type(input.name) == "string" and __TS__StringTrim(sanitizeUTF8(input.name)) or "" -- 145
	local executable = type(input.executable) == "string" and __TS__StringTrim(sanitizeUTF8(input.executable)) or "" -- 146
	if not provider or name == "" or executable == "" then -- 146
		return {success = false, message = "invalid local Agent config"} -- 147
	end -- 147
	local extraArgs = normalizeArgs(input.extraArgs) -- 148
	local encodedArgs = encodeJson(extraArgs) -- 149
	local id = tonumber(input.id) -- 150
	local t = os.time() -- 151
	if id and id > 0 then -- 151
		local old = ____exports.getConfig(id) -- 153
		if not old then -- 153
			return {success = false, message = "local Agent config not found"} -- 154
		end -- 154
		local changed = old.provider ~= provider or old.executable ~= executable or encodeJson(old.extraArgs) ~= encodedArgs -- 155
		DB:exec(("UPDATE " .. CONFIG_TABLE) .. " SET name=?,provider=?,executable=?,extra_args=?,verified_at=?,verified_version=?,verified_fingerprint=?,updated_at=? WHERE id=?", { -- 156
			name, -- 157
			provider, -- 157
			executable, -- 157
			encodedArgs, -- 157
			changed and 0 or (old.verifiedAt or 0), -- 158
			changed and "" or (old.verifiedVersion or ""), -- 159
			changed and "" or (old.verifiedFingerprint or ""), -- 160
			t, -- 161
			id -- 161
		}) -- 161
		return {success = true, id = id} -- 163
	end -- 163
	DB:exec(("INSERT INTO " .. CONFIG_TABLE) .. "(name,provider,executable,extra_args,created_at,updated_at) VALUES(?,?,?,?,?,?)", { -- 165
		name, -- 165
		provider, -- 165
		executable, -- 165
		encodedArgs, -- 165
		t, -- 165
		t -- 165
	}) -- 165
	local rows = DB:query("SELECT last_insert_rowid()") or ({}) -- 166
	local ____tonumber_17 = tonumber -- 167
	local ____opt_15 = rows[1] -- 167
	return { -- 167
		success = true, -- 167
		id = ____tonumber_17(____opt_15 and ____opt_15[1]) or 0 -- 167
	} -- 167
end -- 142
function ____exports.deleteConfig(id) -- 170
	ensureTables() -- 171
	local configId = tonumber(id) -- 172
	if not configId then -- 172
		return {success = false, message = "invalid local Agent config id"} -- 173
	end -- 173
	DB:exec(("DELETE FROM " .. CONFIG_TABLE) .. " WHERE id=?", {configId}) -- 174
	return {success = true} -- 175
end -- 170
local function buildSpec(config, cwd, prompt, resumeId) -- 180
	local args -- 181
	if config.provider == "codex" then -- 181
		local ____resumeId_20 -- 183
		if resumeId then -- 183
			local ____array_18 = __TS__SparseArrayNew( -- 183
				"exec", -- 184
				"resume", -- 184
				"--json",
				"--dangerously-bypass-approvals-and-sandbox",
				table.unpack(config.extraArgs) -- 184
			) -- 184
			__TS__SparseArrayPush(____array_18, resumeId, prompt) -- 184
			____resumeId_20 = {__TS__SparseArraySpread(____array_18)} -- 184
		else -- 184
			local ____array_19 = __TS__SparseArrayNew( -- 184
				"exec", -- 185
				"--json",
				"--dangerously-bypass-approvals-and-sandbox",
				"-C", -- 185
				cwd, -- 185
				table.unpack(config.extraArgs) -- 185
			) -- 185
			__TS__SparseArrayPush(____array_19, prompt) -- 185
			____resumeId_20 = {__TS__SparseArraySpread(____array_19)} -- 185
		end -- 185
		args = ____resumeId_20 -- 183
	elseif config.provider == "opencode" then -- 183
		args = { -- 187
			"run", -- 187
			"--format",
			"json", -- 187
			"--auto",
			"--dir",
			cwd, -- 187
			table.unpack(config.extraArgs) -- 187
		} -- 187
		if resumeId then -- 187
			__TS__ArrayPush(args, "--session", resumeId)
		end -- 188
		args[#args + 1] = prompt -- 189
	else -- 189
		args = { -- 191
			"--prompt",
			prompt, -- 191
			"--json",
			"--mode",
			"yolo", -- 191
			"--cwd",
			cwd, -- 191
			table.unpack(config.extraArgs) -- 191
		} -- 191
		if resumeId then -- 191
			__TS__ArrayPush(args, "--resume", resumeId)
		end -- 192
	end -- 192
	return {program = config.executable, args = args, cwd = cwd} -- 194
end -- 180
local function getString(record, ...) -- 197
	local keys = {...} -- 197
	do -- 197
		local i = 0 -- 198
		while i < #keys do -- 198
			local value = record[keys[i + 1]] -- 199
			if type(value) == "string" and value ~= "" then -- 199
				return value -- 200
			end -- 200
			i = i + 1 -- 198
		end -- 198
	end -- 198
	return nil -- 202
end -- 197
local function parseRecord(provider, record) -- 205
	local events = {} -- 206
	local eventType = getString(record, "type", "event", "kind") or "activity" -- 207
	local resumeId = getString( -- 208
		record, -- 208
		"thread_id", -- 208
		"threadId", -- 208
		"session_id", -- 208
		"sessionId", -- 208
		"sessionID" -- 208
	) -- 208
	local item = record.item -- 209
	if item and type(item) == "table" then -- 209
		local itemRecord = item -- 211
		resumeId = resumeId or getString( -- 212
			itemRecord, -- 212
			"thread_id", -- 212
			"session_id", -- 212
			"sessionId", -- 212
			"sessionID" -- 212
		) -- 212
		local itemType = getString(itemRecord, "type", "kind") or eventType -- 213
		local handledTool = false
		if provider == "codex" and itemType == "mcp_tool_call" then
			local server = getString(itemRecord, "server") or "mcp"
			local tool = getString(itemRecord, "tool") or "tool"
			local status = getString(itemRecord, "status") or eventType
			local details = {(server .. "." .. tool .. " (") .. status .. ")"}
			if itemRecord.arguments ~= nil then
				details[#details + 1] = "arguments: " .. encodeJson(itemRecord.arguments)
			end
			if itemRecord.result ~= nil then
				details[#details + 1] = "result:\n" .. (type(itemRecord.result) == "string" and itemRecord.result or encodeJson(itemRecord.result))
			end
			if itemRecord.error ~= nil then
				details[#details + 1] = "error:\n" .. (type(itemRecord.error) == "string" and itemRecord.error or encodeJson(itemRecord.error))
			end
			events[#events + 1] = {kind = "command", text = table.concat(details, "\n"), resumeId = resumeId, raw = record}
			handledTool = true
		end
		if not handledTool then
			local text = getString( -- 214
				itemRecord, -- 214
				"text", -- 214
				"content", -- 214
				"message", -- 214
				"command", -- 214
				"aggregated_output" -- 214
			) -- 214
			if text then -- 214
				local kind = (__TS__StringIncludes(itemType, "agent") or __TS__StringIncludes(itemType, "text") or __TS__StringIncludes(itemType, "message")) and "assistant" or ((__TS__StringIncludes(itemType, "command") or __TS__StringIncludes(itemType, "tool")) and "command" or "activity") -- 216
				events[#events + 1] = {kind = kind, text = text, resumeId = resumeId, raw = record} -- 218
			end
		end -- 218
	end -- 218
	local part = record.part -- 221
	if part and type(part) == "table" then -- 221
		local partRecord = part -- 223
		resumeId = resumeId or getString(partRecord, "sessionID", "sessionId", "session_id") -- 224
		local handledTool = false
		if provider == "opencode" and eventType == "tool_use" and partRecord.state and type(partRecord.state) == "table" then
			local state = partRecord.state
			local tool = getString(partRecord, "tool") or "tool"
			local status = getString(state, "status")
			local details = {tool .. (status and (" (" .. status .. ")") or "")}
			if state.input and type(state.input) == "table" then
				details[#details + 1] = "input: " .. encodeJson(state.input)
			end
			local output = getString(state, "output")
			if output then
				details[#details + 1] = "output:\n" .. output
			end
			events[#events + 1] = {kind = "command", text = table.concat(details, "\n"), resumeId = resumeId, raw = record}
			handledTool = true
		end
		if not handledTool then
			local text = getString( -- 225
				partRecord, -- 225
				"text", -- 225
				"content", -- 225
				"message", -- 225
				"command" -- 225
			) -- 225
			if text then -- 225
				events[#events + 1] = { -- 226
					kind = __TS__StringIncludes(eventType, "tool") and "command" or "assistant", -- 226
					text = text, -- 226
					resumeId = resumeId, -- 226
					raw = record -- 226
				} -- 226
			end -- 226
		end
	end -- 226
	local text = getString( -- 228
		record, -- 228
		"text", -- 228
		"content", -- 228
		"message", -- 228
		"output", -- 228
		"result", -- 228
		"response" -- 228
	) -- 228
	if text and #events == 0 then -- 228
		local kind = provider == "zcode" and type(record.response) == "string" and "assistant" or ((__TS__StringIncludes(eventType, "command") or __TS__StringIncludes(eventType, "tool")) and "command" or ((__TS__StringIncludes(eventType, "assistant") or __TS__StringIncludes(eventType, "message") or __TS__StringIncludes(eventType, "text")) and "assistant" or "activity")) -- 230
		events[#events + 1] = {kind = kind, text = text, resumeId = resumeId, raw = record} -- 233
	end -- 233
	if resumeId and #events == 0 then -- 233
		events[#events + 1] = {kind = "status", text = (provider .. " session ") .. resumeId, resumeId = resumeId, raw = record} -- 235
	end -- 235
	return events -- 236
end -- 205
local function parseLines(provider, buffer, onEvent) -- 239
	local lines = __TS__StringSplit(buffer, "\n") -- 240
	local rest = table.remove(lines) or "" -- 241
	do -- 241
		local i = 0 -- 242
		while i < #lines do -- 242
			do -- 242
				local line = __TS__StringTrim(sanitizeUTF8(lines[i + 1])) -- 243
				if line == "" then -- 243
					goto __continue44 -- 244
				end -- 244
				local decoded = safeJsonDecode(line) -- 245
				if decoded and type(decoded) == "table" and not __TS__ArrayIsArray(decoded) then -- 245
					local events = parseRecord(provider, decoded) -- 247
					if #events > 0 then -- 247
						do -- 247
							local e = 0 -- 248
							while e < #events do -- 248
								onEvent(events[e + 1]) -- 248
								e = e + 1 -- 248
							end -- 248
						end -- 248
					else -- 248
						onEvent({kind = "activity", text = line, raw = decoded}) -- 249
					end -- 249
				else -- 249
					onEvent({kind = "activity", text = line}) -- 251
				end -- 251
			end -- 251
			::__continue44:: -- 251
			i = i + 1 -- 242
		end -- 242
	end -- 242
	return rest -- 254
end -- 239
local function parseCompleteOutput(provider, output, onEvent) -- 257
	local text = __TS__StringTrim(sanitizeUTF8(output)) -- 258
	if text == "" then -- 258
		return -- 259
	end -- 259
	local decoded = safeJsonDecode(text) -- 260
	if decoded and type(decoded) == "table" and not __TS__ArrayIsArray(decoded) then -- 260
		local events = parseRecord(provider, decoded) -- 262
		if #events > 0 then -- 262
			do -- 262
				local i = 0 -- 264
				while i < #events do -- 264
					onEvent(events[i + 1]) -- 264
					i = i + 1 -- 264
				end -- 264
			end -- 264
			return -- 265
		end -- 265
	end -- 265
	parseLines(provider, text .. "\n", onEvent) -- 268
end -- 257
local function ensureSkill(projectRoot) -- 271
	local skillContent = buildSkillContent() -- 274
	local dir = Path(projectRoot, ".agents", "skills", "dora-engine-coding") -- 272
	local target = Path(dir, "SKILL.md") -- 273
	if Content:exist(target) then -- 273
		local existing = Content:load(target) -- 275
		if existing == skillContent then -- 275
			return {success = true, state = "current"} -- 276
		end -- 276
		if not __TS__StringIncludes(existing, "<!-- dora-managed-skill:v") then -- 276
			return {success = true, state = "custom", message = "custom Dora skill preserved"} -- 278
		end -- 278
	end -- 278
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 278
		return {success = false, state = "failed", message = "failed to create Dora skill directory"} -- 281
	end -- 281
	local temp = target .. ".tmp" -- 282
	if not Content:save(temp, skillContent) or not Content:move(temp, target) then -- 282
		if Content:exist(temp) then -- 282
			Content:remove(temp) -- 284
		end -- 284
		return {success = false, state = "failed", message = "failed to install Dora skill"} -- 285
	end -- 285
	return {success = true, state = "installed"} -- 287
end -- 271
local function getExternalSession(doraSessionId, config) -- 290
	ensureTables() -- 291
	local rows = DB:query(("SELECT config_id,provider,resume_id,generation FROM " .. SESSION_TABLE) .. " WHERE dora_session_id=?", {doraSessionId}) or ({}) -- 292
	if #rows > 0 and tonumber(rows[1][1]) == config.id and tostring(rows[1][2]) == config.provider then -- 292
		return { -- 294
			resumeId = tostring(rows[1][3]) or nil, -- 294
			generation = tonumber(rows[1][4]) or 1 -- 294
		} -- 294
	end -- 294
	DB:exec( -- 296
		("INSERT INTO " .. SESSION_TABLE) .. "(dora_session_id,config_id,provider,resume_id,generation,updated_at) VALUES(?,?,?,?,1,?) ON CONFLICT(dora_session_id) DO UPDATE SET config_id=excluded.config_id,provider=excluded.provider,resume_id='',generation=generation+1,abandoned_at=?,updated_at=excluded.updated_at", -- 296
		{ -- 296
			doraSessionId, -- 296
			config.id, -- 296
			config.provider, -- 296
			"", -- 296
			os.time(), -- 296
			os.time() -- 296
		} -- 296
	) -- 296
	return {generation = 1} -- 297
end -- 290
local function saveResumeId(doraSessionId, config, resumeId) -- 300
	DB:exec( -- 301
		("UPDATE " .. SESSION_TABLE) .. " SET resume_id=?,updated_at=? WHERE dora_session_id=? AND config_id=?", -- 301
		{ -- 301
			resumeId, -- 301
			os.time(), -- 301
			doraSessionId, -- 301
			config.id -- 301
		} -- 301
	) -- 301
end -- 300
local function isMissingExternalSession(text) -- 304
	local lower = string.lower(text) -- 305
	return __TS__StringIncludes(lower, "session not found") or __TS__StringIncludes(lower, "thread not found") or __TS__StringIncludes(lower, "unknown session") or __TS__StringIncludes(lower, "invalid session") or __TS__StringIncludes(lower, "no conversation found") -- 306
end -- 304
function ____exports.abandonSession(doraSessionId) -- 313
	ensureTables() -- 314
	local id = tonumber(doraSessionId) -- 315
	if not id then -- 315
		return {success = false, message = "invalid Dora session id"} -- 316
	end -- 316
	DB:exec( -- 317
		("UPDATE " .. SESSION_TABLE) .. " SET resume_id='',generation=generation+1,abandoned_at=?,updated_at=? WHERE dora_session_id=?", -- 317
		{ -- 317
			os.time(), -- 317
			os.time(), -- 317
			id -- 317
		} -- 317
	) -- 317
	return {success = true} -- 318
end -- 313
function ____exports.getSessionInfo(doraSessionId) -- 321
	ensureTables() -- 322
	local id = tonumber(doraSessionId) -- 323
	if not id then -- 323
		return nil -- 324
	end -- 324
	local rows = DB:query(("SELECT config_id,provider,resume_id,generation,abandoned_at,updated_at FROM " .. SESSION_TABLE) .. " WHERE dora_session_id=?", {id}) or ({}) -- 325
	if #rows == 0 then -- 325
		return nil -- 326
	end -- 326
	return { -- 327
		configId = rows[1][1], -- 327
		provider = rows[1][2], -- 327
		resumeId = rows[1][3], -- 327
		generation = rows[1][4], -- 327
		abandonedAt = rows[1][5], -- 327
		updatedAt = rows[1][6] -- 327
	} -- 327
end -- 321
function ____exports.run(doraSessionId, config, projectRoot, prompt, onEvent, onDone) -- 330
	local stopRequested = false -- 338
	local handle -- 339
	local skill = ensureSkill(projectRoot) -- 340
	if not skill.success then -- 340
		onDone({success = false, exitCode = -1, message = skill.message or "failed to install Dora skill"}) -- 342
		return {stop = function(self) -- 343
			stopRequested = true -- 343
		end} -- 343
	end -- 343
	local external = getExternalSession(doraSessionId, config) -- 345
	onEvent({
		kind = "status",
		text = config.provider == "zcode" and ((("Started " .. config.name) .. " (") .. config.provider .. "); its CLI returns the structured message when the task completes") or (("Started " .. config.name) .. " (") .. config.provider .. ")"
	})
	local monitorHost = Node()
	monitorHost:addTo(Director.systemUI)
	local function finish(result)
		onDone(result)
		monitorHost:removeFromParent(false)
	end
	monitorHost:once(function() -- 346
		local doraCommand = prepareDoraCommandEnvironment()
		if not doraCommand then
			finish({success = false, exitCode = -1, message = "failed to resolve Dora executable or Asset path"})
			return
		end
		if not doraCommand.shim then
			onEvent({kind = "status", text = "Dora command shim was unavailable; using the absolute Dora CLI command for this turn"})
		end
		local resumeId = external.resumeId -- 347
		local retriedMissingSession = false -- 348
		while true do -- 348
			local commandPrompt = doraCommand.shim and "Dora CLI is available in this Agent environment as `dora cli`.\n\n" .. prompt or (("For this turn, invoke Dora CLI only with this exact prefix (do not use a bare dora command):\n" .. doraCommand.command) .. "\n\n") .. prompt
			local skillPrompt = resumeId and commandPrompt or "Use the dora-engine-coding skill for this task.\n\n" .. commandPrompt -- 395
			local spec = buildSpec(config, projectRoot, skillPrompt, resumeId) -- 351
			spec.env = doraCommand.env
			handle = Process:spawn(spec) -- 352
			if handle == nil then -- 352
				finish({success = false, exitCode = -1, message = "failed to start " .. config.executable}) -- 354
				return -- 355
			end -- 355
			Process:write(handle) -- 357
			local stdoutOffset = 0 -- 358
			local stderrOffset = 0 -- 359
			local stdoutBuffer = "" -- 360
			local stderrBuffer = "" -- 361
			local diagnostic = "" -- 362
			local lastActivity = App.runningTime -- 363
			local startedAt = App.runningTime
			local lastProgressNotice = App.runningTime
			local retryFresh = false -- 364
			local function emitEvent(event) -- 365
				if event.resumeId and event.resumeId ~= resumeId then -- 365
					resumeId = event.resumeId -- 367
					saveResumeId(doraSessionId, config, resumeId) -- 368
				end -- 368
				onEvent(event) -- 370
			end -- 365
			while true do -- 365
				local chunk = Process:read(handle, stdoutOffset, stderrOffset) -- 373
				stdoutOffset = chunk.stdoutOffset -- 374
				stderrOffset = chunk.stderrOffset -- 375
				if chunk.stdout ~= "" then -- 375
					lastActivity = App.runningTime -- 377
					diagnostic = string.sub(diagnostic .. chunk.stdout, -32768) -- 378
					stdoutBuffer = config.provider == "zcode" and stdoutBuffer .. chunk.stdout or parseLines(config.provider, stdoutBuffer .. chunk.stdout, emitEvent) -- 379
				end -- 379
				if chunk.stderr ~= "" then -- 379
					lastActivity = App.runningTime -- 384
					diagnostic = string.sub(diagnostic .. chunk.stderr, -32768) -- 385
					stderrBuffer = stderrBuffer .. chunk.stderr -- 386
					local lines = __TS__StringSplit(stderrBuffer, "\n") -- 387
					stderrBuffer = table.remove(lines) or "" -- 388
					do -- 388
						local i = 0 -- 389
						while i < #lines do -- 389
							if __TS__StringTrim(lines[i + 1]) ~= "" then -- 389
								onEvent({ -- 389
									kind = "stderr", -- 389
									text = sanitizeUTF8(lines[i + 1]) -- 389
								}) -- 389
							end -- 389
							i = i + 1 -- 389
						end -- 389
					end -- 389
				end -- 389
				if not chunk.running then -- 389
					if __TS__StringTrim(stdoutBuffer) ~= "" then -- 389
						parseCompleteOutput(config.provider, stdoutBuffer, emitEvent) -- 392
					end -- 392
					if __TS__StringTrim(stderrBuffer) ~= "" then -- 392
						onEvent({ -- 393
							kind = "stderr", -- 393
							text = sanitizeUTF8(stderrBuffer) -- 393
						}) -- 393
					end -- 393
					local exitCode = chunk.exit.exitCode or -1 -- 394
					Process:destroy(handle) -- 395
					handle = nil -- 396
					if exitCode ~= 0 and external.resumeId and not retriedMissingSession and isMissingExternalSession(diagnostic) then -- 396
						retriedMissingSession = true -- 398
						resumeId = nil -- 399
						saveResumeId(doraSessionId, config, "") -- 400
						onEvent({kind = "status", text = "Stored local Agent session is unavailable; retrying once with a new session"}) -- 401
						retryFresh = true -- 402
						break -- 403
					end -- 403
					finish({ -- 405
						success = exitCode == 0 and not stopRequested, -- 405
						exitCode = exitCode, -- 405
						message = exitCode == 0 and "completed" or "local Agent exited with code " .. tostring(exitCode), -- 405
						resumeId = resumeId, -- 405
						stopped = stopRequested -- 405
					}) -- 405
					return -- 406
				end -- 406
				if stopRequested then -- 406
					Process:stop(handle, "interrupt") -- 409
					sleep(1.5) -- 410
					local after = Process:read(handle, stdoutOffset, stderrOffset) -- 411
					if after.running then -- 411
						Process:stop(handle, "kill-tree") -- 412
					end -- 412
				end -- 412
				if config.provider == "zcode" and App.runningTime - lastProgressNotice >= 30 then
					lastProgressNotice = App.runningTime
					local elapsed = math.floor(App.runningTime - startedAt)
					onEvent({kind = "status", text = ("ZCode is still running (" .. tostring(elapsed)) .. "s); waiting for its buffered response"})
				end
				local inactivityTimeout = config.provider == "zcode" and 1800 or 900
				if App.runningTime - lastActivity > inactivityTimeout then -- 412
					stopRequested = true -- 415
					onEvent({kind = "stderr", text = ("local Agent stopped after " .. tostring(math.floor(inactivityTimeout / 60))) .. " minutes without output"}) -- 416
				end -- 416
				sleep(0.05) -- 418
			end -- 418
			if not retryFresh then -- 418
				return -- 420
			end -- 420
		end -- 420
	end) -- 346
	return {stop = function(self) -- 423
		stopRequested = true -- 423
		if handle ~= nil then -- 423
			Process:stop(handle, "interrupt") -- 423
		end -- 423
	end} -- 423
end -- 330
local function runProbe(config, args, cwd, timeoutSeconds) -- 426
	local handle = Process:spawn({program = config.executable, args = args, cwd = cwd}) -- 427
	if handle == nil then -- 427
		return {exitCode = -1, stdout = "", stderr = "failed to start executable"} -- 428
	end -- 428
	Process:write(handle) -- 429
	local stdoutOffset = 0 -- 430
	local stderrOffset = 0 -- 431
	local stdout = "" -- 432
	local stderr = "" -- 433
	local started = App.runningTime -- 434
	while true do -- 434
		local chunk = Process:read(handle, stdoutOffset, stderrOffset) -- 436
		stdoutOffset = chunk.stdoutOffset -- 437
		stderrOffset = chunk.stderrOffset -- 438
		stdout = stdout .. chunk.stdout -- 439
		stderr = stderr .. chunk.stderr -- 440
		if not chunk.running then -- 440
			local exitCode = chunk.exit.exitCode or -1 -- 442
			Process:destroy(handle) -- 443
			return {exitCode = exitCode, stdout = stdout, stderr = stderr} -- 444
		end -- 444
		if App.runningTime - started >= timeoutSeconds then -- 444
			Process:stop(handle, "kill-tree") -- 447
			Process:destroy(handle) -- 448
			return {exitCode = -1, stdout = stdout, stderr = stderr .. "\nprobe timed out"} -- 449
		end -- 449
		sleep(0.05) -- 451
	end -- 451
end -- 426
function ____exports.verifyConfig(id, projectRoot) -- 455
	if not ____exports.isLocalAgentSupported() then -- 455
		return {success = false, code = "UNSUPPORTED_PLATFORM", message = "local Agent is only available on desktop platforms"} -- 456
	end -- 456
	local config = ____exports.getConfig(id) -- 457
	if not config then -- 457
		return {success = false, code = "NOT_FOUND", message = "local Agent config not found"} -- 458
	end -- 458
	local verifyBase = type(projectRoot) == "string" and Content:exist(projectRoot) and Content:isdir(projectRoot) and projectRoot or Content.writablePath -- 459
	local cwd = Path( -- 460
		verifyBase, -- 460
		(((".dora-local-agent-verify-" .. tostring(config.id)) .. "-") .. tostring(os.time()) .. "-") .. tostring(math.floor(App.runningTime * 1000)) -- 460
	) -- 460
	if not Content:mkdir(cwd) then -- 460
		return {success = false, code = "VERIFY_SETUP_FAILED", message = "failed to create local Agent verification directory"} -- 461
	end -- 461
	local function finish(result) -- 462
		Content:remove(cwd) -- 463
		return result -- 464
	end -- 462
	local versionArgs = config.provider == "zcode" and ({"version"}) or ({"--version"})
	local versionProbe = runProbe(config, versionArgs, cwd, 15) -- 461
	if versionProbe.exitCode ~= 0 then -- 461
		return finish({success = false, code = "DETECT_FAILED", message = versionProbe.stderr or versionProbe.stdout or "version probe failed"}) -- 462
	end -- 462
	local version = __TS__StringSplit( -- 463
		__TS__StringTrim(versionProbe.stdout or versionProbe.stderr), -- 463
		"\n" -- 463
	)[1] -- 463
	local prompt = "Reply with exactly DORA_LOCAL_AGENT_OK and do not edit files or run tools." -- 464
	local spec = buildSpec(config, cwd, prompt) -- 465
	local probe = runProbe(config, spec.args, cwd, 180) -- 466
	local output = (probe.stdout .. "\n") .. probe.stderr -- 467
	if probe.exitCode ~= 0 or not __TS__StringIncludes(output, "DORA_LOCAL_AGENT_OK") then -- 467
		return finish({ -- 468
			success = false, -- 468
			code = "VERIFY_FAILED", -- 468
			version = version, -- 468
			message = string.sub(output, 1, 4000) or "Agent exited with code " .. tostring(probe.exitCode) -- 468
		}) -- 468
	end -- 468
	local fingerprint = (((config.provider .. ":") .. config.executable) .. ":") .. encodeJson(config.extraArgs) -- 469
	DB:exec( -- 470
		("UPDATE " .. CONFIG_TABLE) .. " SET verified_at=?,verified_version=?,verified_fingerprint=?,updated_at=? WHERE id=?", -- 470
		{ -- 470
			os.time(), -- 470
			version, -- 470
			fingerprint, -- 470
			os.time(), -- 470
			config.id -- 470
		} -- 470
	) -- 470
	return finish({ -- 471
		success = true, -- 471
		version = version, -- 471
		verifiedAt = os.time() -- 471
	}) -- 471
end -- 455
return ____exports -- 455
