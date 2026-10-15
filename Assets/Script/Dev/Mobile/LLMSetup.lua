-- [tsx]: LLMSetup.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__ArrayFlatMap = ____lualib.__TS__ArrayFlatMap -- 1
local __TS__ArrayFindIndex = ____lualib.__TS__ArrayFindIndex -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local ____exports = {} -- 1
local compactText -- 1
local ____DoraX = require("DoraX") -- 1
local React = ____DoraX.React -- 1
local reference = ____DoraX.reference -- 1
local toNode = ____DoraX.toNode -- 1
local ____Gamepad = require("Dev.Mobile.Gamepad") -- 2
local attachGamepad = ____Gamepad.attachGamepad -- 2
local ____Dora = require("Dora") -- 3
local App = ____Dora.App -- 3
local DB = ____Dora.DB -- 3
local Director = ____Dora.Director -- 3
local HttpServer = ____Dora.HttpServer -- 3
local Node = ____Dora.Node -- 3
local ____LLMConfigMigration = require("Agent.LLMConfigMigration") -- 4
local upgradeLLMConfig = ____LLMConfigMigration.upgradeLLMConfig -- 4
local ____Config = require("Agent.Config") -- 5
local AGENT_DEFAULTS = ____Config.AGENT_DEFAULTS -- 5
local ____Accessibility = require("Dev.Mobile.Accessibility") -- 6
local mobileFontScale = ____Accessibility.mobileFontScale -- 6
local ____Controls = require("Dev.Mobile.Controls") -- 7
local MobileButton = ____Controls.MobileButton -- 7
local MobilePanelSurface = ____Controls.MobilePanelSurface -- 7
local ____TextInput = require("Dev.Mobile.TextInput") -- 8
local createTextInput = ____TextInput.createTextInput -- 8
local ____Visual = require("Dev.Mobile.Visual") -- 9
local RoundedSurface = ____Visual.RoundedSurface -- 9
function compactText(value, limit) -- 251
	local length = (utf8.len(value)) or 0 -- 252
	if length <= limit then -- 252
		return value -- 253
	end -- 253
	local stop = utf8.offset(value, limit) or #value -- 254
	return string.sub(value, 1, stop - 1) .. "…" -- 255
end -- 255
local function auxiliary(body) -- 36
	return ("{\"auxiliaryOptions\":" .. body) .. "}" -- 36
end -- 36
____exports.mobileLLMPresets = { -- 37
	{ -- 38
		id = "deepseek", -- 38
		name = "DeepSeek", -- 38
		url = "https://api.deepseek.com/v1/chat/completions", -- 38
		model = "deepseek-v4-pro", -- 38
		contextWindow = 1000000, -- 38
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 38
		customOptions = auxiliary("{\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}") -- 38
	}, -- 38
	{ -- 39
		id = "moonshot", -- 39
		name = "Moonshot", -- 39
		url = "https://api.moonshot.cn/v1/chat/completions", -- 39
		model = "kimi-k3", -- 39
		contextWindow = 128000, -- 39
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 39
		customOptions = auxiliary("{\"reasoning_effort\":\"low\"}") -- 39
	}, -- 39
	{ -- 40
		id = "qwen", -- 40
		name = "Qwen", -- 40
		url = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions", -- 40
		model = "qwen3.7-max", -- 40
		contextWindow = 128000, -- 40
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 40
		customOptions = auxiliary("{\"reasoning_effort\":null,\"enable_thinking\":false}") -- 40
	}, -- 40
	{ -- 41
		id = "openrouter", -- 41
		name = "OpenRouter", -- 41
		url = "https://openrouter.ai/api/v1/chat/completions", -- 41
		model = "~anthropic/claude-sonnet-latest", -- 41
		contextWindow = 128000, -- 41
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 41
		customOptions = auxiliary("{\"reasoning_effort\":null,\"reasoning\":{\"effort\":\"none\"}}") -- 41
	}, -- 41
	{ -- 42
		id = "openai", -- 42
		name = "OpenAI", -- 42
		url = "https://api.openai.com/v1/chat/completions", -- 42
		model = "gpt-5.6", -- 42
		contextWindow = 128000, -- 42
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 42
		customOptions = auxiliary("{\"reasoning_effort\":\"none\"}") -- 42
	}, -- 42
	{ -- 43
		id = "aihubmix", -- 43
		name = "AiHubMix", -- 43
		url = "https://aihubmix.com/v1/chat/completions", -- 43
		model = "gpt-5.6-luna", -- 43
		contextWindow = 128000, -- 43
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 43
		customOptions = auxiliary("{\"reasoning_effort\":\"none\"}") -- 43
	}, -- 43
	{ -- 44
		id = "siliconflow", -- 44
		name = "SiliconFlow", -- 44
		url = "https://api.siliconflow.cn/v1/chat/completions", -- 44
		model = "deepseek-ai/DeepSeek-V4-Pro", -- 44
		contextWindow = 128000, -- 44
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 44
		customOptions = auxiliary("{\"reasoning_effort\":null,\"enable_thinking\":false}") -- 44
	}, -- 44
	{ -- 45
		id = "volcengine", -- 45
		name = "VolcEngine", -- 45
		url = "https://ark.cn-beijing.volces.com/api/v3/chat/completions", -- 45
		model = "doubao-seed-2-0-pro-260215", -- 45
		contextWindow = 128000, -- 45
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 45
		customOptions = auxiliary("{\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}") -- 45
	}, -- 45
	{ -- 46
		id = "volcengine-coding-plan", -- 46
		name = "VolcEngine Coding Plan", -- 46
		url = "https://ark.cn-beijing.volces.com/api/coding/v3/chat/completions", -- 46
		model = "ark-code-latest", -- 46
		contextWindow = 128000, -- 46
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 46
		customOptions = auxiliary("{\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}") -- 46
	}, -- 46
	{ -- 47
		id = "byteplus", -- 47
		name = "BytePlus", -- 47
		url = "https://ark.ap-southeast.bytepluses.com/api/v3/chat/completions", -- 47
		model = "dola-seed-2-1-turbo-260628", -- 47
		contextWindow = 128000, -- 47
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 47
		customOptions = auxiliary("{\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}") -- 47
	}, -- 47
	{ -- 48
		id = "byteplus-coding-plan", -- 48
		name = "BytePlus Coding Plan", -- 48
		url = "https://ark.ap-southeast.bytepluses.com/api/coding/v3/chat/completions", -- 48
		model = "ark-code-latest", -- 48
		contextWindow = 128000, -- 48
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 48
		customOptions = auxiliary("{\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}") -- 48
	}, -- 48
	{ -- 49
		id = "minimax", -- 49
		name = "MiniMax", -- 49
		url = "https://api.minimax.io/v1/chat/completions", -- 49
		model = "MiniMax-M2.7", -- 49
		contextWindow = 128000, -- 49
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 49
		customOptions = auxiliary("{\"reasoning_effort\":null}") -- 49
	}, -- 49
	{ -- 50
		id = "minimax-cn", -- 50
		name = "MiniMax (CN)", -- 50
		url = "https://api.minimaxi.com/v1/chat/completions", -- 50
		model = "MiniMax-M2.7", -- 50
		contextWindow = 128000, -- 50
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 50
		customOptions = auxiliary("{\"reasoning_effort\":null}") -- 50
	}, -- 50
	{ -- 51
		id = "mimo", -- 51
		name = "Xiaomi MiMo", -- 51
		url = "https://api.xiaomimimo.com/v1/chat/completions", -- 51
		model = "mimo-v2.5-pro", -- 51
		contextWindow = 128000, -- 51
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 51
		customOptions = "{\"max_tokens\":null,\"max_completion_tokens\":64000,\"top_p\":0.95,\"auxiliaryOptions\":{\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}}" -- 51
	}, -- 51
	{ -- 52
		id = "zai", -- 52
		name = "ZAI", -- 52
		url = "https://open.bigmodel.cn/api/paas/v4/chat/completions", -- 52
		model = "glm-5.2", -- 52
		contextWindow = 128000, -- 52
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 52
		customOptions = auxiliary("{\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}") -- 52
	}, -- 52
	{ -- 53
		id = "zai-coding-plan", -- 53
		name = "ZAI Coding Plan", -- 53
		url = "https://open.bigmodel.cn/api/coding/paas/v4/chat/completions", -- 53
		model = "glm-5.2", -- 53
		contextWindow = 128000, -- 53
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 53
		customOptions = auxiliary("{\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}") -- 53
	}, -- 53
	{ -- 54
		id = "ollama", -- 54
		name = "Ollama", -- 54
		url = "http://localhost:11434/v1/chat/completions", -- 54
		model = "llama3.2", -- 54
		contextWindow = 128000, -- 54
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 54
		customOptions = auxiliary("{\"reasoning_effort\":\"none\"}") -- 54
	}, -- 54
	{ -- 55
		id = "vllm", -- 55
		name = "vLLM", -- 55
		url = "http://localhost:8000/v1/chat/completions", -- 55
		model = "meta-llama/Llama-3.1-8B-Instruct", -- 55
		contextWindow = 128000, -- 55
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 55
		customOptions = auxiliary("{\"reasoning_effort\":\"none\",\"chat_template_kwargs\":{\"enable_thinking\":false}}") -- 55
	} -- 55
} -- 55
local fontName = "sarasa-mono-sc-regular" -- 58
local function trim(value) -- 59
	return (string.match(value, "^%s*(.-)%s*$")) or "" -- 59
end -- 59
local activeSetup -- 60
local function ensureLLMConfigTable() -- 62
	DB:exec("CREATE TABLE IF NOT EXISTS LLMConfig(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tname TEXT NOT NULL, url TEXT NOT NULL, model TEXT NOT NULL, api_key TEXT NOT NULL,\n\t\tcontext_window INTEGER NOT NULL DEFAULT 64000, temperature REAL NOT NULL DEFAULT 0.1,\n\t\tmax_tokens INTEGER NOT NULL DEFAULT 64000, reasoning_effort TEXT NOT NULL DEFAULT '',\n\t\tcustom_options TEXT NOT NULL DEFAULT '', supports_function_calling INTEGER NOT NULL DEFAULT 1,\n\t\tactive INTEGER NOT NULL DEFAULT 1, created_at INTEGER, updated_at INTEGER\n\t)") -- 63
	upgradeLLMConfig() -- 71
end -- 62
local function uniqueConfigName(base) -- 74
	local rows = DB:query("select name from LLMConfig") -- 75
	local names = __TS__ArrayMap( -- 76
		rows or ({}), -- 76
		function(____, row) return tostring(row[1]) end -- 76
	) -- 76
	if __TS__ArrayIndexOf(names, base) < 0 then -- 76
		return base -- 77
	end -- 77
	local suffix = 2 -- 78
	while __TS__ArrayIndexOf( -- 78
		names, -- 79
		(base .. " ") .. tostring(suffix) -- 79
	) >= 0 do -- 79
		suffix = suffix + 1 -- 79
	end -- 79
	return (base .. " ") .. tostring(suffix) -- 80
end -- 74
function ____exports.hasMobileLLMConfig() -- 83
	ensureLLMConfigTable() -- 84
	local rows = DB:query("select id from LLMConfig limit 1") -- 85
	return rows ~= nil and #rows > 0 -- 86
end -- 83
function ____exports.startMobileLLMSetup(options) -- 89
	local render -- 89
	if activeSetup ~= nil then -- 89
		activeSetup:removeFromParent(true) -- 90
	end -- 90
	local coveredNode = options.coveredNode -- 91
	if coveredNode then -- 91
		coveredNode.visible = false -- 92
	end -- 92
	local coveredRestored = false -- 93
	local function restoreCovered() -- 94
		if coveredRestored then -- 94
			return -- 95
		end -- 95
		coveredRestored = true -- 96
		if coveredNode and coveredNode.parent then -- 96
			coveredNode.visible = true -- 97
		end -- 97
	end -- 94
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 99
	local host = Node() -- 100
	host.tag = "mobile-llm-setup" -- 101
	host.order = 10000 -- 102
	host.renderGroup = true -- 103
	host.scaleX = App.devicePixelRatio -- 104
	host.scaleY = App.devicePixelRatio -- 105
	host:addTo(Director.systemUI) -- 106
	activeSetup = host -- 107
	local presetIndex = 0 -- 108
	local apiKey = "" -- 109
	local ____error = "" -- 110
	local disposed = false -- 111
	local keyRef = reference() -- 112
	local function canEdit() -- 113
		return not disposed and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 -- 113
	end -- 113
	local keyInput = createTextInput({ -- 114
		fontSize = math.floor(15 * mobileFontScale), -- 115
		singleLine = true, -- 115
		isSecure = function() return true end, -- 115
		getText = function() return apiKey end, -- 116
		setText = function(value) -- 116
			apiKey = value -- 116
			____error = "" -- 116
		end, -- 116
		getPlaceholder = function() return "sk-…" end, -- 117
		isEnabled = canEdit, -- 117
		onReturn = function() return true end -- 118
	}) -- 118
	local function blurInputs() -- 120
		return keyInput.blur() -- 120
	end -- 120
	local function close() -- 121
		if disposed then -- 121
			return -- 122
		end -- 122
		disposed = true -- 123
		blurInputs() -- 124
		restoreCovered() -- 125
		host:removeFromParent(true) -- 126
		if activeSetup == host then -- 126
			activeSetup = nil -- 127
		end -- 127
		local ____opt_4 = options.onClose -- 127
		if ____opt_4 ~= nil then -- 127
			____opt_4() -- 128
		end -- 128
	end -- 121
	local function choose(delta) -- 130
		presetIndex = (presetIndex + delta + #____exports.mobileLLMPresets) % #____exports.mobileLLMPresets -- 131
		____error = "" -- 132
		blurInputs() -- 133
		render() -- 133
	end -- 130
	local function save() -- 135
		if not canEdit() then -- 135
			return -- 136
		end -- 136
		local preset = ____exports.mobileLLMPresets[presetIndex + 1] -- 137
		local key = trim(apiKey) -- 138
		if key == "" then -- 138
			____error = zh and "请粘贴 API Key" or "Paste an API key" -- 139
			render() -- 139
			return -- 139
		end -- 139
		ensureLLMConfigTable() -- 140
		local now = os.time() -- 141
		local name = uniqueConfigName(preset.name) -- 142
		local affected = DB:exec("insert into LLMConfig(\n\t\t\tname, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort,\n\t\t\tcustom_options, supports_function_calling, active, created_at, updated_at\n\t\t) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 143
			name, -- 147
			preset.url, -- 147
			preset.model, -- 147
			key, -- 147
			preset.contextWindow, -- 147
			0.1, -- 147
			preset.maxTokens, -- 147
			"", -- 147
			preset.customOptions, -- 148
			1, -- 148
			1, -- 148
			now, -- 148
			now -- 148
		}) -- 148
		if affected < 0 then -- 148
			____error = zh and "配置保存失败，请重试" or "Could not save the configuration" -- 150
			render() -- 150
			return -- 150
		end -- 150
		local rows = DB:query("select last_insert_rowid()") -- 151
		local ____temp_6 -- 152
		if rows and #rows > 0 then -- 152
			____temp_6 = tonumber(rows[1][1]) -- 152
		else -- 152
			____temp_6 = nil -- 152
		end -- 152
		local id = ____temp_6 -- 152
		if not id then -- 152
			____error = zh and "无法读取新配置" or "Could not read the new configuration" -- 153
			render() -- 153
			return -- 153
		end -- 153
		DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", {id}) -- 154
		options.onSaved(id) -- 155
		close() -- 156
	end -- 135
	render = function() -- 158
		if disposed then -- 158
			return -- 159
		end -- 159
		keyInput.unmount() -- 160
		keyRef = reference() -- 161
		host:removeAllChildren() -- 162
		host.scaleX = App.devicePixelRatio -- 163
		host.scaleY = App.devicePixelRatio -- 163
		local ____App_visualSize_7 = App.visualSize -- 164
		local width = ____App_visualSize_7.width -- 164
		local height = ____App_visualSize_7.height -- 164
		local safe = App.safeArea -- 165
		local shortLandscape = safe.width >= 760 and safe.height < 500 -- 166
		local sheetWidth = shortLandscape and math.min(720, safe.width - 24) or safe.width -- 167
		local sheetHeight = shortLandscape and math.min(240, safe.height - 16) or math.min(300, safe.height - 20) -- 168
		local left = safe.x + (safe.width - sheetWidth) / 2 -- 169
		local bottom = safe.y -- 170
		local contentWidth = sheetWidth - 40 -- 171
		local fieldGap = 12 -- 172
		local fieldWidth = shortLandscape and math.floor((contentWidth - fieldGap) / 2) or contentWidth -- 173
		local keyButtonWidth = 92 -- 174
		local keyX = shortLandscape and 20 + fieldWidth + fieldGap or 20 -- 175
		local keyWidth = fieldWidth - keyButtonWidth - fieldGap -- 176
		local providerLabelY = sheetHeight - 66 -- 177
		local providerY = sheetHeight - 126 -- 178
		local keyLabelY = shortLandscape and providerLabelY or sheetHeight - 150 -- 179
		local keyY = shortLandscape and providerY or sheetHeight - 204 -- 180
		local actionGap = 12 -- 181
		local cancelWidth = math.floor((contentWidth - actionGap) * (shortLandscape and 0.34 or 0.38)) -- 182
		local preset = ____exports.mobileLLMPresets[presetIndex + 1] -- 183
		local scene = toNode(React.createElement( -- 184
			"node", -- 184
			{ -- 184
				order = 10000, -- 184
				x = -width / 2, -- 184
				y = -height / 2, -- 184
				width = width, -- 184
				height = height, -- 184
				anchorX = 0, -- 184
				anchorY = 0 -- 184
			}, -- 184
			React.createElement( -- 184
				"node", -- 184
				{ -- 184
					tag = "mobile-llm-setup-backdrop", -- 184
					width = width, -- 184
					height = height, -- 184
					anchorX = 0, -- 184
					anchorY = 0, -- 184
					touchEnabled = true, -- 184
					swallowTouches = true, -- 184
					onTapped = close -- 184
				}, -- 184
				React.createElement(RoundedSurface, { -- 184
					width = width, -- 184
					height = height, -- 184
					radius = 0, -- 184
					fillColor = 2348810240, -- 184
					renderOrder = 0 -- 184
				}) -- 184
			), -- 184
			React.createElement( -- 184
				"node", -- 184
				{ -- 184
					order = 10, -- 184
					x = left, -- 184
					y = bottom, -- 184
					width = sheetWidth, -- 184
					height = sheetHeight, -- 184
					anchorX = 0, -- 184
					anchorY = 0, -- 184
					touchEnabled = true, -- 184
					swallowTouches = true -- 184
				}, -- 184
				React.createElement(MobilePanelSurface, {width = sheetWidth, height = sheetHeight, renderOrder = 10}), -- 184
				React.createElement("label", { -- 184
					x = 20, -- 184
					y = sheetHeight - 24, -- 184
					anchorX = 0, -- 184
					anchorY = 1, -- 184
					fontName = fontName, -- 184
					fontSize = 22, -- 184
					text = zh and "从模板新增配置" or "Add from template", -- 184
					color3 = 16052712 -- 184
				}), -- 184
				React.createElement( -- 184
					"label", -- 184
					{ -- 184
						x = sheetWidth - 20, -- 184
						y = sheetHeight - 24, -- 184
						anchorX = 1, -- 184
						anchorY = 1, -- 184
						fontName = fontName, -- 184
						fontSize = 12, -- 184
						text = compactText(preset.model, shortLandscape and 42 or 24), -- 184
						color3 = 11055037 -- 184
					} -- 184
				), -- 184
				React.createElement("label", { -- 184
					x = 20, -- 184
					y = providerLabelY, -- 184
					anchorX = 0, -- 184
					anchorY = 1, -- 184
					fontName = fontName, -- 184
					fontSize = 14, -- 184
					text = zh and "配置模板" or "Template", -- 184
					color3 = 11055037 -- 184
				}), -- 184
				React.createElement( -- 184
					MobileButton, -- 193
					{ -- 193
						tag = "mobile-llm-provider-prev", -- 193
						x = 20, -- 193
						y = providerY, -- 193
						width = 48, -- 193
						text = "‹", -- 193
						renderOrder = 10, -- 193
						onTapped = function() return choose(-1) end -- 193
					} -- 193
				), -- 193
				React.createElement( -- 193
					MobileButton, -- 194
					{ -- 194
						tag = "mobile-llm-provider", -- 194
						x = 80, -- 194
						y = providerY, -- 194
						width = fieldWidth - 120, -- 194
						text = preset.name, -- 194
						renderOrder = 10, -- 194
						onTapped = function() return choose(1) end -- 194
					} -- 194
				), -- 194
				React.createElement( -- 194
					MobileButton, -- 195
					{ -- 195
						tag = "mobile-llm-provider-next", -- 195
						x = 20 + fieldWidth - 48, -- 195
						y = providerY, -- 195
						width = 48, -- 195
						text = "›", -- 195
						renderOrder = 10, -- 195
						onTapped = function() return choose(1) end -- 195
					} -- 195
				), -- 195
				React.createElement("label", { -- 195
					x = keyX, -- 195
					y = keyLabelY, -- 195
					anchorX = 0, -- 195
					anchorY = 1, -- 195
					fontName = fontName, -- 195
					fontSize = 14, -- 195
					text = "API Key", -- 195
					color3 = 11055037 -- 195
				}), -- 195
				React.createElement("node", { -- 195
					tag = "mobile-llm-key", -- 195
					ref = keyRef, -- 195
					renderOrder = 10, -- 195
					x = keyX, -- 195
					y = keyY, -- 195
					width = keyWidth, -- 195
					height = 44, -- 195
					anchorX = 0, -- 195
					anchorY = 0, -- 195
					onMount = keyInput.mount -- 195
				}), -- 195
				React.createElement( -- 195
					MobileButton, -- 198
					{ -- 198
						tag = "mobile-llm-paste", -- 198
						x = keyX + keyWidth + fieldGap, -- 198
						y = keyY - 2, -- 198
						width = keyButtonWidth, -- 198
						text = zh and "粘贴" or "Paste", -- 198
						renderOrder = 10, -- 198
						onTapped = function() -- 198
							if not keyInput.pasteFromClipboard(true) then -- 198
								____error = zh and "剪贴板为空" or "Clipboard is empty" -- 199
							else -- 199
								____error = "" -- 200
							end -- 200
							keyInput.refresh() -- 201
						end -- 198
					} -- 198
				), -- 198
				React.createElement("label", { -- 198
					tag = "mobile-llm-error", -- 198
					x = 20, -- 198
					y = 78, -- 198
					anchorX = 0, -- 198
					fontName = fontName, -- 198
					fontSize = 12, -- 198
					text = ____error, -- 198
					textWidth = contentWidth, -- 198
					alignment = "Left", -- 198
					color3 = 16739179 -- 198
				}), -- 198
				React.createElement(MobileButton, { -- 198
					tag = "mobile-llm-cancel", -- 198
					x = 20, -- 198
					y = 20, -- 198
					width = cancelWidth, -- 198
					text = zh and "返回" or "Back", -- 198
					renderOrder = 10, -- 198
					onTapped = close -- 198
				}), -- 198
				React.createElement(MobileButton, { -- 198
					tag = "mobile-llm-save", -- 198
					x = 20 + cancelWidth + actionGap, -- 198
					y = 20, -- 198
					width = contentWidth - cancelWidth - actionGap, -- 198
					text = zh and "新增并使用" or "Add and use", -- 198
					primary = true, -- 198
					renderOrder = 10, -- 198
					onTapped = save -- 198
				}) -- 198
			) -- 198
		)) -- 198
		if scene then -- 198
			host:addChild(scene) -- 208
		end -- 208
	end -- 158
	attachGamepad( -- 210
		host, -- 210
		{ -- 210
			initialTag = "mobile-llm-provider", -- 211
			onBack = function() -- 212
				if keyInput.isFocused() then -- 212
					keyInput.blur() -- 212
				else -- 212
					close() -- 212
				end -- 212
			end -- 212
		} -- 212
	) -- 212
	host:onAppChange(function(setting) -- 214
		if setting == "Locale" then -- 214
			zh = (string.match(App.locale, "^zh")) ~= nil -- 215
		end -- 215
		if setting == "Size" or setting == "Locale" then -- 215
			render() -- 216
		end -- 216
	end) -- 214
	host:onAppEvent(function(event) -- 218
		if event == "BackButton" then -- 218
			close() -- 218
		end -- 218
	end) -- 218
	host:onCleanup(function() -- 219
		disposed = true -- 219
		restoreCovered() -- 219
		if activeSetup == host then -- 219
			activeSetup = nil -- 219
		end -- 219
	end) -- 219
	render() -- 220
	return host -- 221
end -- 89
local function getMobileLLMConfigs() -- 233
	ensureLLMConfigTable() -- 234
	local rows = DB:query("select id, name, url, model, context_window, supports_function_calling\n\t\tfrom LLMConfig order by id asc") -- 235
	return __TS__ArrayFlatMap( -- 237
		rows or ({}), -- 237
		function(____, row) -- 237
			local id = tonumber(row[1]) -- 238
			if not id then -- 238
				return {} -- 239
			end -- 239
			return {{ -- 240
				id = id, -- 241
				name = tostring(row[2]), -- 242
				url = tostring(row[3]), -- 243
				model = tostring(row[4]), -- 244
				contextWindow = tonumber(row[5]) or 128000, -- 245
				supportsFunctionCalling = tonumber(row[6]) ~= 0 -- 246
			}} -- 246
		end -- 237
	) -- 237
end -- 233
function ____exports.startMobileLLMManager(options) -- 258
	local render -- 258
	local configs = getMobileLLMConfigs() -- 259
	if #configs == 0 then -- 259
		return ____exports.startMobileLLMSetup({coveredNode = options.coveredNode, onSaved = options.onSelected, onClose = options.onClose}) -- 261
	end -- 261
	if activeSetup ~= nil then -- 261
		activeSetup:removeFromParent(true) -- 267
	end -- 267
	local coveredNode = options.coveredNode -- 268
	if coveredNode then -- 268
		coveredNode.visible = false -- 269
	end -- 269
	local coveredRestored = false -- 270
	local function restoreCovered() -- 271
		if coveredRestored then -- 271
			return -- 272
		end -- 272
		coveredRestored = true -- 273
		if coveredNode and coveredNode.parent then -- 273
			coveredNode.visible = true -- 274
		end -- 274
	end -- 271
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 276
	local host = Node() -- 277
	host.tag = "mobile-llm-manager" -- 278
	host.order = 10000 -- 279
	host.renderGroup = true -- 280
	host.scaleX = App.devicePixelRatio -- 281
	host.scaleY = App.devicePixelRatio -- 282
	host:addTo(Director.systemUI) -- 283
	activeSetup = host -- 284
	local page = -1 -- 285
	local detailId = 0 -- 286
	local detailMode = "view" -- 287
	local detailKey = "" -- 288
	local detailError = "" -- 289
	local selectedId = options.selectedId -- 290
	local disposed = false -- 291
	local detailKeyRef = reference() -- 292
	local function canEdit() -- 293
		return not disposed and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 -- 293
	end -- 293
	local detailKeyInput = createTextInput({ -- 294
		fontSize = math.floor(15 * mobileFontScale), -- 295
		singleLine = true, -- 295
		isSecure = function() return true end, -- 295
		getText = function() return detailKey end, -- 296
		setText = function(value) -- 296
			detailKey = value -- 296
			detailError = "" -- 296
		end, -- 296
		getPlaceholder = function() return zh and "粘贴新的 API Key" or "Paste a new API key" end, -- 297
		isEnabled = canEdit, -- 297
		onReturn = function() return true end -- 298
	}) -- 298
	local function close(notify) -- 300
		if notify == nil then -- 300
			notify = true -- 300
		end -- 300
		if disposed then -- 300
			return -- 301
		end -- 301
		disposed = true -- 302
		detailKeyInput.blur() -- 303
		restoreCovered() -- 304
		host:removeFromParent(true) -- 305
		if activeSetup == host then -- 305
			activeSetup = nil -- 306
		end -- 306
		if notify then -- 306
			local ____opt_12 = options.onClose -- 306
			if ____opt_12 ~= nil then -- 306
				____opt_12() -- 307
			end -- 307
		end -- 307
	end -- 300
	local function select(id) -- 309
		DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", {id}) -- 310
		options.onSelected(id) -- 311
		close() -- 312
	end -- 309
	local function openDetail(id) -- 314
		detailId = id -- 315
		detailMode = "view" -- 316
		detailKey = "" -- 317
		detailError = "" -- 318
		render() -- 319
	end -- 314
	local function saveDetailKey() -- 321
		if not canEdit() or detailId <= 0 then -- 321
			return -- 322
		end -- 322
		local key = trim(detailKey) -- 323
		if key == "" then -- 323
			detailError = zh and "请粘贴新的 API Key" or "Paste a new API key" -- 324
			render() -- 324
			return -- 324
		end -- 324
		local affected = DB:exec( -- 325
			"update LLMConfig set api_key = ?, updated_at = ? where id = ?", -- 325
			{ -- 325
				key, -- 325
				os.time(), -- 325
				detailId -- 325
			} -- 325
		) -- 325
		if affected <= 0 then -- 325
			detailError = zh and "API Key 保存失败" or "Could not save the API key" -- 326
			render() -- 326
			return -- 326
		end -- 326
		detailKeyInput.blur() -- 327
		detailKey = "" -- 328
		detailError = zh and "API Key 已更新" or "API key updated" -- 329
		detailMode = "view" -- 330
		render() -- 331
	end -- 321
	local function deleteDetail() -- 333
		if not canEdit() or detailId <= 0 then -- 333
			return -- 334
		end -- 334
		local deletingId = detailId -- 335
		local affected = DB:exec("delete from LLMConfig where id = ?", {deletingId}) -- 336
		if affected <= 0 then -- 336
			detailError = zh and "删除失败，请重试" or "Could not delete the configuration" -- 337
			render() -- 337
			return -- 337
		end -- 337
		configs = getMobileLLMConfigs() -- 338
		if selectedId == deletingId then -- 338
			local ____opt_14 = configs[1] -- 338
			selectedId = ____opt_14 and ____opt_14.id or 0 -- 340
			if selectedId > 0 then -- 340
				DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", {selectedId}) -- 341
			else -- 341
				DB:exec("delete from Config where name = 'mobileRemixLLMConfigId'") -- 342
			end -- 342
			options.onSelected(selectedId) -- 343
		end -- 343
		detailId = 0 -- 345
		detailMode = "view" -- 346
		detailKey = "" -- 347
		detailError = "" -- 348
		page = -1 -- 349
		if #configs > 0 then -- 349
			render() -- 350
		else -- 350
			close(false) -- 352
			____exports.startMobileLLMSetup({coveredNode = coveredNode, onSaved = options.onSelected, onClose = options.onClose}) -- 353
		end -- 353
	end -- 333
	local function add() -- 356
		close(false) -- 357
		local saved = false -- 358
		____exports.startMobileLLMSetup({ -- 359
			coveredNode = coveredNode, -- 360
			onSaved = function(id) -- 361
				saved = true -- 361
				options.onSelected(id) -- 361
			end, -- 361
			onClose = function() -- 362
				if saved then -- 362
					local ____opt_16 = options.onClose -- 362
					if ____opt_16 ~= nil then -- 362
						____opt_16() -- 363
					end -- 363
				else -- 363
					____exports.startMobileLLMManager(options) -- 364
				end -- 364
			end -- 362
		}) -- 362
	end -- 356
	render = function() -- 368
		if disposed then -- 368
			return -- 369
		end -- 369
		detailKeyInput.unmount() -- 370
		detailKeyRef = reference() -- 371
		host:removeAllChildren() -- 372
		host.scaleX = App.devicePixelRatio -- 373
		host.scaleY = App.devicePixelRatio -- 374
		local ____App_visualSize_18 = App.visualSize -- 375
		local width = ____App_visualSize_18.width -- 375
		local height = ____App_visualSize_18.height -- 375
		local safe = App.safeArea -- 376
		local shortLandscape = safe.width >= 760 and safe.height < 500 -- 377
		local rowsPerPage = shortLandscape and 3 or 5 -- 378
		local desiredHeight = detailId > 0 and 410 or math.max( -- 379
			260, -- 379
			160 + math.min(#configs, rowsPerPage) * 68 -- 379
		) -- 379
		local sheetWidth = shortLandscape and math.min(720, safe.width - 24) or safe.width -- 380
		local sheetHeight = math.min(desiredHeight, safe.height - (shortLandscape and 16 or 20)) -- 381
		local left = safe.x + (safe.width - sheetWidth) / 2 -- 382
		local bottom = safe.y -- 383
		local contentWidth = sheetWidth - 40 -- 384
		local pageCount = math.max( -- 385
			1, -- 385
			math.ceil(#configs / rowsPerPage) -- 385
		) -- 385
		if page < 0 then -- 385
			local selectedIndex = __TS__ArrayFindIndex( -- 387
				configs, -- 387
				function(____, item) return item.id == selectedId end -- 387
			) -- 387
			page = selectedIndex < 0 and 0 or math.floor(selectedIndex / rowsPerPage) -- 388
		end -- 388
		page = math.max( -- 390
			0, -- 390
			math.min(pageCount - 1, page) -- 390
		) -- 390
		local pageItems = __TS__ArraySlice(configs, page * rowsPerPage, (page + 1) * rowsPerPage) -- 391
		local detail = __TS__ArrayFind( -- 392
			configs, -- 392
			function(____, item) return item.id == detailId end -- 392
		) -- 392
		local switchPending = options.taskRunning and (options.runningId or selectedId) ~= selectedId -- 393
		local ____toNode_39 = toNode -- 394
		local ____React_createElement_38 = React.createElement -- 394
		local ____temp_36 = { -- 394
			order = 10000, -- 394
			x = -width / 2, -- 394
			y = -height / 2, -- 394
			width = width, -- 394
			height = height, -- 394
			anchorX = 0, -- 394
			anchorY = 0 -- 394
		} -- 394
		local ____React_createElement_result_37 = React.createElement( -- 394
			"node", -- 394
			{ -- 394
				tag = "mobile-llm-manager-backdrop", -- 394
				width = width, -- 394
				height = height, -- 394
				anchorX = 0, -- 394
				anchorY = 0, -- 394
				touchEnabled = true, -- 394
				swallowTouches = true, -- 394
				onTapped = function() return close() end -- 394
			}, -- 394
			React.createElement(RoundedSurface, { -- 394
				width = width, -- 394
				height = height, -- 394
				radius = 0, -- 394
				fillColor = 2348810240, -- 394
				renderOrder = 0 -- 394
			}) -- 394
		) -- 394
		local ____React_createElement_35 = React.createElement -- 394
		local ____temp_33 = { -- 394
			order = 10, -- 394
			x = left, -- 394
			y = bottom, -- 394
			width = sheetWidth, -- 394
			height = sheetHeight, -- 394
			anchorX = 0, -- 394
			anchorY = 0, -- 394
			touchEnabled = true, -- 394
			swallowTouches = true -- 394
		} -- 394
		local ____React_createElement_result_34 = React.createElement(MobilePanelSurface, {width = sheetWidth, height = sheetHeight, renderOrder = 10}) -- 394
		local ____detail_32 -- 400
		if detail then -- 400
			local ____temp_24 -- 400
			if detailMode == "key" then -- 400
				____temp_24 = React.createElement( -- 400
					"node", -- 400
					{tag = "mobile-llm-detail-key"}, -- 400
					React.createElement("label", { -- 400
						x = 20, -- 400
						y = sheetHeight - 24, -- 400
						anchorX = 0, -- 400
						anchorY = 1, -- 400
						fontName = fontName, -- 400
						fontSize = 22, -- 400
						text = zh and "修改 API Key" or "Update API key", -- 400
						color3 = 16052712 -- 400
					}), -- 400
					React.createElement( -- 400
						"label", -- 400
						{ -- 400
							x = 20, -- 400
							y = sheetHeight - 66, -- 400
							anchorX = 0, -- 400
							anchorY = 1, -- 400
							fontName = fontName, -- 400
							fontSize = 13, -- 400
							text = compactText(detail.name, shortLandscape and 44 or 28), -- 400
							color3 = 11055037 -- 400
						} -- 400
					), -- 400
					React.createElement("label", { -- 400
						x = 20, -- 400
						y = sheetHeight - 104, -- 400
						anchorX = 0, -- 400
						anchorY = 1, -- 400
						fontName = fontName, -- 400
						fontSize = 13, -- 400
						text = zh and "原 Key 不会显示，保存后立即替换" or "The current key stays hidden and will be replaced", -- 400
						color3 = 11055037 -- 400
					}), -- 400
					React.createElement("node", { -- 400
						tag = "mobile-llm-detail-key-input", -- 400
						ref = detailKeyRef, -- 400
						renderOrder = 10, -- 400
						x = 20, -- 400
						y = sheetHeight - 166, -- 400
						width = contentWidth - 104, -- 400
						height = 44, -- 400
						anchorX = 0, -- 400
						anchorY = 0, -- 400
						onMount = detailKeyInput.mount -- 400
					}), -- 400
					React.createElement( -- 400
						MobileButton, -- 405
						{ -- 405
							tag = "mobile-llm-detail-key-paste", -- 405
							x = contentWidth - 72, -- 405
							y = sheetHeight - 168, -- 405
							width = 92, -- 405
							text = zh and "粘贴" or "Paste", -- 405
							renderOrder = 10, -- 405
							onTapped = function() -- 405
								if not detailKeyInput.pasteFromClipboard(true) then -- 405
									detailError = zh and "剪贴板为空" or "Clipboard is empty" -- 406
								else -- 406
									detailError = "" -- 407
								end -- 407
								detailKeyInput.refresh() -- 408
							end -- 405
						} -- 405
					), -- 405
					React.createElement("label", { -- 405
						x = 20, -- 405
						y = 82, -- 405
						anchorX = 0, -- 405
						fontName = fontName, -- 405
						fontSize = 12, -- 405
						text = detailError, -- 405
						textWidth = contentWidth, -- 405
						alignment = "Left", -- 405
						color3 = 16739179 -- 405
					}), -- 405
					React.createElement( -- 405
						MobileButton, -- 411
						{ -- 411
							tag = "mobile-llm-detail-key-cancel", -- 411
							x = 20, -- 411
							y = 20, -- 411
							width = math.floor((contentWidth - 12) * 0.36), -- 411
							text = zh and "取消" or "Cancel", -- 411
							renderOrder = 10, -- 411
							onTapped = function() -- 411
								detailKeyInput.blur() -- 411
								detailMode = "view" -- 411
								detailKey = "" -- 411
								detailError = "" -- 411
								render() -- 411
							end -- 411
						} -- 411
					), -- 411
					React.createElement( -- 411
						MobileButton, -- 412
						{ -- 412
							tag = "mobile-llm-detail-key-save", -- 412
							x = 32 + math.floor((contentWidth - 12) * 0.36), -- 412
							y = 20, -- 412
							width = contentWidth - 12 - math.floor((contentWidth - 12) * 0.36), -- 412
							text = zh and "保存新 Key" or "Save new key", -- 412
							primary = true, -- 412
							renderOrder = 10, -- 412
							onTapped = saveDetailKey -- 412
						} -- 412
					) -- 412
				) -- 412
			else -- 412
				local ____temp_23 -- 413
				if detailMode == "delete" then -- 413
					____temp_23 = React.createElement( -- 413
						"node", -- 413
						{tag = "mobile-llm-detail-delete"}, -- 413
						React.createElement("label", { -- 413
							x = 20, -- 413
							y = sheetHeight - 24, -- 413
							anchorX = 0, -- 413
							anchorY = 1, -- 413
							fontName = fontName, -- 413
							fontSize = 22, -- 413
							text = zh and "删除这个配置？" or "Delete this configuration?", -- 413
							color3 = 16052712 -- 413
						}), -- 413
						React.createElement( -- 413
							"label", -- 413
							{ -- 413
								x = 20, -- 413
								y = sheetHeight - 78, -- 413
								anchorX = 0, -- 413
								anchorY = 1, -- 413
								fontName = fontName, -- 413
								fontSize = 16, -- 413
								text = compactText(detail.name, shortLandscape and 52 or 32), -- 413
								color3 = 4294935941 -- 413
							} -- 413
						), -- 413
						React.createElement("label", { -- 413
							x = 20, -- 413
							y = sheetHeight - 120, -- 413
							anchorX = 0, -- 413
							anchorY = 1, -- 413
							fontName = fontName, -- 413
							fontSize = 13, -- 413
							text = zh and "删除后无法恢复；若它是当前配置，将自动切换到下一项。" or "This cannot be undone. The next configuration will become active.", -- 413
							textWidth = contentWidth, -- 413
							alignment = "Left", -- 413
							color3 = 11055037 -- 413
						}), -- 413
						React.createElement("label", { -- 413
							x = 20, -- 413
							y = 82, -- 413
							anchorX = 0, -- 413
							fontName = fontName, -- 413
							fontSize = 12, -- 413
							text = detailError, -- 413
							textWidth = contentWidth, -- 413
							alignment = "Left", -- 413
							color3 = 16739179 -- 413
						}), -- 413
						React.createElement( -- 413
							MobileButton, -- 418
							{ -- 418
								tag = "mobile-llm-detail-delete-cancel", -- 418
								x = 20, -- 418
								y = 20, -- 418
								width = math.floor((contentWidth - 12) * 0.42), -- 418
								text = zh and "保留配置" or "Keep it", -- 418
								renderOrder = 10, -- 418
								onTapped = function() -- 418
									detailMode = "view" -- 418
									detailError = "" -- 418
									render() -- 418
								end -- 418
							} -- 418
						), -- 418
						React.createElement( -- 418
							MobileButton, -- 419
							{ -- 419
								tag = "mobile-llm-detail-delete-confirm", -- 419
								x = 32 + math.floor((contentWidth - 12) * 0.42), -- 419
								y = 20, -- 419
								width = contentWidth - 12 - math.floor((contentWidth - 12) * 0.42), -- 419
								text = zh and "确认删除" or "Delete", -- 419
								danger = true, -- 419
								renderOrder = 10, -- 419
								onTapped = deleteDetail -- 419
							} -- 419
						) -- 419
					) -- 419
				else -- 419
					local ____React_createElement_22 = React.createElement -- 419
					local ____temp_20 = {tag = "mobile-llm-detail"} -- 419
					local ____React_createElement_result_21 = React.createElement( -- 419
						"label", -- 419
						{ -- 419
							x = 20, -- 419
							y = sheetHeight - 24, -- 419
							anchorX = 0, -- 419
							anchorY = 1, -- 419
							fontName = fontName, -- 419
							fontSize = 22, -- 419
							text = compactText(detail.name, 28), -- 419
							color3 = 16052712 -- 419
						} -- 419
					) -- 419
					local ____temp_19 -- 422
					if detailError ~= "" then -- 422
						____temp_19 = React.createElement("label", { -- 422
							x = sheetWidth - 20, -- 422
							y = sheetHeight - 25, -- 422
							anchorX = 1, -- 422
							anchorY = 1, -- 422
							fontName = fontName, -- 422
							fontSize = 12, -- 422
							text = detailError, -- 422
							color3 = 4286505640 -- 422
						}) -- 422
					else -- 422
						____temp_19 = nil -- 422
					end -- 422
					____temp_23 = ____React_createElement_22( -- 422
						"node", -- 422
						____temp_20, -- 422
						____React_createElement_result_21, -- 422
						____temp_19, -- 422
						React.createElement("label", { -- 422
							x = 20, -- 422
							y = sheetHeight - 68, -- 422
							anchorX = 0, -- 422
							anchorY = 1, -- 422
							fontName = fontName, -- 422
							fontSize = 13, -- 422
							text = zh and "模型" or "Model", -- 422
							color3 = 11055037 -- 422
						}), -- 422
						React.createElement( -- 422
							"label", -- 422
							{ -- 422
								x = 20, -- 422
								y = sheetHeight - 94, -- 422
								anchorX = 0, -- 422
								anchorY = 1, -- 422
								fontName = fontName, -- 422
								fontSize = 15, -- 422
								text = compactText(detail.model, shortLandscape and 56 or 38), -- 422
								color3 = 16052712 -- 422
							} -- 422
						), -- 422
						React.createElement("label", { -- 422
							x = 20, -- 422
							y = sheetHeight - 132, -- 422
							anchorX = 0, -- 422
							anchorY = 1, -- 422
							fontName = fontName, -- 422
							fontSize = 13, -- 422
							text = "API URL", -- 422
							color3 = 11055037 -- 422
						}), -- 422
						React.createElement( -- 422
							"label", -- 422
							{ -- 422
								x = 20, -- 422
								y = sheetHeight - 158, -- 422
								anchorX = 0, -- 422
								anchorY = 1, -- 422
								fontName = fontName, -- 422
								fontSize = 13, -- 422
								text = compactText(detail.url, shortLandscape and 72 or 42), -- 422
								color3 = 16052712 -- 422
							} -- 422
						), -- 422
						React.createElement( -- 422
							"label", -- 422
							{ -- 422
								x = 20, -- 422
								y = sheetHeight - 200, -- 422
								anchorX = 0, -- 422
								anchorY = 1, -- 422
								fontName = fontName, -- 422
								fontSize = 13, -- 422
								text = ((((zh and "上下文" or "Context") .. "  ") .. tostring(detail.contextWindow)) .. "   ·   Function Call  ") .. (detail.supportsFunctionCalling and (zh and "支持" or "On") or (zh and "不支持" or "Off")), -- 422
								color3 = 11055037 -- 422
							} -- 422
						), -- 422
						React.createElement( -- 422
							MobileButton, -- 429
							{ -- 429
								tag = "mobile-llm-detail-key-edit", -- 429
								x = 20, -- 429
								y = 76, -- 429
								width = math.floor((contentWidth - 12) * 0.62), -- 429
								text = zh and "修改 API Key" or "Update API key", -- 429
								renderOrder = 10, -- 429
								onTapped = function() -- 429
									detailMode = "key" -- 429
									detailKey = "" -- 429
									detailError = "" -- 429
									render() -- 429
								end -- 429
							} -- 429
						), -- 429
						React.createElement( -- 429
							MobileButton, -- 430
							{ -- 430
								tag = "mobile-llm-detail-delete", -- 430
								x = 32 + math.floor((contentWidth - 12) * 0.62), -- 430
								y = 76, -- 430
								width = contentWidth - 12 - math.floor((contentWidth - 12) * 0.62), -- 430
								text = zh and "删除" or "Delete", -- 430
								danger = true, -- 430
								renderOrder = 10, -- 430
								onTapped = function() -- 430
									detailMode = "delete" -- 430
									detailError = "" -- 430
									render() -- 430
								end -- 430
							} -- 430
						), -- 430
						React.createElement( -- 430
							MobileButton, -- 431
							{ -- 431
								tag = "mobile-llm-detail-back", -- 431
								x = 20, -- 431
								y = 20, -- 431
								width = math.floor((contentWidth - 12) * 0.36), -- 431
								text = zh and "返回列表" or "Back", -- 431
								renderOrder = 10, -- 431
								onTapped = function() -- 431
									detailId = 0 -- 431
									render() -- 431
								end -- 431
							} -- 431
						), -- 431
						React.createElement( -- 431
							MobileButton, -- 432
							{ -- 432
								tag = "mobile-llm-detail-select", -- 432
								x = 32 + math.floor((contentWidth - 12) * 0.36), -- 432
								y = 20, -- 432
								width = contentWidth - 12 - math.floor((contentWidth - 12) * 0.36), -- 432
								text = detail.id == selectedId and (switchPending and (zh and "下一轮使用" or "Use next") or (options.taskRunning and (zh and "本轮使用" or "In this run") or (zh and "当前使用" or "In use"))) or (zh and "切换到此配置" or "Use this config"), -- 432
								primary = detail.id ~= selectedId, -- 432
								renderOrder = 10, -- 432
								onTapped = function() return select(detail.id) end -- 432
							} -- 432
						) -- 432
					) -- 432
				end -- 432
				____temp_24 = ____temp_23 -- 413
			end -- 413
			____detail_32 = ____temp_24 -- 400
		else -- 400
			local ____React_createElement_31 = React.createElement -- 400
			local ____array_30 = __TS__SparseArrayNew( -- 400
				"node", -- 400
				{tag = "mobile-llm-list"}, -- 400
				React.createElement("label", { -- 400
					x = 20, -- 400
					y = sheetHeight - 24, -- 400
					anchorX = 0, -- 400
					anchorY = 1, -- 400
					fontName = fontName, -- 400
					fontSize = 22, -- 400
					text = zh and "模型配置" or "Model configurations", -- 400
					color3 = 16052712 -- 400
				}), -- 400
				React.createElement("label", { -- 400
					x = 20, -- 400
					y = sheetHeight - 58, -- 400
					anchorX = 0, -- 400
					anchorY = 1, -- 400
					fontName = fontName, -- 400
					fontSize = 13, -- 400
					text = options.taskRunning and (zh and "切换将在下一轮生效" or "Changes apply to the next run") or (zh and "选择当前 Remix 使用的配置" or "Choose the configuration for Remix"), -- 400
					color3 = 11055037 -- 400
				}) -- 400
			) -- 400
			local ____temp_25 -- 439
			if pageCount > 1 then -- 439
				____temp_25 = React.createElement( -- 439
					"label", -- 439
					{ -- 439
						x = sheetWidth - 20, -- 439
						y = sheetHeight - 58, -- 439
						anchorX = 1, -- 439
						anchorY = 1, -- 439
						fontName = fontName, -- 439
						fontSize = 12, -- 439
						text = (tostring(page + 1) .. " / ") .. tostring(pageCount), -- 439
						color3 = 11055037 -- 439
					} -- 439
				) -- 439
			else -- 439
				____temp_25 = nil -- 439
			end -- 439
			__TS__SparseArrayPush( -- 439
				____array_30, -- 439
				____temp_25, -- 439
				__TS__ArrayMap( -- 440
					pageItems, -- 440
					function(____, item, index) -- 440
						local y = sheetHeight - 126 - index * 68 -- 441
						local selected = item.id == selectedId -- 442
						local ____React_createElement_28 = React.createElement -- 442
						local ____array_27 = __TS__SparseArrayNew( -- 442
							"node", -- 442
							{ -- 442
								key = tostring(item.id), -- 442
								tag = "mobile-llm-config-" .. tostring(item.id), -- 442
								x = 20, -- 442
								y = y, -- 442
								width = contentWidth, -- 442
								height = 54, -- 442
								anchorX = 0, -- 442
								anchorY = 0, -- 442
								touchEnabled = true, -- 442
								swallowTouches = true, -- 442
								onTapped = function() return select(item.id) end -- 442
							}, -- 442
							React.createElement(RoundedSurface, { -- 442
								width = contentWidth, -- 442
								height = 54, -- 442
								radius = 14, -- 442
								topColor = selected and 4282004512 or 4280626233, -- 442
								bottomColor = selected and 4280360210 or 4279704613, -- 442
								borderWidth = 1, -- 442
								borderColor = selected and 4294954035 or 4281613128 -- 442
							}), -- 442
							React.createElement( -- 442
								"draw-node", -- 442
								{x = 20, y = 27}, -- 442
								React.createElement("dot-shape", {radius = 8, color = selected and 4294954035 or 4285495432}), -- 442
								React.createElement("dot-shape", {radius = selected and 3 or 5, color = selected and 4279702282 or 4279704613}) -- 442
							), -- 442
							React.createElement( -- 442
								"label", -- 442
								{ -- 442
									x = 38, -- 442
									y = 34, -- 442
									anchorX = 0, -- 442
									fontName = fontName, -- 442
									fontSize = 15, -- 442
									text = compactText(item.name, shortLandscape and 34 or 22), -- 442
									color3 = 16052712 -- 442
								} -- 442
							), -- 442
							React.createElement( -- 442
								"label", -- 442
								{ -- 442
									x = 38, -- 442
									y = 15, -- 442
									anchorX = 0, -- 442
									fontName = fontName, -- 442
									fontSize = 11, -- 442
									text = compactText(item.model, shortLandscape and 52 or 30), -- 442
									color3 = 11055037 -- 442
								} -- 442
							) -- 442
						) -- 442
						local ____selected_26 -- 448
						if selected then -- 448
							____selected_26 = React.createElement("label", { -- 448
								x = contentWidth - 54, -- 448
								y = 27, -- 448
								anchorX = 1, -- 448
								fontName = fontName, -- 448
								fontSize = 11, -- 448
								text = switchPending and (zh and "下一轮" or "Next") or (options.taskRunning and (zh and "本轮" or "Running") or (zh and "当前" or "Current")), -- 448
								color3 = 16763955 -- 448
							}) -- 448
						else -- 448
							____selected_26 = nil -- 448
						end -- 448
						__TS__SparseArrayPush( -- 448
							____array_27, -- 448
							____selected_26, -- 448
							React.createElement( -- 448
								"node", -- 448
								{ -- 448
									tag = "mobile-llm-detail-" .. tostring(item.id), -- 448
									x = contentWidth - 44, -- 448
									y = 0, -- 448
									width = 44, -- 448
									height = 54, -- 448
									anchorX = 0, -- 448
									anchorY = 0, -- 448
									touchEnabled = true, -- 448
									swallowTouches = true, -- 448
									onTapped = function() return openDetail(item.id) end -- 448
								}, -- 448
								React.createElement("label", { -- 448
									x = 26, -- 448
									y = 27, -- 448
									fontName = fontName, -- 448
									fontSize = 18, -- 448
									text = "›", -- 448
									color3 = 11055037 -- 448
								}) -- 448
							) -- 448
						) -- 448
						return ____React_createElement_28(__TS__SparseArraySpread(____array_27)) -- 443
					end -- 440
				) -- 440
			) -- 440
			local ____temp_29 -- 454
			if pageCount > 1 then -- 454
				____temp_29 = React.createElement( -- 454
					"node", -- 454
					nil, -- 454
					React.createElement( -- 454
						MobileButton, -- 455
						{ -- 455
							tag = "mobile-llm-page-prev", -- 455
							x = 20, -- 455
							y = 20, -- 455
							width = 54, -- 455
							text = "‹", -- 455
							renderOrder = 10, -- 455
							onTapped = function() -- 455
								page = (page - 1 + pageCount) % pageCount -- 455
								render() -- 455
							end -- 455
						} -- 455
					), -- 455
					React.createElement( -- 455
						MobileButton, -- 456
						{ -- 456
							tag = "mobile-llm-page-next", -- 456
							x = 86, -- 456
							y = 20, -- 456
							width = 54, -- 456
							text = "›", -- 456
							renderOrder = 10, -- 456
							onTapped = function() -- 456
								page = (page + 1) % pageCount -- 456
								render() -- 456
							end -- 456
						} -- 456
					) -- 456
				) -- 456
			else -- 456
				____temp_29 = React.createElement( -- 456
					MobileButton, -- 457
					{ -- 457
						tag = "mobile-llm-close", -- 457
						x = 20, -- 457
						y = 20, -- 457
						width = math.floor(contentWidth * 0.28), -- 457
						text = zh and "关闭" or "Close", -- 457
						renderOrder = 10, -- 457
						onTapped = function() return close() end -- 457
					} -- 457
				) -- 457
			end -- 457
			__TS__SparseArrayPush( -- 457
				____array_30, -- 457
				____temp_29, -- 457
				React.createElement( -- 457
					MobileButton, -- 458
					{ -- 458
						tag = "mobile-llm-add", -- 458
						x = pageCount > 1 and 152 or 32 + math.floor(contentWidth * 0.28), -- 458
						y = 20, -- 458
						width = pageCount > 1 and contentWidth - 132 or contentWidth - 12 - math.floor(contentWidth * 0.28), -- 458
						text = zh and "＋ 从模板新增" or "+ Add from template", -- 458
						primary = true, -- 458
						renderOrder = 10, -- 458
						onTapped = add -- 458
					} -- 458
				) -- 458
			) -- 458
			____detail_32 = ____React_createElement_31(__TS__SparseArraySpread(____array_30)) -- 458
		end -- 458
		local scene = ____toNode_39(____React_createElement_38( -- 394
			"node", -- 394
			____temp_36, -- 394
			____React_createElement_result_37, -- 394
			____React_createElement_35("node", ____temp_33, ____React_createElement_result_34, ____detail_32) -- 394
		)) -- 394
		if scene then -- 394
			host:addChild(scene) -- 463
		end -- 463
	end -- 368
	local ____attachGamepad_42 = attachGamepad -- 465
	local ____opt_40 = __TS__ArrayFind( -- 465
		configs, -- 466
		function(____, item) return item.id == selectedId end -- 466
	) -- 466
	____attachGamepad_42( -- 465
		host, -- 465
		{ -- 465
			initialTag = "mobile-llm-config-" .. tostring(____opt_40 and ____opt_40.id or selectedId), -- 466
			onBack = function() -- 467
				if detailKeyInput.isFocused() then -- 467
					detailKeyInput.blur() -- 468
				elseif detailMode ~= "view" then -- 468
					detailMode = "view" -- 469
					detailKey = "" -- 469
					detailError = "" -- 469
					render() -- 469
				elseif detailId > 0 then -- 469
					detailId = 0 -- 470
					render() -- 470
				else -- 470
					close() -- 471
				end -- 471
			end -- 467
		} -- 467
	) -- 467
	host:onAppChange(function(setting) -- 474
		if setting == "Locale" then -- 474
			zh = (string.match(App.locale, "^zh")) ~= nil -- 475
		end -- 475
		if setting == "Size" or setting == "Locale" then -- 475
			render() -- 476
		end -- 476
	end) -- 474
	host:onAppEvent(function(event) -- 478
		if event == "BackButton" then -- 478
			if detailId > 0 then -- 478
				detailId = 0 -- 478
				render() -- 478
			else -- 478
				close() -- 478
			end -- 478
		end -- 478
	end) -- 478
	host:onCleanup(function() -- 479
		disposed = true -- 479
		restoreCovered() -- 479
		if activeSetup == host then -- 479
			activeSetup = nil -- 479
		end -- 479
	end) -- 479
	render() -- 480
	return host -- 481
end -- 258
return ____exports -- 258