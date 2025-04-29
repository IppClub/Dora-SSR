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
							local userContent = ("\n请先在内部进行思维链推理：\n1. 研读 Blockly DSL 框架 API 与示例用法；\n2. 将下列需求拆分为具体积木块功能；\n3. 规划对应的 TypeScript 代码结构；\n4. 依次生成所需的积木块实现代码。\n完成推理后，仅输出最终的 TypeScript 积木代码，不展示任何思考过程、说明或注释。\n\n需求如下：\n\n" .. message) .. "\n" -- 130
							shared.messages = {{role = "system", content = systemContent}, {role = "user", content = userContent}} -- 142
							resolve(nil, nil) -- 146
						end -- 128
					) -- 128
				end -- 127
			) -- 127
		) -- 127
	end) -- 127
end -- 126
local LLMCode = __TS__Class() -- 152
LLMCode.name = "LLMCode" -- 152
__TS__ClassExtends(LLMCode, Node) -- 152
function LLMCode.prototype.prep(self, shared) -- 153
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 153
		return ____awaiter_resolve(nil, shared.messages) -- 153
	end) -- 153
end -- 153
function LLMCode.prototype.exec(self, messages) -- 156
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 156
		return ____awaiter_resolve( -- 156
			nil, -- 156
			__TS__New( -- 157
				__TS__Promise, -- 157
				function(____, resolve, reject) -- 157
					return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 157
						local str = "" -- 158
						root:emit("Output", "Coder: ") -- 159
						llmWorking = true -- 160
						local ____try = __TS__AsyncAwaiter(function() -- 160
							__TS__Await(callLLM( -- 162
								messages, -- 162
								url.text, -- 162
								apiKey.text, -- 162
								model.text, -- 162
								function(data) -- 162
									if not running then -- 162
										return true -- 164
									end -- 164
									local done = string.match(data, "data:%s*(%b[])") -- 166
									if done == "[DONE]" then -- 166
										resolve(nil, str) -- 168
										return false -- 169
									end -- 169
									for item in string.gmatch(data, "data:%s*(%b{})") do -- 171
										local res = json.load(item) -- 172
										if res then -- 172
											local part = res.choices[1].delta.content -- 174
											if type(part) == "string" then -- 174
												str = str .. part -- 176
											end -- 176
										end -- 176
									end -- 176
									root:emit("Update", "Coder: " .. str) -- 180
									return false -- 181
								end -- 162
							)) -- 162
						end) -- 162
						__TS__Await(____try.catch( -- 161
							____try, -- 161
							function(____, e) -- 161
								llmWorking = false -- 184
								reject(nil, e) -- 185
							end -- 185
						)) -- 185
					end) -- 185
				end -- 157
			) -- 157
		) -- 157
	end) -- 157
end -- 156
function LLMCode.prototype.post(self, shared, _prepRes, execRes) -- 189
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 189
		local code = extractTSBlocks(execRes) -- 190
		local ____shared_messages_1 = shared.messages -- 190
		____shared_messages_1[#____shared_messages_1 + 1] = {role = "system", content = code} -- 191
		return ____awaiter_resolve(nil, nil) -- 191
	end) -- 191
end -- 189
____exports.compileTS = function(file, content) -- 201
	local data = {name = "TranspileTS", file = file, content = content} -- 202
	return __TS__New( -- 203
		__TS__Promise, -- 203
		function(____, resolve) -- 203
			local node = DoraNode() -- 204
			node:gslot( -- 205
				"AppWS", -- 205
				function(eventType, msg) -- 205
					if eventType == "Receive" then -- 205
						node:removeFromParent() -- 207
						local res = json.load(msg) -- 208
						if res then -- 208
							if res.success then -- 208
								resolve(nil, {success = true, result = res.luaCode}) -- 211
							else -- 211
								resolve(nil, {success = false, result = res.message}) -- 213
							end -- 213
						end -- 213
					end -- 213
				end -- 205
			) -- 205
			local str = json.dump(data) -- 218
			if str then -- 218
				emit("AppWS", "Send", str) -- 220
			end -- 220
		end -- 203
	) -- 203
end -- 201
local CompileNode = __TS__Class() -- 225
CompileNode.name = "CompileNode" -- 225
__TS__ClassExtends(CompileNode, Node) -- 225
function CompileNode.prototype.prep(self, shared) -- 226
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 226
		return ____awaiter_resolve(nil, shared.messages[#shared.messages].content) -- 226
	end) -- 226
end -- 226
function CompileNode.prototype.exec(self, code) -- 229
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 229
		return ____awaiter_resolve( -- 229
			nil, -- 229
			__TS__Await(____exports.compileTS( -- 230
				Path( -- 230
					Content.writablePath, -- 230
					Path:getPath(outputFile.text), -- 230
					"__code__.ts" -- 230
				), -- 230
				code -- 230
			)) -- 230
		) -- 230
	end) -- 230
end -- 229
function CompileNode.prototype.post(self, shared, prepRes, execRes) -- 232
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 232
		if execRes.success then -- 232
			local ____shared_messages_2 = shared.messages -- 232
			____shared_messages_2[#____shared_messages_2 + 1] = {role = "user", content = prepRes} -- 234
			logs[#logs + 1] = "代码编译成功！" -- 235
			return ____awaiter_resolve(nil, "Success") -- 235
		else -- 235
			local ____shared_messages_3 = shared.messages -- 235
			____shared_messages_3[#____shared_messages_3 + 1] = {role = "user", content = (prepRes .. "\n\n编译错误信息如下：\n") .. execRes.result} -- 238
			logs[#logs + 1] = "代码编译失败！" -- 239
			logs[#logs + 1] = execRes.result -- 240
			return ____awaiter_resolve(nil, "Failed") -- 240
		end -- 240
	end) -- 240
end -- 232
local FixNode = __TS__Class() -- 246
FixNode.name = "FixNode" -- 246
__TS__ClassExtends(FixNode, Node) -- 246
function FixNode.prototype.prep(self, shared) -- 247
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 247
		local codeAndError = shared.messages[#shared.messages].content -- 248
		local systemContent = getSystemPrompt() -- 249
		local userContent = ("\n你是一名经验丰富的 TypeScript 代码专家。\n\n任务目标：\n1. 阅读「相关代码模块信息」、原始代码片段，以及随后的编译错误信息。\n2. 找出导致编译失败的根本原因，并给出修正后的完整代码。\n3. 展示修正后代码运行的正确输出结果或关键行为。\n\n回答格式必须分两部分：\n1. 思考过程\n逐步阐述你的推理：先定位错误 → 分析原因 → 制定修复策略 → 说明为何这样修改。\n用条目或小节清晰列出，不要省略中间推理步骤。\n\n2. 最终答案\n修正后的完整代码（用 ```typescript``` 代码块包裹）。\n期望输出或结果说明，用简要文字或示例输出展示。\n注意：先完整写出思考过程，再给出最终答案；不要在思考过程中提前透露最终代码或结果。\n\n原始代码及编译错误信息：\n\n" .. codeAndError) .. "\n" -- 250
		shared.messages = {{role = "system", content = systemContent}, {role = "user", content = userContent}} -- 272
	end) -- 272
end -- 247
function FixNode.prototype.exec(self) -- 277
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 277
		logs[#logs + 1] = "开始修复代码！" -- 278
	end) -- 278
end -- 277
local SaveNode = __TS__Class() -- 282
SaveNode.name = "SaveNode" -- 282
__TS__ClassExtends(SaveNode, Node) -- 282
function SaveNode.prototype.prep(self, shared) -- 283
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 283
		return ____awaiter_resolve(nil, shared.messages[#shared.messages].content) -- 283
	end) -- 283
end -- 283
function SaveNode.prototype.exec(self, code) -- 286
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 286
		llmWorking = false -- 287
		local filename = Path( -- 288
			Content.writablePath, -- 288
			Path:getPath(outputFile.text), -- 288
			Path:getFilename(Path:replaceExt(outputFile.text, "")) .. "Gen.ts" -- 288
		) -- 288
		if Content:save(filename, code) then -- 288
			logs[#logs + 1] = "保存代码成功！" .. filename -- 290
		else -- 290
			logs[#logs + 1] = "保存代码失败！" .. filename -- 292
		end -- 292
		local res = __TS__Await(____exports.compileTS(filename, code)) -- 294
		if res.success then -- 294
			local luaFile = Path:replaceExt(filename, "lua") -- 296
			if Content:save(luaFile, res.result) then -- 296
				logs[#logs + 1] = "保存代码成功！" .. luaFile -- 298
			else -- 298
				logs[#logs + 1] = "保存代码失败！" .. luaFile -- 300
			end -- 300
			local ____try = __TS__AsyncAwaiter(function() -- 300
				local func = load(res.result, luaFile) -- 303
				if func then -- 303
					func() -- 304
				end -- 304
				logs[#logs + 1] = "生成代码成功！" -- 305
			end) -- 305
			__TS__Await(____try.catch( -- 302
				____try, -- 302
				function(____, e) -- 302
					logs[#logs + 1] = "生成代码失败！" -- 307
					Log( -- 308
						"Error", -- 308
						tostring(e) -- 308
					) -- 308
				end -- 308
			)) -- 308
		end -- 308
	end) -- 308
end -- 286
local chatNode = __TS__New(ChatNode) -- 314
local llmCode = __TS__New(LLMCode, 2, 1) -- 315
local compileNode = __TS__New(CompileNode) -- 316
local saveNode = __TS__New(SaveNode) -- 317
local fixNode = __TS__New(FixNode) -- 318
chatNode:next(llmCode) -- 319
llmCode:next(compileNode) -- 320
compileNode:on("Success", saveNode) -- 321
compileNode:on("Failed", fixNode) -- 322
fixNode:next(llmCode) -- 323
saveNode:next(chatNode) -- 324
local flow = __TS__New(Flow, chatNode) -- 326
local runFlow -- 327
runFlow = function() -- 327
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 327
		local chatInfo = {messages = {}} -- 328
		local ____try = __TS__AsyncAwaiter(function() -- 328
			__TS__Await(flow:run(chatInfo)) -- 332
		end) -- 332
		__TS__Await(____try.catch( -- 331
			____try, -- 331
			function(____, err) -- 331
				Log("Error", err) -- 334
				runFlow() -- 335
			end -- 335
		)) -- 335
	end) -- 335
end -- 327
runFlow() -- 338
logs = {} -- 340
local inputBuffer = Buffer(5000) -- 341
local function ChatButton() -- 343
	ImGui.PushItemWidth( -- 344
		-80, -- 344
		function() -- 344
			if ImGui.InputText(zh and "描述需求" or "Desc", inputBuffer, {"EnterReturnsTrue"}) then -- 344
				local command = inputBuffer.text -- 346
				if command ~= "" then -- 346
					logs = {} -- 348
					logs[#logs + 1] = "User: " .. command -- 349
					root:emit("Input", command) -- 350
				end -- 350
				inputBuffer.text = "" -- 352
			end -- 352
		end -- 344
	) -- 344
end -- 343
local inputFlags = {"Password"} -- 357
local windowsFlags = { -- 358
	"NoMove", -- 359
	"NoCollapse", -- 360
	"NoResize", -- 361
	"NoDecoration", -- 362
	"NoNav" -- 363
} -- 363
root:loop(function() -- 365
	local ____App_visualSize_4 = App.visualSize -- 366
	local width = ____App_visualSize_4.width -- 366
	local height = ____App_visualSize_4.height -- 366
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 367
	ImGui.SetNextWindowSize( -- 368
		Vec2(width, height), -- 368
		"Always" -- 368
	) -- 368
	ImGui.Begin( -- 369
		"Blockly Coder", -- 369
		windowsFlags, -- 369
		function() -- 369
			ImGui.Text(zh and "Blockly 编程家" or "Blockly Coder") -- 370
			ImGui.SameLine() -- 371
			ImGui.TextDisabled("(?)") -- 372
			if ImGui.IsItemHovered() then -- 372
				ImGui.BeginTooltip(function() -- 374
					ImGui.PushTextWrapPos( -- 375
						400, -- 375
						function() -- 375
							ImGui.Text(zh and "请先配置大模型 API 密钥，然后输入自然语言需求，Agent 将自动生成 TypeScript 积木代码，编译成 Blockly 积木并翻译为 Lua 脚本运行。遇到编译失败会自动修正，无需手动干预。" or "First, configure the API key for the large language model. Then, input your natural language requirements. The Agent will automatically generate TypeScript building block code, compile it into Blockly blocks, and translate it into Lua scripts for execution. If any compilation errors occur, they will be automatically corrected without requiring manual intervention.") -- 376
						end -- 375
					) -- 375
				end) -- 374
			end -- 374
			ImGui.SameLine() -- 381
			ImGui.Dummy(Vec2(width - 290, 0)) -- 382
			ImGui.SameLine() -- 383
			if ImGui.CollapsingHeader(zh and "配置" or "Config") then -- 383
				if ImGui.InputText(zh and "API 地址" or "API URL", url) then -- 383
					config.url = url.text -- 386
				end -- 386
				if ImGui.InputText(zh and "API 密钥" or "API Key", apiKey, inputFlags) then -- 386
					config.apiKey = apiKey.text -- 389
				end -- 389
				if ImGui.InputText(zh and "模型" or "Model", model) then -- 389
					config.model = model.text -- 392
				end -- 392
				if ImGui.InputText(zh and "输出文件" or "Output File", outputFile) then -- 392
					config.output = outputFile.text -- 395
				end -- 395
			end -- 395
			ImGui.Separator() -- 398
			ImGui.BeginChild( -- 399
				"LogArea", -- 399
				Vec2(0, -40), -- 399
				function() -- 399
					for ____, log in ipairs(logs) do -- 400
						ImGui.TextWrapped(log) -- 401
					end -- 401
					if ImGui.GetScrollY() >= ImGui.GetScrollMaxY() then -- 401
						ImGui.SetScrollHereY(1) -- 404
					end -- 404
				end -- 399
			) -- 399
			if llmWorking or config.output == "" then -- 399
				ImGui.BeginDisabled(function() -- 408
					ChatButton() -- 409
				end) -- 408
			else -- 408
				ChatButton() -- 412
			end -- 412
		end -- 369
	) -- 369
	return false -- 415
end) -- 365
root:slot( -- 418
	"Output", -- 418
	function(message) -- 418
		logs[#logs + 1] = message -- 419
	end -- 418
) -- 418
root:slot( -- 422
	"Update", -- 422
	function(message) -- 422
		logs[#logs] = message -- 423
	end -- 422
) -- 422
return ____exports -- 422