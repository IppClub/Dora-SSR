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
local SKILL_VERSION = 6 -- 39
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
	return ("---\nname: dora-engine-coding\ndescription: Build and validate games for the Dora SSR engine using the local Dora CLI.\n---\n" .. SKILL_MARKER) .. "\n\n# Dora Engine coding\n\nWork inside the current Dora project. Dora games run in the Dora runtime, not a browser or Node.js: do not generate DOM, Canvas, browser-only, or Node-only runtime code.\n\n- Dora injects a project-scoped `dora` command into this Agent process. Use `dora cli` directly; do not search for Dora, create aliases, or guess installation paths.\n- Inspect the project before editing. The usual entry is `init.lua`, `init.ts`, `init.yue`, or another project entry selected by the user.\n- When naming a game, use the `atompie-submission` skill to configure its launcher title and cover. At project handoff, generate or update a player-facing README.md beside the game entry from verified gameplay, controls and launch steps. Preserve the author's existing text. AtomPie imports the README as its detailed description; authors choose tags.\n- Do not guess Dora APIs. Use `dora cli doc search <query>` and `dora cli doc read <name>` to verify them.\n- Edit source files with your own file tools. TypeScript is transpiled to Lua by Dora; keep imports compatible with the Dora module declarations.\n- Validate compilation with `dora cli build <path>`.\n- Inspect the engine with `dora cli agent status -p <project>` and logs with `dora cli agent log -n 200`.\n- Run a controlled game check with `dora cli agent preview -p <project> --entry init.lua --capture-at 0.5,2`. Preview requests are FIFO and can interrupt a user-run game because Agent validation has priority.\n- Treat stdout from `dora cli agent` as one JSON result. stderr is diagnostic output.\n- `dora cli agent` only accesses engine tools. It never starts Dora Agent or another third-party Agent; do not construct nested Agent scheduling.\n\nFinish by reporting the files changed and the exact build/preview evidence you obtained.\n"
end -- 114
local function ensureTables() -- 140
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. CONFIG_TABLE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tname TEXT NOT NULL,\n\t\tprovider TEXT NOT NULL,\n\t\texecutable TEXT NOT NULL,\n\t\textra_args TEXT NOT NULL DEFAULT '[]',\n\t\tverified_at INTEGER,\n\t\tverified_version TEXT NOT NULL DEFAULT '',\n\t\tverified_fingerprint TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t)") -- 141
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. SESSION_TABLE) .. "(\n\t\tdora_session_id INTEGER PRIMARY KEY,\n\t\tconfig_id INTEGER NOT NULL,\n\t\tprovider TEXT NOT NULL,\n\t\tresume_id TEXT NOT NULL DEFAULT '',\n\t\tgeneration INTEGER NOT NULL DEFAULT 1,\n\t\tabandoned_at INTEGER,\n\t\tupdated_at INTEGER NOT NULL\n\t)") -- 153
end -- 140
local function rowToConfig(row) -- 164
	local provider = tostring(row[3]) -- 165
	if provider ~= "opencode" and provider ~= "codex" and provider ~= "zcode" and provider ~= "claude-code" then -- 165
		return nil -- 166
	end -- 166
	local ____safeJsonDecode_2 = safeJsonDecode -- 167
	local ____tostring_1 = tostring -- 167
	local ____row__5_0 = row[5] -- 167
	if ____row__5_0 == nil then -- 167
		____row__5_0 = "[]" -- 167
	end -- 167
	local decoded = ____safeJsonDecode_2(____tostring_1(____row__5_0)) -- 167
	local extraArgs = __TS__ArrayIsArray(decoded) and __TS__ArrayFilter( -- 168
		decoded, -- 168
		function(____, value) return type(value) == "string" end -- 168
	) or ({}) -- 168
	local verifiedAt = tonumber(row[6]) -- 169
	local ____temp_13 = tonumber(row[1]) or 0 -- 171
	local ____tostring_result_14 = tostring(row[2]) -- 172
	local ____provider_15 = provider -- 173
	local ____tostring_result_16 = tostring(row[4]) -- 174
	local ____extraArgs_17 = extraArgs -- 175
	local ____temp_18 = verifiedAt and verifiedAt > 0 and verifiedAt or nil -- 176
	local ____temp_7 -- 177
	local ____tostring_4 = tostring -- 177
	local ____row__7_3 = row[7] -- 177
	if ____row__7_3 == nil then -- 177
		____row__7_3 = "" -- 177
	end -- 177
	if ____tostring_4(____row__7_3) ~= "" then -- 177
		local ____tostring_6 = tostring -- 177
		local ____row__7_5 = row[7] -- 177
		if ____row__7_5 == nil then -- 177
			____row__7_5 = "" -- 177
		end -- 177
		____temp_7 = ____tostring_6(____row__7_5) -- 177
	else -- 177
		____temp_7 = nil -- 177
	end -- 177
	local ____temp_12 -- 178
	local ____tostring_9 = tostring -- 178
	local ____row__8_8 = row[8] -- 178
	if ____row__8_8 == nil then -- 178
		____row__8_8 = "" -- 178
	end -- 178
	if ____tostring_9(____row__8_8) ~= "" then -- 178
		local ____tostring_11 = tostring -- 178
		local ____row__8_10 = row[8] -- 178
		if ____row__8_10 == nil then -- 178
			____row__8_10 = "" -- 178
		end -- 178
		____temp_12 = ____tostring_11(____row__8_10) -- 178
	else -- 178
		____temp_12 = nil -- 178
	end -- 178
	return { -- 170
		id = ____temp_13, -- 171
		name = ____tostring_result_14, -- 172
		provider = ____provider_15, -- 173
		executable = ____tostring_result_16, -- 174
		extraArgs = ____extraArgs_17, -- 175
		verifiedAt = ____temp_18, -- 176
		verifiedVersion = ____temp_7, -- 177
		verifiedFingerprint = ____temp_12 -- 178
	} -- 178
end -- 164
function ____exports.isLocalAgentSupported() -- 182
	return __TS__ArrayIncludes(supportedPlatforms, App.platform) -- 183
end -- 182
function ____exports.listConfigs() -- 186
	ensureTables() -- 187
	local rows = DB:query(("SELECT id,name,provider,executable,extra_args,verified_at,verified_version,verified_fingerprint FROM " .. CONFIG_TABLE) .. " ORDER BY id") or ({}) -- 188
	local result = {} -- 189
	do -- 189
		local i = 0 -- 190
		while i < #rows do -- 190
			local config = rowToConfig(rows[i + 1]) -- 191
			if config then -- 191
				result[#result + 1] = config -- 192
			end -- 192
			i = i + 1 -- 190
		end -- 190
	end -- 190
	return result -- 194
end -- 186
function ____exports.getConfig(id) -- 197
	local configId = tonumber(id) -- 198
	local ____configId_19 -- 199
	if configId then -- 199
		____configId_19 = __TS__ArrayFind( -- 199
			____exports.listConfigs(), -- 199
			function(____, item) return item.id == configId end -- 199
		) -- 199
	else -- 199
		____configId_19 = nil -- 199
	end -- 199
	return ____configId_19 -- 199
end -- 197
local function normalizeProvider(value) -- 202
	return (value == "opencode" or value == "codex" or value == "zcode" or value == "claude-code") and value or nil -- 203
end -- 202
local function normalizeArgs(value) -- 206
	if not __TS__ArrayIsArray(value) then -- 206
		return {} -- 207
	end -- 207
	return __TS__ArrayMap( -- 208
		__TS__ArrayFilter( -- 208
			value, -- 208
			function(____, item) return type(item) == "string" end -- 208
		), -- 208
		function(____, item) return sanitizeUTF8(item) end -- 208
	) -- 208
end -- 206
function ____exports.saveConfig(input) -- 211
	ensureTables() -- 212
	local provider = normalizeProvider(input.provider) -- 213
	local name = type(input.name) == "string" and __TS__StringTrim(sanitizeUTF8(input.name)) or "" -- 214
	local executable = type(input.executable) == "string" and __TS__StringTrim(sanitizeUTF8(input.executable)) or "" -- 215
	if not provider or name == "" or executable == "" then -- 215
		return {success = false, message = "invalid local Agent config"} -- 216
	end -- 216
	local extraArgs = normalizeArgs(input.extraArgs) -- 217
	local encodedArgs = encodeJson(extraArgs) -- 218
	local id = tonumber(input.id) -- 219
	local t = os.time() -- 220
	if id and id > 0 then -- 220
		local old = ____exports.getConfig(id) -- 222
		if not old then -- 222
			return {success = false, message = "local Agent config not found"} -- 223
		end -- 223
		local changed = old.provider ~= provider or old.executable ~= executable or encodeJson(old.extraArgs) ~= encodedArgs -- 224
		DB:exec(("UPDATE " .. CONFIG_TABLE) .. " SET name=?,provider=?,executable=?,extra_args=?,verified_at=?,verified_version=?,verified_fingerprint=?,updated_at=? WHERE id=?", { -- 225
			name, -- 226
			provider, -- 226
			executable, -- 226
			encodedArgs, -- 226
			changed and 0 or (old.verifiedAt or 0), -- 227
			changed and "" or (old.verifiedVersion or ""), -- 228
			changed and "" or (old.verifiedFingerprint or ""), -- 229
			t, -- 230
			id -- 230
		}) -- 230
		return {success = true, id = id} -- 232
	end -- 232
	DB:exec(("INSERT INTO " .. CONFIG_TABLE) .. "(name,provider,executable,extra_args,created_at,updated_at) VALUES(?,?,?,?,?,?)", { -- 234
		name, -- 234
		provider, -- 234
		executable, -- 234
		encodedArgs, -- 234
		t, -- 234
		t -- 234
	}) -- 234
	local rows = DB:query("SELECT last_insert_rowid()") or ({}) -- 235
	local ____tonumber_22 = tonumber -- 236
	local ____opt_20 = rows[1] -- 236
	return { -- 236
		success = true, -- 236
		id = ____tonumber_22(____opt_20 and ____opt_20[1]) or 0 -- 236
	} -- 236
end -- 211
function ____exports.deleteConfig(id) -- 239
	ensureTables() -- 240
	local configId = tonumber(id) -- 241
	if not configId then -- 241
		return {success = false, message = "invalid local Agent config id"} -- 242
	end -- 242
	DB:exec(("DELETE FROM " .. CONFIG_TABLE) .. " WHERE id=?", {configId}) -- 243
	return {success = true} -- 244
end -- 239
local function buildSpec(config, cwd, prompt, resumeId) -- 249
	local args -- 250
	if config.provider == "codex" then -- 250
		local ____resumeId_25 -- 252
		if resumeId then -- 252
			local ____array_23 = __TS__SparseArrayNew( -- 252
				"exec", -- 253
				"resume", -- 253
				"--json",
				"--dangerously-bypass-approvals-and-sandbox",
				table.unpack(config.extraArgs) -- 253
			) -- 253
			__TS__SparseArrayPush(____array_23, resumeId, prompt) -- 253
			____resumeId_25 = {__TS__SparseArraySpread(____array_23)} -- 253
		else -- 253
			local ____array_24 = __TS__SparseArrayNew( -- 253
				"exec", -- 254
				"--json",
				"--dangerously-bypass-approvals-and-sandbox",
				"-C", -- 254
				cwd, -- 254
				table.unpack(config.extraArgs) -- 254
			) -- 254
			__TS__SparseArrayPush(____array_24, prompt) -- 254
			____resumeId_25 = {__TS__SparseArraySpread(____array_24)} -- 254
		end -- 254
		args = ____resumeId_25 -- 252
	elseif config.provider == "claude-code" then -- 252
		args = { -- 256
			"-p", -- 256
			"--output-format",
			"stream-json", -- 256
			"--verbose",
			"--dangerously-skip-permissions",
			table.unpack(config.extraArgs) -- 256
		} -- 256
		if resumeId then -- 256
			__TS__ArrayPush(args, "--resume", resumeId)
		end -- 257
		args[#args + 1] = prompt -- 258
	elseif config.provider == "opencode" then -- 258
		args = { -- 260
			"run", -- 260
			"--format",
			"json", -- 260
			"--auto",
			"--dir",
			cwd, -- 260
			table.unpack(config.extraArgs) -- 260
		} -- 260
		if resumeId then -- 260
			__TS__ArrayPush(args, "--session", resumeId)
		end -- 261
		args[#args + 1] = prompt -- 262
	else -- 262
		args = { -- 264
			"--prompt",
			prompt, -- 264
			"--json",
			"--mode",
			"yolo", -- 264
			"--cwd",
			cwd, -- 264
			table.unpack(config.extraArgs) -- 264
		} -- 264
		if resumeId then -- 264
			__TS__ArrayPush(args, "--resume", resumeId)
		end -- 265
	end -- 265
	return {program = config.executable, args = args, cwd = cwd} -- 267
end -- 249
local function getString(record, ...) -- 270
	local keys = {...} -- 270
	do -- 270
		local i = 0 -- 271
		while i < #keys do -- 271
			local value = record[keys[i + 1]] -- 272
			if type(value) == "string" and value ~= "" then -- 272
				return value -- 273
			end -- 273
			i = i + 1 -- 271
		end -- 271
	end -- 271
	return nil -- 275
end -- 270
local function getClaudeBlockText(value) -- 278
	if type(value) == "string" and value ~= "" then -- 278
		return value -- 279
	end -- 279
	if not __TS__ArrayIsArray(value) then -- 279
		return nil -- 280
	end -- 280
	local parts = {} -- 281
	do -- 281
		local i = 0 -- 282
		while i < #value do -- 282
			local block = value[i + 1] -- 283
			if type(block) == "string" and block ~= "" then -- 283
				parts[#parts + 1] = block -- 284
			elseif block and type(block) == "table" then -- 284
				local text = getString(block, "text", "content") -- 286
				if text then -- 286
					parts[#parts + 1] = text -- 287
				end -- 287
			end -- 287
			i = i + 1 -- 282
		end -- 282
	end -- 282
	return #parts > 0 and table.concat(parts, "\n") or nil -- 290
end -- 278
local function parseRecord(provider, record) -- 293
	local events = {} -- 294
	local eventType = getString(record, "type", "event", "kind") or "activity" -- 295
	local resumeId = getString( -- 296
		record, -- 296
		"thread_id", -- 296
		"threadId", -- 296
		"session_id", -- 296
		"sessionId", -- 296
		"sessionID" -- 296
	) -- 296
	local item = record.item -- 297
	if item and type(item) == "table" then -- 297
		local itemRecord = item -- 299
		resumeId = resumeId or getString( -- 300
			itemRecord, -- 300
			"thread_id", -- 300
			"session_id", -- 300
			"sessionId", -- 300
			"sessionID" -- 300
		) -- 300
		local itemType = getString(itemRecord, "type", "kind") or eventType -- 301
		local handledTool = false -- 302
		if provider == "codex" and itemType == "mcp_tool_call" then -- 302
			local server = getString(itemRecord, "server") or "mcp" -- 304
			local tool = getString(itemRecord, "tool") or "tool" -- 305
			local status = getString(itemRecord, "status") or eventType -- 306
			local details = {((((server .. ".") .. tool) .. " (") .. status) .. ")"} -- 307
			if itemRecord.arguments ~= nil then -- 307
				details[#details + 1] = "arguments: " .. encodeJson(itemRecord.arguments) -- 308
			end -- 308
			if itemRecord.result ~= nil then -- 308
				details[#details + 1] = "result:\n" .. (type(itemRecord.result) == "string" and itemRecord.result or encodeJson(itemRecord.result)) -- 309
			end -- 309
			if itemRecord.error ~= nil then -- 309
				details[#details + 1] = "error:\n" .. (type(itemRecord.error) == "string" and itemRecord.error or encodeJson(itemRecord.error)) -- 310
			end -- 310
			events[#events + 1] = { -- 311
				kind = "command", -- 311
				text = table.concat(details, "\n"), -- 311
				resumeId = resumeId, -- 311
				raw = record -- 311
			} -- 311
			handledTool = true -- 312
		end -- 312
		if not handledTool then -- 312
			local text = getString( -- 315
				itemRecord, -- 315
				"text", -- 315
				"content", -- 315
				"message", -- 315
				"command", -- 315
				"aggregated_output" -- 315
			) -- 315
			if text then -- 315
				local kind = (__TS__StringIncludes(itemType, "agent") or __TS__StringIncludes(itemType, "text") or __TS__StringIncludes(itemType, "message")) and "assistant" or ((__TS__StringIncludes(itemType, "command") or __TS__StringIncludes(itemType, "tool")) and "command" or "activity") -- 317
				events[#events + 1] = {kind = kind, text = text, resumeId = resumeId, raw = record} -- 319
			end -- 319
		end -- 319
	end -- 319
	local message = record.message -- 323
	if provider == "claude-code" and message and type(message) == "table" then -- 323
		local content = message.content -- 325
		if __TS__ArrayIsArray(content) then -- 325
			do -- 325
				local i = 0 -- 327
				while i < #content do -- 327
					do -- 327
						local block = content[i + 1] -- 328
						if not block or type(block) ~= "table" then -- 328
							goto __continue70 -- 329
						end -- 329
						local blockRecord = block -- 330
						local blockType = getString(blockRecord, "type") or "" -- 331
						if blockType == "text" then -- 331
							local text = getString(blockRecord, "text") -- 333
							if text then -- 333
								events[#events + 1] = {kind = "assistant", text = text, resumeId = resumeId, raw = record} -- 334
							end -- 334
						elseif blockType == "tool_use" then -- 334
							local name = getString(blockRecord, "name") or "tool" -- 336
							local details = {name} -- 337
							if blockRecord.input ~= nil then -- 337
								details[#details + 1] = "input: " .. encodeJson(blockRecord.input) -- 338
							end -- 338
							events[#events + 1] = { -- 339
								kind = "command", -- 339
								text = table.concat(details, "\n"), -- 339
								resumeId = resumeId, -- 339
								raw = record -- 339
							} -- 339
						elseif blockType == "tool_result" then -- 339
							local text = getClaudeBlockText(blockRecord.content) or encodeJson(blockRecord.content) -- 341
							events[#events + 1] = {kind = "command", text = "tool result" .. (text ~= nil and text ~= "" and "\n" .. text or ""), resumeId = resumeId, raw = record} -- 342
						end -- 342
					end -- 342
					::__continue70:: -- 342
					i = i + 1 -- 327
				end -- 327
			end -- 327
		end -- 327
	end -- 327
	local part = record.part -- 347
	if part and type(part) == "table" then -- 347
		local partRecord = part -- 349
		resumeId = resumeId or getString(partRecord, "sessionID", "sessionId", "session_id") -- 350
		local handledTool = false -- 351
		if provider == "opencode" and eventType == "tool_use" and partRecord.state and type(partRecord.state) == "table" then -- 351
			local state = partRecord.state -- 353
			local tool = getString(partRecord, "tool") or "tool" -- 354
			local status = getString(state, "status") -- 355
			local details = {tool .. (status and (" (" .. status) .. ")" or "")} -- 356
			if state.input and type(state.input) == "table" then -- 356
				details[#details + 1] = "input: " .. encodeJson(state.input) -- 357
			end -- 357
			local output = getString(state, "output") -- 358
			if output then -- 358
				details[#details + 1] = "output:\n" .. output -- 359
			end -- 359
			events[#events + 1] = { -- 360
				kind = "command", -- 360
				text = table.concat(details, "\n"), -- 360
				resumeId = resumeId, -- 360
				raw = record -- 360
			} -- 360
			handledTool = true -- 361
		end -- 361
		if not handledTool then -- 361
			local text = getString( -- 364
				partRecord, -- 364
				"text", -- 364
				"content", -- 364
				"message", -- 364
				"command" -- 364
			) -- 364
			if text then -- 364
				events[#events + 1] = { -- 365
					kind = __TS__StringIncludes(eventType, "tool") and "command" or "assistant", -- 365
					text = text, -- 365
					resumeId = resumeId, -- 365
					raw = record -- 365
				} -- 365
			end -- 365
		end -- 365
	end -- 365
	local text = getString( -- 368
		record, -- 368
		"text", -- 368
		"content", -- 368
		"message", -- 368
		"output", -- 368
		"result", -- 368
		"response" -- 368
	) -- 368
	if text and #events == 0 then -- 368
		local kind = (provider == "zcode" and type(record.response) == "string" or provider == "claude-code" and eventType == "result") and "assistant" or ((__TS__StringIncludes(eventType, "command") or __TS__StringIncludes(eventType, "tool")) and "command" or ((__TS__StringIncludes(eventType, "assistant") or __TS__StringIncludes(eventType, "message") or __TS__StringIncludes(eventType, "text")) and "assistant" or "activity")) -- 370
		events[#events + 1] = {kind = kind, text = text, resumeId = resumeId, raw = record} -- 373
	end -- 373
	if resumeId and #events == 0 then -- 373
		events[#events + 1] = {kind = "status", text = (provider .. " session ") .. resumeId, resumeId = resumeId, raw = record} -- 375
	end -- 375
	return events -- 376
end -- 293
local function parseLines(provider, buffer, onEvent) -- 379
	local lines = __TS__StringSplit(buffer, "\n") -- 380
	local rest = table.remove(lines) or "" -- 381
	do -- 381
		local i = 0 -- 382
		while i < #lines do -- 382
			do -- 382
				local line = __TS__StringTrim(sanitizeUTF8(lines[i + 1])) -- 383
				if line == "" then -- 383
					goto __continue87 -- 384
				end -- 384
				local decoded = safeJsonDecode(line) -- 385
				if decoded and type(decoded) == "table" and not __TS__ArrayIsArray(decoded) then -- 385
					local events = parseRecord(provider, decoded) -- 387
					if #events > 0 then -- 387
						do -- 387
							local e = 0 -- 388
							while e < #events do -- 388
								onEvent(events[e + 1]) -- 388
								e = e + 1 -- 388
							end -- 388
						end -- 388
					else -- 388
						onEvent({kind = "activity", text = line, raw = decoded}) -- 389
					end -- 389
				else -- 389
					onEvent({kind = "activity", text = line}) -- 391
				end -- 391
			end -- 391
			::__continue87:: -- 391
			i = i + 1 -- 382
		end -- 382
	end -- 382
	return rest -- 394
end -- 379
local function parseCompleteOutput(provider, output, onEvent) -- 397
	local text = __TS__StringTrim(sanitizeUTF8(output)) -- 398
	if text == "" then -- 398
		return -- 399
	end -- 399
	local decoded = safeJsonDecode(text) -- 400
	if decoded and type(decoded) == "table" and not __TS__ArrayIsArray(decoded) then -- 400
		local events = parseRecord(provider, decoded) -- 402
		if #events > 0 then -- 402
			do -- 402
				local i = 0 -- 404
				while i < #events do -- 404
					onEvent(events[i + 1]) -- 404
					i = i + 1 -- 404
				end -- 404
			end -- 404
			return -- 405
		end -- 405
	end -- 405
	parseLines(provider, text .. "\n", onEvent) -- 408
end -- 397
local function loadManagedSkills() -- 417
	local sourceRoot = Path(Content.assetPath, "Doc", "local-agent-skills") -- 418
	local commandContent = Content:load(Path(sourceRoot, "dora-agent-command", "SKILL.md")) -- 419
	local musicContent = Content:load(Path(sourceRoot, "music-generation", "SKILL.md")) -- 420
	local submissionContent = Content:load(Path( -- 421
		Content.assetPath, -- 421
		"Doc", -- 421
		"skills", -- 421
		"atompie-submission", -- 421
		"SKILL.md" -- 421
	)) -- 421
	if commandContent == "" or musicContent == "" or submissionContent == "" then -- 421
		return nil -- 422
	end -- 422
	return { -- 423
		{ -- 424
			name = "dora-engine-coding", -- 424
			content = buildSkillContent() -- 424
		}, -- 424
		{name = "dora-agent-command", content = commandContent}, -- 425
		{name = "atompie-submission", content = submissionContent}, -- 426
		{ -- 427
			name = "music-generation", -- 428
			content = musicContent, -- 429
			resources = { -- 430
				{ -- 431
					source = Path( -- 431
						Content.assetPath, -- 431
						"Script", -- 431
						"Lib", -- 431
						"Agent", -- 431
						"Gen", -- 431
						"Music.d.ts" -- 431
					), -- 431
					target = Path("references", "Music.d.ts") -- 431
				}, -- 431
				{ -- 432
					source = Path( -- 432
						Content.assetPath, -- 432
						"Doc", -- 432
						"skills", -- 432
						"music-generation", -- 432
						"GeneralUserGS-Presets.md" -- 432
					), -- 432
					target = Path("references", "GeneralUserGS-Presets.md") -- 432
				} -- 432
			} -- 432
		} -- 432
	} -- 432
end -- 417
local function installSkill(projectRoot, provider, skill) -- 438
	local dir = provider == "claude-code" and Path(projectRoot, ".claude", "skills", skill.name) or Path(projectRoot, ".agents", "skills", skill.name) -- 439
	local target = Path(dir, "SKILL.md") -- 442
	local targetExisted = Content:exist(target) -- 443
	if targetExisted then -- 443
		local existing = Content:load(target) -- 445
		if not __TS__StringIncludes(existing, "<!-- dora-managed-skill:v") and not __TS__StringIncludes(existing, MANAGED_SKILL_MARKER) then
			return {success = true, state = "custom", message = ("custom " .. skill.name) .. " skill preserved"} -- 447
		end -- 447
	end -- 447
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 447
		return {success = false, state = "failed", message = "failed to create Dora skill directory"} -- 450
	end -- 450
	local temp = target .. ".tmp" -- 451
	if not Content:save(temp, skill.content) or not Content:move(temp, target) then -- 451
		if Content:exist(temp) then -- 451
			Content:remove(temp) -- 453
		end -- 453
		return {success = false, state = "failed", message = ("failed to install " .. skill.name) .. " skill"} -- 454
	end -- 454
	for ____, resource in ipairs(skill.resources or ({})) do -- 456
		local content = Content:load(resource.source) -- 457
		if content == "" then -- 457
			return {success = false, state = "failed", message = (("failed to load " .. skill.name) .. " resource ") .. resource.source} -- 458
		end -- 458
		local resourceTarget = Path(dir, resource.target) -- 459
		local resourceDir = Path:getPath(resourceTarget) -- 460
		if not Content:exist(resourceDir) and not Content:mkdir(resourceDir) then -- 460
			return {success = false, state = "failed", message = ("failed to create " .. skill.name) .. " resource directory"} -- 461
		end -- 461
		local resourceTemp = resourceTarget .. ".tmp" -- 462
		if not Content:save(resourceTemp, content) or not Content:move(resourceTemp, resourceTarget) then -- 462
			if Content:exist(resourceTemp) then -- 462
				Content:remove(resourceTemp) -- 464
			end -- 464
			return {success = false, state = "failed", message = ("failed to install " .. skill.name) .. " resource"} -- 465
		end -- 465
	end -- 465
	return {success = true, state = targetExisted and "current" or "installed"} -- 468
end -- 438
local function ensureSkills(projectRoot, provider) -- 471
	local skills = loadManagedSkills() -- 472
	if not skills then -- 472
		return {success = false, message = "failed to load Dora local Agent skills"} -- 473
	end -- 473
	for ____, skill in ipairs(skills) do -- 474
		local result = installSkill(projectRoot, provider, skill) -- 475
		if not result.success then -- 475
			return result -- 476
		end -- 476
	end -- 476
	return {success = true} -- 478
end -- 471
local function getExternalSession(doraSessionId, config) -- 481
	ensureTables() -- 482
	local rows = DB:query(("SELECT config_id,provider,resume_id,generation FROM " .. SESSION_TABLE) .. " WHERE dora_session_id=?", {doraSessionId}) or ({}) -- 483
	if #rows > 0 and tonumber(rows[1][1]) == config.id and tostring(rows[1][2]) == config.provider then -- 483
		local storedResumeId = tostring(rows[1][3]) -- 485
		return { -- 486
			resumeId = storedResumeId ~= "" and storedResumeId or nil, -- 486
			generation = tonumber(rows[1][4]) or 1 -- 486
		} -- 486
	end -- 486
	DB:exec( -- 488
		("INSERT INTO " .. SESSION_TABLE) .. "(dora_session_id,config_id,provider,resume_id,generation,updated_at) VALUES(?,?,?,?,1,?) ON CONFLICT(dora_session_id) DO UPDATE SET config_id=excluded.config_id,provider=excluded.provider,resume_id='',generation=generation+1,abandoned_at=?,updated_at=excluded.updated_at", -- 488
		{ -- 488
			doraSessionId, -- 488
			config.id, -- 488
			config.provider, -- 488
			"", -- 488
			os.time(), -- 488
			os.time() -- 488
		} -- 488
	) -- 488
	return {generation = 1} -- 489
end -- 481
local function saveResumeId(doraSessionId, config, resumeId) -- 492
	DB:exec( -- 493
		("UPDATE " .. SESSION_TABLE) .. " SET resume_id=?,updated_at=? WHERE dora_session_id=? AND config_id=?", -- 493
		{ -- 493
			resumeId, -- 493
			os.time(), -- 493
			doraSessionId, -- 493
			config.id -- 493
		} -- 493
	) -- 493
end -- 492
local function isMissingExternalSession(text) -- 496
	local lower = string.lower(text) -- 497
	return __TS__StringIncludes(lower, "session not found") or __TS__StringIncludes(lower, "thread not found") or __TS__StringIncludes(lower, "unknown session") or __TS__StringIncludes(lower, "invalid session") or __TS__StringIncludes(lower, "no conversation found") -- 498
end -- 496
function ____exports.abandonSession(doraSessionId) -- 505
	ensureTables() -- 506
	local id = tonumber(doraSessionId) -- 507
	if not id then -- 507
		return {success = false, message = "invalid Dora session id"} -- 508
	end -- 508
	DB:exec( -- 509
		("UPDATE " .. SESSION_TABLE) .. " SET resume_id='',generation=generation+1,abandoned_at=?,updated_at=? WHERE dora_session_id=?", -- 509
		{ -- 509
			os.time(), -- 509
			os.time(), -- 509
			id -- 509
		} -- 509
	) -- 509
	return {success = true} -- 510
end -- 505
function ____exports.getSessionInfo(doraSessionId) -- 513
	ensureTables() -- 514
	local id = tonumber(doraSessionId) -- 515
	if not id then -- 515
		return nil -- 516
	end -- 516
	local rows = DB:query(("SELECT config_id,provider,resume_id,generation,abandoned_at,updated_at FROM " .. SESSION_TABLE) .. " WHERE dora_session_id=?", {id}) or ({}) -- 517
	if #rows == 0 then -- 517
		return nil -- 518
	end -- 518
	return { -- 519
		configId = rows[1][1], -- 519
		provider = rows[1][2], -- 519
		resumeId = rows[1][3], -- 519
		generation = rows[1][4], -- 519
		abandonedAt = rows[1][5], -- 519
		updatedAt = rows[1][6] -- 519
	} -- 519
end -- 513
function ____exports.run(doraSessionId, config, projectRoot, prompt, onEvent, onDone) -- 522
	local stopRequested = false -- 530
	local handle -- 531
	local skills = ensureSkills(projectRoot, config.provider) -- 532
	if not skills.success then -- 532
		onDone({success = false, exitCode = -1, message = skills.message or "failed to install Dora skills"}) -- 534
		return {stop = function(self) -- 535
			stopRequested = true -- 535
		end} -- 535
	end -- 535
	local external = getExternalSession(doraSessionId, config) -- 537
	onEvent({kind = "status", text = config.provider == "zcode" and ((("Started " .. config.name) .. " (") .. config.provider) .. "); its CLI returns the structured message when the task completes" or ((("Started " .. config.name) .. " (") .. config.provider) .. ")"}) -- 538
	local monitorHost = Node() -- 546
	monitorHost:addTo(Director.systemUI) -- 547
	local function finish(result) -- 548
		onDone(result) -- 549
		monitorHost:removeFromParent(false) -- 550
	end -- 548
	monitorHost:once(function() -- 552
		local doraCommand = prepareDoraCommandEnvironment() -- 553
		if not doraCommand then -- 553
			finish({success = false, exitCode = -1, message = "failed to resolve Dora executable or Asset path"}) -- 555
			return -- 556
		end -- 556
		if not doraCommand.shim then -- 556
			onEvent({kind = "status", text = "Dora command shim was unavailable; using the absolute Dora CLI command for this turn"}) -- 558
		end -- 558
		local resumeId = external.resumeId -- 559
		local retriedMissingSession = false -- 560
		while true do -- 560
			local commandPrompt = doraCommand.shim and "Dora CLI is available in this Agent environment as `dora cli`.\n\n" .. prompt or (("For this turn, invoke Dora CLI only with this exact prefix (do not use a bare dora command):\n" .. doraCommand.command) .. "\n\n") .. prompt -- 562
			local skillPrompt = "Dora project skills available: dora-engine-coding, dora-agent-command, music-generation. Read the relevant skill before using Dora engine commands or generating music.\n\n" .. commandPrompt -- 565
			local spec = buildSpec(config, projectRoot, skillPrompt, resumeId) -- 566
			spec.env = doraCommand.env -- 567
			handle = Process:spawn(spec) -- 568
			if handle == nil then -- 568
				finish({success = false, exitCode = -1, message = "failed to start " .. config.executable}) -- 570
				return -- 571
			end -- 571
			Process:write(handle) -- 573
			local stdoutOffset = 0 -- 574
			local stderrOffset = 0 -- 575
			local stdoutBuffer = "" -- 576
			local stderrBuffer = "" -- 577
			local diagnostic = "" -- 578
			local lastActivity = App.runningTime -- 579
			local startedAt = App.runningTime -- 580
			local lastProgressNotice = App.runningTime -- 581
			local retryFresh = false -- 582
			local protocolFailure -- 583
			local function emitEvent(event) -- 584
				local ____temp_28 = config.provider == "claude-code" -- 585
				if ____temp_28 then -- 585
					local ____opt_26 = event.raw -- 585
					____temp_28 = (____opt_26 and ____opt_26.type) == "result" -- 585
				end -- 585
				if ____temp_28 and event.raw.is_error == true then -- 585
					protocolFailure = getString(event.raw, "result", "subtype") or "Claude Code reported an error" -- 586
				end -- 586
				if event.resumeId and event.resumeId ~= resumeId then -- 586
					resumeId = event.resumeId -- 589
					saveResumeId(doraSessionId, config, resumeId) -- 590
				end -- 590
				onEvent(event) -- 592
			end -- 584
			while true do -- 584
				local chunk = Process:read(handle, stdoutOffset, stderrOffset) -- 595
				stdoutOffset = chunk.stdoutOffset -- 596
				stderrOffset = chunk.stderrOffset -- 597
				if chunk.stdout ~= "" then -- 597
					lastActivity = App.runningTime -- 599
					diagnostic = string.sub(diagnostic .. chunk.stdout, -32768) -- 600
					stdoutBuffer = config.provider == "zcode" and stdoutBuffer .. chunk.stdout or parseLines(config.provider, stdoutBuffer .. chunk.stdout, emitEvent) -- 601
				end -- 601
				if chunk.stderr ~= "" then -- 601
					lastActivity = App.runningTime -- 606
					diagnostic = string.sub(diagnostic .. chunk.stderr, -32768) -- 607
					stderrBuffer = stderrBuffer .. chunk.stderr -- 608
					local lines = __TS__StringSplit(stderrBuffer, "\n") -- 609
					stderrBuffer = table.remove(lines) or "" -- 610
					do -- 610
						local i = 0 -- 611
						while i < #lines do -- 611
							if __TS__StringTrim(lines[i + 1]) ~= "" then -- 611
								onEvent({ -- 611
									kind = "stderr", -- 611
									text = sanitizeUTF8(lines[i + 1]) -- 611
								}) -- 611
							end -- 611
							i = i + 1 -- 611
						end -- 611
					end -- 611
				end -- 611
				if not chunk.running then -- 611
					if __TS__StringTrim(stdoutBuffer) ~= "" then -- 611
						parseCompleteOutput(config.provider, stdoutBuffer, emitEvent) -- 614
					end -- 614
					if __TS__StringTrim(stderrBuffer) ~= "" then -- 614
						onEvent({ -- 615
							kind = "stderr", -- 615
							text = sanitizeUTF8(stderrBuffer) -- 615
						}) -- 615
					end -- 615
					local exitCode = chunk.exit.exitCode or -1 -- 616
					Process:destroy(handle) -- 617
					handle = nil -- 618
					local failureText = protocolFailure or diagnostic -- 619
					if (exitCode ~= 0 or protocolFailure ~= nil) and external.resumeId and not retriedMissingSession and isMissingExternalSession(failureText) then -- 619
						retriedMissingSession = true -- 621
						resumeId = nil -- 622
						saveResumeId(doraSessionId, config, "") -- 623
						onEvent({kind = "status", text = "Stored local Agent session is unavailable; retrying once with a new session"}) -- 624
						retryFresh = true -- 625
						break -- 626
					end -- 626
					local success = exitCode == 0 and protocolFailure == nil and not stopRequested -- 628
					finish({ -- 629
						success = success, -- 629
						exitCode = exitCode, -- 629
						message = protocolFailure or (exitCode == 0 and "completed" or "local Agent exited with code " .. tostring(exitCode)), -- 629
						resumeId = resumeId, -- 629
						stopped = stopRequested -- 629
					}) -- 629
					return -- 630
				end -- 630
				if stopRequested then -- 630
					Process:stop(handle, "interrupt") -- 633
					sleep(1.5) -- 634
					local after = Process:read(handle, stdoutOffset, stderrOffset) -- 635
					if after.running then -- 635
						Process:stop(handle, "kill-tree") -- 636
					end -- 636
				end -- 636
				if config.provider == "zcode" and App.runningTime - lastProgressNotice >= 30 then -- 636
					lastProgressNotice = App.runningTime -- 639
					local elapsed = math.floor(App.runningTime - startedAt) -- 640
					onEvent({ -- 641
						kind = "status", -- 641
						text = ("ZCode is still running (" .. tostring(elapsed)) .. "s); waiting for its buffered response" -- 641
					}) -- 641
				end -- 641
				local inactivityTimeout = config.provider == "zcode" and 1800 or 900 -- 643
				if App.runningTime - lastActivity > inactivityTimeout then -- 643
					stopRequested = true -- 645
					onEvent({ -- 646
						kind = "stderr", -- 646
						text = ("local Agent stopped after " .. tostring(math.floor(inactivityTimeout / 60))) .. " minutes without output" -- 646
					}) -- 646
				end -- 646
				sleep(0.05) -- 648
			end -- 648
			if not retryFresh then -- 648
				return -- 650
			end -- 650
		end -- 650
	end) -- 552
	return {stop = function(self) -- 653
		stopRequested = true -- 653
		if handle ~= nil then -- 653
			Process:stop(handle, "interrupt") -- 653
		end -- 653
	end} -- 653
end -- 522
local function runProbe(config, args, cwd, timeoutSeconds) -- 656
	local handle = Process:spawn({program = config.executable, args = args, cwd = cwd}) -- 657
	if handle == nil then -- 657
		return {exitCode = -1, stdout = "", stderr = "failed to start executable"} -- 658
	end -- 658
	Process:write(handle) -- 659
	local stdoutOffset = 0 -- 660
	local stderrOffset = 0 -- 661
	local stdout = "" -- 662
	local stderr = "" -- 663
	local started = App.runningTime -- 664
	while true do -- 664
		local chunk = Process:read(handle, stdoutOffset, stderrOffset) -- 666
		stdoutOffset = chunk.stdoutOffset -- 667
		stderrOffset = chunk.stderrOffset -- 668
		stdout = stdout .. chunk.stdout -- 669
		stderr = stderr .. chunk.stderr -- 670
		if not chunk.running then -- 670
			local exitCode = chunk.exit.exitCode or -1 -- 672
			Process:destroy(handle) -- 673
			return {exitCode = exitCode, stdout = stdout, stderr = stderr} -- 674
		end -- 674
		if App.runningTime - started >= timeoutSeconds then -- 674
			Process:stop(handle, "kill-tree") -- 677
			Process:destroy(handle) -- 678
			return {exitCode = -1, stdout = stdout, stderr = stderr .. "\nprobe timed out"} -- 679
		end -- 679
		sleep(0.05) -- 681
	end -- 681
end -- 656
function ____exports.verifyConfig(id, projectRoot) -- 685
	if not ____exports.isLocalAgentSupported() then -- 685
		return {success = false, code = "UNSUPPORTED_PLATFORM", message = "local Agent is only available on desktop platforms"} -- 686
	end -- 686
	local config = ____exports.getConfig(id) -- 687
	if not config then -- 687
		return {success = false, code = "NOT_FOUND", message = "local Agent config not found"} -- 688
	end -- 688
	local verifyBase = type(projectRoot) == "string" and Content:exist(projectRoot) and Content:isdir(projectRoot) and projectRoot or Content.writablePath -- 689
	local cwd = Path( -- 690
		verifyBase, -- 690
		((((".dora-local-agent-verify-" .. tostring(config.id)) .. "-") .. tostring(os.time())) .. "-") .. tostring(math.floor(App.runningTime * 1000)) -- 690
	) -- 690
	if not Content:mkdir(cwd) then -- 690
		return {success = false, code = "VERIFY_SETUP_FAILED", message = "failed to create local Agent verification directory"} -- 691
	end -- 691
	local function finish(result) -- 692
		Content:remove(cwd) -- 693
		return result -- 694
	end -- 692
	local versionArgs = config.provider == "zcode" and ({"version"}) or ({"--version"})
	local versionProbe = runProbe(config, versionArgs, cwd, 15) -- 697
	if versionProbe.exitCode ~= 0 then -- 697
		local message = versionProbe.stderr ~= "" and versionProbe.stderr or (versionProbe.stdout ~= "" and versionProbe.stdout or "version probe failed") -- 699
		return finish({success = false, code = "DETECT_FAILED", message = message}) -- 700
	end -- 700
	local version = __TS__StringSplit( -- 702
		__TS__StringTrim(versionProbe.stdout ~= "" and versionProbe.stdout or versionProbe.stderr), -- 702
		"\n" -- 702
	)[1] -- 702
	local prompt = "Reply with exactly DORA_LOCAL_AGENT_OK and do not edit files or run tools." -- 703
	local spec = buildSpec(config, cwd, prompt) -- 704
	local probe = runProbe(config, spec.args, cwd, 180) -- 705
	local output = (probe.stdout .. "\n") .. probe.stderr -- 706
	if probe.exitCode ~= 0 or not __TS__StringIncludes(output, "DORA_LOCAL_AGENT_OK") then -- 706
		local preview = string.sub(output, 1, 4000) -- 708
		return finish({ -- 709
			success = false, -- 709
			code = "VERIFY_FAILED", -- 709
			version = version, -- 709
			message = preview ~= "" and preview or "Agent exited with code " .. tostring(probe.exitCode) -- 709
		}) -- 709
	end -- 709
	local fingerprint = (((config.provider .. ":") .. config.executable) .. ":") .. encodeJson(config.extraArgs) -- 711
	DB:exec( -- 712
		("UPDATE " .. CONFIG_TABLE) .. " SET verified_at=?,verified_version=?,verified_fingerprint=?,updated_at=? WHERE id=?", -- 712
		{ -- 712
			os.time(), -- 712
			version, -- 712
			fingerprint, -- 712
			os.time(), -- 712
			config.id -- 712
		} -- 712
	) -- 712
	return finish({ -- 713
		success = true, -- 713
		version = version, -- 713
		verifiedAt = os.time() -- 713
	}) -- 713
end -- 685
return ____exports -- 685