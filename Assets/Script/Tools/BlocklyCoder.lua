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
local ImGui = require("ImGui") -- 3
local ____flow = require("Agent.flow") -- 5
local Node = ____flow.Node -- 5
local Flow = ____flow.Flow -- 5
local Config = require("Config") -- 6
local zh = false -- 8
do -- 8
	local res = string.match(App.locale, "^zh") -- 10
	zh = res ~= nil and ImGui.IsFontLoaded() -- 11
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
				local jsonStr = json.dump(data) -- 72
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
										local res = json.load(item) -- 183
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
____exports.compileTS = function(file, content) -- 212
	local data = {name = "TranspileTS", file = file, content = content} -- 213
	return __TS__New( -- 214
		__TS__Promise, -- 214
		function(____, resolve) -- 214
			local node = DoraNode() -- 215
			node:gslot( -- 216
				"AppWS", -- 216
				function(eventType, msg) -- 216
					if eventType == "Receive" then -- 216
						node:removeFromParent() -- 218
						local res = json.load(msg) -- 219
						if res then -- 219
							if res.success then -- 219
								resolve(nil, {success = true, result = res.luaCode}) -- 222
							else -- 222
								resolve(nil, {success = false, result = res.message}) -- 224
							end -- 224
						end -- 224
					end -- 224
				end -- 216
			) -- 216
			local str = json.dump(data) -- 229
			if str then -- 229
				emit("AppWS", "Send", str) -- 231
			end -- 231
		end -- 214
	) -- 214
end -- 212
local CompileNode = __TS__Class() -- 236
CompileNode.name = "CompileNode" -- 236
__TS__ClassExtends(CompileNode, Node) -- 236
function CompileNode.prototype.prep(self, shared) -- 237
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 237
		return ____awaiter_resolve(nil, shared.messages[#shared.messages].content) -- 237
	end) -- 237
end -- 237
function CompileNode.prototype.exec(self, code) -- 240
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 240
		return ____awaiter_resolve( -- 240
			nil, -- 240
			__TS__Await(____exports.compileTS( -- 241
				Path( -- 241
					Content.writablePath, -- 241
					Path:getPath(outputFile.text), -- 241
					"__code__.ts" -- 241
				), -- 241
				code -- 241
			)) -- 241
		) -- 241
	end) -- 241
end -- 240
function CompileNode.prototype.post(self, shared, prepRes, execRes) -- 243
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 243
		if execRes.success then -- 243
			local ____shared_messages_2 = shared.messages -- 243
			____shared_messages_2[#____shared_messages_2 + 1] = {role = "user", content = prepRes} -- 245
			logs[#logs + 1] = "代码编译成功！" -- 246
			return ____awaiter_resolve(nil, "Success") -- 246
		else -- 246
			local ____shared_messages_3 = shared.messages -- 246
			____shared_messages_3[#____shared_messages_3 + 1] = {role = "user", content = (prepRes .. "\n\n编译错误信息如下：\n") .. execRes.result} -- 249
			logs[#logs + 1] = "代码编译失败！" -- 250
			logs[#logs + 1] = execRes.result -- 251
			return ____awaiter_resolve(nil, "Failed") -- 251
		end -- 251
	end) -- 251
end -- 243
local FixNode = __TS__Class() -- 257
FixNode.name = "FixNode" -- 257
__TS__ClassExtends(FixNode, Node) -- 257
function FixNode.prototype.prep(self, shared) -- 258
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 258
		local codeAndError = shared.messages[#shared.messages].content -- 259
		local systemContent = getSystemPrompt() -- 260
		local userContent = ("\n你是一名经验丰富的 TypeScript 代码专家。\n\n任务目标：\n1. 阅读「相关代码模块信息」、原始代码片段，以及随后的编译错误信息。\n2. 找出导致编译失败的根本原因，并给出修正后的完整代码。\n3. 展示修正后代码运行的正确输出结果或关键行为。\n\n回答格式必须分两部分：\n1. 思考过程\n逐步阐述你的推理：先定位错误 → 分析原因 → 制定修复策略 → 说明为何这样修改。\n用条目或小节清晰列出，不要省略中间推理步骤。\n\n2. 最终答案\n修正后的完整代码（用 ```typescript``` 代码块包裹）。\n期望输出或结果说明，用简要文字或示例输出展示。\n注意：先完整写出思考过程，再给出最终答案；不要在思考过程中提前透露最终代码或结果。\n\n原始代码及编译错误信息：\n\n" .. codeAndError) .. "\n" -- 261
		shared.messages = {{role = "system", content = systemContent}, {role = "user", content = userContent}} -- 283
	end) -- 283
end -- 258
function FixNode.prototype.exec(self) -- 288
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 288
		logs[#logs + 1] = "开始修复代码！" -- 289
	end) -- 289
end -- 288
local SaveNode = __TS__Class() -- 293
SaveNode.name = "SaveNode" -- 293
__TS__ClassExtends(SaveNode, Node) -- 293
function SaveNode.prototype.prep(self, shared) -- 294
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 294
		return ____awaiter_resolve(nil, shared.messages[#shared.messages].content) -- 294
	end) -- 294
end -- 294
function SaveNode.prototype.exec(self, code) -- 297
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 297
		llmWorking = false -- 298
		local filename = Path( -- 299
			Content.writablePath, -- 299
			Path:getPath(outputFile.text), -- 299
			Path:getFilename(Path:replaceExt(outputFile.text, "")) .. "Gen.ts" -- 299
		) -- 299
		if Content:save(filename, code) then -- 299
			logs[#logs + 1] = "保存代码成功！" .. filename -- 301
		else -- 301
			logs[#logs + 1] = "保存代码失败！" .. filename -- 303
		end -- 303
		local res = __TS__Await(____exports.compileTS(filename, code)) -- 305
		if res.success then -- 305
			local luaFile = Path:replaceExt(filename, "lua") -- 307
			if Content:save(luaFile, res.result) then -- 307
				logs[#logs + 1] = "保存代码成功！" .. luaFile -- 309
			else -- 309
				logs[#logs + 1] = "保存代码失败！" .. luaFile -- 311
			end -- 311
			local ____try = __TS__AsyncAwaiter(function() -- 311
				local func = load(res.result, luaFile) -- 314
				if func then -- 314
					func() -- 315
				end -- 315
				logs[#logs + 1] = "生成代码成功！" -- 316
			end) -- 316
			__TS__Await(____try.catch( -- 313
				____try, -- 313
				function(____, e) -- 313
					logs[#logs + 1] = "生成代码失败！" -- 318
					Log( -- 319
						"Error", -- 319
						tostring(e) -- 319
					) -- 319
				end -- 319
			)) -- 319
		end -- 319
	end) -- 319
end -- 297
local chatNode = __TS__New(ChatNode) -- 325
local llmCode = __TS__New(LLMCode, 2, 1) -- 326
local compileNode = __TS__New(CompileNode) -- 327
local saveNode = __TS__New(SaveNode) -- 328
local fixNode = __TS__New(FixNode) -- 329
chatNode:next(llmCode) -- 330
llmCode:next(compileNode) -- 331
compileNode:on("Success", saveNode) -- 332
compileNode:on("Failed", fixNode) -- 333
fixNode:next(llmCode) -- 334
saveNode:next(chatNode) -- 335
local flow = __TS__New(Flow, chatNode) -- 337
local runFlow -- 338
runFlow = function() -- 338
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 338
		local chatInfo = {messages = {}} -- 339
		local ____try = __TS__AsyncAwaiter(function() -- 339
			__TS__Await(flow:run(chatInfo)) -- 343
		end) -- 343
		__TS__Await(____try.catch( -- 342
			____try, -- 342
			function(____, err) -- 342
				Log("Error", err) -- 345
				runFlow() -- 346
			end -- 346
		)) -- 346
	end) -- 346
end -- 338
runFlow() -- 349
logs = {} -- 351
local inputBuffer = Buffer(5000) -- 352
local function ChatButton() -- 354
	ImGui.PushItemWidth( -- 355
		-80, -- 355
		function() -- 355
			if ImGui.InputText(zh and "描述需求" or "Desc", inputBuffer, {"EnterReturnsTrue"}) then -- 355
				local command = inputBuffer.text -- 357
				if command ~= "" then -- 357
					logs = {} -- 359
					logs[#logs + 1] = "User: " .. command -- 360
					root:emit("Input", command) -- 361
				end -- 361
				inputBuffer.text = "" -- 363
			end -- 363
		end -- 355
	) -- 355
end -- 354
local inputFlags = {"Password"} -- 368
local windowsFlags = { -- 369
	"NoMove", -- 370
	"NoCollapse", -- 371
	"NoResize", -- 372
	"NoDecoration", -- 373
	"NoNav" -- 374
} -- 374
root:loop(function() -- 376
	local ____App_visualSize_4 = App.visualSize -- 377
	local width = ____App_visualSize_4.width -- 377
	local height = ____App_visualSize_4.height -- 377
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 378
	ImGui.SetNextWindowSize( -- 379
		Vec2(width, height - 40), -- 379
		"Always" -- 379
	) -- 379
	ImGui.Begin( -- 380
		"Blockly Coder", -- 380
		windowsFlags, -- 380
		function() -- 380
			ImGui.Text(zh and "Blockly 编程家" or "Blockly Coder") -- 381
			ImGui.SameLine() -- 382
			ImGui.TextDisabled("(?)") -- 383
			if ImGui.IsItemHovered() then -- 383
				ImGui.BeginTooltip(function() -- 385
					ImGui.PushTextWrapPos( -- 386
						400, -- 386
						function() -- 386
							ImGui.Text(zh and "请先配置大模型 API 密钥，然后输入自然语言需求，Agent 将自动生成 TypeScript 积木代码，编译成 Blockly 积木并翻译为 Lua 脚本运行。遇到编译失败会自动修正，无需手动干预。" or "First, configure the API key for the large language model. Then, input your natural language requirements. The Agent will automatically generate TypeScript building block code, compile it into Blockly blocks, and translate it into Lua scripts for execution. If any compilation errors occur, they will be automatically corrected without requiring manual intervention.") -- 387
						end -- 386
					) -- 386
				end) -- 385
			end -- 385
			ImGui.SameLine() -- 392
			ImGui.Dummy(Vec2(width - 290, 0)) -- 393
			ImGui.SameLine() -- 394
			if ImGui.CollapsingHeader(zh and "配置" or "Config") then -- 394
				if ImGui.InputText(zh and "API 地址" or "API URL", url) then -- 394
					config.url = url.text -- 397
				end -- 397
				if ImGui.InputText(zh and "API 密钥" or "API Key", apiKey, inputFlags) then -- 397
					config.apiKey = apiKey.text -- 400
				end -- 400
				if ImGui.InputText(zh and "模型" or "Model", model) then -- 400
					config.model = model.text -- 403
				end -- 403
				if ImGui.InputText(zh and "输出文件" or "Output File", outputFile) then -- 403
					config.output = outputFile.text -- 406
				end -- 406
			end -- 406
			ImGui.Separator() -- 409
			ImGui.BeginChild( -- 410
				"LogArea", -- 410
				Vec2(0, -40), -- 410
				function() -- 410
					for ____, log in ipairs(logs) do -- 411
						ImGui.TextWrapped(log) -- 412
					end -- 412
					if ImGui.GetScrollY() >= ImGui.GetScrollMaxY() then -- 412
						ImGui.SetScrollHereY(1) -- 415
					end -- 415
				end -- 410
			) -- 410
			if llmWorking or config.output == "" then -- 410
				ImGui.BeginDisabled(function() -- 419
					ChatButton() -- 420
				end) -- 419
			else -- 419
				ChatButton() -- 423
			end -- 423
		end -- 380
	) -- 380
	return false -- 426
end) -- 376
root:slot( -- 429
	"Output", -- 429
	function(message) -- 429
		logs[#logs + 1] = message -- 430
	end -- 429
) -- 429
root:slot( -- 433
	"Update", -- 433
	function(message) -- 433
		logs[#logs] = message -- 434
	end -- 433
) -- 433
return ____exports -- 433