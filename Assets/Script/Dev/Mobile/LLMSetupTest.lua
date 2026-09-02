-- [ts]: LLMSetupTest.ts
local ____lualib = require("lualib_bundle") -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 1
local Content = ____Dora.Content -- 1
local DB = ____Dora.DB -- 1
local Path = ____Dora.Path -- 1
local thread = ____Dora.thread -- 1
local ____LLMSetup = require("Dev.Mobile.LLMSetup") -- 2
local mobileLLMPresets = ____LLMSetup.mobileLLMPresets -- 2
local startMobileLLMManager = ____LLMSetup.startMobileLLMManager -- 2
local startMobileLLMSetup = ____LLMSetup.startMobileLLMSetup -- 2
local resultPath = Path(Content.writablePath, "dora-mobile-llm-setup.result") -- 4
local function find(node, tag) -- 6
	if node.tag == tag then -- 6
		return node -- 7
	end -- 7
	local result -- 8
	node:eachChild(function(child) -- 9
		result = find(child, tag) -- 9
		return result ~= nil -- 9
	end) -- 9
	return result -- 10
end -- 6
thread(function() -- 13
	local host -- 14
	local savedId = 0 -- 15
	local backupId = 0 -- 16
	local selectedId = 0 -- 17
	local selectedRows = DB:query("select value_num from Config where name = 'mobileRemixLLMConfigId' limit 1") -- 18
	local ____temp_0 -- 19
	if selectedRows and #selectedRows > 0 then -- 19
		____temp_0 = tonumber(selectedRows[1][1]) -- 19
	else -- 19
		____temp_0 = nil -- 19
	end -- 19
	local previousSelected = ____temp_0 -- 19
	local key = "dora-mobile-test-key" -- 20
	local function cleanup() -- 21
		if host ~= nil then -- 21
			host:removeFromParent(true) -- 22
		end -- 22
		if savedId > 0 then -- 22
			DB:exec("delete from LLMConfig where id = ?", {savedId}) -- 23
		end -- 23
		if backupId > 0 then -- 23
			DB:exec("delete from LLMConfig where id = ?", {backupId}) -- 24
		end -- 24
		if previousSelected ~= nil then -- 24
			DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", {previousSelected}) -- 26
		else -- 26
			DB:exec("delete from Config where name = 'mobileRemixLLMConfigId'") -- 28
		end -- 28
	end -- 21
	local ok, err = xpcall( -- 31
		function() -- 31
			host = startMobileLLMSetup({onSaved = function(id) -- 32
				savedId = id -- 32
			end}) -- 32
			local function get(tag) -- 33
				local node = find(host, tag) -- 34
				if not node then -- 34
					error( -- 35
						__TS__New(Error, "missing " .. tag), -- 35
						0 -- 35
					) -- 35
				end -- 35
				return node -- 36
			end -- 33
			if __TS__ArraySome( -- 33
				mobileLLMPresets, -- 38
				function(____, preset) return preset.id == "custom" end -- 38
			) then -- 38
				error( -- 38
					__TS__New(Error, "custom provider remains in quick setup"), -- 38
					0 -- 38
				) -- 38
			end -- 38
			local expectedTemplates = { -- 39
				"deepseek", -- 39
				"moonshot", -- 39
				"qwen", -- 39
				"openrouter", -- 39
				"openai", -- 39
				"aihubmix", -- 39
				"siliconflow", -- 39
				"volcengine", -- 39
				"volcengine-coding-plan", -- 39
				"byteplus", -- 39
				"byteplus-coding-plan", -- 39
				"minimax", -- 39
				"minimax-cn", -- 39
				"mimo", -- 39
				"zai", -- 39
				"zai-coding-plan", -- 39
				"ollama", -- 39
				"vllm" -- 39
			} -- 39
			if table.concat( -- 39
				__TS__ArrayMap( -- 40
					mobileLLMPresets, -- 40
					function(____, item) return item.id end -- 40
				), -- 40
				"," -- 40
			) ~= table.concat(expectedTemplates, ",") then -- 40
				error( -- 40
					__TS__New(Error, "mobile templates do not match Web IDE"), -- 40
					0 -- 40
				) -- 40
			end -- 40
			if find(host, "mobile-llm-advanced") or find(host, "mobile-llm-url") or find(host, "mobile-llm-model") or find(host, "mobile-llm-key-visibility") then -- 40
				error( -- 42
					__TS__New(Error, "advanced controls remain in quick setup"), -- 42
					0 -- 42
				) -- 42
			end -- 42
			get("mobile-llm-key-border") -- 44
			get("mobile-llm-paste") -- 45
			get("mobile-llm-key"):emit("TextInput", key) -- 46
			local keyLabel = get("remix-input-text") -- 47
			if keyLabel.text == key or (string.find(keyLabel.text, "•", nil, true) or 0) - 1 < 0 then -- 47
				error( -- 48
					__TS__New(Error, "API key was not masked by the shared input"), -- 48
					0 -- 48
				) -- 48
			end -- 48
			get("mobile-llm-save"):emit("Tapped") -- 49
			if savedId <= 0 then -- 49
				error( -- 50
					__TS__New(Error, "save callback did not return an id"), -- 50
					0 -- 50
				) -- 50
			end -- 50
			local rows = DB:query("select name, api_key from LLMConfig where id = ?", {savedId}) -- 51
			if not rows or #rows ~= 1 or (string.find( -- 51
				tostring(rows[1][1]), -- 52
				"DeepSeek", -- 52
				nil, -- 52
				true -- 52
			) or 0) - 1 ~= 0 or rows[1][2] ~= key then -- 52
				error( -- 52
					__TS__New(Error, "saved LLM configuration mismatch"), -- 52
					0 -- 52
				) -- 52
			end -- 52
			DB:exec("insert into LLMConfig(name, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at)\n\t\t\tselect name || ' Test Backup', url, model, api_key, context_window, temperature, max_tokens, reasoning_effort, custom_options, supports_function_calling, active, created_at, updated_at from LLMConfig where id = ?", {savedId}) -- 53
			local backupRows = DB:query("select last_insert_rowid()") -- 55
			backupId = backupRows and #backupRows > 0 and (tonumber(backupRows[1][1]) or 0) or 0 -- 56
			if backupId <= 0 then -- 56
				error( -- 57
					__TS__New(Error, "could not create deletion fallback"), -- 57
					0 -- 57
				) -- 57
			end -- 57
			if host.parent ~= nil then -- 57
				error( -- 58
					__TS__New(Error, "setup panel remained mounted after save"), -- 58
					0 -- 58
				) -- 58
			end -- 58
			host = startMobileLLMManager({ -- 59
				selectedId = savedId, -- 59
				onSelected = function(id) -- 59
					selectedId = id -- 59
				end -- 59
			}) -- 59
			get("mobile-llm-config-" .. tostring(savedId)) -- 60
			get("mobile-llm-detail-" .. tostring(savedId)):emit("Tapped") -- 61
			get("mobile-llm-detail-key-edit"):emit("Tapped") -- 62
			local updatedKey = "dora-mobile-updated-key" -- 63
			get("mobile-llm-detail-key-input"):emit("TextInput", updatedKey) -- 64
			local updatedKeyLabel = get("remix-input-text") -- 65
			if updatedKeyLabel.text == updatedKey or (string.find(updatedKeyLabel.text, "•", nil, true) or 0) - 1 < 0 then -- 65
				error( -- 66
					__TS__New(Error, "updated API key was not masked"), -- 66
					0 -- 66
				) -- 66
			end -- 66
			get("mobile-llm-detail-key-save"):emit("Tapped") -- 67
			local updatedRows = DB:query("select api_key from LLMConfig where id = ?", {savedId}) -- 68
			if not updatedRows or #updatedRows ~= 1 or updatedRows[1][1] ~= updatedKey then -- 68
				error( -- 69
					__TS__New(Error, "API key update failed"), -- 69
					0 -- 69
				) -- 69
			end -- 69
			get("mobile-llm-detail-delete"):emit("Tapped") -- 70
			get("mobile-llm-detail-delete-cancel"):emit("Tapped") -- 71
			get("mobile-llm-detail-delete"):emit("Tapped") -- 72
			get("mobile-llm-detail-delete-confirm"):emit("Tapped") -- 73
			local deletedRows = DB:query("select id from LLMConfig where id = ?", {savedId}) -- 74
			if deletedRows and #deletedRows > 0 then -- 74
				error( -- 75
					__TS__New(Error, "configuration deletion failed"), -- 75
					0 -- 75
				) -- 75
			end -- 75
			if selectedId <= 0 or selectedId == savedId or host.parent == nil then -- 75
				error( -- 76
					__TS__New(Error, "selection fallback after deletion failed"), -- 76
					0 -- 76
				) -- 76
			end -- 76
			savedId = 0 -- 77
		end, -- 31
		debug.traceback -- 78
	) -- 78
	cleanup() -- 79
	Content:save( -- 80
		resultPath, -- 80
		ok and "passed templates=18 sharedInput=1 pasteButton=1 masked=1 persisted=1 listed=1 keyUpdated=1 deleteConfirmed=1 fallback=1 cleanup=1\n" or "failed: " .. tostring(err) -- 80
	) -- 80
end) -- 13
return ____exports -- 13
