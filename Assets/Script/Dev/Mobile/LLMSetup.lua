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
local ____LLMConfigMigration = require("Agent.Config.LLMConfigMigration") -- 4
local upgradeLLMConfig = ____LLMConfigMigration.upgradeLLMConfig -- 4
local ____Defaults = require("Agent.Config.Defaults") -- 5
local AGENT_DEFAULTS = ____Defaults.AGENT_DEFAULTS -- 5
local ____Accessibility = require("Dev.Mobile.Accessibility") -- 6
local mobileFontScale = ____Accessibility.mobileFontScale -- 6
local ____Controls = require("Dev.Mobile.Controls") -- 7
local MobileButton = ____Controls.MobileButton -- 7
local MobilePanelSurface = ____Controls.MobilePanelSurface -- 7
local ____TextInput = require("Dev.Mobile.TextInput") -- 8
local createTextInput = ____TextInput.createTextInput -- 8
local ____Visual = require("Dev.Mobile.Visual") -- 9
local RoundedSurface = ____Visual.RoundedSurface -- 9
function compactText(value, limit) -- 249
	local length = (utf8.len(value)) or 0 -- 250
	if length <= limit then -- 250
		return value -- 251
	end -- 251
	local stop = utf8.offset(value, limit) or #value -- 252
	return string.sub(value, 1, stop - 1) .. "…" -- 253
end -- 253
local function auxiliary(body) -- 36
	return ("{\"auxiliaryOptions\":" .. body) .. "}" -- 36
end -- 36
____exports.mobileLLMPresets = { -- 37
	{ -- 38
		id = "deepseek", -- 38
		name = "DeepSeek", -- 38
		url = "https://api.deepseek.com/v1/chat/completions", -- 38
		model = "deepseek-flash", -- 38
		contextWindow = 1000000, -- 38
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 38
		customOptions = auxiliary("{\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}") -- 38
	}, -- 38
	{ -- 39
		id = "moonshot", -- 39
		name = "Moonshot", -- 39
		url = "https://api.moonshot.cn/v1/chat/completions", -- 39
		model = "kimi-k3.1-pro", -- 39
		contextWindow = 1000000, -- 39
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 39
		customOptions = auxiliary("{\"reasoning_effort\":\"low\"}") -- 39
	}, -- 39
	{ -- 40
		id = "qwen", -- 40
		name = "Qwen", -- 40
		url = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions", -- 40
		model = "qwen3.8-max", -- 40
		contextWindow = 1000000, -- 40
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
		model = "deepseek-ai/DeepSeek-V4.1-Flash", -- 44
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
		model = "MiniMax-M3.1-Flash", -- 49
		contextWindow = 1000000, -- 49
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 49
		customOptions = auxiliary("{\"reasoning_effort\":\"low\",\"thinking\":{\"type\":\"adaptive\"}}") -- 49
	}, -- 49
	{ -- 50
		id = "minimax-cn", -- 50
		name = "MiniMax (CN)", -- 50
		url = "https://api.minimaxi.com/v1/chat/completions", -- 50
		model = "MiniMax-M3.1-Flash", -- 50
		contextWindow = 1000000, -- 50
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 50
		customOptions = auxiliary("{\"reasoning_effort\":\"low\",\"thinking\":{\"type\":\"adaptive\"}}") -- 50
	}, -- 50
	{ -- 51
		id = "mimo", -- 51
		name = "Xiaomi MiMo", -- 51
		url = "https://api.xiaomimimo.com/v1/chat/completions", -- 51
		model = "mimo-v2.6-pro", -- 51
		contextWindow = 1000000, -- 51
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 51
		customOptions = "{\"max_tokens\":null,\"max_completion_tokens\":64000,\"top_p\":0.95,\"auxiliaryOptions\":{\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}}" -- 51
	}, -- 51
	{ -- 52
		id = "zai", -- 52
		name = "ZAI", -- 52
		url = "https://open.bigmodel.cn/api/paas/v4/chat/completions", -- 52
		model = "glm-5.3", -- 52
		contextWindow = 1000000, -- 52
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 52
		customOptions = "{\"thinking\":{\"type\":\"enabled\"},\"auxiliaryOptions\":{\"reasoning_effort\":\"low\",\"thinking\":{\"type\":\"enabled\"}}}" -- 52
	}, -- 52
	{ -- 53
		id = "zai-coding-plan", -- 53
		name = "ZAI Coding Plan", -- 53
		url = "https://open.bigmodel.cn/api/coding/paas/v4/chat/completions", -- 53
		model = "glm-5.3", -- 53
		contextWindow = 1000000, -- 53
		maxTokens = AGENT_DEFAULTS.llmMaxTokens, -- 53
		customOptions = "{\"thinking\":{\"type\":\"enabled\"},\"auxiliaryOptions\":{\"reasoning_effort\":\"low\",\"thinking\":{\"type\":\"enabled\"}}}" -- 53
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
	DB:exec("CREATE TABLE IF NOT EXISTS LLMConfig(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tname TEXT NOT NULL, url TEXT NOT NULL, model TEXT NOT NULL, api_key TEXT NOT NULL,\n\t\tcontext_window INTEGER NOT NULL DEFAULT 64000, temperature REAL NOT NULL DEFAULT 0.1,\n\t\tmax_tokens INTEGER NOT NULL DEFAULT 64000, reasoning_effort TEXT NOT NULL DEFAULT '',\n\t\tcustom_options TEXT NOT NULL DEFAULT '',\n\t\tactive INTEGER NOT NULL DEFAULT 1, created_at INTEGER, updated_at INTEGER\n\t)") -- 63
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
		local affected = DB:exec("insert into LLMConfig(\n\t\t\tname, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort,\n\t\t\tcustom_options, active, created_at, updated_at\n\t\t) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 143
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
local function getMobileLLMConfigs() -- 232
	ensureLLMConfigTable() -- 233
	local rows = DB:query("select id, name, url, model, context_window\n\t\tfrom LLMConfig order by id asc") -- 234
	return __TS__ArrayFlatMap( -- 236
		rows or ({}), -- 236
		function(____, row) -- 236
			local id = tonumber(row[1]) -- 237
			if not id then -- 237
				return {} -- 238
			end -- 238
			return {{ -- 239
				id = id, -- 240
				name = tostring(row[2]), -- 241
				url = tostring(row[3]), -- 242
				model = tostring(row[4]), -- 243
				contextWindow = tonumber(row[5]) or 128000 -- 244
			}} -- 244
		end -- 236
	) -- 236
end -- 232
function ____exports.startMobileLLMManager(options) -- 256
	local render -- 256
	local configs = getMobileLLMConfigs() -- 257
	if #configs == 0 then -- 257
		return ____exports.startMobileLLMSetup({coveredNode = options.coveredNode, onSaved = options.onSelected, onClose = options.onClose}) -- 259
	end -- 259
	if activeSetup ~= nil then -- 259
		activeSetup:removeFromParent(true) -- 265
	end -- 265
	local coveredNode = options.coveredNode -- 266
	if coveredNode then -- 266
		coveredNode.visible = false -- 267
	end -- 267
	local coveredRestored = false -- 268
	local function restoreCovered() -- 269
		if coveredRestored then -- 269
			return -- 270
		end -- 270
		coveredRestored = true -- 271
		if coveredNode and coveredNode.parent then -- 271
			coveredNode.visible = true -- 272
		end -- 272
	end -- 269
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 274
	local host = Node() -- 275
	host.tag = "mobile-llm-manager" -- 276
	host.order = 10000 -- 277
	host.renderGroup = true -- 278
	host.scaleX = App.devicePixelRatio -- 279
	host.scaleY = App.devicePixelRatio -- 280
	host:addTo(Director.systemUI) -- 281
	activeSetup = host -- 282
	local page = -1 -- 283
	local detailId = 0 -- 284
	local detailMode = "view" -- 285
	local detailKey = "" -- 286
	local detailError = "" -- 287
	local selectedId = options.selectedId -- 288
	local disposed = false -- 289
	local detailKeyRef = reference() -- 290
	local function canEdit() -- 291
		return not disposed and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 -- 291
	end -- 291
	local detailKeyInput = createTextInput({ -- 292
		fontSize = math.floor(15 * mobileFontScale), -- 293
		singleLine = true, -- 293
		isSecure = function() return true end, -- 293
		getText = function() return detailKey end, -- 294
		setText = function(value) -- 294
			detailKey = value -- 294
			detailError = "" -- 294
		end, -- 294
		getPlaceholder = function() return zh and "粘贴新的 API Key" or "Paste a new API key" end, -- 295
		isEnabled = canEdit, -- 295
		onReturn = function() return true end -- 296
	}) -- 296
	local function close(notify) -- 298
		if notify == nil then -- 298
			notify = true -- 298
		end -- 298
		if disposed then -- 298
			return -- 299
		end -- 299
		disposed = true -- 300
		detailKeyInput.blur() -- 301
		restoreCovered() -- 302
		host:removeFromParent(true) -- 303
		if activeSetup == host then -- 303
			activeSetup = nil -- 304
		end -- 304
		if notify then -- 304
			local ____opt_12 = options.onClose -- 304
			if ____opt_12 ~= nil then -- 304
				____opt_12() -- 305
			end -- 305
		end -- 305
	end -- 298
	local function select(id) -- 307
		DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", {id}) -- 308
		options.onSelected(id) -- 309
		close() -- 310
	end -- 307
	local function openDetail(id) -- 312
		detailId = id -- 313
		detailMode = "view" -- 314
		detailKey = "" -- 315
		detailError = "" -- 316
		render() -- 317
	end -- 312
	local function saveDetailKey() -- 319
		if not canEdit() or detailId <= 0 then -- 319
			return -- 320
		end -- 320
		local key = trim(detailKey) -- 321
		if key == "" then -- 321
			detailError = zh and "请粘贴新的 API Key" or "Paste a new API key" -- 322
			render() -- 322
			return -- 322
		end -- 322
		local affected = DB:exec( -- 323
			"update LLMConfig set api_key = ?, updated_at = ? where id = ?", -- 323
			{ -- 323
				key, -- 323
				os.time(), -- 323
				detailId -- 323
			} -- 323
		) -- 323
		if affected <= 0 then -- 323
			detailError = zh and "API Key 保存失败" or "Could not save the API key" -- 324
			render() -- 324
			return -- 324
		end -- 324
		detailKeyInput.blur() -- 325
		detailKey = "" -- 326
		detailError = zh and "API Key 已更新" or "API key updated" -- 327
		detailMode = "view" -- 328
		render() -- 329
	end -- 319
	local function deleteDetail() -- 331
		if not canEdit() or detailId <= 0 then -- 331
			return -- 332
		end -- 332
		local deletingId = detailId -- 333
		local affected = DB:exec("delete from LLMConfig where id = ?", {deletingId}) -- 334
		if affected <= 0 then -- 334
			detailError = zh and "删除失败，请重试" or "Could not delete the configuration" -- 335
			render() -- 335
			return -- 335
		end -- 335
		configs = getMobileLLMConfigs() -- 336
		if selectedId == deletingId then -- 336
			local ____opt_14 = configs[1] -- 336
			selectedId = ____opt_14 and ____opt_14.id or 0 -- 338
			if selectedId > 0 then -- 338
				DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", {selectedId}) -- 339
			else -- 339
				DB:exec("delete from Config where name = 'mobileRemixLLMConfigId'") -- 340
			end -- 340
			options.onSelected(selectedId) -- 341
		end -- 341
		detailId = 0 -- 343
		detailMode = "view" -- 344
		detailKey = "" -- 345
		detailError = "" -- 346
		page = -1 -- 347
		if #configs > 0 then -- 347
			render() -- 348
		else -- 348
			close(false) -- 350
			____exports.startMobileLLMSetup({coveredNode = coveredNode, onSaved = options.onSelected, onClose = options.onClose}) -- 351
		end -- 351
	end -- 331
	local function add() -- 354
		close(false) -- 355
		local saved = false -- 356
		____exports.startMobileLLMSetup({ -- 357
			coveredNode = coveredNode, -- 358
			onSaved = function(id) -- 359
				saved = true -- 359
				options.onSelected(id) -- 359
			end, -- 359
			onClose = function() -- 360
				if saved then -- 360
					local ____opt_16 = options.onClose -- 360
					if ____opt_16 ~= nil then -- 360
						____opt_16() -- 361
					end -- 361
				else -- 361
					____exports.startMobileLLMManager(options) -- 362
				end -- 362
			end -- 360
		}) -- 360
	end -- 354
	render = function() -- 366
		if disposed then -- 366
			return -- 367
		end -- 367
		detailKeyInput.unmount() -- 368
		detailKeyRef = reference() -- 369
		host:removeAllChildren() -- 370
		host.scaleX = App.devicePixelRatio -- 371
		host.scaleY = App.devicePixelRatio -- 372
		local ____App_visualSize_18 = App.visualSize -- 373
		local width = ____App_visualSize_18.width -- 373
		local height = ____App_visualSize_18.height -- 373
		local safe = App.safeArea -- 374
		local shortLandscape = safe.width >= 760 and safe.height < 500 -- 375
		local rowsPerPage = shortLandscape and 3 or 5 -- 376
		local desiredHeight = detailId > 0 and 410 or math.max( -- 377
			260, -- 377
			160 + math.min(#configs, rowsPerPage) * 68 -- 377
		) -- 377
		local sheetWidth = shortLandscape and math.min(720, safe.width - 24) or safe.width -- 378
		local sheetHeight = math.min(desiredHeight, safe.height - (shortLandscape and 16 or 20)) -- 379
		local left = safe.x + (safe.width - sheetWidth) / 2 -- 380
		local bottom = safe.y -- 381
		local contentWidth = sheetWidth - 40 -- 382
		local pageCount = math.max( -- 383
			1, -- 383
			math.ceil(#configs / rowsPerPage) -- 383
		) -- 383
		if page < 0 then -- 383
			local selectedIndex = __TS__ArrayFindIndex( -- 385
				configs, -- 385
				function(____, item) return item.id == selectedId end -- 385
			) -- 385
			page = selectedIndex < 0 and 0 or math.floor(selectedIndex / rowsPerPage) -- 386
		end -- 386
		page = math.max( -- 388
			0, -- 388
			math.min(pageCount - 1, page) -- 388
		) -- 388
		local pageItems = __TS__ArraySlice(configs, page * rowsPerPage, (page + 1) * rowsPerPage) -- 389
		local detail = __TS__ArrayFind( -- 390
			configs, -- 390
			function(____, item) return item.id == detailId end -- 390
		) -- 390
		local switchPending = options.taskRunning and (options.runningId or selectedId) ~= selectedId -- 391
		local ____toNode_39 = toNode -- 392
		local ____React_createElement_38 = React.createElement -- 392
		local ____temp_36 = { -- 392
			order = 10000, -- 392
			x = -width / 2, -- 392
			y = -height / 2, -- 392
			width = width, -- 392
			height = height, -- 392
			anchorX = 0, -- 392
			anchorY = 0 -- 392
		} -- 392
		local ____React_createElement_result_37 = React.createElement( -- 392
			"node", -- 392
			{ -- 392
				tag = "mobile-llm-manager-backdrop", -- 392
				width = width, -- 392
				height = height, -- 392
				anchorX = 0, -- 392
				anchorY = 0, -- 392
				touchEnabled = true, -- 392
				swallowTouches = true, -- 392
				onTapped = function() return close() end -- 392
			}, -- 392
			React.createElement(RoundedSurface, { -- 392
				width = width, -- 392
				height = height, -- 392
				radius = 0, -- 392
				fillColor = 2348810240, -- 392
				renderOrder = 0 -- 392
			}) -- 392
		) -- 392
		local ____React_createElement_35 = React.createElement -- 392
		local ____temp_33 = { -- 392
			order = 10, -- 392
			x = left, -- 392
			y = bottom, -- 392
			width = sheetWidth, -- 392
			height = sheetHeight, -- 392
			anchorX = 0, -- 392
			anchorY = 0, -- 392
			touchEnabled = true, -- 392
			swallowTouches = true -- 392
		} -- 392
		local ____React_createElement_result_34 = React.createElement(MobilePanelSurface, {width = sheetWidth, height = sheetHeight, renderOrder = 10}) -- 392
		local ____detail_32 -- 398
		if detail then -- 398
			local ____temp_24 -- 398
			if detailMode == "key" then -- 398
				____temp_24 = React.createElement( -- 398
					"node", -- 398
					{tag = "mobile-llm-detail-key"}, -- 398
					React.createElement("label", { -- 398
						x = 20, -- 398
						y = sheetHeight - 24, -- 398
						anchorX = 0, -- 398
						anchorY = 1, -- 398
						fontName = fontName, -- 398
						fontSize = 22, -- 398
						text = zh and "修改 API Key" or "Update API key", -- 398
						color3 = 16052712 -- 398
					}), -- 398
					React.createElement( -- 398
						"label", -- 398
						{ -- 398
							x = 20, -- 398
							y = sheetHeight - 66, -- 398
							anchorX = 0, -- 398
							anchorY = 1, -- 398
							fontName = fontName, -- 398
							fontSize = 13, -- 398
							text = compactText(detail.name, shortLandscape and 44 or 28), -- 398
							color3 = 11055037 -- 398
						} -- 398
					), -- 398
					React.createElement("label", { -- 398
						x = 20, -- 398
						y = sheetHeight - 104, -- 398
						anchorX = 0, -- 398
						anchorY = 1, -- 398
						fontName = fontName, -- 398
						fontSize = 13, -- 398
						text = zh and "原 Key 不会显示，保存后立即替换" or "The current key stays hidden and will be replaced", -- 398
						color3 = 11055037 -- 398
					}), -- 398
					React.createElement("node", { -- 398
						tag = "mobile-llm-detail-key-input", -- 398
						ref = detailKeyRef, -- 398
						renderOrder = 10, -- 398
						x = 20, -- 398
						y = sheetHeight - 166, -- 398
						width = contentWidth - 104, -- 398
						height = 44, -- 398
						anchorX = 0, -- 398
						anchorY = 0, -- 398
						onMount = detailKeyInput.mount -- 398
					}), -- 398
					React.createElement( -- 398
						MobileButton, -- 403
						{ -- 403
							tag = "mobile-llm-detail-key-paste", -- 403
							x = contentWidth - 72, -- 403
							y = sheetHeight - 168, -- 403
							width = 92, -- 403
							text = zh and "粘贴" or "Paste", -- 403
							renderOrder = 10, -- 403
							onTapped = function() -- 403
								if not detailKeyInput.pasteFromClipboard(true) then -- 403
									detailError = zh and "剪贴板为空" or "Clipboard is empty" -- 404
								else -- 404
									detailError = "" -- 405
								end -- 405
								detailKeyInput.refresh() -- 406
							end -- 403
						} -- 403
					), -- 403
					React.createElement("label", { -- 403
						x = 20, -- 403
						y = 82, -- 403
						anchorX = 0, -- 403
						fontName = fontName, -- 403
						fontSize = 12, -- 403
						text = detailError, -- 403
						textWidth = contentWidth, -- 403
						alignment = "Left", -- 403
						color3 = 16739179 -- 403
					}), -- 403
					React.createElement( -- 403
						MobileButton, -- 409
						{ -- 409
							tag = "mobile-llm-detail-key-cancel", -- 409
							x = 20, -- 409
							y = 20, -- 409
							width = math.floor((contentWidth - 12) * 0.36), -- 409
							text = zh and "取消" or "Cancel", -- 409
							renderOrder = 10, -- 409
							onTapped = function() -- 409
								detailKeyInput.blur() -- 409
								detailMode = "view" -- 409
								detailKey = "" -- 409
								detailError = "" -- 409
								render() -- 409
							end -- 409
						} -- 409
					), -- 409
					React.createElement( -- 409
						MobileButton, -- 410
						{ -- 410
							tag = "mobile-llm-detail-key-save", -- 410
							x = 32 + math.floor((contentWidth - 12) * 0.36), -- 410
							y = 20, -- 410
							width = contentWidth - 12 - math.floor((contentWidth - 12) * 0.36), -- 410
							text = zh and "保存新 Key" or "Save new key", -- 410
							primary = true, -- 410
							renderOrder = 10, -- 410
							onTapped = saveDetailKey -- 410
						} -- 410
					) -- 410
				) -- 410
			else -- 410
				local ____temp_23 -- 411
				if detailMode == "delete" then -- 411
					____temp_23 = React.createElement( -- 411
						"node", -- 411
						{tag = "mobile-llm-detail-delete"}, -- 411
						React.createElement("label", { -- 411
							x = 20, -- 411
							y = sheetHeight - 24, -- 411
							anchorX = 0, -- 411
							anchorY = 1, -- 411
							fontName = fontName, -- 411
							fontSize = 22, -- 411
							text = zh and "删除这个配置？" or "Delete this configuration?", -- 411
							color3 = 16052712 -- 411
						}), -- 411
						React.createElement( -- 411
							"label", -- 411
							{ -- 411
								x = 20, -- 411
								y = sheetHeight - 78, -- 411
								anchorX = 0, -- 411
								anchorY = 1, -- 411
								fontName = fontName, -- 411
								fontSize = 16, -- 411
								text = compactText(detail.name, shortLandscape and 52 or 32), -- 411
								color3 = 4294935941 -- 411
							} -- 411
						), -- 411
						React.createElement("label", { -- 411
							x = 20, -- 411
							y = sheetHeight - 120, -- 411
							anchorX = 0, -- 411
							anchorY = 1, -- 411
							fontName = fontName, -- 411
							fontSize = 13, -- 411
							text = zh and "删除后无法恢复；若它是当前配置，将自动切换到下一项。" or "This cannot be undone. The next configuration will become active.", -- 411
							textWidth = contentWidth, -- 411
							alignment = "Left", -- 411
							color3 = 11055037 -- 411
						}), -- 411
						React.createElement("label", { -- 411
							x = 20, -- 411
							y = 82, -- 411
							anchorX = 0, -- 411
							fontName = fontName, -- 411
							fontSize = 12, -- 411
							text = detailError, -- 411
							textWidth = contentWidth, -- 411
							alignment = "Left", -- 411
							color3 = 16739179 -- 411
						}), -- 411
						React.createElement( -- 411
							MobileButton, -- 416
							{ -- 416
								tag = "mobile-llm-detail-delete-cancel", -- 416
								x = 20, -- 416
								y = 20, -- 416
								width = math.floor((contentWidth - 12) * 0.42), -- 416
								text = zh and "保留配置" or "Keep it", -- 416
								renderOrder = 10, -- 416
								onTapped = function() -- 416
									detailMode = "view" -- 416
									detailError = "" -- 416
									render() -- 416
								end -- 416
							} -- 416
						), -- 416
						React.createElement( -- 416
							MobileButton, -- 417
							{ -- 417
								tag = "mobile-llm-detail-delete-confirm", -- 417
								x = 32 + math.floor((contentWidth - 12) * 0.42), -- 417
								y = 20, -- 417
								width = contentWidth - 12 - math.floor((contentWidth - 12) * 0.42), -- 417
								text = zh and "确认删除" or "Delete", -- 417
								danger = true, -- 417
								renderOrder = 10, -- 417
								onTapped = deleteDetail -- 417
							} -- 417
						) -- 417
					) -- 417
				else -- 417
					local ____React_createElement_22 = React.createElement -- 417
					local ____temp_20 = {tag = "mobile-llm-detail"} -- 417
					local ____React_createElement_result_21 = React.createElement( -- 417
						"label", -- 417
						{ -- 417
							x = 20, -- 417
							y = sheetHeight - 24, -- 417
							anchorX = 0, -- 417
							anchorY = 1, -- 417
							fontName = fontName, -- 417
							fontSize = 22, -- 417
							text = compactText(detail.name, 28), -- 417
							color3 = 16052712 -- 417
						} -- 417
					) -- 417
					local ____temp_19 -- 420
					if detailError ~= "" then -- 420
						____temp_19 = React.createElement("label", { -- 420
							x = sheetWidth - 20, -- 420
							y = sheetHeight - 25, -- 420
							anchorX = 1, -- 420
							anchorY = 1, -- 420
							fontName = fontName, -- 420
							fontSize = 12, -- 420
							text = detailError, -- 420
							color3 = 4286505640 -- 420
						}) -- 420
					else -- 420
						____temp_19 = nil -- 420
					end -- 420
					____temp_23 = ____React_createElement_22( -- 420
						"node", -- 420
						____temp_20, -- 420
						____React_createElement_result_21, -- 420
						____temp_19, -- 420
						React.createElement("label", { -- 420
							x = 20, -- 420
							y = sheetHeight - 68, -- 420
							anchorX = 0, -- 420
							anchorY = 1, -- 420
							fontName = fontName, -- 420
							fontSize = 13, -- 420
							text = zh and "模型" or "Model", -- 420
							color3 = 11055037 -- 420
						}), -- 420
						React.createElement( -- 420
							"label", -- 420
							{ -- 420
								x = 20, -- 420
								y = sheetHeight - 94, -- 420
								anchorX = 0, -- 420
								anchorY = 1, -- 420
								fontName = fontName, -- 420
								fontSize = 15, -- 420
								text = compactText(detail.model, shortLandscape and 56 or 38), -- 420
								color3 = 16052712 -- 420
							} -- 420
						), -- 420
						React.createElement("label", { -- 420
							x = 20, -- 420
							y = sheetHeight - 132, -- 420
							anchorX = 0, -- 420
							anchorY = 1, -- 420
							fontName = fontName, -- 420
							fontSize = 13, -- 420
							text = "API URL", -- 420
							color3 = 11055037 -- 420
						}), -- 420
						React.createElement( -- 420
							"label", -- 420
							{ -- 420
								x = 20, -- 420
								y = sheetHeight - 158, -- 420
								anchorX = 0, -- 420
								anchorY = 1, -- 420
								fontName = fontName, -- 420
								fontSize = 13, -- 420
								text = compactText(detail.url, shortLandscape and 72 or 42), -- 420
								color3 = 16052712 -- 420
							} -- 420
						), -- 420
						React.createElement( -- 420
							"label", -- 420
							{ -- 420
								x = 20, -- 420
								y = sheetHeight - 200, -- 420
								anchorX = 0, -- 420
								anchorY = 1, -- 420
								fontName = fontName, -- 420
								fontSize = 13, -- 420
								text = ((zh and "上下文" or "Context") .. "  ") .. tostring(detail.contextWindow), -- 420
								color3 = 11055037 -- 420
							} -- 420
						), -- 420
						React.createElement( -- 420
							MobileButton, -- 427
							{ -- 427
								tag = "mobile-llm-detail-key-edit", -- 427
								x = 20, -- 427
								y = 76, -- 427
								width = math.floor((contentWidth - 12) * 0.62), -- 427
								text = zh and "修改 API Key" or "Update API key", -- 427
								renderOrder = 10, -- 427
								onTapped = function() -- 427
									detailMode = "key" -- 427
									detailKey = "" -- 427
									detailError = "" -- 427
									render() -- 427
								end -- 427
							} -- 427
						), -- 427
						React.createElement( -- 427
							MobileButton, -- 428
							{ -- 428
								tag = "mobile-llm-detail-delete", -- 428
								x = 32 + math.floor((contentWidth - 12) * 0.62), -- 428
								y = 76, -- 428
								width = contentWidth - 12 - math.floor((contentWidth - 12) * 0.62), -- 428
								text = zh and "删除" or "Delete", -- 428
								danger = true, -- 428
								renderOrder = 10, -- 428
								onTapped = function() -- 428
									detailMode = "delete" -- 428
									detailError = "" -- 428
									render() -- 428
								end -- 428
							} -- 428
						), -- 428
						React.createElement( -- 428
							MobileButton, -- 429
							{ -- 429
								tag = "mobile-llm-detail-back", -- 429
								x = 20, -- 429
								y = 20, -- 429
								width = math.floor((contentWidth - 12) * 0.36), -- 429
								text = zh and "返回列表" or "Back", -- 429
								renderOrder = 10, -- 429
								onTapped = function() -- 429
									detailId = 0 -- 429
									render() -- 429
								end -- 429
							} -- 429
						), -- 429
						React.createElement( -- 429
							MobileButton, -- 430
							{ -- 430
								tag = "mobile-llm-detail-select", -- 430
								x = 32 + math.floor((contentWidth - 12) * 0.36), -- 430
								y = 20, -- 430
								width = contentWidth - 12 - math.floor((contentWidth - 12) * 0.36), -- 430
								text = detail.id == selectedId and (switchPending and (zh and "下一轮使用" or "Use next") or (options.taskRunning and (zh and "本轮使用" or "In this run") or (zh and "当前使用" or "In use"))) or (zh and "切换到此配置" or "Use this config"), -- 430
								primary = detail.id ~= selectedId, -- 430
								renderOrder = 10, -- 430
								onTapped = function() return select(detail.id) end -- 430
							} -- 430
						) -- 430
					) -- 430
				end -- 430
				____temp_24 = ____temp_23 -- 411
			end -- 411
			____detail_32 = ____temp_24 -- 398
		else -- 398
			local ____React_createElement_31 = React.createElement -- 398
			local ____array_30 = __TS__SparseArrayNew( -- 398
				"node", -- 398
				{tag = "mobile-llm-list"}, -- 398
				React.createElement("label", { -- 398
					x = 20, -- 398
					y = sheetHeight - 24, -- 398
					anchorX = 0, -- 398
					anchorY = 1, -- 398
					fontName = fontName, -- 398
					fontSize = 22, -- 398
					text = zh and "模型配置" or "Model configurations", -- 398
					color3 = 16052712 -- 398
				}), -- 398
				React.createElement("label", { -- 398
					x = 20, -- 398
					y = sheetHeight - 58, -- 398
					anchorX = 0, -- 398
					anchorY = 1, -- 398
					fontName = fontName, -- 398
					fontSize = 13, -- 398
					text = options.taskRunning and (zh and "切换将在下一轮生效" or "Changes apply to the next run") or (zh and "选择当前 Remix 使用的配置" or "Choose the configuration for Remix"), -- 398
					color3 = 11055037 -- 398
				}) -- 398
			) -- 398
			local ____temp_25 -- 437
			if pageCount > 1 then -- 437
				____temp_25 = React.createElement( -- 437
					"label", -- 437
					{ -- 437
						x = sheetWidth - 20, -- 437
						y = sheetHeight - 58, -- 437
						anchorX = 1, -- 437
						anchorY = 1, -- 437
						fontName = fontName, -- 437
						fontSize = 12, -- 437
						text = (tostring(page + 1) .. " / ") .. tostring(pageCount), -- 437
						color3 = 11055037 -- 437
					} -- 437
				) -- 437
			else -- 437
				____temp_25 = nil -- 437
			end -- 437
			__TS__SparseArrayPush( -- 437
				____array_30, -- 437
				____temp_25, -- 437
				__TS__ArrayMap( -- 438
					pageItems, -- 438
					function(____, item, index) -- 438
						local y = sheetHeight - 126 - index * 68 -- 439
						local selected = item.id == selectedId -- 440
						local ____React_createElement_28 = React.createElement -- 440
						local ____array_27 = __TS__SparseArrayNew( -- 440
							"node", -- 440
							{ -- 440
								key = tostring(item.id), -- 440
								tag = "mobile-llm-config-" .. tostring(item.id), -- 440
								x = 20, -- 440
								y = y, -- 440
								width = contentWidth, -- 440
								height = 54, -- 440
								anchorX = 0, -- 440
								anchorY = 0, -- 440
								touchEnabled = true, -- 440
								swallowTouches = true, -- 440
								onTapped = function() return select(item.id) end -- 440
							}, -- 440
							React.createElement(RoundedSurface, { -- 440
								width = contentWidth, -- 440
								height = 54, -- 440
								radius = 14, -- 440
								topColor = selected and 4282004512 or 4280626233, -- 440
								bottomColor = selected and 4280360210 or 4279704613, -- 440
								borderWidth = 1, -- 440
								borderColor = selected and 4294954035 or 4281613128 -- 440
							}), -- 440
							React.createElement( -- 440
								"draw-node", -- 440
								{x = 20, y = 27}, -- 440
								React.createElement("dot-shape", {radius = 8, color = selected and 4294954035 or 4285495432}), -- 440
								React.createElement("dot-shape", {radius = selected and 3 or 5, color = selected and 4279702282 or 4279704613}) -- 440
							), -- 440
							React.createElement( -- 440
								"label", -- 440
								{ -- 440
									x = 38, -- 440
									y = 34, -- 440
									anchorX = 0, -- 440
									fontName = fontName, -- 440
									fontSize = 15, -- 440
									text = compactText(item.name, shortLandscape and 34 or 22), -- 440
									color3 = 16052712 -- 440
								} -- 440
							), -- 440
							React.createElement( -- 440
								"label", -- 440
								{ -- 440
									x = 38, -- 440
									y = 15, -- 440
									anchorX = 0, -- 440
									fontName = fontName, -- 440
									fontSize = 11, -- 440
									text = compactText(item.model, shortLandscape and 52 or 30), -- 440
									color3 = 11055037 -- 440
								} -- 440
							) -- 440
						) -- 440
						local ____selected_26 -- 446
						if selected then -- 446
							____selected_26 = React.createElement("label", { -- 446
								x = contentWidth - 54, -- 446
								y = 27, -- 446
								anchorX = 1, -- 446
								fontName = fontName, -- 446
								fontSize = 11, -- 446
								text = switchPending and (zh and "下一轮" or "Next") or (options.taskRunning and (zh and "本轮" or "Running") or (zh and "当前" or "Current")), -- 446
								color3 = 16763955 -- 446
							}) -- 446
						else -- 446
							____selected_26 = nil -- 446
						end -- 446
						__TS__SparseArrayPush( -- 446
							____array_27, -- 446
							____selected_26, -- 446
							React.createElement( -- 446
								"node", -- 446
								{ -- 446
									tag = "mobile-llm-detail-" .. tostring(item.id), -- 446
									x = contentWidth - 44, -- 446
									y = 0, -- 446
									width = 44, -- 446
									height = 54, -- 446
									anchorX = 0, -- 446
									anchorY = 0, -- 446
									touchEnabled = true, -- 446
									swallowTouches = true, -- 446
									onTapped = function() return openDetail(item.id) end -- 446
								}, -- 446
								React.createElement("label", { -- 446
									x = 26, -- 446
									y = 27, -- 446
									fontName = fontName, -- 446
									fontSize = 18, -- 446
									text = "›", -- 446
									color3 = 11055037 -- 446
								}) -- 446
							) -- 446
						) -- 446
						return ____React_createElement_28(__TS__SparseArraySpread(____array_27)) -- 441
					end -- 438
				) -- 438
			) -- 438
			local ____temp_29 -- 452
			if pageCount > 1 then -- 452
				____temp_29 = React.createElement( -- 452
					"node", -- 452
					nil, -- 452
					React.createElement( -- 452
						MobileButton, -- 453
						{ -- 453
							tag = "mobile-llm-page-prev", -- 453
							x = 20, -- 453
							y = 20, -- 453
							width = 54, -- 453
							text = "‹", -- 453
							renderOrder = 10, -- 453
							onTapped = function() -- 453
								page = (page - 1 + pageCount) % pageCount -- 453
								render() -- 453
							end -- 453
						} -- 453
					), -- 453
					React.createElement( -- 453
						MobileButton, -- 454
						{ -- 454
							tag = "mobile-llm-page-next", -- 454
							x = 86, -- 454
							y = 20, -- 454
							width = 54, -- 454
							text = "›", -- 454
							renderOrder = 10, -- 454
							onTapped = function() -- 454
								page = (page + 1) % pageCount -- 454
								render() -- 454
							end -- 454
						} -- 454
					) -- 454
				) -- 454
			else -- 454
				____temp_29 = React.createElement( -- 454
					MobileButton, -- 455
					{ -- 455
						tag = "mobile-llm-close", -- 455
						x = 20, -- 455
						y = 20, -- 455
						width = math.floor(contentWidth * 0.28), -- 455
						text = zh and "关闭" or "Close", -- 455
						renderOrder = 10, -- 455
						onTapped = function() return close() end -- 455
					} -- 455
				) -- 455
			end -- 455
			__TS__SparseArrayPush( -- 455
				____array_30, -- 455
				____temp_29, -- 455
				React.createElement( -- 455
					MobileButton, -- 456
					{ -- 456
						tag = "mobile-llm-add", -- 456
						x = pageCount > 1 and 152 or 32 + math.floor(contentWidth * 0.28), -- 456
						y = 20, -- 456
						width = pageCount > 1 and contentWidth - 132 or contentWidth - 12 - math.floor(contentWidth * 0.28), -- 456
						text = zh and "＋ 从模板新增" or "+ Add from template", -- 456
						primary = true, -- 456
						renderOrder = 10, -- 456
						onTapped = add -- 456
					} -- 456
				) -- 456
			) -- 456
			____detail_32 = ____React_createElement_31(__TS__SparseArraySpread(____array_30)) -- 456
		end -- 456
		local scene = ____toNode_39(____React_createElement_38( -- 392
			"node", -- 392
			____temp_36, -- 392
			____React_createElement_result_37, -- 392
			____React_createElement_35("node", ____temp_33, ____React_createElement_result_34, ____detail_32) -- 392
		)) -- 392
		if scene then -- 392
			host:addChild(scene) -- 461
		end -- 461
	end -- 366
	local ____attachGamepad_42 = attachGamepad -- 463
	local ____opt_40 = __TS__ArrayFind( -- 463
		configs, -- 464
		function(____, item) return item.id == selectedId end -- 464
	) -- 464
	____attachGamepad_42( -- 463
		host, -- 463
		{ -- 463
			initialTag = "mobile-llm-config-" .. tostring(____opt_40 and ____opt_40.id or selectedId), -- 464
			onBack = function() -- 465
				if detailKeyInput.isFocused() then -- 465
					detailKeyInput.blur() -- 466
				elseif detailMode ~= "view" then -- 466
					detailMode = "view" -- 467
					detailKey = "" -- 467
					detailError = "" -- 467
					render() -- 467
				elseif detailId > 0 then -- 467
					detailId = 0 -- 468
					render() -- 468
				else -- 468
					close() -- 469
				end -- 469
			end -- 465
		} -- 465
	) -- 465
	host:onAppChange(function(setting) -- 472
		if setting == "Locale" then -- 472
			zh = (string.match(App.locale, "^zh")) ~= nil -- 473
		end -- 473
		if setting == "Size" or setting == "Locale" then -- 473
			render() -- 474
		end -- 474
	end) -- 472
	host:onAppEvent(function(event) -- 476
		if event == "BackButton" then -- 476
			if detailId > 0 then -- 476
				detailId = 0 -- 476
				render() -- 476
			else -- 476
				close() -- 476
			end -- 476
		end -- 476
	end) -- 476
	host:onCleanup(function() -- 477
		disposed = true -- 477
		restoreCovered() -- 477
		if activeSetup == host then -- 477
			activeSetup = nil -- 477
		end -- 477
	end) -- 477
	render() -- 478
	return host -- 479
end -- 256
return ____exports -- 256