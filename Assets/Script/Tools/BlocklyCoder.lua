-- [ts]: BlocklyCoder.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local logs -- 1
local ____Dora = require("Dora") -- 2
local HttpClient = ____Dora.HttpClient -- 2
local json = ____Dora.json -- 2
local thread = ____Dora.thread -- 2
local Buffer = ____Dora.Buffer -- 2
local Vec2 = ____Dora.Vec2 -- 2
local DNode = ____Dora.Node -- 2
local Log = ____Dora.Log -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local Content = ____Dora.Content -- 2
local Director = ____Dora.Director -- 2
local emit = ____Dora.emit -- 2
local DoraNode = ____Dora.Node -- 2
local App = ____Dora.App -- 2
local HttpServer = ____Dora.HttpServer -- 2
local ImGui = require("ImGui") -- 3
local ____flow = require("Agent.flow") -- 5
local Node = ____flow.Node -- 5
local Flow = ____flow.Flow -- 5
local Config = require("Config") -- 6
local zh = false -- 8
do -- 8
	local res = string.match(App.locale, "^zh") -- 10
	zh = res ~= nil -- 11
end -- 11
local running = true -- 21
if not DB:existDB("llm") then -- 21
	local dbPath = Path(Content.writablePath, "llm.db") -- 24
	DB:exec(("ATTACH DATABASE '" .. dbPath) .. "' AS llm") -- 25
	Director.entry:onCleanup(function() -- 26
		DB:exec("DETACH DATABASE llm") -- 27
		running = false -- 28
	end) -- 26
end -- 26
local config = Config( -- 32
	"llm", -- 32
	"url", -- 32
	"model", -- 32
	"apiKey", -- 32
	"output" -- 32
) -- 32
config:load() -- 33
local url = Buffer(512) -- 35
if type(config.url) == "string" then -- 35
	url.text = config.url -- 37
else -- 37
	config.url = "https://api.deepseek.com/chat/completions" -- 39
	url.text = "https://api.deepseek.com/chat/completions" -- 39
end -- 39
local apiKey = Buffer(256) -- 41
if type(config.apiKey) == "string" then -- 41
	apiKey.text = config.apiKey -- 43
end -- 43
local model = Buffer(128) -- 45
if type(config.model) == "string" then -- 45
	model.text = config.model -- 47
else -- 47
	config.model = "deepseek-chat" -- 49
	model.text = "deepseek-chat" -- 49
end -- 49
local outputFile = Buffer(512) -- 51
if type(config.output) == "string" then -- 51
	outputFile.text = config.output -- 53
else -- 53
	local ____Path_result_0 = Path("Blockly", "Output.bl") -- 55
	config.output = ____Path_result_0 -- 55
	outputFile.text = ____Path_result_0 -- 55
end -- 55
local function callLLM(messages, url, apiKey, model, receiver) -- 63
	local data = {model = model, messages = messages, temperature = 0, stream = true} -- 64
	return __TS__New( -- 70
		__TS__Promise, -- 70
		function(____, resolve, reject) -- 70
			thread(function() -- 71
				local jsonStr = json.encode(data) -- 72
				if jsonStr ~= nil then -- 72
					local res = HttpClient:postAsync( -- 74
						url, -- 74
						{"Authorization: Bearer " .. apiKey}, -- 74
						jsonStr, -- 76
						10, -- 76
						receiver -- 76
					) -- 76
					if res ~= nil then -- 76
						resolve(nil, res) -- 78
					else -- 78
						reject(nil, "failed to get http response") -- 80
					end -- 80
				end -- 80
			end) -- 71
		end -- 70
	) -- 70
end -- 63
local function extractTSBlocks(text) -- 87
	local blocks = {} -- 88
	for code in string.gmatch(text, "```%s*[tT][sS%w-]*%s*\n(.-)\n()```") do -- 89
		blocks[#blocks + 1] = code -- 90
	end -- 90
	return #blocks == 0 and text or table.concat(blocks, "\n") -- 92
end -- 87
local root = DNode() -- 95
local llmWorking = false -- 101
local function getSystemPrompt() -- 103
	local filename = Path(Content.writablePath, outputFile.text) -- 104
	return ((("\n你有一个 TypeScript 的 DSL 框架，用来模拟编写 Blockly 的积木编程代码。\n\nDSL 框架模块的 API 定义和用法示例如下：\n\n" .. Content:load(Path( -- 105
		Content.assetPath, -- 110
		"Script", -- 110
		"Lib", -- 110
		"Agent", -- 110
		"BlocklyGen.d.ts" -- 110
	))) .. "\n\n编写出的 Blockly 积木代码需遵守以下事项：\n- 数组下标从1开始\n- 对变量名对大小写不敏感，勿用大小写区分变量\n- 导入 DSL 模块请使用代码 `import Gen from 'Agent/BlocklyGen';`\n- 确保最后给我的回答只包含纯粹的 TypeScript 代码，不要包含任何非代码的说明\n- 坐标计算均使用左手系坐标，包括所有绘图 API 中的坐标\n- 程序块请放在`const root`变量中，函数定义放在`const funcs`变量中\n- 最后输出的 jsonCode 变量请原样补充如下的处理代码：\nimport * as Dora from 'Dora';\nDora.Content.save(\"") .. filename) .. "\"), jsonCode);\n" -- 110
end -- 103
local ChatNode = __TS__Class() -- 125
ChatNode.name = "ChatNode" -- 125
__TS__ClassExtends(ChatNode, Node) -- 125
function ChatNode.prototype.prep(self, shared) -- 126
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 126
		return ____awaiter_resolve( -- 126
			nil, -- 126
			__TS__New( -- 127
				__TS__Promise, -- 127
				function(____, resolve) -- 127
					root:slot( -- 128
						"Input", -- 128
						function(message) -- 128
							local systemContent = getSystemPrompt() -- 129
							local userContent = ("\n你是一名经验丰富的 TypeScript 代码专家。\n\n任务目标：\n1. 阅读「Blockly DSL 框架 API 与示例用法」以及需求描述。\n2. 将需求拆分为具体的积木块功能，并规划对应的 TypeScript 代码结构。\n3. 编写完整的积木块实现代码，使其符合需求并能够正确运行。\n\n回答格式必须分两部分：\n\n1.思考过程\n逐步阐述你的推理：先研读 API 与示例 → 拆解需求 → 规划积木块功能 → 制定代码结构 → 编写实现代码。\n用条目或小节清晰列出，不要省略中间推理步骤。\n\n2.最终答案\n完整的 TypeScript 积木块实现代码（用 ```typescript``` 代码块包裹）。\n期望的功能行为或输出结果，用简要文字或示例说明。\n注意：先完整写出思考过程，再给出最终代码；不要在思考过程中提前透露最终代码或结果。\n\n需求如下：\n\n" .. message) .. "\n" -- 130
							shared.messages = {{role = "system", content = systemContent}, {role = "user", content = userContent}} -- 153
							resolve(nil, nil) -- 157
						end -- 128
					) -- 128
				end -- 127
			) -- 127
		) -- 127
	end) -- 127
end -- 126
local LLMCode = __TS__Class() -- 163
LLMCode.name = "LLMCode" -- 163
__TS__ClassExtends(LLMCode, Node) -- 163
function LLMCode.prototype.prep(self, shared) -- 164
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 164
		return ____awaiter_resolve(nil, shared.messages) -- 164
	end) -- 164
end -- 164
function LLMCode.prototype.exec(self, messages) -- 167
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 167
		return ____awaiter_resolve( -- 167
			nil, -- 167
			__TS__New( -- 168
				__TS__Promise, -- 168
				function(____, resolve, reject) -- 168
					return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 168
						local str = "" -- 169
						root:emit("Output", "Coder: ") -- 170
						llmWorking = true -- 171
						local ____try = __TS__AsyncAwaiter(function() -- 171
							__TS__Await(callLLM( -- 173
								messages, -- 173
								url.text, -- 173
								apiKey.text, -- 173
								model.text, -- 173
								function(data) -- 173
									if not running then -- 173
										return true -- 175
									end -- 175
									local done = string.match(data, "data:%s*(%b[])") -- 177
									if done == "[DONE]" then -- 177
										resolve(nil, str) -- 179
										return false -- 180
									end -- 180
									for item in string.gmatch(data, "data:%s*(%b{})") do -- 182
										local res = json.decode(item) -- 183
										if res then -- 183
											local part = res.choices[1].delta.content -- 185
											if type(part) == "string" then -- 185
												str = str .. part -- 187
											end -- 187
										end -- 187
									end -- 187
									root:emit("Update", "Coder: " .. str) -- 191
									return false -- 192
								end -- 173
							)) -- 173
						end) -- 173
						__TS__Await(____try.catch( -- 172
							____try, -- 172
							function(____, e) -- 172
								llmWorking = false -- 195
								reject(nil, e) -- 196
							end -- 196
						)) -- 196
					end) -- 196
				end -- 168
			) -- 168
		) -- 168
	end) -- 168
end -- 167
function LLMCode.prototype.post(self, shared, _prepRes, execRes) -- 200
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 200
		local code = extractTSBlocks(execRes) -- 201
		local ____shared_messages_1 = shared.messages -- 201
		____shared_messages_1[#____shared_messages_1 + 1] = {role = "system", content = code} -- 202
		return ____awaiter_resolve(nil, nil) -- 202
	end) -- 202
end -- 200
local function compileTS(file, content) -- 212
	local data = {name = "TranspileTS", file = file, content = content} -- 213
	return __TS__New( -- 214
		__TS__Promise, -- 214
		function(____, resolve) -- 214
			if HttpServer.wsConnectionCount == 0 then -- 214
				resolve(nil, {success = false, result = "Web IDE not connected"}) -- 216
				return -- 217
			end -- 217
			local node = DoraNode() -- 219
			node:gslot( -- 220
				"AppWS", -- 220
				function(eventType, msg) -- 220
					if eventType == "Receive" then -- 220
						node:removeFromParent() -- 222
						local res = json.decode(msg) -- 223
						if res and res.name == "TranspileTS" then -- 223
							if res.success then -- 223
								resolve(nil, {success = true, result = res.luaCode}) -- 226
							else -- 226
								resolve(nil, {success = false, result = res.message}) -- 228
							end -- 228
						end -- 228
					end -- 228
				end -- 220
			) -- 220
			local str = json.encode(data) -- 233
			if str then -- 233
				emit("AppWS", "Send", str) -- 235
			end -- 235
		end -- 214
	) -- 214
end -- 212
local CompileNode = __TS__Class() -- 240
CompileNode.name = "CompileNode" -- 240
__TS__ClassExtends(CompileNode, Node) -- 240
function CompileNode.prototype.prep(self, shared) -- 241
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 241
		return ____awaiter_resolve(nil, shared.messages[#shared.messages].content) -- 241
	end) -- 241
end -- 241
function CompileNode.prototype.exec(self, code) -- 244
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 244
		return ____awaiter_resolve( -- 244
			nil, -- 244
			__TS__Await(compileTS( -- 245
				Path( -- 245
					Content.writablePath, -- 245
					Path:getPath(outputFile.text), -- 245
					"__code__.ts" -- 245
				), -- 245
				code -- 245
			)) -- 245
		) -- 245
	end) -- 245
end -- 244
function CompileNode.prototype.post(self, shared, prepRes, execRes) -- 247
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 247
		if execRes.success then -- 247
			local ____shared_messages_2 = shared.messages -- 247
			____shared_messages_2[#____shared_messages_2 + 1] = {role = "user", content = prepRes} -- 249
			logs[#logs + 1] = "代码编译成功！" -- 250
			return ____awaiter_resolve(nil, "Success") -- 250
		else -- 250
			local ____shared_messages_3 = shared.messages -- 250
			____shared_messages_3[#____shared_messages_3 + 1] = {role = "user", content = (prepRes .. "\n\n编译错误信息如下：\n") .. execRes.result} -- 253
			logs[#logs + 1] = "代码编译失败！" -- 254
			logs[#logs + 1] = execRes.result -- 255
			return ____awaiter_resolve(nil, "Failed") -- 255
		end -- 255
	end) -- 255
end -- 247
local FixNode = __TS__Class() -- 261
FixNode.name = "FixNode" -- 261
__TS__ClassExtends(FixNode, Node) -- 261
function FixNode.prototype.prep(self, shared) -- 262
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 262
		local codeAndError = shared.messages[#shared.messages].content -- 263
		local systemContent = getSystemPrompt() -- 264
		local userContent = ("\n你是一名经验丰富的 TypeScript 代码专家。\n\n任务目标：\n1. 阅读「相关代码模块信息」、原始代码片段，以及随后的编译错误信息。\n2. 找出导致编译失败的根本原因，并给出修正后的完整代码。\n3. 展示修正后代码运行的正确输出结果或关键行为。\n\n回答格式必须分两部分：\n1. 思考过程\n逐步阐述你的推理：先定位错误 → 分析原因 → 制定修复策略 → 说明为何这样修改。\n用条目或小节清晰列出，不要省略中间推理步骤。\n\n2. 最终答案\n修正后的完整代码（用 ```typescript``` 代码块包裹）。\n期望输出或结果说明，用简要文字或示例输出展示。\n注意：先完整写出思考过程，再给出最终答案；不要在思考过程中提前透露最终代码或结果。\n\n原始代码及编译错误信息：\n\n" .. codeAndError) .. "\n" -- 265
		shared.messages = {{role = "system", content = systemContent}, {role = "user", content = userContent}} -- 287
	end) -- 287
end -- 262
function FixNode.prototype.exec(self) -- 292
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 292
		logs[#logs + 1] = "开始修复代码！" -- 293
	end) -- 293
end -- 292
local SaveNode = __TS__Class() -- 297
SaveNode.name = "SaveNode" -- 297
__TS__ClassExtends(SaveNode, Node) -- 297
function SaveNode.prototype.prep(self, shared) -- 298
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 298
		return ____awaiter_resolve(nil, shared.messages[#shared.messages].content) -- 298
	end) -- 298
end -- 298
function SaveNode.prototype.exec(self, code) -- 301
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 301
		llmWorking = false -- 302
		local filename = Path( -- 303
			Content.writablePath, -- 303
			Path:getPath(outputFile.text), -- 303
			Path:getFilename(Path:replaceExt(outputFile.text, "")) .. "Gen.ts" -- 303
		) -- 303
		if Content:save(filename, code) then -- 303
			logs[#logs + 1] = "保存代码成功！" .. filename -- 305
		else -- 305
			logs[#logs + 1] = "保存代码失败！" .. filename -- 307
		end -- 307
		local res = __TS__Await(compileTS(filename, code)) -- 309
		if res.success then -- 309
			local luaFile = Path:replaceExt(filename, "lua") -- 311
			if Content:save(luaFile, res.result) then -- 311
				logs[#logs + 1] = "保存代码成功！" .. luaFile -- 313
			else -- 313
				logs[#logs + 1] = "保存代码失败！" .. luaFile -- 315
			end -- 315
			local ____try = __TS__AsyncAwaiter(function() -- 315
				local func = load(res.result, luaFile) -- 318
				if func then -- 318
					func() -- 319
				end -- 319
				logs[#logs + 1] = "生成代码成功！" -- 320
			end) -- 320
			__TS__Await(____try.catch( -- 317
				____try, -- 317
				function(____, e) -- 317
					logs[#logs + 1] = "生成代码失败！" -- 322
					Log( -- 323
						"Error", -- 323
						tostring(e) -- 323
					) -- 323
				end -- 323
			)) -- 323
		end -- 323
	end) -- 323
end -- 301
local chatNode = __TS__New(ChatNode) -- 329
local llmCode = __TS__New(LLMCode, 2, 1) -- 330
local compileNode = __TS__New(CompileNode) -- 331
local saveNode = __TS__New(SaveNode) -- 332
local fixNode = __TS__New(FixNode) -- 333
chatNode:next(llmCode) -- 334
llmCode:next(compileNode) -- 335
compileNode:on("Success", saveNode) -- 336
compileNode:on("Failed", fixNode) -- 337
fixNode:next(llmCode) -- 338
saveNode:next(chatNode) -- 339
local flow = __TS__New(Flow, chatNode) -- 341
local runFlow -- 342
runFlow = function() -- 342
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 342
		local chatInfo = {messages = {}} -- 343
		local ____try = __TS__AsyncAwaiter(function() -- 343
			__TS__Await(flow:run(chatInfo)) -- 347
		end) -- 347
		__TS__Await(____try.catch( -- 346
			____try, -- 346
			function(____, err) -- 346
				Log("Error", err) -- 349
				runFlow() -- 350
			end -- 350
		)) -- 350
	end) -- 350
end -- 342
runFlow() -- 353
logs = {} -- 355
local inputBuffer = Buffer(5000) -- 356
local function ChatButton() -- 358
	ImGui.PushItemWidth( -- 359
		-80, -- 359
		function() -- 359
			if ImGui.InputText(zh and "描述需求" or "Desc", inputBuffer, {"EnterReturnsTrue"}) then -- 359
				local command = inputBuffer.text -- 361
				if command ~= "" then -- 361
					logs = {} -- 363
					logs[#logs + 1] = "User: " .. command -- 364
					root:emit("Input", command) -- 365
				end -- 365
				inputBuffer.text = "" -- 367
			end -- 367
		end -- 359
	) -- 359
end -- 358
local inputFlags = {"Password"} -- 372
local windowsFlags = { -- 373
	"NoMove", -- 374
	"NoCollapse", -- 375
	"NoResize", -- 376
	"NoDecoration", -- 377
	"NoNav", -- 378
	"NoSavedSettings", -- 379
	"NoBringToFrontOnFocus", -- 380
	"NoFocusOnAppearing" -- 381
} -- 381
root:loop(function() -- 383
	local ____App_visualSize_4 = App.visualSize -- 384
	local width = ____App_visualSize_4.width -- 384
	local height = ____App_visualSize_4.height -- 384
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 385
	ImGui.SetNextWindowSize( -- 386
		Vec2(width, height - 40), -- 386
		"Always" -- 386
	) -- 386
	ImGui.Begin( -- 387
		"Blockly Coder", -- 387
		windowsFlags, -- 387
		function() -- 387
			ImGui.Text(zh and "Blockly 编程家" or "Blockly Coder") -- 388
			ImGui.SameLine() -- 389
			ImGui.TextDisabled("(?)") -- 390
			if ImGui.IsItemHovered() then -- 390
				ImGui.BeginTooltip(function() -- 392
					ImGui.PushTextWrapPos( -- 393
						400, -- 393
						function() -- 393
							ImGui.Text(zh and "请先配置大模型 API 密钥，然后输入自然语言需求，Agent 将自动生成 TypeScript 积木代码，编译成 Blockly 积木并翻译为 Lua 脚本运行。遇到编译失败会自动修正，无需手动干预。" or "First, configure the API key for the large language model. Then, input your natural language requirements. The Agent will automatically generate TypeScript building block code, compile it into Blockly blocks, and translate it into Lua scripts for execution. If any compilation errors occur, they will be automatically corrected without requiring manual intervention.") -- 394
						end -- 393
					) -- 393
				end) -- 392
			end -- 392
			ImGui.SameLine() -- 399
			ImGui.Dummy(Vec2(width - 290, 0)) -- 400
			ImGui.SameLine() -- 401
			if ImGui.CollapsingHeader(zh and "配置" or "Config") then -- 401
				if ImGui.InputText(zh and "API 地址" or "API URL", url) then -- 401
					config.url = url.text -- 404
				end -- 404
				if ImGui.InputText(zh and "API 密钥" or "API Key", apiKey, inputFlags) then -- 404
					config.apiKey = apiKey.text -- 407
				end -- 407
				if ImGui.InputText(zh and "模型" or "Model", model) then -- 407
					config.model = model.text -- 410
				end -- 410
				if ImGui.InputText(zh and "输出文件" or "Output File", outputFile) then -- 410
					config.output = outputFile.text -- 413
				end -- 413
			end -- 413
			ImGui.Separator() -- 416
			ImGui.BeginChild( -- 417
				"LogArea", -- 417
				Vec2(0, -40), -- 417
				function() -- 417
					for ____, log in ipairs(logs) do -- 418
						ImGui.TextWrapped(log) -- 419
					end -- 419
					if ImGui.GetScrollY() >= ImGui.GetScrollMaxY() then -- 419
						ImGui.SetScrollHereY(1) -- 422
					end -- 422
				end -- 417
			) -- 417
			if llmWorking or config.output == "" then -- 417
				ImGui.BeginDisabled(function() -- 426
					ChatButton() -- 427
				end) -- 426
			else -- 426
				ChatButton() -- 430
			end -- 430
		end -- 387
	) -- 387
	return false -- 433
end) -- 383
root:slot( -- 436
	"Output", -- 436
	function(message) -- 436
		logs[#logs + 1] = message -- 437
	end -- 436
) -- 436
root:slot( -- 440
	"Update", -- 440
	function(message) -- 440
		logs[#logs] = message -- 441
	end -- 440
) -- 440
return ____exports -- 440