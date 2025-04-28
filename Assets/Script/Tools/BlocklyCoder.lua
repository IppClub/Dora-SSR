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
local ImGui = require("ImGui") -- 3
local ____flow = require("Agent.flow") -- 5
local Node = ____flow.Node -- 5
local Flow = ____flow.Flow -- 5
local Config = require("Config") -- 6
local running = true -- 15
if not DB:existDB("llm") then -- 15
	local dbPath = Path(Content.writablePath, "llm.db") -- 18
	DB:exec(("ATTACH DATABASE '" .. dbPath) .. "' AS llm") -- 19
	Director.entry:slot( -- 20
		"Cleanup", -- 20
		function() -- 20
			DB:exec("DETACH DATABASE llm") -- 21
			running = false -- 22
		end -- 20
	) -- 20
end -- 20
local config = Config( -- 26
	"llm", -- 26
	"url", -- 26
	"model", -- 26
	"apiKey", -- 26
	"output" -- 26
) -- 26
config:load() -- 27
local url = Buffer(512) -- 29
if type(config.url) == "string" then -- 29
	url.text = config.url -- 31
else -- 31
	config.url = "https://api.deepseek.com/chat/completions" -- 33
	url.text = "https://api.deepseek.com/chat/completions" -- 33
end -- 33
local apiKey = Buffer(256) -- 35
if type(config.apiKey) == "string" then -- 35
	apiKey.text = config.apiKey -- 37
end -- 37
local model = Buffer(128) -- 39
if type(config.model) == "string" then -- 39
	model.text = config.model -- 41
else -- 41
	config.model = "deepseek-chat" -- 43
	model.text = "deepseek-chat" -- 43
end -- 43
local outputFile = Buffer(512) -- 45
if type(config.output) == "string" then -- 45
	outputFile.text = config.output -- 47
else -- 47
	local ____Path_result_0 = Path("Blockly", "Output.bl") -- 49
	config.output = ____Path_result_0 -- 49
	outputFile.text = ____Path_result_0 -- 49
end -- 49
local function callLLM(messages, url, apiKey, model, receiver) -- 57
	local data = {model = model, messages = messages, temperature = 0, stream = true} -- 58
	return __TS__New( -- 64
		__TS__Promise, -- 64
		function(____, resolve, reject) -- 64
			thread(function() -- 65
				local jsonStr = json.dump(data) -- 66
				if jsonStr ~= nil then -- 66
					local res = HttpClient:postAsync( -- 68
						url, -- 68
						{"Authorization: Bearer " .. apiKey}, -- 68
						jsonStr, -- 70
						10, -- 70
						receiver -- 70
					) -- 70
					if res ~= nil then -- 70
						resolve(nil, res) -- 72
					else -- 72
						reject(nil, "failed to get http response") -- 74
					end -- 74
				end -- 74
			end) -- 65
		end -- 64
	) -- 64
end -- 57
local function extractTSBlocks(text) -- 81
	local blocks = {} -- 82
	for code in string.gmatch(text, "```%s*[tT][sS%w-]*%s*\n(.-)\n()```") do -- 83
		blocks[#blocks + 1] = code -- 84
	end -- 84
	return #blocks == 0 and text or table.concat(blocks, "\n") -- 86
end -- 81
local root = DNode() -- 89
local llmWorking = false -- 95
local function getSystemPrompt() -- 97
	local filename = Path(Content.writablePath, outputFile.text) -- 98
	return ((("\n你有一个 TypeScript 的 DSL 框架，用来模拟编写 Blockly 的积木编程代码。\n\nDSL 框架模块的 API 定义和用法示例如下：\n\n" .. Content:load(Path( -- 99
		Content.assetPath, -- 104
		"Script", -- 104
		"Lib", -- 104
		"Agent", -- 104
		"BlocklyGen.d.ts" -- 104
	))) .. "\n\n编写出的 Blockly 积木代码需遵守以下事项：\n- 数组下标从1开始\n- 对变量名对大小写不敏感，勿用大小写区分变量\n- 导入 DSL 模块请使用代码 `import Gen from 'Agent/BlocklyGen';`\n- 确保最后给我的回答只包含纯粹的 TypeScript 代码，不要包含任何非代码的说明\n- 程序块请放在`const root`变量中，函数定义放在`const funcs`变量中\n- 最后输出的 jsonCode 变量请原样补充如下的处理代码：\nimport * as Dora from 'Dora';\nDora.Content.save(\"") .. filename) .. "\"), jsonCode);\n" -- 104
end -- 97
local ChatNode = __TS__Class() -- 118
ChatNode.name = "ChatNode" -- 118
__TS__ClassExtends(ChatNode, Node) -- 118
function ChatNode.prototype.prep(self, shared) -- 119
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 119
		return ____awaiter_resolve( -- 119
			nil, -- 119
			__TS__New( -- 120
				__TS__Promise, -- 120
				function(____, resolve) -- 120
					root:slot( -- 121
						"Input", -- 121
						function(message) -- 121
							local systemContent = getSystemPrompt() -- 122
							local userContent = ("\n请先在内部进行思维链推理：\n1. 研读 Blockly DSL 框架 API 与示例用法；\n2. 将下列需求拆分为具体积木块功能；\n3. 规划对应的 TypeScript 代码结构；\n4. 依次生成所需的积木块实现代码。\n完成推理后，仅输出最终的 TypeScript 积木代码，不展示任何思考过程、说明或注释。\n\n需求如下：\n\n" .. message) .. "\n" -- 123
							shared.messages = {{role = "system", content = systemContent}, {role = "user", content = userContent}} -- 135
							resolve(nil, nil) -- 139
						end -- 121
					) -- 121
				end -- 120
			) -- 120
		) -- 120
	end) -- 120
end -- 119
function ChatNode.prototype.exec(self) -- 143
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 143
	end) -- 143
end -- 143
function ChatNode.prototype.post(self, _shared, _prepRes, _execRes) -- 145
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 145
		return ____awaiter_resolve(nil, nil) -- 145
	end) -- 145
end -- 145
local LLMCode = __TS__Class() -- 150
LLMCode.name = "LLMCode" -- 150
__TS__ClassExtends(LLMCode, Node) -- 150
function LLMCode.prototype.prep(self, shared) -- 151
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 151
		return ____awaiter_resolve(nil, shared.messages) -- 151
	end) -- 151
end -- 151
function LLMCode.prototype.exec(self, messages) -- 154
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 154
		return ____awaiter_resolve( -- 154
			nil, -- 154
			__TS__New( -- 155
				__TS__Promise, -- 155
				function(____, resolve, reject) -- 155
					return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 155
						local str = "" -- 156
						root:emit("Output", "Coder: ") -- 157
						llmWorking = true -- 158
						local ____try = __TS__AsyncAwaiter(function() -- 158
							__TS__Await(callLLM( -- 160
								messages, -- 160
								url.text, -- 160
								apiKey.text, -- 160
								model.text, -- 160
								function(data) -- 160
									if not running then -- 160
										return true -- 162
									end -- 162
									local done = string.match(data, "data:%s*(%b[])") -- 164
									if done == "[DONE]" then -- 164
										resolve(nil, str) -- 166
										return false -- 167
									end -- 167
									for item in string.gmatch(data, "data:%s*(%b{})") do -- 169
										local res = json.load(item) -- 170
										if res then -- 170
											local part = res.choices[1].delta.content -- 172
											if type(part) == "string" then -- 172
												str = str .. part -- 174
											end -- 174
										end -- 174
									end -- 174
									root:emit("Update", "Coder: " .. str) -- 178
									return false -- 179
								end -- 160
							)) -- 160
						end) -- 160
						__TS__Await(____try.catch( -- 159
							____try, -- 159
							function(____, e) -- 159
								llmWorking = false -- 182
								reject(nil, e) -- 183
							end -- 183
						)) -- 183
					end) -- 183
				end -- 155
			) -- 155
		) -- 155
	end) -- 155
end -- 154
function LLMCode.prototype.post(self, shared, _prepRes, execRes) -- 187
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 187
		local code = extractTSBlocks(execRes) -- 188
		local ____shared_messages_1 = shared.messages -- 188
		____shared_messages_1[#____shared_messages_1 + 1] = {role = "system", content = code} -- 189
		return ____awaiter_resolve(nil, nil) -- 189
	end) -- 189
end -- 187
____exports.compileTS = function(file, content) -- 199
	local data = {name = "TranspileTS", file = file, content = content} -- 200
	return __TS__New( -- 201
		__TS__Promise, -- 201
		function(____, resolve) -- 201
			local node = DoraNode() -- 202
			node:gslot( -- 203
				"AppWS", -- 203
				function(eventType, msg) -- 203
					if eventType == "Receive" then -- 203
						node:removeFromParent() -- 205
						local res = json.load(msg) -- 206
						if res then -- 206
							if res.success then -- 206
								resolve(nil, {success = true, result = res.luaCode}) -- 209
							else -- 209
								resolve(nil, {success = false, result = res.message}) -- 211
							end -- 211
						end -- 211
					end -- 211
				end -- 203
			) -- 203
			local str = json.dump(data) -- 216
			if str then -- 216
				emit("AppWS", "Send", str) -- 218
			end -- 218
		end -- 201
	) -- 201
end -- 199
local CompileNode = __TS__Class() -- 223
CompileNode.name = "CompileNode" -- 223
__TS__ClassExtends(CompileNode, Node) -- 223
function CompileNode.prototype.prep(self, shared) -- 224
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 224
		return ____awaiter_resolve(nil, shared.messages[#shared.messages].content) -- 224
	end) -- 224
end -- 224
function CompileNode.prototype.exec(self, code) -- 227
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 227
		return ____awaiter_resolve( -- 227
			nil, -- 227
			__TS__Await(____exports.compileTS( -- 228
				Path( -- 228
					Content.writablePath, -- 228
					Path:getPath(outputFile.text), -- 228
					"__code__.ts" -- 228
				), -- 228
				code -- 228
			)) -- 228
		) -- 228
	end) -- 228
end -- 227
function CompileNode.prototype.post(self, shared, prepRes, execRes) -- 230
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 230
		if execRes.success then -- 230
			local ____shared_messages_2 = shared.messages -- 230
			____shared_messages_2[#____shared_messages_2 + 1] = {role = "user", content = prepRes} -- 232
			logs[#logs + 1] = "代码编译成功！" -- 233
			return ____awaiter_resolve(nil, "Success") -- 233
		else -- 233
			local ____shared_messages_3 = shared.messages -- 233
			____shared_messages_3[#____shared_messages_3 + 1] = {role = "user", content = (prepRes .. "\n\n编译错误信息如下：\n") .. execRes.result} -- 236
			logs[#logs + 1] = "代码编译失败！" -- 237
			logs[#logs + 1] = execRes.result -- 238
			return ____awaiter_resolve(nil, "Failed") -- 238
		end -- 238
	end) -- 238
end -- 230
local FixNode = __TS__Class() -- 244
FixNode.name = "FixNode" -- 244
__TS__ClassExtends(FixNode, Node) -- 244
function FixNode.prototype.prep(self, shared) -- 245
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 245
		local codeAndError = shared.messages[#shared.messages].content -- 246
		local systemContent = getSystemPrompt() -- 247
		local userContent = ("\n你是一名经验丰富的 TypeScript 代码专家。\n\n任务目标：\n1. 阅读「相关代码模块信息」、原始代码片段，以及随后的编译错误信息。\n2. 找出导致编译失败的根本原因，并给出修正后的完整代码。\n3. 展示修正后代码运行的正确输出结果或关键行为。\n\n回答格式必须分两部分：\n1. 思考过程\n逐步阐述你的推理：先定位错误 → 分析原因 → 制定修复策略 → 说明为何这样修改。\n用条目或小节清晰列出，不要省略中间推理步骤。\n\n2. 最终答案\n修正后的完整代码（用 ```typescript``` 代码块包裹）。\n期望输出或结果说明，用简要文字或示例输出展示。\n注意：先完整写出思考过程，再给出最终答案；不要在思考过程中提前透露最终代码或结果。\n\n原始代码及编译错误信息：\n\n" .. codeAndError) .. "\n" -- 248
		shared.messages = {{role = "system", content = systemContent}, {role = "user", content = userContent}} -- 270
	end) -- 270
end -- 245
function FixNode.prototype.exec(self) -- 275
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 275
		logs[#logs + 1] = "开始修复代码！" -- 276
	end) -- 276
end -- 275
function FixNode.prototype.post(self, _shared, _prepRes, _execRes) -- 278
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 278
		return ____awaiter_resolve(nil, nil) -- 278
	end) -- 278
end -- 278
local SaveNode = __TS__Class() -- 283
SaveNode.name = "SaveNode" -- 283
__TS__ClassExtends(SaveNode, Node) -- 283
function SaveNode.prototype.prep(self, shared) -- 284
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 284
		return ____awaiter_resolve(nil, shared.messages[#shared.messages].content) -- 284
	end) -- 284
end -- 284
function SaveNode.prototype.exec(self, code) -- 287
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 287
		llmWorking = false -- 288
		local filename = Path( -- 289
			Content.writablePath, -- 289
			Path:getPath(outputFile.text), -- 289
			Path:getFilename(Path:replaceExt(outputFile.text, "")) .. "Gen.ts" -- 289
		) -- 289
		if Content:save(filename, code) then -- 289
			logs[#logs + 1] = "保存代码成功！" .. filename -- 291
		else -- 291
			logs[#logs + 1] = "保存代码失败！" .. filename -- 293
		end -- 293
		local res = __TS__Await(____exports.compileTS(filename, code)) -- 295
		if res.success then -- 295
			local luaFile = Path:replaceExt(filename, "lua") -- 297
			if Content:save(luaFile, res.result) then -- 297
				logs[#logs + 1] = "保存代码成功！" .. luaFile -- 299
			else -- 299
				logs[#logs + 1] = "保存代码失败！" .. luaFile -- 301
			end -- 301
			local ____try = __TS__AsyncAwaiter(function() -- 301
				local func = load(res.result, luaFile) -- 304
				if func then -- 304
					func() -- 305
				end -- 305
				logs[#logs + 1] = "生成代码成功！" -- 306
			end) -- 306
			__TS__Await(____try.catch( -- 303
				____try, -- 303
				function(____, e) -- 303
					logs[#logs + 1] = "生成代码失败！" -- 308
					Log( -- 309
						"Error", -- 309
						tostring(e) -- 309
					) -- 309
				end -- 309
			)) -- 309
		end -- 309
	end) -- 309
end -- 287
function SaveNode.prototype.post(self, _shared, _prepRes, _execRes) -- 313
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 313
		return ____awaiter_resolve(nil, nil) -- 313
	end) -- 313
end -- 313
local chatNode = __TS__New(ChatNode) -- 318
local llmCode = __TS__New(LLMCode, 2, 1) -- 319
local compileNode = __TS__New(CompileNode) -- 320
local saveNode = __TS__New(SaveNode) -- 321
local fixNode = __TS__New(FixNode) -- 322
chatNode:next(llmCode) -- 323
llmCode:next(compileNode) -- 324
compileNode:on("Success", saveNode) -- 325
compileNode:on("Failed", fixNode) -- 326
fixNode:next(llmCode) -- 327
saveNode:next(chatNode) -- 328
local flow = __TS__New(Flow, chatNode) -- 330
local runFlow -- 331
runFlow = function() -- 331
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 331
		local chatInfo = {messages = {}} -- 332
		local ____try = __TS__AsyncAwaiter(function() -- 332
			__TS__Await(flow:run(chatInfo)) -- 336
		end) -- 336
		__TS__Await(____try.catch( -- 335
			____try, -- 335
			function(____, err) -- 335
				Log("Error", err) -- 338
				runFlow() -- 339
			end -- 339
		)) -- 339
	end) -- 339
end -- 331
runFlow() -- 342
logs = {} -- 344
local inputBuffer = Buffer(5000) -- 345
local function ChatButton() -- 347
	if ImGui.InputText("Desc", inputBuffer, {"EnterReturnsTrue"}) then -- 347
		local command = inputBuffer.text -- 349
		if command ~= "" then -- 349
			logs = {} -- 351
			logs[#logs + 1] = "User: " .. command -- 352
			root:emit("Input", command) -- 353
		end -- 353
		inputBuffer.text = "" -- 355
	end -- 355
end -- 347
local inputFlags = {"Password"} -- 359
root:loop(function() -- 360
	ImGui.SetNextWindowSize( -- 361
		Vec2(400, 300), -- 361
		"FirstUseEver" -- 361
	) -- 361
	ImGui.Begin( -- 362
		"Blockly Coder", -- 362
		function() -- 362
			if ImGui.InputText("URL", url) then -- 362
				config.url = url.text -- 364
			end -- 364
			if ImGui.InputText("API Key", apiKey, inputFlags) then -- 364
				config.apiKey = apiKey.text -- 367
			end -- 367
			if ImGui.InputText("Model", model) then -- 367
				config.model = model.text -- 370
			end -- 370
			if ImGui.InputText("Output File", outputFile) then -- 370
				config.output = outputFile.text -- 373
			end -- 373
			ImGui.Separator() -- 375
			ImGui.BeginChild( -- 376
				"LogArea", -- 376
				Vec2(0, -40), -- 376
				function() -- 376
					for ____, log in ipairs(logs) do -- 377
						ImGui.TextWrapped(log) -- 378
					end -- 378
					if ImGui.GetScrollY() >= ImGui.GetScrollMaxY() then -- 378
						ImGui.SetScrollHereY(1) -- 381
					end -- 381
				end -- 376
			) -- 376
			if llmWorking then -- 376
				ImGui.BeginDisabled(function() -- 385
					ChatButton() -- 386
				end) -- 385
			else -- 385
				ChatButton() -- 389
			end -- 389
		end -- 362
	) -- 362
	return false -- 392
end) -- 360
root:slot( -- 395
	"Output", -- 395
	function(message) -- 395
		logs[#logs + 1] = message -- 396
	end -- 395
) -- 395
root:slot( -- 399
	"Update", -- 399
	function(message) -- 399
		logs[#logs] = message -- 400
	end -- 399
) -- 399
return ____exports -- 399