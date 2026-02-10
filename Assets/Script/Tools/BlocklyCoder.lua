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
local ____Utils = require("Agent.Utils") -- 6
local createSSEJSONParser = ____Utils.createSSEJSONParser -- 6
local Config = require("Config") -- 7
local zh = false -- 9
do -- 9
	local res = string.match(App.locale, "^zh") -- 11
	zh = res ~= nil -- 12
end -- 12
local running = true -- 22
if not DB:existDB("llm") then -- 22
	local dbPath = Path(Content.writablePath, "llm.db") -- 25
	DB:exec(("ATTACH DATABASE '" .. dbPath) .. "' AS llm") -- 26
	Director.entry:onCleanup(function() -- 27
		DB:exec("DETACH DATABASE llm") -- 28
		running = false -- 29
	end) -- 27
end -- 27
local config = Config( -- 33
	"llm", -- 33
	"url", -- 33
	"model", -- 33
	"apiKey", -- 33
	"output" -- 33
) -- 33
config:load() -- 34
local url = Buffer(512) -- 36
if type(config.url) == "string" then -- 36
	url.text = config.url -- 38
else -- 38
	config.url = "https://api.deepseek.com/chat/completions" -- 40
	url.text = "https://api.deepseek.com/chat/completions" -- 40
end -- 40
local apiKey = Buffer(256) -- 42
if type(config.apiKey) == "string" then -- 42
	apiKey.text = config.apiKey -- 44
end -- 44
local model = Buffer(128) -- 46
if type(config.model) == "string" then -- 46
	model.text = config.model -- 48
else -- 48
	config.model = "deepseek-chat" -- 50
	model.text = "deepseek-chat" -- 50
end -- 50
local outputFile = Buffer(512) -- 52
if type(config.output) == "string" then -- 52
	outputFile.text = config.output -- 54
else -- 54
	local ____Path_result_0 = Path("Blockly", "Output.bl") -- 56
	config.output = ____Path_result_0 -- 56
	outputFile.text = ____Path_result_0 -- 56
end -- 56
local function callLLM(messages, url, apiKey, model, receiver) -- 64
	local data = {model = model, messages = messages, temperature = 0, stream = true} -- 65
	return __TS__New( -- 71
		__TS__Promise, -- 71
		function(____, resolve, reject) -- 71
			thread(function() -- 72
				local jsonStr = json.encode(data) -- 73
				if jsonStr ~= nil then -- 73
					local res = HttpClient:postAsync( -- 75
						url, -- 75
						{"Authorization: Bearer " .. apiKey}, -- 75
						jsonStr, -- 77
						10, -- 77
						receiver -- 77
					) -- 77
					if res ~= nil then -- 77
						resolve(nil, res) -- 79
					else -- 79
						reject(nil, "failed to get http response") -- 81
					end -- 81
				end -- 81
			end) -- 72
		end -- 71
	) -- 71
end -- 64
local function extractTSBlocks(text) -- 88
	local blocks = {} -- 89
	for code in string.gmatch(text, "```%s*[tT][sS%w-]*%s*\n(.-)\n()```") do -- 90
		blocks[#blocks + 1] = code -- 91
	end -- 91
	return #blocks == 0 and text or table.concat(blocks, "\n") -- 93
end -- 88
local root = DNode() -- 96
local llmWorking = false -- 102
local function getSystemPrompt() -- 104
	local filename = Path(Content.writablePath, outputFile.text) -- 105
	return ((("\n你有一个 TypeScript 的 DSL 框架，用来模拟编写 Blockly 的积木编程代码。\n\nDSL 框架模块的 API 定义和用法示例如下：\n\n" .. Content:load(Path( -- 106
		Content.assetPath, -- 111
		"Script", -- 111
		"Lib", -- 111
		"Agent", -- 111
		"BlocklyGen.d.ts" -- 111
	))) .. "\n\n编写出的 Blockly 积木代码需遵守以下事项：\n- 数组下标从1开始\n- 对变量名对大小写不敏感，勿用大小写区分变量\n- 导入 DSL 模块请使用代码 `import Gen from 'Agent/BlocklyGen';`\n- 确保最后给我的回答只包含纯粹的 TypeScript 代码，不要包含任何非代码的说明\n- 坐标计算均使用左手系坐标，包括所有绘图 API 中的坐标\n- 程序块请放在`const root`变量中，函数定义放在`const funcs`变量中\n- 最后输出的 jsonCode 变量请原样补充如下的处理代码：\nimport * as Dora from 'Dora';\nDora.Content.save(\"") .. filename) .. "\"), jsonCode);\n" -- 111
end -- 104
local ChatNode = __TS__Class() -- 126
ChatNode.name = "ChatNode" -- 126
__TS__ClassExtends(ChatNode, Node) -- 126
function ChatNode.prototype.prep(self, shared) -- 127
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 127
		return ____awaiter_resolve( -- 127
			nil, -- 127
			__TS__New( -- 128
				__TS__Promise, -- 128
				function(____, resolve) -- 128
					root:slot( -- 129
						"Input", -- 129
						function(message) -- 129
							local systemContent = getSystemPrompt() -- 130
							local userContent = ("\n你是一名经验丰富的 TypeScript 代码专家。\n\n任务目标：\n1. 阅读「Blockly DSL 框架 API 与示例用法」以及需求描述。\n2. 将需求拆分为具体的积木块功能，并规划对应的 TypeScript 代码结构。\n3. 编写完整的积木块实现代码，使其符合需求并能够正确运行。\n\n回答格式必须分两部分：\n\n1.思考过程\n逐步阐述你的推理：先研读 API 与示例 → 拆解需求 → 规划积木块功能 → 制定代码结构 → 编写实现代码。\n用条目或小节清晰列出，不要省略中间推理步骤。\n\n2.最终答案\n完整的 TypeScript 积木块实现代码（用 ```typescript``` 代码块包裹）。\n期望的功能行为或输出结果，用简要文字或示例说明。\n注意：先完整写出思考过程，再给出最终代码；不要在思考过程中提前透露最终代码或结果。\n\n需求如下：\n\n" .. message) .. "\n" -- 131
							shared.messages = {{role = "system", content = systemContent}, {role = "user", content = userContent}} -- 154
							resolve(nil, nil) -- 158
						end -- 129
					) -- 129
				end -- 128
			) -- 128
		) -- 128
	end) -- 128
end -- 127
local LLMCode = __TS__Class() -- 164
LLMCode.name = "LLMCode" -- 164
__TS__ClassExtends(LLMCode, Node) -- 164
function LLMCode.prototype.prep(self, shared) -- 165
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 165
		return ____awaiter_resolve(nil, shared.messages) -- 165
	end) -- 165
end -- 165
function LLMCode.prototype.exec(self, messages) -- 168
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 168
		return ____awaiter_resolve( -- 168
			nil, -- 168
			__TS__New( -- 169
				__TS__Promise, -- 169
				function(____, resolve, reject) -- 169
					return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 169
						local allContent = "" -- 170
						local allReasoning = "" -- 171
						root:emit("Output", "Coder: ") -- 172
						llmWorking = true -- 173
						local parser = createSSEJSONParser({onJSON = function(obj) -- 174
							local ____obj_choices__1_delta_1 = obj.choices[1].delta -- 176
							local reasoning_content = ____obj_choices__1_delta_1.reasoning_content -- 176
							local content = ____obj_choices__1_delta_1.content -- 176
							if reasoning_content ~= nil then -- 176
								allReasoning = allReasoning .. reasoning_content -- 178
							end -- 178
							if content ~= nil then -- 178
								allContent = allContent .. content -- 181
							end -- 181
							root:emit("Update", "Coder: " .. allReasoning .. (allContent ~= "" and "\n" .. allContent or "")) -- 183
						end}) -- 175
						local ____try = __TS__AsyncAwaiter(function() -- 175
							__TS__Await(callLLM( -- 187
								messages, -- 187
								url.text, -- 187
								apiKey.text, -- 187
								model.text, -- 187
								function(data) -- 187
									if not running then -- 187
										return true -- 189
									end -- 189
									parser.feed(data) -- 191
									return false -- 192
								end -- 187
							)) -- 187
							parser["end"]() -- 194
							resolve(nil, allContent) -- 195
						end) -- 195
						__TS__Await(____try.catch( -- 186
							____try, -- 186
							function(____, e) -- 186
								llmWorking = false -- 197
								reject(nil, e) -- 198
							end -- 198
						)) -- 198
					end) -- 198
				end -- 169
			) -- 169
		) -- 169
	end) -- 169
end -- 168
function LLMCode.prototype.post(self, shared, _prepRes, execRes) -- 202
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 202
		local code = extractTSBlocks(execRes) -- 203
		local ____shared_messages_2 = shared.messages -- 203
		____shared_messages_2[#____shared_messages_2 + 1] = {role = "system", content = code} -- 204
		return ____awaiter_resolve(nil, nil) -- 204
	end) -- 204
end -- 202
local function compileTS(file, content) -- 214
	local data = {name = "TranspileTS", file = file, content = content} -- 215
	return __TS__New( -- 216
		__TS__Promise, -- 216
		function(____, resolve) -- 216
			if HttpServer.wsConnectionCount == 0 then -- 216
				resolve(nil, {success = false, result = "Web IDE not connected"}) -- 218
				return -- 219
			end -- 219
			local node = DoraNode() -- 221
			node:gslot( -- 222
				"AppWS", -- 222
				function(eventType, msg) -- 222
					if eventType == "Receive" then -- 222
						node:removeFromParent() -- 224
						local res = json.decode(msg) -- 225
						if res and res.name == "TranspileTS" then -- 225
							if res.success then -- 225
								resolve(nil, {success = true, result = res.luaCode}) -- 228
							else -- 228
								resolve(nil, {success = false, result = res.message}) -- 230
							end -- 230
						end -- 230
					end -- 230
				end -- 222
			) -- 222
			local str = json.encode(data) -- 235
			if str then -- 235
				emit("AppWS", "Send", str) -- 237
			end -- 237
		end -- 216
	) -- 216
end -- 214
local CompileNode = __TS__Class() -- 242
CompileNode.name = "CompileNode" -- 242
__TS__ClassExtends(CompileNode, Node) -- 242
function CompileNode.prototype.prep(self, shared) -- 243
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 243
		return ____awaiter_resolve(nil, shared.messages[#shared.messages].content) -- 243
	end) -- 243
end -- 243
function CompileNode.prototype.exec(self, code) -- 246
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 246
		return ____awaiter_resolve( -- 246
			nil, -- 246
			__TS__Await(compileTS( -- 247
				Path( -- 247
					Content.writablePath, -- 247
					Path:getPath(outputFile.text), -- 247
					"__code__.ts" -- 247
				), -- 247
				code -- 247
			)) -- 247
		) -- 247
	end) -- 247
end -- 246
function CompileNode.prototype.post(self, shared, prepRes, execRes) -- 249
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 249
		if execRes.success then -- 249
			local ____shared_messages_3 = shared.messages -- 249
			____shared_messages_3[#____shared_messages_3 + 1] = {role = "user", content = prepRes} -- 251
			logs[#logs + 1] = "代码编译成功！" -- 252
			return ____awaiter_resolve(nil, "Success") -- 252
		else -- 252
			local ____shared_messages_4 = shared.messages -- 252
			____shared_messages_4[#____shared_messages_4 + 1] = {role = "user", content = (prepRes .. "\n\n编译错误信息如下：\n") .. execRes.result} -- 255
			logs[#logs + 1] = "代码编译失败！" -- 256
			logs[#logs + 1] = execRes.result -- 257
			return ____awaiter_resolve(nil, "Failed") -- 257
		end -- 257
	end) -- 257
end -- 249
local FixNode = __TS__Class() -- 263
FixNode.name = "FixNode" -- 263
__TS__ClassExtends(FixNode, Node) -- 263
function FixNode.prototype.prep(self, shared) -- 264
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 264
		local codeAndError = shared.messages[#shared.messages].content -- 265
		local systemContent = getSystemPrompt() -- 266
		local userContent = ("\n你是一名经验丰富的 TypeScript 代码专家。\n\n任务目标：\n1. 阅读「相关代码模块信息」、原始代码片段，以及随后的编译错误信息。\n2. 找出导致编译失败的根本原因，并给出修正后的完整代码。\n3. 展示修正后代码运行的正确输出结果或关键行为。\n\n回答格式必须分两部分：\n1. 思考过程\n逐步阐述你的推理：先定位错误 → 分析原因 → 制定修复策略 → 说明为何这样修改。\n用条目或小节清晰列出，不要省略中间推理步骤。\n\n2. 最终答案\n修正后的完整代码（用 ```typescript``` 代码块包裹）。\n期望输出或结果说明，用简要文字或示例输出展示。\n注意：先完整写出思考过程，再给出最终答案；不要在思考过程中提前透露最终代码或结果。\n\n原始代码及编译错误信息：\n\n" .. codeAndError) .. "\n" -- 267
		shared.messages = {{role = "system", content = systemContent}, {role = "user", content = userContent}} -- 289
	end) -- 289
end -- 264
function FixNode.prototype.exec(self) -- 294
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 294
		logs[#logs + 1] = "开始修复代码！" -- 295
	end) -- 295
end -- 294
local SaveNode = __TS__Class() -- 299
SaveNode.name = "SaveNode" -- 299
__TS__ClassExtends(SaveNode, Node) -- 299
function SaveNode.prototype.prep(self, shared) -- 300
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 300
		return ____awaiter_resolve(nil, shared.messages[#shared.messages].content) -- 300
	end) -- 300
end -- 300
function SaveNode.prototype.exec(self, code) -- 303
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 303
		llmWorking = false -- 304
		local filename = Path( -- 305
			Content.writablePath, -- 305
			Path:getPath(outputFile.text), -- 305
			Path:getFilename(Path:replaceExt(outputFile.text, "")) .. "Gen.ts" -- 305
		) -- 305
		if Content:save(filename, code) then -- 305
			logs[#logs + 1] = "保存代码成功！" .. filename -- 307
		else -- 307
			logs[#logs + 1] = "保存代码失败！" .. filename -- 309
		end -- 309
		local res = __TS__Await(compileTS(filename, code)) -- 311
		if res.success then -- 311
			local luaFile = Path:replaceExt(filename, "lua") -- 313
			if Content:save(luaFile, res.result) then -- 313
				logs[#logs + 1] = "保存代码成功！" .. luaFile -- 315
			else -- 315
				logs[#logs + 1] = "保存代码失败！" .. luaFile -- 317
			end -- 317
			local ____try = __TS__AsyncAwaiter(function() -- 317
				local func = load(res.result, luaFile) -- 320
				if func then -- 320
					func() -- 321
				end -- 321
				logs[#logs + 1] = "生成代码成功！" -- 322
			end) -- 322
			__TS__Await(____try.catch( -- 319
				____try, -- 319
				function(____, e) -- 319
					logs[#logs + 1] = "生成代码失败！" -- 324
					Log( -- 325
						"Error", -- 325
						tostring(e) -- 325
					) -- 325
				end -- 325
			)) -- 325
		end -- 325
	end) -- 325
end -- 303
local chatNode = __TS__New(ChatNode) -- 331
local llmCode = __TS__New(LLMCode, 2, 1) -- 332
local compileNode = __TS__New(CompileNode) -- 333
local saveNode = __TS__New(SaveNode) -- 334
local fixNode = __TS__New(FixNode) -- 335
chatNode:next(llmCode) -- 336
llmCode:next(compileNode) -- 337
compileNode:on("Success", saveNode) -- 338
compileNode:on("Failed", fixNode) -- 339
fixNode:next(llmCode) -- 340
saveNode:next(chatNode) -- 341
local flow = __TS__New(Flow, chatNode) -- 343
local runFlow -- 344
runFlow = function() -- 344
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 344
		local chatInfo = {messages = {}} -- 345
		local ____try = __TS__AsyncAwaiter(function() -- 345
			__TS__Await(flow:run(chatInfo)) -- 349
		end) -- 349
		__TS__Await(____try.catch( -- 348
			____try, -- 348
			function(____, err) -- 348
				Log("Error", err) -- 351
				runFlow() -- 352
			end -- 352
		)) -- 352
	end) -- 352
end -- 344
runFlow() -- 355
logs = {} -- 357
local inputBuffer = Buffer(5000) -- 358
local function ChatButton() -- 360
	ImGui.PushItemWidth( -- 361
		-80, -- 361
		function() -- 361
			if ImGui.InputText(zh and "描述需求" or "Desc", inputBuffer, {"EnterReturnsTrue"}) then -- 361
				local command = inputBuffer.text -- 363
				if command ~= "" then -- 363
					logs = {} -- 365
					logs[#logs + 1] = "User: " .. command -- 366
					root:emit("Input", command) -- 367
				end -- 367
				inputBuffer.text = "" -- 369
			end -- 369
		end -- 361
	) -- 361
end -- 360
local inputFlags = {"Password"} -- 374
local windowsFlags = { -- 375
	"NoMove", -- 376
	"NoCollapse", -- 377
	"NoResize", -- 378
	"NoDecoration", -- 379
	"NoNav", -- 380
	"NoSavedSettings", -- 381
	"NoBringToFrontOnFocus", -- 382
	"NoFocusOnAppearing" -- 383
} -- 383
root:loop(function() -- 385
	local ____App_visualSize_5 = App.visualSize -- 386
	local width = ____App_visualSize_5.width -- 386
	local height = ____App_visualSize_5.height -- 386
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 387
	ImGui.SetNextWindowSize( -- 388
		Vec2(width, height - 40), -- 388
		"Always" -- 388
	) -- 388
	ImGui.Begin( -- 389
		"Blockly Coder", -- 389
		windowsFlags, -- 389
		function() -- 389
			ImGui.Text(zh and "Blockly 编程家" or "Blockly Coder") -- 390
			ImGui.SameLine() -- 391
			ImGui.TextDisabled("(?)") -- 392
			if ImGui.IsItemHovered() then -- 392
				ImGui.BeginTooltip(function() -- 394
					ImGui.PushTextWrapPos( -- 395
						400, -- 395
						function() -- 395
							ImGui.Text(zh and "请先配置大模型 API 密钥，然后输入自然语言需求，Agent 将自动生成 TypeScript 积木代码，编译成 Blockly 积木并翻译为 Lua 脚本运行。遇到编译失败会自动修正，无需手动干预。" or "First, configure the API key for the large language model. Then, input your natural language requirements. The Agent will automatically generate TypeScript building block code, compile it into Blockly blocks, and translate it into Lua scripts for execution. If any compilation errors occur, they will be automatically corrected without requiring manual intervention.") -- 396
						end -- 395
					) -- 395
				end) -- 394
			end -- 394
			ImGui.SameLine() -- 401
			ImGui.Dummy(Vec2(width - 290, 0)) -- 402
			ImGui.SameLine() -- 403
			if ImGui.CollapsingHeader(zh and "配置" or "Config") then -- 403
				if ImGui.InputText(zh and "API 地址" or "API URL", url) then -- 403
					config.url = url.text -- 406
				end -- 406
				if ImGui.InputText(zh and "API 密钥" or "API Key", apiKey, inputFlags) then -- 406
					config.apiKey = apiKey.text -- 409
				end -- 409
				if ImGui.InputText(zh and "模型" or "Model", model) then -- 409
					config.model = model.text -- 412
				end -- 412
				if ImGui.InputText(zh and "输出文件" or "Output File", outputFile) then -- 412
					config.output = outputFile.text -- 415
				end -- 415
			end -- 415
			ImGui.Separator() -- 418
			ImGui.BeginChild( -- 419
				"LogArea", -- 419
				Vec2(0, -40), -- 419
				function() -- 419
					for ____, log in ipairs(logs) do -- 420
						ImGui.TextWrapped(log) -- 421
					end -- 421
					if ImGui.GetScrollY() >= ImGui.GetScrollMaxY() then -- 421
						ImGui.SetScrollHereY(1) -- 424
					end -- 424
				end -- 419
			) -- 419
			if llmWorking or config.output == "" then -- 419
				ImGui.BeginDisabled(function() -- 428
					ChatButton() -- 429
				end) -- 428
			else -- 428
				ChatButton() -- 432
			end -- 432
		end -- 389
	) -- 389
	return false -- 435
end) -- 385
root:slot( -- 438
	"Output", -- 438
	function(message) -- 438
		logs[#logs + 1] = message -- 439
	end -- 438
) -- 438
root:slot( -- 442
	"Update", -- 442
	function(message) -- 442
		logs[#logs] = message -- 443
	end -- 442
) -- 442
return ____exports -- 442