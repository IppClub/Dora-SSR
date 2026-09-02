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
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local DB = ____Dora.DB -- 2
local Director = ____Dora.Director -- 2
local HttpServer = ____Dora.HttpServer -- 2
local Node = ____Dora.Node -- 2
local ____Accessibility = require("Dev.Mobile.Accessibility") -- 3
local mobileFontScale = ____Accessibility.mobileFontScale -- 3
local ____Controls = require("Dev.Mobile.Controls") -- 4
local MobileButton = ____Controls.MobileButton -- 4
local MobilePanelSurface = ____Controls.MobilePanelSurface -- 4
local ____TextInput = require("Dev.Mobile.TextInput") -- 5
local createTextInput = ____TextInput.createTextInput -- 5
local ____Visual = require("Dev.Mobile.Visual") -- 6
local RoundedSurface = ____Visual.RoundedSurface -- 6
function compactText(value, limit) -- 240
	local length = (utf8.len(value)) or 0 -- 241
	if length <= limit then -- 241
		return value -- 242
	end -- 242
	local stop = utf8.offset(value, limit) or #value -- 243
	return string.sub(value, 1, stop - 1) .. "…" -- 244
end -- 244
local function auxiliary(body) -- 33
	return ("{\"auxiliaryOptions\":" .. body) .. "}" -- 33
end -- 33
____exports.mobileLLMPresets = { -- 34
	{ -- 35
		id = "deepseek", -- 35
		name = "DeepSeek", -- 35
		url = "https://api.deepseek.com/v1/chat/completions", -- 35
		model = "deepseek-v4-pro", -- 35
		contextWindow = 1000000, -- 35
		maxTokens = 64000, -- 35
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}") -- 35
	}, -- 35
	{ -- 36
		id = "moonshot", -- 36
		name = "Moonshot", -- 36
		url = "https://api.moonshot.cn/v1/chat/completions", -- 36
		model = "kimi-k3", -- 36
		contextWindow = 128000, -- 36
		maxTokens = 8192, -- 36
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":\"low\"}") -- 36
	}, -- 36
	{ -- 37
		id = "qwen", -- 37
		name = "Qwen", -- 37
		url = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions", -- 37
		model = "qwen3.7-max", -- 37
		contextWindow = 128000, -- 37
		maxTokens = 8192, -- 37
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"enable_thinking\":false}") -- 37
	}, -- 37
	{ -- 38
		id = "openrouter", -- 38
		name = "OpenRouter", -- 38
		url = "https://openrouter.ai/api/v1/chat/completions", -- 38
		model = "~anthropic/claude-sonnet-latest", -- 38
		contextWindow = 128000, -- 38
		maxTokens = 8192, -- 38
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"reasoning\":{\"effort\":\"none\"}}") -- 38
	}, -- 38
	{ -- 39
		id = "openai", -- 39
		name = "OpenAI", -- 39
		url = "https://api.openai.com/v1/chat/completions", -- 39
		model = "gpt-5.6", -- 39
		contextWindow = 128000, -- 39
		maxTokens = 8192, -- 39
		customOptions = auxiliary("{\"max_tokens\":null,\"max_completion_tokens\":8192,\"reasoning_effort\":\"none\"}") -- 39
	}, -- 39
	{ -- 40
		id = "aihubmix", -- 40
		name = "AiHubMix", -- 40
		url = "https://aihubmix.com/v1/chat/completions", -- 40
		model = "gpt-5.6-luna", -- 40
		contextWindow = 128000, -- 40
		maxTokens = 8192, -- 40
		customOptions = auxiliary("{\"max_tokens\":null,\"max_completion_tokens\":8192,\"reasoning_effort\":\"none\"}") -- 40
	}, -- 40
	{ -- 41
		id = "siliconflow", -- 41
		name = "SiliconFlow", -- 41
		url = "https://api.siliconflow.cn/v1/chat/completions", -- 41
		model = "deepseek-ai/DeepSeek-V4-Pro", -- 41
		contextWindow = 128000, -- 41
		maxTokens = 8192, -- 41
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"enable_thinking\":false}") -- 41
	}, -- 41
	{ -- 42
		id = "volcengine", -- 42
		name = "VolcEngine", -- 42
		url = "https://ark.cn-beijing.volces.com/api/v3/chat/completions", -- 42
		model = "doubao-seed-2-0-pro-260215", -- 42
		contextWindow = 128000, -- 42
		maxTokens = 8192, -- 42
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}") -- 42
	}, -- 42
	{ -- 43
		id = "volcengine-coding-plan", -- 43
		name = "VolcEngine Coding Plan", -- 43
		url = "https://ark.cn-beijing.volces.com/api/coding/v3/chat/completions", -- 43
		model = "ark-code-latest", -- 43
		contextWindow = 128000, -- 43
		maxTokens = 8192, -- 43
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}") -- 43
	}, -- 43
	{ -- 44
		id = "byteplus", -- 44
		name = "BytePlus", -- 44
		url = "https://ark.ap-southeast.bytepluses.com/api/v3/chat/completions", -- 44
		model = "dola-seed-2-1-turbo-260628", -- 44
		contextWindow = 128000, -- 44
		maxTokens = 8192, -- 44
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}") -- 44
	}, -- 44
	{ -- 45
		id = "byteplus-coding-plan", -- 45
		name = "BytePlus Coding Plan", -- 45
		url = "https://ark.ap-southeast.bytepluses.com/api/coding/v3/chat/completions", -- 45
		model = "ark-code-latest", -- 45
		contextWindow = 128000, -- 45
		maxTokens = 8192, -- 45
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}") -- 45
	}, -- 45
	{ -- 46
		id = "minimax", -- 46
		name = "MiniMax", -- 46
		url = "https://api.minimax.io/v1/chat/completions", -- 46
		model = "MiniMax-M2.7", -- 46
		contextWindow = 128000, -- 46
		maxTokens = 8192, -- 46
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null}") -- 46
	}, -- 46
	{ -- 47
		id = "minimax-cn", -- 47
		name = "MiniMax (CN)", -- 47
		url = "https://api.minimaxi.com/v1/chat/completions", -- 47
		model = "MiniMax-M2.7", -- 47
		contextWindow = 128000, -- 47
		maxTokens = 8192, -- 47
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null}") -- 47
	}, -- 47
	{ -- 48
		id = "mimo", -- 48
		name = "Xiaomi MiMo", -- 48
		url = "https://api.xiaomimimo.com/v1/chat/completions", -- 48
		model = "mimo-v2.5-pro", -- 48
		contextWindow = 128000, -- 48
		maxTokens = 8192, -- 48
		customOptions = "{\"max_tokens\":null,\"max_completion_tokens\":8192,\"top_p\":0.95,\"auxiliaryOptions\":{\"max_tokens\":null,\"max_completion_tokens\":8192,\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}}" -- 48
	}, -- 48
	{ -- 49
		id = "zai", -- 49
		name = "ZAI", -- 49
		url = "https://open.bigmodel.cn/api/paas/v4/chat/completions", -- 49
		model = "glm-5.2", -- 49
		contextWindow = 128000, -- 49
		maxTokens = 8192, -- 49
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}") -- 49
	}, -- 49
	{ -- 50
		id = "zai-coding-plan", -- 50
		name = "ZAI Coding Plan", -- 50
		url = "https://open.bigmodel.cn/api/coding/paas/v4/chat/completions", -- 50
		model = "glm-5.2", -- 50
		contextWindow = 128000, -- 50
		maxTokens = 8192, -- 50
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":null,\"thinking\":{\"type\":\"disabled\"}}") -- 50
	}, -- 50
	{ -- 51
		id = "ollama", -- 51
		name = "Ollama", -- 51
		url = "http://localhost:11434/v1/chat/completions", -- 51
		model = "llama3.2", -- 51
		contextWindow = 128000, -- 51
		maxTokens = 8192, -- 51
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":\"none\"}") -- 51
	}, -- 51
	{ -- 52
		id = "vllm", -- 52
		name = "vLLM", -- 52
		url = "http://localhost:8000/v1/chat/completions", -- 52
		model = "meta-llama/Llama-3.1-8B-Instruct", -- 52
		contextWindow = 128000, -- 52
		maxTokens = 8192, -- 52
		customOptions = auxiliary("{\"max_tokens\":8192,\"reasoning_effort\":\"none\",\"chat_template_kwargs\":{\"enable_thinking\":false}}") -- 52
	} -- 52
} -- 52
local fontName = "sarasa-mono-sc-regular" -- 55
local function trim(value) -- 56
	return (string.match(value, "^%s*(.-)%s*$")) or "" -- 56
end -- 56
local activeSetup -- 57
local function ensureLLMConfigTable() -- 59
	DB:exec("CREATE TABLE IF NOT EXISTS LLMConfig(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tname TEXT NOT NULL, url TEXT NOT NULL, model TEXT NOT NULL, api_key TEXT NOT NULL,\n\t\tcontext_window INTEGER NOT NULL DEFAULT 64000, temperature REAL NOT NULL DEFAULT 0.1,\n\t\tmax_tokens INTEGER NOT NULL DEFAULT 8192, reasoning_effort TEXT NOT NULL DEFAULT '',\n\t\tcustom_options TEXT NOT NULL DEFAULT '', supports_function_calling INTEGER NOT NULL DEFAULT 1,\n\t\tactive INTEGER NOT NULL DEFAULT 1, created_at INTEGER, updated_at INTEGER\n\t)") -- 60
end -- 59
local function uniqueConfigName(base) -- 70
	local rows = DB:query("select name from LLMConfig") -- 71
	local names = __TS__ArrayMap( -- 72
		rows or ({}), -- 72
		function(____, row) return tostring(row[1]) end -- 72
	) -- 72
	if __TS__ArrayIndexOf(names, base) < 0 then -- 72
		return base -- 73
	end -- 73
	local suffix = 2 -- 74
	while __TS__ArrayIndexOf( -- 74
		names, -- 75
		(base .. " ") .. tostring(suffix) -- 75
	) >= 0 do -- 75
		suffix = suffix + 1 -- 75
	end -- 75
	return (base .. " ") .. tostring(suffix) -- 76
end -- 70
function ____exports.hasMobileLLMConfig() -- 79
	ensureLLMConfigTable() -- 80
	local rows = DB:query("select id from LLMConfig limit 1") -- 81
	return rows ~= nil and #rows > 0 -- 82
end -- 79
function ____exports.startMobileLLMSetup(options) -- 85
	local render -- 85
	if activeSetup ~= nil then -- 85
		activeSetup:removeFromParent(true) -- 86
	end -- 86
	local coveredNode = options.coveredNode -- 87
	if coveredNode then -- 87
		coveredNode.visible = false -- 88
	end -- 88
	local coveredRestored = false -- 89
	local function restoreCovered() -- 90
		if coveredRestored then -- 90
			return -- 91
		end -- 91
		coveredRestored = true -- 92
		if coveredNode and coveredNode.parent then -- 92
			coveredNode.visible = true -- 93
		end -- 93
	end -- 90
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 95
	local host = Node() -- 96
	host.tag = "mobile-llm-setup" -- 97
	host.order = 10000 -- 98
	host.renderGroup = true -- 99
	host.scaleX = App.devicePixelRatio -- 100
	host.scaleY = App.devicePixelRatio -- 101
	host:addTo(Director.systemUI) -- 102
	activeSetup = host -- 103
	local presetIndex = 0 -- 104
	local apiKey = "" -- 105
	local ____error = "" -- 106
	local disposed = false -- 107
	local keyRef = reference() -- 108
	local function canEdit() -- 109
		return not disposed and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 -- 109
	end -- 109
	local keyInput = createTextInput({ -- 110
		fontSize = math.floor(15 * mobileFontScale), -- 111
		singleLine = true, -- 111
		isSecure = function() return true end, -- 111
		getText = function() return apiKey end, -- 112
		setText = function(value) -- 112
			apiKey = value -- 112
			____error = "" -- 112
		end, -- 112
		getPlaceholder = function() return "sk-…" end, -- 113
		isEnabled = canEdit, -- 113
		onReturn = function() return true end -- 114
	}) -- 114
	local function blurInputs() -- 116
		return keyInput.blur() -- 116
	end -- 116
	local function close() -- 117
		if disposed then -- 117
			return -- 118
		end -- 118
		disposed = true -- 119
		blurInputs() -- 120
		restoreCovered() -- 121
		host:removeFromParent(true) -- 122
		if activeSetup == host then -- 122
			activeSetup = nil -- 123
		end -- 123
		local ____opt_4 = options.onClose -- 123
		if ____opt_4 ~= nil then -- 123
			____opt_4() -- 124
		end -- 124
	end -- 117
	local function choose(delta) -- 126
		presetIndex = (presetIndex + delta + #____exports.mobileLLMPresets) % #____exports.mobileLLMPresets -- 127
		____error = "" -- 128
		blurInputs() -- 129
		render() -- 129
	end -- 126
	local function save() -- 131
		if not canEdit() then -- 131
			return -- 132
		end -- 132
		local preset = ____exports.mobileLLMPresets[presetIndex + 1] -- 133
		local key = trim(apiKey) -- 134
		if key == "" then -- 134
			____error = zh and "请粘贴 API Key" or "Paste an API key" -- 135
			render() -- 135
			return -- 135
		end -- 135
		ensureLLMConfigTable() -- 136
		local now = os.time() -- 137
		local name = uniqueConfigName(preset.name) -- 138
		local affected = DB:exec("insert into LLMConfig(\n\t\t\tname, url, model, api_key, context_window, temperature, max_tokens, reasoning_effort,\n\t\t\tcustom_options, supports_function_calling, active, created_at, updated_at\n\t\t) values(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 139
			name, -- 143
			preset.url, -- 143
			preset.model, -- 143
			key, -- 143
			preset.contextWindow, -- 143
			0.1, -- 143
			preset.maxTokens, -- 143
			"", -- 143
			preset.customOptions, -- 144
			1, -- 144
			1, -- 144
			now, -- 144
			now -- 144
		}) -- 144
		if affected < 0 then -- 144
			____error = zh and "配置保存失败，请重试" or "Could not save the configuration" -- 146
			render() -- 146
			return -- 146
		end -- 146
		local rows = DB:query("select last_insert_rowid()") -- 147
		local ____temp_6 -- 148
		if rows and #rows > 0 then -- 148
			____temp_6 = tonumber(rows[1][1]) -- 148
		else -- 148
			____temp_6 = nil -- 148
		end -- 148
		local id = ____temp_6 -- 148
		if not id then -- 148
			____error = zh and "无法读取新配置" or "Could not read the new configuration" -- 149
			render() -- 149
			return -- 149
		end -- 149
		DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", {id}) -- 150
		options.onSaved(id) -- 151
		close() -- 152
	end -- 131
	render = function() -- 154
		if disposed then -- 154
			return -- 155
		end -- 155
		keyInput.unmount() -- 156
		keyRef = reference() -- 157
		host:removeAllChildren() -- 158
		host.scaleX = App.devicePixelRatio -- 159
		host.scaleY = App.devicePixelRatio -- 159
		local ____App_visualSize_7 = App.visualSize -- 160
		local width = ____App_visualSize_7.width -- 160
		local height = ____App_visualSize_7.height -- 160
		local safe = App.safeArea -- 161
		local shortLandscape = safe.width >= 760 and safe.height < 500 -- 162
		local sheetWidth = shortLandscape and math.min(720, safe.width - 24) or safe.width -- 163
		local sheetHeight = shortLandscape and math.min(240, safe.height - 16) or math.min(300, safe.height - 20) -- 164
		local left = safe.x + (safe.width - sheetWidth) / 2 -- 165
		local bottom = safe.y -- 166
		local contentWidth = sheetWidth - 40 -- 167
		local fieldGap = 12 -- 168
		local fieldWidth = shortLandscape and math.floor((contentWidth - fieldGap) / 2) or contentWidth -- 169
		local keyButtonWidth = 92 -- 170
		local keyX = shortLandscape and 20 + fieldWidth + fieldGap or 20 -- 171
		local keyWidth = fieldWidth - keyButtonWidth - fieldGap -- 172
		local providerLabelY = sheetHeight - 66 -- 173
		local providerY = sheetHeight - 126 -- 174
		local keyLabelY = shortLandscape and providerLabelY or sheetHeight - 150 -- 175
		local keyY = shortLandscape and providerY or sheetHeight - 204 -- 176
		local actionGap = 12 -- 177
		local cancelWidth = math.floor((contentWidth - actionGap) * (shortLandscape and 0.34 or 0.38)) -- 178
		local preset = ____exports.mobileLLMPresets[presetIndex + 1] -- 179
		local scene = toNode(React.createElement( -- 180
			"node", -- 180
			{ -- 180
				order = 10000, -- 180
				x = -width / 2, -- 180
				y = -height / 2, -- 180
				width = width, -- 180
				height = height, -- 180
				anchorX = 0, -- 180
				anchorY = 0 -- 180
			}, -- 180
			React.createElement( -- 180
				"node", -- 180
				{ -- 180
					tag = "mobile-llm-setup-backdrop", -- 180
					width = width, -- 180
					height = height, -- 180
					anchorX = 0, -- 180
					anchorY = 0, -- 180
					touchEnabled = true, -- 180
					swallowTouches = true, -- 180
					onTapped = close -- 180
				}, -- 180
				React.createElement(RoundedSurface, { -- 180
					width = width, -- 180
					height = height, -- 180
					radius = 0, -- 180
					fillColor = 2348810240, -- 180
					renderOrder = 0 -- 180
				}) -- 180
			), -- 180
			React.createElement( -- 180
				"node", -- 180
				{ -- 180
					order = 10, -- 180
					x = left, -- 180
					y = bottom, -- 180
					width = sheetWidth, -- 180
					height = sheetHeight, -- 180
					anchorX = 0, -- 180
					anchorY = 0, -- 180
					touchEnabled = true, -- 180
					swallowTouches = true -- 180
				}, -- 180
				React.createElement(MobilePanelSurface, {width = sheetWidth, height = sheetHeight, renderOrder = 10}), -- 180
				React.createElement("label", { -- 180
					x = 20, -- 180
					y = sheetHeight - 24, -- 180
					anchorX = 0, -- 180
					anchorY = 1, -- 180
					fontName = fontName, -- 180
					fontSize = 22, -- 180
					text = zh and "从模板新增配置" or "Add from template", -- 180
					color3 = 16052712 -- 180
				}), -- 180
				React.createElement( -- 180
					"label", -- 180
					{ -- 180
						x = sheetWidth - 20, -- 180
						y = sheetHeight - 24, -- 180
						anchorX = 1, -- 180
						anchorY = 1, -- 180
						fontName = fontName, -- 180
						fontSize = 12, -- 180
						text = compactText(preset.model, shortLandscape and 42 or 24), -- 180
						color3 = 11055037 -- 180
					} -- 180
				), -- 180
				React.createElement("label", { -- 180
					x = 20, -- 180
					y = providerLabelY, -- 180
					anchorX = 0, -- 180
					anchorY = 1, -- 180
					fontName = fontName, -- 180
					fontSize = 14, -- 180
					text = zh and "配置模板" or "Template", -- 180
					color3 = 11055037 -- 180
				}), -- 180
				React.createElement( -- 180
					MobileButton, -- 189
					{ -- 189
						tag = "mobile-llm-provider-prev", -- 189
						x = 20, -- 189
						y = providerY, -- 189
						width = 48, -- 189
						text = "‹", -- 189
						renderOrder = 10, -- 189
						onTapped = function() return choose(-1) end -- 189
					} -- 189
				), -- 189
				React.createElement( -- 189
					MobileButton, -- 190
					{ -- 190
						tag = "mobile-llm-provider", -- 190
						x = 80, -- 190
						y = providerY, -- 190
						width = fieldWidth - 120, -- 190
						text = preset.name, -- 190
						renderOrder = 10, -- 190
						onTapped = function() return choose(1) end -- 190
					} -- 190
				), -- 190
				React.createElement( -- 190
					MobileButton, -- 191
					{ -- 191
						tag = "mobile-llm-provider-next", -- 191
						x = 20 + fieldWidth - 48, -- 191
						y = providerY, -- 191
						width = 48, -- 191
						text = "›", -- 191
						renderOrder = 10, -- 191
						onTapped = function() return choose(1) end -- 191
					} -- 191
				), -- 191
				React.createElement("label", { -- 191
					x = keyX, -- 191
					y = keyLabelY, -- 191
					anchorX = 0, -- 191
					anchorY = 1, -- 191
					fontName = fontName, -- 191
					fontSize = 14, -- 191
					text = "API Key", -- 191
					color3 = 11055037 -- 191
				}), -- 191
				React.createElement("node", { -- 191
					tag = "mobile-llm-key", -- 191
					ref = keyRef, -- 191
					renderOrder = 10, -- 191
					x = keyX, -- 191
					y = keyY, -- 191
					width = keyWidth, -- 191
					height = 44, -- 191
					anchorX = 0, -- 191
					anchorY = 0, -- 191
					onMount = keyInput.mount -- 191
				}), -- 191
				React.createElement( -- 191
					MobileButton, -- 194
					{ -- 194
						tag = "mobile-llm-paste", -- 194
						x = keyX + keyWidth + fieldGap, -- 194
						y = keyY - 2, -- 194
						width = keyButtonWidth, -- 194
						text = zh and "粘贴" or "Paste", -- 194
						renderOrder = 10, -- 194
						onTapped = function() -- 194
							if not keyInput.pasteFromClipboard(true) then -- 194
								____error = zh and "剪贴板为空" or "Clipboard is empty" -- 195
							else -- 195
								____error = "" -- 196
							end -- 196
							keyInput.refresh() -- 197
						end -- 194
					} -- 194
				), -- 194
				React.createElement("label", { -- 194
					tag = "mobile-llm-error", -- 194
					x = 20, -- 194
					y = 78, -- 194
					anchorX = 0, -- 194
					fontName = fontName, -- 194
					fontSize = 12, -- 194
					text = ____error, -- 194
					textWidth = contentWidth, -- 194
					alignment = "Left", -- 194
					color3 = 16739179 -- 194
				}), -- 194
				React.createElement(MobileButton, { -- 194
					tag = "mobile-llm-cancel", -- 194
					x = 20, -- 194
					y = 20, -- 194
					width = cancelWidth, -- 194
					text = zh and "返回" or "Back", -- 194
					renderOrder = 10, -- 194
					onTapped = close -- 194
				}), -- 194
				React.createElement(MobileButton, { -- 194
					tag = "mobile-llm-save", -- 194
					x = 20 + cancelWidth + actionGap, -- 194
					y = 20, -- 194
					width = contentWidth - cancelWidth - actionGap, -- 194
					text = zh and "新增并使用" or "Add and use", -- 194
					primary = true, -- 194
					renderOrder = 10, -- 194
					onTapped = save -- 194
				}) -- 194
			) -- 194
		)) -- 194
		if scene then -- 194
			host:addChild(scene) -- 204
		end -- 204
	end -- 154
	host:onAppChange(function(setting) -- 206
		if setting == "Locale" then -- 207
			zh = (string.match(App.locale, "^zh")) ~= nil -- 207
		end -- 207
		if setting == "Size" or setting == "Locale" then -- 206
			render() -- 206
		end -- 206
	end) -- 206
	host:onAppEvent(function(event) -- 207
		if event == "BackButton" then -- 207
			close() -- 207
		end -- 207
	end) -- 207
	host:onCleanup(function() -- 208
		disposed = true -- 208
		restoreCovered() -- 208
		if activeSetup == host then -- 208
			activeSetup = nil -- 208
		end -- 208
	end) -- 208
	render() -- 209
	return host -- 210
end -- 85
local function getMobileLLMConfigs() -- 222
	ensureLLMConfigTable() -- 223
	local rows = DB:query("select id, name, url, model, context_window, supports_function_calling\n\t\tfrom LLMConfig order by id asc") -- 224
	return __TS__ArrayFlatMap( -- 226
		rows or ({}), -- 226
		function(____, row) -- 226
			local id = tonumber(row[1]) -- 227
			if not id then -- 227
				return {} -- 228
			end -- 228
			return {{ -- 229
				id = id, -- 230
				name = tostring(row[2]), -- 231
				url = tostring(row[3]), -- 232
				model = tostring(row[4]), -- 233
				contextWindow = tonumber(row[5]) or 128000, -- 234
				supportsFunctionCalling = tonumber(row[6]) ~= 0 -- 235
			}} -- 235
		end -- 226
	) -- 226
end -- 222
function ____exports.startMobileLLMManager(options) -- 247
	local render -- 247
	local configs = getMobileLLMConfigs() -- 248
	if #configs == 0 then -- 248
		return ____exports.startMobileLLMSetup({coveredNode = options.coveredNode, onSaved = options.onSelected, onClose = options.onClose}) -- 250
	end -- 250
	if activeSetup ~= nil then -- 250
		activeSetup:removeFromParent(true) -- 256
	end -- 256
	local coveredNode = options.coveredNode -- 257
	if coveredNode then -- 257
		coveredNode.visible = false -- 258
	end -- 258
	local coveredRestored = false -- 259
	local function restoreCovered() -- 260
		if coveredRestored then -- 260
			return -- 261
		end -- 261
		coveredRestored = true -- 262
		if coveredNode and coveredNode.parent then -- 262
			coveredNode.visible = true -- 263
		end -- 263
	end -- 260
	local zh = (string.match(App.locale, "^zh")) ~= nil -- 265
	local host = Node() -- 266
	host.tag = "mobile-llm-manager" -- 267
	host.order = 10000 -- 268
	host.renderGroup = true -- 269
	host.scaleX = App.devicePixelRatio -- 270
	host.scaleY = App.devicePixelRatio -- 271
	host:addTo(Director.systemUI) -- 272
	activeSetup = host -- 273
	local page = -1 -- 274
	local detailId = 0 -- 275
	local detailMode = "view" -- 276
	local detailKey = "" -- 277
	local detailError = "" -- 278
	local selectedId = options.selectedId -- 279
	local disposed = false -- 280
	local detailKeyRef = reference() -- 281
	local function canEdit() -- 282
		return not disposed and host.parent ~= nil and host.visible and HttpServer.wsConnectionCount == 0 -- 282
	end -- 282
	local detailKeyInput = createTextInput({ -- 283
		fontSize = math.floor(15 * mobileFontScale), -- 284
		singleLine = true, -- 284
		isSecure = function() return true end, -- 284
		getText = function() return detailKey end, -- 285
		setText = function(value) -- 285
			detailKey = value -- 285
			detailError = "" -- 285
		end, -- 285
		getPlaceholder = function() return zh and "粘贴新的 API Key" or "Paste a new API key" end, -- 286
		isEnabled = canEdit, -- 286
		onReturn = function() return true end -- 287
	}) -- 287
	local function close(notify) -- 289
		if notify == nil then -- 289
			notify = true -- 289
		end -- 289
		if disposed then -- 289
			return -- 290
		end -- 290
		disposed = true -- 291
		detailKeyInput.blur() -- 292
		restoreCovered() -- 293
		host:removeFromParent(true) -- 294
		if activeSetup == host then -- 294
			activeSetup = nil -- 295
		end -- 295
		if notify then -- 295
			local ____opt_12 = options.onClose -- 295
			if ____opt_12 ~= nil then -- 295
				____opt_12() -- 296
			end -- 296
		end -- 296
	end -- 289
	local function select(id) -- 298
		DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", {id}) -- 299
		options.onSelected(id) -- 300
		close() -- 301
	end -- 298
	local function openDetail(id) -- 303
		detailId = id -- 304
		detailMode = "view" -- 305
		detailKey = "" -- 306
		detailError = "" -- 307
		render() -- 308
	end -- 303
	local function saveDetailKey() -- 310
		if not canEdit() or detailId <= 0 then -- 310
			return -- 311
		end -- 311
		local key = trim(detailKey) -- 312
		if key == "" then -- 312
			detailError = zh and "请粘贴新的 API Key" or "Paste a new API key" -- 313
			render() -- 313
			return -- 313
		end -- 313
		local affected = DB:exec( -- 314
			"update LLMConfig set api_key = ?, updated_at = ? where id = ?", -- 314
			{ -- 314
				key, -- 314
				os.time(), -- 314
				detailId -- 314
			} -- 314
		) -- 314
		if affected <= 0 then -- 314
			detailError = zh and "API Key 保存失败" or "Could not save the API key" -- 315
			render() -- 315
			return -- 315
		end -- 315
		detailKeyInput.blur() -- 316
		detailKey = "" -- 317
		detailError = zh and "API Key 已更新" or "API key updated" -- 318
		detailMode = "view" -- 319
		render() -- 320
	end -- 310
	local function deleteDetail() -- 322
		if not canEdit() or detailId <= 0 then -- 322
			return -- 323
		end -- 323
		local deletingId = detailId -- 324
		local affected = DB:exec("delete from LLMConfig where id = ?", {deletingId}) -- 325
		if affected <= 0 then -- 325
			detailError = zh and "删除失败，请重试" or "Could not delete the configuration" -- 326
			render() -- 326
			return -- 326
		end -- 326
		configs = getMobileLLMConfigs() -- 327
		if selectedId == deletingId then -- 327
			local ____opt_14 = configs[1] -- 327
			selectedId = ____opt_14 and ____opt_14.id or 0 -- 329
			if selectedId > 0 then -- 329
				DB:exec("insert or replace into Config(name, value_num, value_str, value_bool) values('mobileRemixLLMConfigId', ?, NULL, NULL)", {selectedId}) -- 330
			else -- 330
				DB:exec("delete from Config where name = 'mobileRemixLLMConfigId'") -- 331
			end -- 331
			options.onSelected(selectedId) -- 332
		end -- 332
		detailId = 0 -- 334
		detailMode = "view" -- 335
		detailKey = "" -- 336
		detailError = "" -- 337
		page = -1 -- 338
		if #configs > 0 then -- 338
			render() -- 339
		else -- 339
			close(false) -- 341
			____exports.startMobileLLMSetup({coveredNode = coveredNode, onSaved = options.onSelected, onClose = options.onClose}) -- 342
		end -- 342
	end -- 322
	local function add() -- 345
		close(false) -- 346
		local saved = false -- 347
		____exports.startMobileLLMSetup({ -- 348
			coveredNode = coveredNode, -- 349
			onSaved = function(id) -- 350
				saved = true -- 350
				options.onSelected(id) -- 350
			end, -- 350
			onClose = function() -- 351
				if saved then -- 351
					local ____opt_16 = options.onClose -- 351
					if ____opt_16 ~= nil then -- 351
						____opt_16() -- 352
					end -- 352
				else -- 352
					____exports.startMobileLLMManager(options) -- 353
				end -- 353
			end -- 351
		}) -- 351
	end -- 345
	render = function() -- 357
		if disposed then -- 357
			return -- 358
		end -- 358
		detailKeyInput.unmount() -- 359
		detailKeyRef = reference() -- 360
		host:removeAllChildren() -- 361
		host.scaleX = App.devicePixelRatio -- 362
		host.scaleY = App.devicePixelRatio -- 363
		local ____App_visualSize_18 = App.visualSize -- 364
		local width = ____App_visualSize_18.width -- 364
		local height = ____App_visualSize_18.height -- 364
		local safe = App.safeArea -- 365
		local shortLandscape = safe.width >= 760 and safe.height < 500 -- 366
		local rowsPerPage = shortLandscape and 3 or 5 -- 367
		local desiredHeight = detailId > 0 and 410 or math.max( -- 368
			260, -- 368
			160 + math.min(#configs, rowsPerPage) * 68 -- 368
		) -- 368
		local sheetWidth = shortLandscape and math.min(720, safe.width - 24) or safe.width -- 369
		local sheetHeight = math.min(desiredHeight, safe.height - (shortLandscape and 16 or 20)) -- 370
		local left = safe.x + (safe.width - sheetWidth) / 2 -- 371
		local bottom = safe.y -- 372
		local contentWidth = sheetWidth - 40 -- 373
		local pageCount = math.max( -- 374
			1, -- 374
			math.ceil(#configs / rowsPerPage) -- 374
		) -- 374
		if page < 0 then -- 374
			local selectedIndex = __TS__ArrayFindIndex( -- 376
				configs, -- 376
				function(____, item) return item.id == selectedId end -- 376
			) -- 376
			page = selectedIndex < 0 and 0 or math.floor(selectedIndex / rowsPerPage) -- 377
		end -- 377
		page = math.max( -- 379
			0, -- 379
			math.min(pageCount - 1, page) -- 379
		) -- 379
		local pageItems = __TS__ArraySlice(configs, page * rowsPerPage, (page + 1) * rowsPerPage) -- 380
		local detail = __TS__ArrayFind( -- 381
			configs, -- 381
			function(____, item) return item.id == detailId end -- 381
		) -- 381
		local switchPending = options.taskRunning and (options.runningId or selectedId) ~= selectedId -- 382
		local ____toNode_39 = toNode -- 383
		local ____React_createElement_38 = React.createElement -- 383
		local ____temp_36 = { -- 383
			order = 10000, -- 383
			x = -width / 2, -- 383
			y = -height / 2, -- 383
			width = width, -- 383
			height = height, -- 383
			anchorX = 0, -- 383
			anchorY = 0 -- 383
		} -- 383
		local ____React_createElement_result_37 = React.createElement( -- 383
			"node", -- 383
			{ -- 383
				tag = "mobile-llm-manager-backdrop", -- 383
				width = width, -- 383
				height = height, -- 383
				anchorX = 0, -- 383
				anchorY = 0, -- 383
				touchEnabled = true, -- 383
				swallowTouches = true, -- 383
				onTapped = function() return close() end -- 383
			}, -- 383
			React.createElement(RoundedSurface, { -- 383
				width = width, -- 383
				height = height, -- 383
				radius = 0, -- 383
				fillColor = 2348810240, -- 383
				renderOrder = 0 -- 383
			}) -- 383
		) -- 383
		local ____React_createElement_35 = React.createElement -- 383
		local ____temp_33 = { -- 383
			order = 10, -- 383
			x = left, -- 383
			y = bottom, -- 383
			width = sheetWidth, -- 383
			height = sheetHeight, -- 383
			anchorX = 0, -- 383
			anchorY = 0, -- 383
			touchEnabled = true, -- 383
			swallowTouches = true -- 383
		} -- 383
		local ____React_createElement_result_34 = React.createElement(MobilePanelSurface, {width = sheetWidth, height = sheetHeight, renderOrder = 10}) -- 383
		local ____detail_32 -- 389
		if detail then -- 389
			local ____temp_24 -- 389
			if detailMode == "key" then -- 389
				____temp_24 = React.createElement( -- 389
					"node", -- 389
					{tag = "mobile-llm-detail-key"}, -- 389
					React.createElement("label", { -- 389
						x = 20, -- 389
						y = sheetHeight - 24, -- 389
						anchorX = 0, -- 389
						anchorY = 1, -- 389
						fontName = fontName, -- 389
						fontSize = 22, -- 389
						text = zh and "修改 API Key" or "Update API key", -- 389
						color3 = 16052712 -- 389
					}), -- 389
					React.createElement( -- 389
						"label", -- 389
						{ -- 389
							x = 20, -- 389
							y = sheetHeight - 66, -- 389
							anchorX = 0, -- 389
							anchorY = 1, -- 389
							fontName = fontName, -- 389
							fontSize = 13, -- 389
							text = compactText(detail.name, shortLandscape and 44 or 28), -- 389
							color3 = 11055037 -- 389
						} -- 389
					), -- 389
					React.createElement("label", { -- 389
						x = 20, -- 389
						y = sheetHeight - 104, -- 389
						anchorX = 0, -- 389
						anchorY = 1, -- 389
						fontName = fontName, -- 389
						fontSize = 13, -- 389
						text = zh and "原 Key 不会显示，保存后立即替换" or "The current key stays hidden and will be replaced", -- 389
						color3 = 11055037 -- 389
					}), -- 389
					React.createElement("node", { -- 389
						tag = "mobile-llm-detail-key-input", -- 389
						ref = detailKeyRef, -- 389
						renderOrder = 10, -- 389
						x = 20, -- 389
						y = sheetHeight - 166, -- 389
						width = contentWidth - 104, -- 389
						height = 44, -- 389
						anchorX = 0, -- 389
						anchorY = 0, -- 389
						onMount = detailKeyInput.mount -- 389
					}), -- 389
					React.createElement( -- 389
						MobileButton, -- 394
						{ -- 394
							tag = "mobile-llm-detail-key-paste", -- 394
							x = contentWidth - 72, -- 394
							y = sheetHeight - 168, -- 394
							width = 92, -- 394
							text = zh and "粘贴" or "Paste", -- 394
							renderOrder = 10, -- 394
							onTapped = function() -- 394
								if not detailKeyInput.pasteFromClipboard(true) then -- 394
									detailError = zh and "剪贴板为空" or "Clipboard is empty" -- 395
								else -- 395
									detailError = "" -- 396
								end -- 396
								detailKeyInput.refresh() -- 397
							end -- 394
						} -- 394
					), -- 394
					React.createElement("label", { -- 394
						x = 20, -- 394
						y = 82, -- 394
						anchorX = 0, -- 394
						fontName = fontName, -- 394
						fontSize = 12, -- 394
						text = detailError, -- 394
						textWidth = contentWidth, -- 394
						alignment = "Left", -- 394
						color3 = 16739179 -- 394
					}), -- 394
					React.createElement( -- 394
						MobileButton, -- 400
						{ -- 400
							tag = "mobile-llm-detail-key-cancel", -- 400
							x = 20, -- 400
							y = 20, -- 400
							width = math.floor((contentWidth - 12) * 0.36), -- 400
							text = zh and "取消" or "Cancel", -- 400
							renderOrder = 10, -- 400
							onTapped = function() -- 400
								detailKeyInput.blur() -- 400
								detailMode = "view" -- 400
								detailKey = "" -- 400
								detailError = "" -- 400
								render() -- 400
							end -- 400
						} -- 400
					), -- 400
					React.createElement( -- 400
						MobileButton, -- 401
						{ -- 401
							tag = "mobile-llm-detail-key-save", -- 401
							x = 32 + math.floor((contentWidth - 12) * 0.36), -- 401
							y = 20, -- 401
							width = contentWidth - 12 - math.floor((contentWidth - 12) * 0.36), -- 401
							text = zh and "保存新 Key" or "Save new key", -- 401
							primary = true, -- 401
							renderOrder = 10, -- 401
							onTapped = saveDetailKey -- 401
						} -- 401
					) -- 401
				) -- 401
			else -- 401
				local ____temp_23 -- 402
				if detailMode == "delete" then -- 402
					____temp_23 = React.createElement( -- 402
						"node", -- 402
						{tag = "mobile-llm-detail-delete"}, -- 402
						React.createElement("label", { -- 402
							x = 20, -- 402
							y = sheetHeight - 24, -- 402
							anchorX = 0, -- 402
							anchorY = 1, -- 402
							fontName = fontName, -- 402
							fontSize = 22, -- 402
							text = zh and "删除这个配置？" or "Delete this configuration?", -- 402
							color3 = 16052712 -- 402
						}), -- 402
						React.createElement( -- 402
							"label", -- 402
							{ -- 402
								x = 20, -- 402
								y = sheetHeight - 78, -- 402
								anchorX = 0, -- 402
								anchorY = 1, -- 402
								fontName = fontName, -- 402
								fontSize = 16, -- 402
								text = compactText(detail.name, shortLandscape and 52 or 32), -- 402
								color3 = 4294935941 -- 402
							} -- 402
						), -- 402
						React.createElement("label", { -- 402
							x = 20, -- 402
							y = sheetHeight - 120, -- 402
							anchorX = 0, -- 402
							anchorY = 1, -- 402
							fontName = fontName, -- 402
							fontSize = 13, -- 402
							text = zh and "删除后无法恢复；若它是当前配置，将自动切换到下一项。" or "This cannot be undone. The next configuration will become active.", -- 402
							textWidth = contentWidth, -- 402
							alignment = "Left", -- 402
							color3 = 11055037 -- 402
						}), -- 402
						React.createElement("label", { -- 402
							x = 20, -- 402
							y = 82, -- 402
							anchorX = 0, -- 402
							fontName = fontName, -- 402
							fontSize = 12, -- 402
							text = detailError, -- 402
							textWidth = contentWidth, -- 402
							alignment = "Left", -- 402
							color3 = 16739179 -- 402
						}), -- 402
						React.createElement( -- 402
							MobileButton, -- 407
							{ -- 407
								tag = "mobile-llm-detail-delete-cancel", -- 407
								x = 20, -- 407
								y = 20, -- 407
								width = math.floor((contentWidth - 12) * 0.42), -- 407
								text = zh and "保留配置" or "Keep it", -- 407
								renderOrder = 10, -- 407
								onTapped = function() -- 407
									detailMode = "view" -- 407
									detailError = "" -- 407
									render() -- 407
								end -- 407
							} -- 407
						), -- 407
						React.createElement( -- 407
							MobileButton, -- 408
							{ -- 408
								tag = "mobile-llm-detail-delete-confirm", -- 408
								x = 32 + math.floor((contentWidth - 12) * 0.42), -- 408
								y = 20, -- 408
								width = contentWidth - 12 - math.floor((contentWidth - 12) * 0.42), -- 408
								text = zh and "确认删除" or "Delete", -- 408
								danger = true, -- 408
								renderOrder = 10, -- 408
								onTapped = deleteDetail -- 408
							} -- 408
						) -- 408
					) -- 408
				else -- 408
					local ____React_createElement_22 = React.createElement -- 408
					local ____temp_20 = {tag = "mobile-llm-detail"} -- 408
					local ____React_createElement_result_21 = React.createElement( -- 408
						"label", -- 408
						{ -- 408
							x = 20, -- 408
							y = sheetHeight - 24, -- 408
							anchorX = 0, -- 408
							anchorY = 1, -- 408
							fontName = fontName, -- 408
							fontSize = 22, -- 408
							text = compactText(detail.name, 28), -- 408
							color3 = 16052712 -- 408
						} -- 408
					) -- 408
					local ____temp_19 -- 411
					if detailError ~= "" then -- 411
						____temp_19 = React.createElement("label", { -- 411
							x = sheetWidth - 20, -- 411
							y = sheetHeight - 25, -- 411
							anchorX = 1, -- 411
							anchorY = 1, -- 411
							fontName = fontName, -- 411
							fontSize = 12, -- 411
							text = detailError, -- 411
							color3 = 4286505640 -- 411
						}) -- 411
					else -- 411
						____temp_19 = nil -- 411
					end -- 411
					____temp_23 = ____React_createElement_22( -- 411
						"node", -- 411
						____temp_20, -- 411
						____React_createElement_result_21, -- 411
						____temp_19, -- 411
						React.createElement("label", { -- 411
							x = 20, -- 411
							y = sheetHeight - 68, -- 411
							anchorX = 0, -- 411
							anchorY = 1, -- 411
							fontName = fontName, -- 411
							fontSize = 13, -- 411
							text = zh and "模型" or "Model", -- 411
							color3 = 11055037 -- 411
						}), -- 411
						React.createElement( -- 411
							"label", -- 411
							{ -- 411
								x = 20, -- 411
								y = sheetHeight - 94, -- 411
								anchorX = 0, -- 411
								anchorY = 1, -- 411
								fontName = fontName, -- 411
								fontSize = 15, -- 411
								text = compactText(detail.model, shortLandscape and 56 or 38), -- 411
								color3 = 16052712 -- 411
							} -- 411
						), -- 411
						React.createElement("label", { -- 411
							x = 20, -- 411
							y = sheetHeight - 132, -- 411
							anchorX = 0, -- 411
							anchorY = 1, -- 411
							fontName = fontName, -- 411
							fontSize = 13, -- 411
							text = "API URL", -- 411
							color3 = 11055037 -- 411
						}), -- 411
						React.createElement( -- 411
							"label", -- 411
							{ -- 411
								x = 20, -- 411
								y = sheetHeight - 158, -- 411
								anchorX = 0, -- 411
								anchorY = 1, -- 411
								fontName = fontName, -- 411
								fontSize = 13, -- 411
								text = compactText(detail.url, shortLandscape and 72 or 42), -- 411
								color3 = 16052712 -- 411
							} -- 411
						), -- 411
						React.createElement( -- 411
							"label", -- 411
							{ -- 411
								x = 20, -- 411
								y = sheetHeight - 200, -- 411
								anchorX = 0, -- 411
								anchorY = 1, -- 411
								fontName = fontName, -- 411
								fontSize = 13, -- 411
								text = ((((zh and "上下文" or "Context") .. "  ") .. tostring(detail.contextWindow)) .. "   ·   Function Call  ") .. (detail.supportsFunctionCalling and (zh and "支持" or "On") or (zh and "不支持" or "Off")), -- 411
								color3 = 11055037 -- 411
							} -- 411
						), -- 411
						React.createElement( -- 411
							MobileButton, -- 418
							{ -- 418
								tag = "mobile-llm-detail-key-edit", -- 418
								x = 20, -- 418
								y = 76, -- 418
								width = math.floor((contentWidth - 12) * 0.62), -- 418
								text = zh and "修改 API Key" or "Update API key", -- 418
								renderOrder = 10, -- 418
								onTapped = function() -- 418
									detailMode = "key" -- 418
									detailKey = "" -- 418
									detailError = "" -- 418
									render() -- 418
								end -- 418
							} -- 418
						), -- 418
						React.createElement( -- 418
							MobileButton, -- 419
							{ -- 419
								tag = "mobile-llm-detail-delete", -- 419
								x = 32 + math.floor((contentWidth - 12) * 0.62), -- 419
								y = 76, -- 419
								width = contentWidth - 12 - math.floor((contentWidth - 12) * 0.62), -- 419
								text = zh and "删除" or "Delete", -- 419
								danger = true, -- 419
								renderOrder = 10, -- 419
								onTapped = function() -- 419
									detailMode = "delete" -- 419
									detailError = "" -- 419
									render() -- 419
								end -- 419
							} -- 419
						), -- 419
						React.createElement( -- 419
							MobileButton, -- 420
							{ -- 420
								tag = "mobile-llm-detail-back", -- 420
								x = 20, -- 420
								y = 20, -- 420
								width = math.floor((contentWidth - 12) * 0.36), -- 420
								text = zh and "返回列表" or "Back", -- 420
								renderOrder = 10, -- 420
								onTapped = function() -- 420
									detailId = 0 -- 420
									render() -- 420
								end -- 420
							} -- 420
						), -- 420
						React.createElement( -- 420
							MobileButton, -- 421
							{ -- 421
								tag = "mobile-llm-detail-select", -- 421
								x = 32 + math.floor((contentWidth - 12) * 0.36), -- 421
								y = 20, -- 421
								width = contentWidth - 12 - math.floor((contentWidth - 12) * 0.36), -- 421
								text = detail.id == selectedId and (switchPending and (zh and "下一轮使用" or "Use next") or (options.taskRunning and (zh and "本轮使用" or "In this run") or (zh and "当前使用" or "In use"))) or (zh and "切换到此配置" or "Use this config"), -- 421
								primary = detail.id ~= selectedId, -- 421
								renderOrder = 10, -- 421
								onTapped = function() return select(detail.id) end -- 421
							} -- 421
						) -- 421
					) -- 421
				end -- 421
				____temp_24 = ____temp_23 -- 402
			end -- 402
			____detail_32 = ____temp_24 -- 389
		else -- 389
			local ____React_createElement_31 = React.createElement -- 389
			local ____array_30 = __TS__SparseArrayNew( -- 389
				"node", -- 389
				{tag = "mobile-llm-list"}, -- 389
				React.createElement("label", { -- 389
					x = 20, -- 389
					y = sheetHeight - 24, -- 389
					anchorX = 0, -- 389
					anchorY = 1, -- 389
					fontName = fontName, -- 389
					fontSize = 22, -- 389
					text = zh and "模型配置" or "Model configurations", -- 389
					color3 = 16052712 -- 389
				}), -- 389
				React.createElement("label", { -- 389
					x = 20, -- 389
					y = sheetHeight - 58, -- 389
					anchorX = 0, -- 389
					anchorY = 1, -- 389
					fontName = fontName, -- 389
					fontSize = 13, -- 389
					text = options.taskRunning and (zh and "切换将在下一轮生效" or "Changes apply to the next run") or (zh and "选择当前 Remix 使用的配置" or "Choose the configuration for Remix"), -- 389
					color3 = 11055037 -- 389
				}) -- 389
			) -- 389
			local ____temp_25 -- 428
			if pageCount > 1 then -- 428
				____temp_25 = React.createElement( -- 428
					"label", -- 428
					{ -- 428
						x = sheetWidth - 20, -- 428
						y = sheetHeight - 58, -- 428
						anchorX = 1, -- 428
						anchorY = 1, -- 428
						fontName = fontName, -- 428
						fontSize = 12, -- 428
						text = (tostring(page + 1) .. " / ") .. tostring(pageCount), -- 428
						color3 = 11055037 -- 428
					} -- 428
				) -- 428
			else -- 428
				____temp_25 = nil -- 428
			end -- 428
			__TS__SparseArrayPush( -- 428
				____array_30, -- 428
				____temp_25, -- 428
				__TS__ArrayMap( -- 429
					pageItems, -- 429
					function(____, item, index) -- 429
						local y = sheetHeight - 126 - index * 68 -- 430
						local selected = item.id == selectedId -- 431
						local ____React_createElement_28 = React.createElement -- 431
						local ____array_27 = __TS__SparseArrayNew( -- 431
							"node", -- 431
							{ -- 431
								key = tostring(item.id), -- 431
								tag = "mobile-llm-config-" .. tostring(item.id), -- 431
								x = 20, -- 431
								y = y, -- 431
								width = contentWidth, -- 431
								height = 54, -- 431
								anchorX = 0, -- 431
								anchorY = 0, -- 431
								touchEnabled = true, -- 431
								swallowTouches = true, -- 431
								onTapped = function() return select(item.id) end -- 431
							}, -- 431
							React.createElement(RoundedSurface, { -- 431
								width = contentWidth, -- 431
								height = 54, -- 431
								radius = 14, -- 431
								topColor = selected and 4282004512 or 4280626233, -- 431
								bottomColor = selected and 4280360210 or 4279704613, -- 431
								borderWidth = 1, -- 431
								borderColor = selected and 4294954035 or 4281613128 -- 431
							}), -- 431
							React.createElement( -- 431
								"draw-node", -- 431
								{x = 20, y = 27}, -- 431
								React.createElement("dot-shape", {radius = 8, color = selected and 4294954035 or 4285495432}), -- 431
								React.createElement("dot-shape", {radius = selected and 3 or 5, color = selected and 4279702282 or 4279704613}) -- 431
							), -- 431
							React.createElement( -- 431
								"label", -- 431
								{ -- 431
									x = 38, -- 431
									y = 34, -- 431
									anchorX = 0, -- 431
									fontName = fontName, -- 431
									fontSize = 15, -- 431
									text = compactText(item.name, shortLandscape and 34 or 22), -- 431
									color3 = 16052712 -- 431
								} -- 431
							), -- 431
							React.createElement( -- 431
								"label", -- 431
								{ -- 431
									x = 38, -- 431
									y = 15, -- 431
									anchorX = 0, -- 431
									fontName = fontName, -- 431
									fontSize = 11, -- 431
									text = compactText(item.model, shortLandscape and 52 or 30), -- 431
									color3 = 11055037 -- 431
								} -- 431
							) -- 431
						) -- 431
						local ____selected_26 -- 437
						if selected then -- 437
							____selected_26 = React.createElement("label", { -- 437
								x = contentWidth - 54, -- 437
								y = 27, -- 437
								anchorX = 1, -- 437
								fontName = fontName, -- 437
								fontSize = 11, -- 437
								text = switchPending and (zh and "下一轮" or "Next") or (options.taskRunning and (zh and "本轮" or "Running") or (zh and "当前" or "Current")), -- 437
								color3 = 16763955 -- 437
							}) -- 437
						else -- 437
							____selected_26 = nil -- 437
						end -- 437
						__TS__SparseArrayPush( -- 437
							____array_27, -- 437
							____selected_26, -- 437
							React.createElement( -- 437
								"node", -- 437
								{ -- 437
									tag = "mobile-llm-detail-" .. tostring(item.id), -- 437
									x = contentWidth - 44, -- 437
									y = 0, -- 437
									width = 44, -- 437
									height = 54, -- 437
									anchorX = 0, -- 437
									anchorY = 0, -- 437
									touchEnabled = true, -- 437
									swallowTouches = true, -- 437
									onTapped = function() return openDetail(item.id) end -- 437
								}, -- 437
								React.createElement("label", { -- 437
									x = 26, -- 437
									y = 27, -- 437
									fontName = fontName, -- 437
									fontSize = 18, -- 437
									text = "›", -- 437
									color3 = 11055037 -- 437
								}) -- 437
							) -- 437
						) -- 437
						return ____React_createElement_28(__TS__SparseArraySpread(____array_27)) -- 432
					end -- 429
				) -- 429
			) -- 429
			local ____temp_29 -- 443
			if pageCount > 1 then -- 443
				____temp_29 = React.createElement( -- 443
					"node", -- 443
					nil, -- 443
					React.createElement( -- 443
						MobileButton, -- 444
						{ -- 444
							tag = "mobile-llm-page-prev", -- 444
							x = 20, -- 444
							y = 20, -- 444
							width = 54, -- 444
							text = "‹", -- 444
							renderOrder = 10, -- 444
							onTapped = function() -- 444
								page = (page - 1 + pageCount) % pageCount -- 444
								render() -- 444
							end -- 444
						} -- 444
					), -- 444
					React.createElement( -- 444
						MobileButton, -- 445
						{ -- 445
							tag = "mobile-llm-page-next", -- 445
							x = 86, -- 445
							y = 20, -- 445
							width = 54, -- 445
							text = "›", -- 445
							renderOrder = 10, -- 445
							onTapped = function() -- 445
								page = (page + 1) % pageCount -- 445
								render() -- 445
							end -- 445
						} -- 445
					) -- 445
				) -- 445
			else -- 445
				____temp_29 = React.createElement( -- 445
					MobileButton, -- 446
					{ -- 446
						tag = "mobile-llm-close", -- 446
						x = 20, -- 446
						y = 20, -- 446
						width = math.floor(contentWidth * 0.28), -- 446
						text = zh and "关闭" or "Close", -- 446
						renderOrder = 10, -- 446
						onTapped = function() return close() end -- 446
					} -- 446
				) -- 446
			end -- 446
			__TS__SparseArrayPush( -- 446
				____array_30, -- 446
				____temp_29, -- 446
				React.createElement( -- 446
					MobileButton, -- 447
					{ -- 447
						tag = "mobile-llm-add", -- 447
						x = pageCount > 1 and 152 or 32 + math.floor(contentWidth * 0.28), -- 447
						y = 20, -- 447
						width = pageCount > 1 and contentWidth - 132 or contentWidth - 12 - math.floor(contentWidth * 0.28), -- 447
						text = zh and "＋ 从模板新增" or "+ Add from template", -- 447
						primary = true, -- 447
						renderOrder = 10, -- 447
						onTapped = add -- 447
					} -- 447
				) -- 447
			) -- 447
			____detail_32 = ____React_createElement_31(__TS__SparseArraySpread(____array_30)) -- 447
		end -- 447
		local scene = ____toNode_39(____React_createElement_38( -- 383
			"node", -- 383
			____temp_36, -- 383
			____React_createElement_result_37, -- 383
			____React_createElement_35("node", ____temp_33, ____React_createElement_result_34, ____detail_32) -- 383
		)) -- 383
		if scene then -- 383
			host:addChild(scene) -- 452
		end -- 452
	end -- 357
	host:onAppChange(function(setting) -- 454
		if setting == "Locale" then -- 455
			zh = (string.match(App.locale, "^zh")) ~= nil -- 455
		end -- 455
		if setting == "Size" or setting == "Locale" then -- 454
			render() -- 454
		end -- 454
	end) -- 454
	host:onAppEvent(function(event) -- 455
		if event == "BackButton" then -- 455
			if detailId > 0 then -- 455
				detailId = 0 -- 455
				render() -- 455
			else -- 455
				close() -- 455
			end -- 455
		end -- 455
	end) -- 455
	host:onCleanup(function() -- 456
		disposed = true -- 456
		restoreCovered() -- 456
		if activeSetup == host then -- 456
			activeSetup = nil -- 456
		end -- 456
	end) -- 456
	render() -- 457
	return host -- 458
end -- 247
return ____exports -- 247
