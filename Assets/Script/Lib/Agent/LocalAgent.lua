-- [ts]: LocalAgent.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
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
local SKILL_VERSION = 5 -- 39
local SKILL_MARKER = ("<!-- dora-managed-skill:v" .. tostring(SKILL_VERSION)) .. " -->"
local MANAGED_SKILL_MARKER = "<!-- dora-managed-skill:"
local supportedPlatforms = {"Windows", "macOS", "Linux"} -- 42
local function encodeJson(value) -- 44
	local text = safeJsonEncode(value) -- 45
	return text or "" -- 46
end -- 44
local function quoteCommandArg(value) -- 49
	if App.platform == "Windows" then -- 49
		return ("'" .. table.concat( -- 50
			__TS__StringSplit(value, "'"), -- 50
			"''" -- 50
		)) .. "'" -- 50
	end -- 50
	return ("'" .. table.concat( -- 51
		__TS__StringSplit(value, "'"), -- 51
		"'\"'\"'" -- 51
	)) .. "'" -- 51
end -- 49
local function buildDoraCLICommand() -- 54
	local executablePath = App.executablePath -- 55
	local assetPath = Content.assetPath -- 56
	if executablePath == "" or assetPath == "" then -- 56
		return nil -- 57
	end -- 57
	local command = ((quoteCommandArg(executablePath) .. " --asset ") .. quoteCommandArg(assetPath)) .. " cli"
	return App.platform == "Windows" and "& " .. command or command -- 59
end -- 54
local function waitForProcess(handle, timeoutSeconds) -- 68
	local startedAt = App.runningTime -- 69
	while App.runningTime - startedAt < timeoutSeconds do -- 69
		local result = Process:read(handle) -- 71
		if not result.running then -- 71
			local exitCode = result.exit.exitCode -- 73
			Process:destroy(handle) -- 74
			return exitCode -- 75
		end -- 75
		sleep(0.02) -- 77
	end -- 77
	Process:stop(handle, "kill-tree") -- 79
	Process:destroy(handle) -- 80
	return nil -- 81
end -- 68
local function prepareDoraCommandEnvironment() -- 84
	local fallback = buildDoraCLICommand() -- 85
	if not fallback then -- 85
		return nil -- 86
	end -- 86
	local executablePath = App.executablePath -- 87
	local assetPath = Content.assetPath -- 88
	local shimDir = Path(Content.writablePath, ".agent", "local-agent-bin") -- 89
	if not Content:exist(shimDir) and not Content:mkdir(shimDir) then -- 89
		return {command = fallback, shim = false} -- 90
	end -- 90
	local windows = App.platform == "Windows" -- 91
	local shimPath = Path(shimDir, windows and "dora.cmd" or "dora") -- 92
	local shimContent = windows and ((("@echo off\r\nif /I not \"%~1\"==\"cli\" (\r\n  >&2 echo This project-scoped Dora command only supports: dora cli ...\r\n  exit /b 2\r\n)\r\n\"" .. table.concat( -- 93
		__TS__StringSplit(executablePath, "%"), -- 94
		"%%" -- 94
	)) .. "\" --asset \"") .. table.concat(
		__TS__StringSplit(assetPath, "%"), -- 94
		"%%" -- 94
	)) .. "\" %*\r\n" or ((("#!/bin/sh\nif [ \"$1\" != \"cli\" ]; then\n  echo \"This project-scoped Dora command only supports: dora cli ...\" >&2\n  exit 2\nfi\nexec " .. quoteCommandArg(executablePath)) .. " --asset ") .. quoteCommandArg(assetPath)) .. " \"$@\"\n"
	if not Content:save(shimPath, shimContent) then -- 94
		return {command = fallback, shim = false} -- 96
	end -- 96
	if not windows then -- 96
		local chmod = Process:spawn({program = "/bin/chmod", args = {"700", shimPath}}) -- 98
		if chmod == nil or waitForProcess(chmod, 5) ~= 0 then -- 98
			return {command = fallback, shim = false} -- 99
		end -- 99
	end -- 99
	local inheritedPath = os.getenv("PATH") or "" -- 101
	local separator = windows and ";" or ":" -- 102
	return {command = "dora cli", shim = true, env = {PATH = inheritedPath == "" and shimDir or (shimDir .. separator) .. inheritedPath, DORA_EXECUTABLE_PATH = executablePath, DORA_ASSET_PATH = assetPath}} -- 103
end -- 84
local function buildSkillContent() -- 114
	return ("---\nname: dora-engine-coding\ndescription: Build and validate games for the Dora SSR engine using the local Dora CLI.\n---\n" .. SKILL_MARKER) .. "\n\n# Dora Engine coding\n\nWork inside the current Dora project. Dora games run in the Dora runtime, not a browser or Node.js: do not generate DOM, Canvas, browser-only, or Node-only runtime code.\n\n- Dora injects a project-scoped `dora` command into this Agent process. Use `dora cli` directly; do not search for Dora, create aliases, or guess installation paths.\n- Inspect the project before editing. The usual entry is `init.lua`, `init.ts`, `init.yue`, or another project entry selected by the user.\n- Do not guess Dora APIs. Use `dora cli doc search <query>` and `dora cli doc read <name>` to verify them.\n- Edit source files with your own file tools. TypeScript is transpiled to Lua by Dora; keep imports compatible with the Dora module declarations.\n- Validate compilation with `dora cli build <path>`.\n- Inspect the engine with `dora cli agent status -p <project>` and logs with `dora cli agent log -n 200`.\n- Run a controlled game check with `dora cli agent preview -p <project> --entry init.lua --capture-at 0.5,2`. Preview requests are FIFO and can interrupt a user-run game because Agent validation has priority.\n- Treat stdout from `dora cli agent` as one JSON result. stderr is diagnostic output.\n- `dora cli agent` only accesses engine tools. It never starts Dora Agent or another third-party Agent; do not construct nested Agent scheduling.\n\nFinish by reporting the files changed and the exact build/preview evidence you obtained.\n"
end -- 114
local function ensureTables() -- 139
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. CONFIG_TABLE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tname TEXT NOT NULL,\n\t\tprovider TEXT NOT NULL,\n\t\texecutable TEXT NOT NULL,\n\t\textra_args TEXT NOT NULL DEFAULT '[]',\n\t\tverified_at INTEGER,\n\t\tverified_version TEXT NOT NULL DEFAULT '',\n\t\tverified_fingerprint TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t)") -- 140
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. SESSION_TABLE) .. "(\n\t\tdora_session_id INTEGER PRIMARY KEY,\n\t\tconfig_id INTEGER NOT NULL,\n\t\tprovider TEXT NOT NULL,\n\t\tresume_id TEXT NOT NULL DEFAULT '',\n\t\tgeneration INTEGER NOT NULL DEFAULT 1,\n\t\tabandoned_at INTEGER,\n\t\tupdated_at INTEGER NOT NULL\n\t)") -- 152
end -- 139
local function rowToConfig(row) -- 163
	local provider = tostring(row[3]) -- 164
	if provider ~= "opencode" and provider ~= "codex" and provider ~= "zcode" and provider ~= "claude-code" then -- 164
		return nil -- 165
	end -- 165
	local ____safeJsonDecode_2 = safeJsonDecode -- 166
	local ____tostring_1 = tostring -- 166
	local ____row__5_0 = row[5] -- 166
	if ____row__5_0 == nil then -- 166
		____row__5_0 = "[]" -- 166
	end -- 166
	local decoded = ____safeJsonDecode_2(____tostring_1(____row__5_0)) -- 166
	local extraArgs = __TS__ArrayIsArray(decoded) and __TS__ArrayFilter( -- 167
		decoded, -- 167
		function(____, value) return type(value) == "string" end -- 167
	) or ({}) -- 167
	local verifiedAt = tonumber(row[6]) -- 168
	local ____temp_13 = tonumber(row[1]) or 0 -- 170
	local ____tostring_result_14 = tostring(row[2]) -- 171
	local ____provider_15 = provider -- 172
	local ____tostring_result_16 = tostring(row[4]) -- 173
	local ____extraArgs_17 = extraArgs -- 174
	local ____temp_18 = verifiedAt and verifiedAt > 0 and verifiedAt or nil -- 175
	local ____temp_7 -- 176
	local ____tostring_4 = tostring -- 176
	local ____row__7_3 = row[7] -- 176
	if ____row__7_3 == nil then -- 176
		____row__7_3 = "" -- 176
	end -- 176
	if ____tostring_4(____row__7_3) ~= "" then -- 176
		local ____tostring_6 = tostring -- 176
		local ____row__7_5 = row[7] -- 176
		if ____row__7_5 == nil then -- 176
			____row__7_5 = "" -- 176
		end -- 176
		____temp_7 = ____tostring_6(____row__7_5) -- 176
	else -- 176
		____temp_7 = nil -- 176
	end -- 176
	local ____temp_12 -- 177
	local ____tostring_9 = tostring -- 177
	local ____row__8_8 = row[8] -- 177
	if ____row__8_8 == nil then -- 177
		____row__8_8 = "" -- 177
	end -- 177
	if ____tostring_9(____row__8_8) ~= "" then -- 177
		local ____tostring_11 = tostring -- 177
		local ____row__8_10 = row[8] -- 177
		if ____row__8_10 == nil then -- 177
			____row__8_10 = "" -- 177
		end -- 177
		____temp_12 = ____tostring_11(____row__8_10) -- 177
	else -- 177
		____temp_12 = nil -- 177
	end -- 177
	return { -- 169
		id = ____temp_13, -- 170
		name = ____tostring_result_14, -- 171
		provider = ____provider_15, -- 172
		executable = ____tostring_result_16, -- 173
		extraArgs = ____extraArgs_17, -- 174
		verifiedAt = ____temp_18, -- 175
		verifiedVersion = ____temp_7, -- 176
		verifiedFingerprint = ____temp_12 -- 177
	} -- 177
end -- 163
function ____exports.isLocalAgentSupported() -- 181
	return __TS__ArrayIncludes(supportedPlatforms, App.platform) -- 182
end -- 181
function ____exports.listConfigs() -- 185
	ensureTables() -- 186
	local rows = DB:query(("SELECT id,name,provider,executable,extra_args,verified_at,verified_version,verified_fingerprint FROM " .. CONFIG_TABLE) .. " ORDER BY id") or ({}) -- 187
	local result = {} -- 188
	do -- 188
		local i = 0 -- 189
		while i < #rows do -- 189
			local config = rowToConfig(rows[i + 1]) -- 190
			if config then -- 190
				result[#result + 1] = config -- 191
			end -- 191
			i = i + 1 -- 189
		end -- 189
	end -- 189
	return result -- 193
end -- 185
function ____exports.getConfig(id) -- 196
	local configId = tonumber(id) -- 197
	local ____configId_19 -- 198
	if configId then -- 198
		____configId_19 = __TS__ArrayFind( -- 198
			____exports.listConfigs(), -- 198
			function(____, item) return item.id == configId end -- 198
		) -- 198
	else -- 198
		____configId_19 = nil -- 198
	end -- 198
	return ____configId_19 -- 198
end -- 196
local function normalizeProvider(value) -- 201
	return (value == "opencode" or value == "codex" or value == "zcode" or value == "claude-code") and value or nil -- 202
end -- 201
local function normalizeArgs(value) -- 205
	if not __TS__ArrayIsArray(value) then -- 205
		return {} -- 206
	end -- 206
	return __TS__ArrayMap( -- 207
		__TS__ArrayFilter( -- 207
			value, -- 207
			function(____, item) return type(item) == "string" end -- 207
		), -- 207
		function(____, item) return sanitizeUTF8(item) end -- 207
	) -- 207
end -- 205
function ____exports.saveConfig(input) -- 210
	ensureTables() -- 211
	local provider = normalizeProvider(input.provider) -- 212
	local name = type(input.name) == "string" and __TS__StringTrim(sanitizeUTF8(input.name)) or "" -- 213
	local executable = type(input.executable) == "string" and __TS__StringTrim(sanitizeUTF8(input.executable)) or "" -- 214
	if not provider or name == "" or executable == "" then -- 214
		return {success = false, message = "invalid local Agent config"} -- 215
	end -- 215
	local extraArgs = normalizeArgs(input.extraArgs) -- 216
	local encodedArgs = encodeJson(extraArgs) -- 217
	local id = tonumber(input.id) -- 218
	local t = os.time() -- 219
	if id and id > 0 then -- 219
		local old = ____exports.getConfig(id) -- 221
		if not old then -- 221
			return {success = false, message = "local Agent config not found"} -- 222
		end -- 222
		local changed = old.provider ~= provider or old.executable ~= executable or encodeJson(old.extraArgs) ~= encodedArgs -- 223
		DB:exec(("UPDATE " .. CONFIG_TABLE) .. " SET name=?,provider=?,executable=?,extra_args=?,verified_at=?,verified_version=?,verified_fingerprint=?,updated_at=? WHERE id=?", { -- 224
			name, -- 225
			provider, -- 225
			executable, -- 225
			encodedArgs, -- 225
			changed and 0 or (old.verifiedAt or 0), -- 226
			changed and "" or (old.verifiedVersion or ""), -- 227
			changed and "" or (old.verifiedFingerprint or ""), -- 228
			t, -- 229
			id -- 229
		}) -- 229
		return {success = true, id = id} -- 231
	end -- 231
	DB:exec(("INSERT INTO " .. CONFIG_TABLE) .. "(name,provider,executable,extra_args,created_at,updated_at) VALUES(?,?,?,?,?,?)", { -- 233
		name, -- 233
		provider, -- 233
		executable, -- 233
		encodedArgs, -- 233
		t, -- 233
		t -- 233
	}) -- 233
	local rows = DB:query("SELECT last_insert_rowid()") or ({}) -- 234
	local ____tonumber_22 = tonumber -- 235
	local ____opt_20 = rows[1] -- 235
	return { -- 235
		success = true, -- 235
		id = ____tonumber_22(____opt_20 and ____opt_20[1]) or 0 -- 235
	} -- 235
end -- 210
function ____exports.deleteConfig(id) -- 238
	ensureTables() -- 239
	local configId = tonumber(id) -- 240
	if not configId then -- 240
		return {success = false, message = "invalid local Agent config id"} -- 241
	end -- 241
	DB:exec(("DELETE FROM " .. CONFIG_TABLE) .. " WHERE id=?", {configId}) -- 242
	return {success = true} -- 243
end -- 238
local function buildSpec(config, cwd, prompt, resumeId) -- 248
	local args -- 249
	if config.provider == "codex" then -- 249
		local ____resumeId_25 -- 251
		if resumeId then -- 251
			local ____array_23 = __TS__SparseArrayNew( -- 251
				"exec", -- 252
				"resume", -- 252
				"--json",
				"--dangerously-bypass-approvals-and-sandbox",
				table.unpack(config.extraArgs) -- 252
			) -- 252
			__TS__SparseArrayPush(____array_23, resumeId, prompt) -- 252
			____resumeId_25 = {__TS__SparseArraySpread(____array_23)} -- 252
		else -- 252
			local ____array_24 = __TS__SparseArrayNew( -- 252
				"exec", -- 253
				"--json",
				"--dangerously-bypass-approvals-and-sandbox",
				"-C", -- 253
				cwd, -- 253
				table.unpack(config.extraArgs) -- 253
			) -- 253
			__TS__SparseArrayPush(____array_24, prompt) -- 253
			____resumeId_25 = {__TS__SparseArraySpread(____array_24)} -- 253
		end -- 253
		args = ____resumeId_25 -- 251
	elseif config.provider == "claude-code" then -- 251
		args = { -- 255
			"-p", -- 255
			"--output-format",
			"stream-json", -- 255
			"--verbose",
			"--dangerously-skip-permissions",
			table.unpack(config.extraArgs) -- 255
		} -- 255
		if resumeId then -- 255
			__TS__ArrayPush(args, "--resume", resumeId)
		end -- 256
		args[#args + 1] = prompt -- 257
	elseif config.provider == "opencode" then -- 257
		args = { -- 259
			"run", -- 259
			"--format",
			"json", -- 259
			"--auto",
			"--dir",
			cwd, -- 259
			table.unpack(config.extraArgs) -- 259
		} -- 259
		if resumeId then -- 259
			__TS__ArrayPush(args, "--session", resumeId)
		end -- 260
		args[#args + 1] = prompt -- 261
	else -- 261
		args = { -- 263
			"--prompt",
			prompt, -- 263
			"--json",
			"--mode",
			"yolo", -- 263
			"--cwd",
			cwd, -- 263
			table.unpack(config.extraArgs) -- 263
		} -- 263
		if resumeId then -- 263
			__TS__ArrayPush(args, "--resume", resumeId)
		end -- 264
	end -- 264
	return {program = config.executable, args = args, cwd = cwd} -- 266
end -- 248
local function getString(record, ...) -- 269
	local keys = {...} -- 269
	do -- 269
		local i = 0 -- 270
		while i < #keys do -- 270
			local value = record[keys[i + 1]] -- 271
			if type(value) == "string" and value ~= "" then -- 271
				return value -- 272
			end -- 272
			i = i + 1 -- 270
		end -- 270
	end -- 270
	return nil -- 274
end -- 269
local function getClaudeBlockText(value) -- 277
	if type(value) == "string" and value ~= "" then -- 277
		return value -- 278
	end -- 278
	if not __TS__ArrayIsArray(value) then -- 278
		return nil -- 279
	end -- 279
	local parts = {} -- 280
	do -- 280
		local i = 0 -- 281
		while i < #value do -- 281
			local block = value[i + 1] -- 282
			if type(block) == "string" and block ~= "" then -- 282
				parts[#parts + 1] = block -- 283
			elseif block and type(block) == "table" then -- 283
				local text = getString(block, "text", "content") -- 285
				if text then -- 285
					parts[#parts + 1] = text -- 286
				end -- 286
			end -- 286
			i = i + 1 -- 281
		end -- 281
	end -- 281
	return #parts > 0 and table.concat(parts, "\n") or nil -- 289
end -- 277
local function parseRecord(provider, record) -- 292
	local events = {} -- 293
	local eventType = getString(record, "type", "event", "kind") or "activity" -- 294
	local resumeId = getString( -- 295
		record, -- 295
		"thread_id", -- 295
		"threadId", -- 295
		"session_id", -- 295
		"sessionId", -- 295
		"sessionID" -- 295
	) -- 295
	local item = record.item -- 296
	if item and type(item) == "table" then -- 296
		local itemRecord = item -- 298
		resumeId = resumeId or getString( -- 299
			itemRecord, -- 299
			"thread_id", -- 299
			"session_id", -- 299
			"sessionId", -- 299
			"sessionID" -- 299
		) -- 299
		local itemType = getString(itemRecord, "type", "kind") or eventType -- 300
		local handledTool = false -- 301
		if provider == "codex" and itemType == "mcp_tool_call" then -- 301
			local server = getString(itemRecord, "server") or "mcp" -- 303
			local tool = getString(itemRecord, "tool") or "tool" -- 304
			local status = getString(itemRecord, "status") or eventType -- 305
			local details = {((((server .. ".") .. tool) .. " (") .. status) .. ")"} -- 306
			if itemRecord.arguments ~= nil then -- 306
				details[#details + 1] = "arguments: " .. encodeJson(itemRecord.arguments) -- 307
			end -- 307
			if itemRecord.result ~= nil then -- 307
				details[#details + 1] = "result:\n" .. (type(itemRecord.result) == "string" and itemRecord.result or encodeJson(itemRecord.result)) -- 308
			end -- 308
			if itemRecord.error ~= nil then -- 308
				details[#details + 1] = "error:\n" .. (type(itemRecord.error) == "string" and itemRecord.error or encodeJson(itemRecord.error)) -- 309
			end -- 309
			events[#events + 1] = { -- 310
				kind = "command", -- 310
				text = table.concat(details, "\n"), -- 310
				resumeId = resumeId, -- 310
				raw = record -- 310
			} -- 310
			handledTool = true -- 311
		end -- 311
		if not handledTool then -- 311
			local text = getString( -- 314
				itemRecord, -- 314
				"text", -- 314
				"content", -- 314
				"message", -- 314
				"command", -- 314
				"aggregated_output" -- 314
			) -- 314
			if text then -- 314
				local kind = (__TS__StringIncludes(itemType, "agent") or __TS__StringIncludes(itemType, "text") or __TS__StringIncludes(itemType, "message")) and "assistant" or ((__TS__StringIncludes(itemType, "command") or __TS__StringIncludes(itemType, "tool")) and "command" or "activity") -- 316
				events[#events + 1] = {kind = kind, text = text, resumeId = resumeId, raw = record} -- 318
			end -- 318
		end -- 318
	end -- 318
	local message = record.message -- 322
	if provider == "claude-code" and message and type(message) == "table" then -- 322
		local content = message.content -- 324
		if __TS__ArrayIsArray(content) then -- 324
			do -- 324
				local i = 0 -- 326
				while i < #content do -- 326
					do -- 326
						local block = content[i + 1] -- 327
						if not block or type(block) ~= "table" then -- 327
							goto __continue70 -- 328
						end -- 328
						local blockRecord = block -- 329
						local blockType = getString(blockRecord, "type") or "" -- 330
						if blockType == "text" then -- 330
							local text = getString(blockRecord, "text") -- 332
							if text then -- 332
								events[#events + 1] = {kind = "assistant", text = text, resumeId = resumeId, raw = record} -- 333
							end -- 333
						elseif blockType == "tool_use" then -- 333
							local name = getString(blockRecord, "name") or "tool" -- 335
							local details = {name} -- 336
							if blockRecord.input ~= nil then -- 336
								details[#details + 1] = "input: " .. encodeJson(blockRecord.input) -- 337
							end -- 337
							events[#events + 1] = { -- 338
								kind = "command", -- 338
								text = table.concat(details, "\n"), -- 338
								resumeId = resumeId, -- 338
								raw = record -- 338
							} -- 338
						elseif blockType == "tool_result" then -- 338
							local text = getClaudeBlockText(blockRecord.content) or encodeJson(blockRecord.content) -- 340
							events[#events + 1] = {kind = "command", text = "tool result" .. (text ~= nil and text ~= "" and "\n" .. text or ""), resumeId = resumeId, raw = record} -- 341
						end -- 341
					end -- 341
					::__continue70:: -- 341
					i = i + 1 -- 326
				end -- 326
			end -- 326
		end -- 326
	end -- 326
	local part = record.part -- 346
	if part and type(part) == "table" then -- 346
		local partRecord = part -- 348
		resumeId = resumeId or getString(partRecord, "sessionID", "sessionId", "session_id") -- 349
		local handledTool = false -- 350
		if provider == "opencode" and eventType == "tool_use" and partRecord.state and type(partRecord.state) == "table" then -- 350
			local state = partRecord.state -- 352
			local tool = getString(partRecord, "tool") or "tool" -- 353
			local status = getString(state, "status") -- 354
			local details = {tool .. (status and (" (" .. status) .. ")" or "")} -- 355
			if state.input and type(state.input) == "table" then -- 355
				details[#details + 1] = "input: " .. encodeJson(state.input) -- 356
			end -- 356
			local output = getString(state, "output") -- 357
			if output then -- 357
				details[#details + 1] = "output:\n" .. output -- 358
			end -- 358
			events[#events + 1] = { -- 359
				kind = "command", -- 359
				text = table.concat(details, "\n"), -- 359
				resumeId = resumeId, -- 359
				raw = record -- 359
			} -- 359
			handledTool = true -- 360
		end -- 360
		if not handledTool then -- 360
			local text = getString( -- 363
				partRecord, -- 363
				"text", -- 363
				"content", -- 363
				"message", -- 363
				"command" -- 363
			) -- 363
			if text then -- 363
				events[#events + 1] = { -- 364
					kind = __TS__StringIncludes(eventType, "tool") and "command" or "assistant", -- 364
					text = text, -- 364
					resumeId = resumeId, -- 364
					raw = record -- 364
				} -- 364
			end -- 364
		end -- 364
	end -- 364
	local text = getString( -- 367
		record, -- 367
		"text", -- 367
		"content", -- 367
		"message", -- 367
		"output", -- 367
		"result", -- 367
		"response" -- 367
	) -- 367
	if text and #events == 0 then -- 367
		local kind = (provider == "zcode" and type(record.response) == "string" or provider == "claude-code" and eventType == "result") and "assistant" or ((__TS__StringIncludes(eventType, "command") or __TS__StringIncludes(eventType, "tool")) and "command" or ((__TS__StringIncludes(eventType, "assistant") or __TS__StringIncludes(eventType, "message") or __TS__StringIncludes(eventType, "text")) and "assistant" or "activity")) -- 369
		events[#events + 1] = {kind = kind, text = text, resumeId = resumeId, raw = record} -- 372
	end -- 372
	if resumeId and #events == 0 then -- 372
		events[#events + 1] = {kind = "status", text = (provider .. " session ") .. resumeId, resumeId = resumeId, raw = record} -- 374
	end -- 374
	return events -- 375
end -- 292
local function parseLines(provider, buffer, onEvent) -- 378
	local lines = __TS__StringSplit(buffer, "\n") -- 379
	local rest = table.remove(lines) or "" -- 380
	do -- 380
		local i = 0 -- 381
		while i < #lines do -- 381
			do -- 381
				local line = __TS__StringTrim(sanitizeUTF8(lines[i + 1])) -- 382
				if line == "" then -- 382
					goto __continue87 -- 383
				end -- 383
				local decoded = safeJsonDecode(line) -- 384
				if decoded and type(decoded) == "table" and not __TS__ArrayIsArray(decoded) then -- 384
					local events = parseRecord(provider, decoded) -- 386
					if #events > 0 then -- 386
						do -- 386
							local e = 0 -- 387
							while e < #events do -- 387
								onEvent(events[e + 1]) -- 387
								e = e + 1 -- 387
							end -- 387
						end -- 387
					else -- 387
						onEvent({kind = "activity", text = line, raw = decoded}) -- 388
					end -- 388
				else -- 388
					onEvent({kind = "activity", text = line}) -- 390
				end -- 390
			end -- 390
			::__continue87:: -- 390
			i = i + 1 -- 381
		end -- 381
	end -- 381
	return rest -- 393
end -- 378
local function parseCompleteOutput(provider, output, onEvent) -- 396
	local text = __TS__StringTrim(sanitizeUTF8(output)) -- 397
	if text == "" then -- 397
		return -- 398
	end -- 398
	local decoded = safeJsonDecode(text) -- 399
	if decoded and type(decoded) == "table" and not __TS__ArrayIsArray(decoded) then -- 399
		local events = parseRecord(provider, decoded) -- 401
		if #events > 0 then -- 401
			do -- 401
				local i = 0 -- 403
				while i < #events do -- 403
					onEvent(events[i + 1]) -- 403
					i = i + 1 -- 403
				end -- 403
			end -- 403
			return -- 404
		end -- 404
	end -- 404
	parseLines(provider, text .. "\n", onEvent) -- 407
end -- 396
local function loadManagedSkills() -- 416
	local sourceRoot = Path(Content.assetPath, "Doc", "local-agent-skills") -- 417
	local commandContent = Content:load(Path(sourceRoot, "dora-agent-command", "SKILL.md")) -- 418
	local musicContent = Content:load(Path(sourceRoot, "music-generation", "SKILL.md")) -- 419
	if commandContent == "" or musicContent == "" then -- 419
		return nil -- 420
	end -- 420
	return { -- 421
		{ -- 422
			name = "dora-engine-coding", -- 422
			content = buildSkillContent() -- 422
		}, -- 422
		{name = "dora-agent-command", content = commandContent}, -- 423
		{ -- 424
			name = "music-generation", -- 425
			content = musicContent, -- 426
			resources = { -- 427
				{ -- 428
					source = Path( -- 428
						Content.assetPath, -- 428
						"Script", -- 428
						"Lib", -- 428
						"Agent", -- 428
						"Gen", -- 428
						"Music.d.ts" -- 428
					), -- 428
					target = Path("references", "Music.d.ts") -- 428
				}, -- 428
				{ -- 429
					source = Path( -- 429
						Content.assetPath, -- 429
						"Doc", -- 429
						"skills", -- 429
						"music-generation", -- 429
						"GeneralUserGS-Presets.md" -- 429
					), -- 429
					target = Path("references", "GeneralUserGS-Presets.md") -- 429
				} -- 429
			} -- 429
		} -- 429
	} -- 429
end -- 416
local function installSkill(projectRoot, provider, skill) -- 435
	local dir = provider == "claude-code" and Path(projectRoot, ".claude", "skills", skill.name) or Path(projectRoot, ".agents", "skills", skill.name) -- 436
	local target = Path(dir, "SKILL.md") -- 439
	local targetExisted = Content:exist(target) -- 440
	if targetExisted then -- 440
		local existing = Content:load(target) -- 442
		if not __TS__StringIncludes(existing, "<!-- dora-managed-skill:v") and not __TS__StringIncludes(existing, MANAGED_SKILL_MARKER) then
			return {success = true, state = "custom", message = ("custom " .. skill.name) .. " skill preserved"} -- 444
		end -- 444
	end -- 444
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 444
		return {success = false, state = "failed", message = "failed to create Dora skill directory"} -- 447
	end -- 447
	local temp = target .. ".tmp" -- 448
	if not Content:save(temp, skill.content) or not Content:move(temp, target) then -- 448
		if Content:exist(temp) then -- 448
			Content:remove(temp) -- 450
		end -- 450
		return {success = false, state = "failed", message = ("failed to install " .. skill.name) .. " skill"} -- 451
	end -- 451
	for ____, resource in ipairs(skill.resources or ({})) do -- 453
		local content = Content:load(resource.source) -- 454
		if content == "" then -- 454
			return {success = false, state = "failed", message = (("failed to load " .. skill.name) .. " resource ") .. resource.source} -- 455
		end -- 455
		local resourceTarget = Path(dir, resource.target) -- 456
		local resourceDir = Path:getPath(resourceTarget) -- 457
		if not Content:exist(resourceDir) and not Content:mkdir(resourceDir) then -- 457
			return {success = false, state = "failed", message = ("failed to create " .. skill.name) .. " resource directory"} -- 458
		end -- 458
		local resourceTemp = resourceTarget .. ".tmp" -- 459
		if not Content:save(resourceTemp, content) or not Content:move(resourceTemp, resourceTarget) then -- 459
			if Content:exist(resourceTemp) then -- 459
				Content:remove(resourceTemp) -- 461
			end -- 461
			return {success = false, state = "failed", message = ("failed to install " .. skill.name) .. " resource"} -- 462
		end -- 462
	end -- 462
	return {success = true, state = targetExisted and "current" or "installed"} -- 465
end -- 435
local function ensureSkills(projectRoot, provider) -- 468
	local skills = loadManagedSkills() -- 469
	if not skills then -- 469
		return {success = false, message = "failed to load Dora local Agent skills"} -- 470
	end -- 470
	for ____, skill in ipairs(skills) do -- 471
		local result = installSkill(projectRoot, provider, skill) -- 472
		if not result.success then -- 472
			return result -- 473
		end -- 473
	end -- 473
	return {success = true} -- 475
end -- 468
local function getExternalSession(doraSessionId, config) -- 478
	ensureTables() -- 479
	local rows = DB:query(("SELECT config_id,provider,resume_id,generation FROM " .. SESSION_TABLE) .. " WHERE dora_session_id=?", {doraSessionId}) or ({}) -- 480
	if #rows > 0 and tonumber(rows[1][1]) == config.id and tostring(rows[1][2]) == config.provider then -- 480
		local storedResumeId = tostring(rows[1][3]) -- 482
		return { -- 483
			resumeId = storedResumeId ~= "" and storedResumeId or nil, -- 483
			generation = tonumber(rows[1][4]) or 1 -- 483
		} -- 483
	end -- 483
	DB:exec( -- 485
		("INSERT INTO " .. SESSION_TABLE) .. "(dora_session_id,config_id,provider,resume_id,generation,updated_at) VALUES(?,?,?,?,1,?) ON CONFLICT(dora_session_id) DO UPDATE SET config_id=excluded.config_id,provider=excluded.provider,resume_id='',generation=generation+1,abandoned_at=?,updated_at=excluded.updated_at", -- 485
		{ -- 485
			doraSessionId, -- 485
			config.id, -- 485
			config.provider, -- 485
			"", -- 485
			os.time(), -- 485
			os.time() -- 485
		} -- 485
	) -- 485
	return {generation = 1} -- 486
end -- 478
local function saveResumeId(doraSessionId, config, resumeId) -- 489
	DB:exec( -- 490
		("UPDATE " .. SESSION_TABLE) .. " SET resume_id=?,updated_at=? WHERE dora_session_id=? AND config_id=?", -- 490
		{ -- 490
			resumeId, -- 490
			os.time(), -- 490
			doraSessionId, -- 490
			config.id -- 490
		} -- 490
	) -- 490
end -- 489
local function isMissingExternalSession(text) -- 493
	local lower = string.lower(text) -- 494
	return __TS__StringIncludes(lower, "session not found") or __TS__StringIncludes(lower, "thread not found") or __TS__StringIncludes(lower, "unknown session") or __TS__StringIncludes(lower, "invalid session") or __TS__StringIncludes(lower, "no conversation found") -- 495
end -- 493
function ____exports.abandonSession(doraSessionId) -- 502
	ensureTables() -- 503
	local id = tonumber(doraSessionId) -- 504
	if not id then -- 504
		return {success = false, message = "invalid Dora session id"} -- 505
	end -- 505
	DB:exec( -- 506
		("UPDATE " .. SESSION_TABLE) .. " SET resume_id='',generation=generation+1,abandoned_at=?,updated_at=? WHERE dora_session_id=?", -- 506
		{ -- 506
			os.time(), -- 506
			os.time(), -- 506
			id -- 506
		} -- 506
	) -- 506
	return {success = true} -- 507
end -- 502
function ____exports.getSessionInfo(doraSessionId) -- 510
	ensureTables() -- 511
	local id = tonumber(doraSessionId) -- 512
	if not id then -- 512
		return nil -- 513
	end -- 513
	local rows = DB:query(("SELECT config_id,provider,resume_id,generation,abandoned_at,updated_at FROM " .. SESSION_TABLE) .. " WHERE dora_session_id=?", {id}) or ({}) -- 514
	if #rows == 0 then -- 514
		return nil -- 515
	end -- 515
	return { -- 516
		configId = rows[1][1], -- 516
		provider = rows[1][2], -- 516
		resumeId = rows[1][3], -- 516
		generation = rows[1][4], -- 516
		abandonedAt = rows[1][5], -- 516
		updatedAt = rows[1][6] -- 516
	} -- 516
end -- 510
function ____exports.run(doraSessionId, config, projectRoot, prompt, onEvent, onDone) -- 519
	local stopRequested = false -- 527
	local handle -- 528
	local skills = ensureSkills(projectRoot, config.provider) -- 529
	if not skills.success then -- 529
		onDone({success = false, exitCode = -1, message = skills.message or "failed to install Dora skills"}) -- 531
		return {stop = function(self) -- 532
			stopRequested = true -- 532
		end} -- 532
	end -- 532
	local external = getExternalSession(doraSessionId, config) -- 534
	onEvent({kind = "status", text = config.provider == "zcode" and ((("Started " .. config.name) .. " (") .. config.provider) .. "); its CLI returns the structured message when the task completes" or ((("Started " .. config.name) .. " (") .. config.provider) .. ")"}) -- 535
	local monitorHost = Node() -- 543
	monitorHost:addTo(Director.systemUI) -- 544
	local function finish(result) -- 545
		onDone(result) -- 546
		monitorHost:removeFromParent(false) -- 547
	end -- 545
	monitorHost:once(function() -- 549
		local doraCommand = prepareDoraCommandEnvironment() -- 550
		if not doraCommand then -- 550
			finish({success = false, exitCode = -1, message = "failed to resolve Dora executable or Asset path"}) -- 552
			return -- 553
		end -- 553
		if not doraCommand.shim then -- 553
			onEvent({kind = "status", text = "Dora command shim was unavailable; using the absolute Dora CLI command for this turn"}) -- 555
		end -- 555
		local resumeId = external.resumeId -- 556
		local retriedMissingSession = false -- 557
		while true do -- 557
			local commandPrompt = doraCommand.shim and "Dora CLI is available in this Agent environment as `dora cli`.\n\n" .. prompt or (("For this turn, invoke Dora CLI only with this exact prefix (do not use a bare dora command):\n" .. doraCommand.command) .. "\n\n") .. prompt -- 559
			local skillPrompt = "Dora project skills available: dora-engine-coding, dora-agent-command, music-generation. Read the relevant skill before using Dora engine commands or generating music.\n\n" .. commandPrompt -- 562
			local spec = buildSpec(config, projectRoot, skillPrompt, resumeId) -- 563
			spec.env = doraCommand.env -- 564
			handle = Process:spawn(spec) -- 565
			if handle == nil then -- 565
				finish({success = false, exitCode = -1, message = "failed to start " .. config.executable}) -- 567
				return -- 568
			end -- 568
			Process:write(handle) -- 570
			local stdoutOffset = 0 -- 571
			local stderrOffset = 0 -- 572
			local stdoutBuffer = "" -- 573
			local stderrBuffer = "" -- 574
			local diagnostic = "" -- 575
			local lastActivity = App.runningTime -- 576
			local startedAt = App.runningTime -- 577
			local lastProgressNotice = App.runningTime -- 578
			local retryFresh = false -- 579
			local protocolFailure -- 580
			local function emitEvent(event) -- 581
				local ____temp_28 = config.provider == "claude-code" -- 582
				if ____temp_28 then -- 582
					local ____opt_26 = event.raw -- 582
					____temp_28 = (____opt_26 and ____opt_26.type) == "result" -- 582
				end -- 582
				if ____temp_28 and event.raw.is_error == true then -- 582
					protocolFailure = getString(event.raw, "result", "subtype") or "Claude Code reported an error" -- 583
				end -- 583
				if event.resumeId and event.resumeId ~= resumeId then -- 583
					resumeId = event.resumeId -- 586
					saveResumeId(doraSessionId, config, resumeId) -- 587
				end -- 587
				onEvent(event) -- 589
			end -- 581
			while true do -- 581
				local chunk = Process:read(handle, stdoutOffset, stderrOffset) -- 592
				stdoutOffset = chunk.stdoutOffset -- 593
				stderrOffset = chunk.stderrOffset -- 594
				if chunk.stdout ~= "" then -- 594
					lastActivity = App.runningTime -- 596
					diagnostic = string.sub(diagnostic .. chunk.stdout, -32768) -- 597
					stdoutBuffer = config.provider == "zcode" and stdoutBuffer .. chunk.stdout or parseLines(config.provider, stdoutBuffer .. chunk.stdout, emitEvent) -- 598
				end -- 598
				if chunk.stderr ~= "" then -- 598
					lastActivity = App.runningTime -- 603
					diagnostic = string.sub(diagnostic .. chunk.stderr, -32768) -- 604
					stderrBuffer = stderrBuffer .. chunk.stderr -- 605
					local lines = __TS__StringSplit(stderrBuffer, "\n") -- 606
					stderrBuffer = table.remove(lines) or "" -- 607
					do -- 607
						local i = 0 -- 608
						while i < #lines do -- 608
							if __TS__StringTrim(lines[i + 1]) ~= "" then -- 608
								onEvent({ -- 608
									kind = "stderr", -- 608
									text = sanitizeUTF8(lines[i + 1]) -- 608
								}) -- 608
							end -- 608
							i = i + 1 -- 608
						end -- 608
					end -- 608
				end -- 608
				if not chunk.running then -- 608
					if __TS__StringTrim(stdoutBuffer) ~= "" then -- 608
						parseCompleteOutput(config.provider, stdoutBuffer, emitEvent) -- 611
					end -- 611
					if __TS__StringTrim(stderrBuffer) ~= "" then -- 611
						onEvent({ -- 612
							kind = "stderr", -- 612
							text = sanitizeUTF8(stderrBuffer) -- 612
						}) -- 612
					end -- 612
					local exitCode = chunk.exit.exitCode or -1 -- 613
					Process:destroy(handle) -- 614
					handle = nil -- 615
					local failureText = protocolFailure or diagnostic -- 616
					if (exitCode ~= 0 or protocolFailure ~= nil) and external.resumeId and not retriedMissingSession and isMissingExternalSession(failureText) then -- 616
						retriedMissingSession = true -- 618
						resumeId = nil -- 619
						saveResumeId(doraSessionId, config, "") -- 620
						onEvent({kind = "status", text = "Stored local Agent session is unavailable; retrying once with a new session"}) -- 621
						retryFresh = true -- 622
						break -- 623
					end -- 623
					local success = exitCode == 0 and protocolFailure == nil and not stopRequested -- 625
					finish({ -- 626
						success = success, -- 626
						exitCode = exitCode, -- 626
						message = protocolFailure or (exitCode == 0 and "completed" or "local Agent exited with code " .. tostring(exitCode)), -- 626
						resumeId = resumeId, -- 626
						stopped = stopRequested -- 626
					}) -- 626
					return -- 627
				end -- 627
				if stopRequested then -- 627
					Process:stop(handle, "interrupt") -- 630
					sleep(1.5) -- 631
					local after = Process:read(handle, stdoutOffset, stderrOffset) -- 632
					if after.running then -- 632
						Process:stop(handle, "kill-tree") -- 633
					end -- 633
				end -- 633
				if config.provider == "zcode" and App.runningTime - lastProgressNotice >= 30 then -- 633
					lastProgressNotice = App.runningTime -- 636
					local elapsed = math.floor(App.runningTime - startedAt) -- 637
					onEvent({ -- 638
						kind = "status", -- 638
						text = ("ZCode is still running (" .. tostring(elapsed)) .. "s); waiting for its buffered response" -- 638
					}) -- 638
				end -- 638
				local inactivityTimeout = config.provider == "zcode" and 1800 or 900 -- 640
				if App.runningTime - lastActivity > inactivityTimeout then -- 640
					stopRequested = true -- 642
					onEvent({ -- 643
						kind = "stderr", -- 643
						text = ("local Agent stopped after " .. tostring(math.floor(inactivityTimeout / 60))) .. " minutes without output" -- 643
					}) -- 643
				end -- 643
				sleep(0.05) -- 645
			end -- 645
			if not retryFresh then -- 645
				return -- 647
			end -- 647
		end -- 647
	end) -- 549
	return {stop = function(self) -- 650
		stopRequested = true -- 650
		if handle ~= nil then -- 650
			Process:stop(handle, "interrupt") -- 650
		end -- 650
	end} -- 650
end -- 519
local function runProbe(config, args, cwd, timeoutSeconds) -- 653
	local handle = Process:spawn({program = config.executable, args = args, cwd = cwd}) -- 654
	if handle == nil then -- 654
		return {exitCode = -1, stdout = "", stderr = "failed to start executable"} -- 655
	end -- 655
	Process:write(handle) -- 656
	local stdoutOffset = 0 -- 657
	local stderrOffset = 0 -- 658
	local stdout = "" -- 659
	local stderr = "" -- 660
	local started = App.runningTime -- 661
	while true do -- 661
		local chunk = Process:read(handle, stdoutOffset, stderrOffset) -- 663
		stdoutOffset = chunk.stdoutOffset -- 664
		stderrOffset = chunk.stderrOffset -- 665
		stdout = stdout .. chunk.stdout -- 666
		stderr = stderr .. chunk.stderr -- 667
		if not chunk.running then -- 667
			local exitCode = chunk.exit.exitCode or -1 -- 669
			Process:destroy(handle) -- 670
			return {exitCode = exitCode, stdout = stdout, stderr = stderr} -- 671
		end -- 671
		if App.runningTime - started >= timeoutSeconds then -- 671
			Process:stop(handle, "kill-tree") -- 674
			Process:destroy(handle) -- 675
			return {exitCode = -1, stdout = stdout, stderr = stderr .. "\nprobe timed out"} -- 676
		end -- 676
		sleep(0.05) -- 678
	end -- 678
end -- 653
function ____exports.verifyConfig(id, projectRoot) -- 682
	if not ____exports.isLocalAgentSupported() then -- 682
		return {success = false, code = "UNSUPPORTED_PLATFORM", message = "local Agent is only available on desktop platforms"} -- 683
	end -- 683
	local config = ____exports.getConfig(id) -- 684
	if not config then -- 684
		return {success = false, code = "NOT_FOUND", message = "local Agent config not found"} -- 685
	end -- 685
	local verifyBase = type(projectRoot) == "string" and Content:exist(projectRoot) and Content:isdir(projectRoot) and projectRoot or Content.writablePath -- 686
	local cwd = Path( -- 687
		verifyBase, -- 687
		((((".dora-local-agent-verify-" .. tostring(config.id)) .. "-") .. tostring(os.time())) .. "-") .. tostring(math.floor(App.runningTime * 1000)) -- 687
	) -- 687
	if not Content:mkdir(cwd) then -- 687
		return {success = false, code = "VERIFY_SETUP_FAILED", message = "failed to create local Agent verification directory"} -- 688
	end -- 688
	local function finish(result) -- 689
		Content:remove(cwd) -- 690
		return result -- 691
	end -- 689
	local versionArgs = config.provider == "zcode" and ({"version"}) or ({"--version"})
	local versionProbe = runProbe(config, versionArgs, cwd, 15) -- 694
	if versionProbe.exitCode ~= 0 then -- 694
		local message = versionProbe.stderr ~= "" and versionProbe.stderr or (versionProbe.stdout ~= "" and versionProbe.stdout or "version probe failed") -- 696
		return finish({success = false, code = "DETECT_FAILED", message = message}) -- 697
	end -- 697
	local version = __TS__StringSplit( -- 699
		__TS__StringTrim(versionProbe.stdout ~= "" and versionProbe.stdout or versionProbe.stderr), -- 699
		"\n" -- 699
	)[1] -- 699
	local prompt = "Reply with exactly DORA_LOCAL_AGENT_OK and do not edit files or run tools." -- 700
	local spec = buildSpec(config, cwd, prompt) -- 701
	local probe = runProbe(config, spec.args, cwd, 180) -- 702
	local output = (probe.stdout .. "\n") .. probe.stderr -- 703
	if probe.exitCode ~= 0 or not __TS__StringIncludes(output, "DORA_LOCAL_AGENT_OK") then -- 703
		local preview = string.sub(output, 1, 4000) -- 705
		return finish({ -- 706
			success = false, -- 706
			code = "VERIFY_FAILED", -- 706
			version = version, -- 706
			message = preview ~= "" and preview or "Agent exited with code " .. tostring(probe.exitCode) -- 706
		}) -- 706
	end -- 706
	local fingerprint = (((config.provider .. ":") .. config.executable) .. ":") .. encodeJson(config.extraArgs) -- 708
	DB:exec( -- 709
		("UPDATE " .. CONFIG_TABLE) .. " SET verified_at=?,verified_version=?,verified_fingerprint=?,updated_at=? WHERE id=?", -- 709
		{ -- 709
			os.time(), -- 709
			version, -- 709
			fingerprint, -- 709
			os.time(), -- 709
			config.id -- 709
		} -- 709
	) -- 709
	return finish({ -- 710
		success = true, -- 710
		version = version, -- 710
		verifiedAt = os.time() -- 710
	}) -- 710
end -- 682
return ____exports -- 682