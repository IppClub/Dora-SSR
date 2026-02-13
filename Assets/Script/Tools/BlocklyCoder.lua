-- [ts]: BlocklyCoder.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local __TS__Promise = ____lualib.__TS__Promise -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local logs -- 1
local ____Dora = require("Dora") -- 2
local json = ____Dora.json -- 2
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
local callLLM = ____Utils.callLLM -- 6
local Config = require("Config") -- 7
local zh = false -- 9
do -- 9
	local res = string.match(App.locale, "^zh") -- 11
	zh = res ~= nil -- 12
end -- 12
local running = true -- 19
if not DB:existDB("llm") then -- 19
	local dbPath = Path(Content.writablePath, "llm.db") -- 22
	DB:exec(("ATTACH DATABASE '" .. dbPath) .. "' AS llm") -- 23
	Director.entry:onCleanup(function() -- 24
		DB:exec("DETACH DATABASE llm") -- 25
		running = false -- 26
	end) -- 24
end -- 24
local config = Config("llm", "output") -- 30
config:load() -- 31
local outputFile = Buffer(512) -- 33
if type(config.output) == "string" then -- 33
	outputFile.text = config.output -- 35
else -- 35
	local ____Path_result_0 = Path("Blockly", "Output.bl") -- 37
	config.output = ____Path_result_0 -- 37
	outputFile.text = ____Path_result_0 -- 37
end -- 37
local function extractTSBlocks(text) -- 40
	local blocks = {} -- 41
	for code in string.gmatch(text, "```%s*[tT][sS%w-]*%s*\n(.-)\n()```") do -- 42
		blocks[#blocks + 1] = code -- 43
	end -- 43
	return #blocks == 0 and text or table.concat(blocks, "\n") -- 45
end -- 40
local root = DNode() -- 48
local llmWorking = false -- 54
local function getSystemPrompt() -- 56
	local filename = Path(Content.writablePath, outputFile.text) -- 57
	return ((("\n你有一个 TypeScript 的 DSL 框架，用来模拟编写 Blockly 的积木编程代码。\n\nDSL 框架模块的 API 定义和用法示例如下：\n\n" .. Content:load(Path( -- 58
		Content.assetPath, -- 63
		"Script", -- 63
		"Lib", -- 63
		"Agent", -- 63
		"BlocklyGen.d.ts" -- 63
	))) .. "\n\n编写出的 Blockly 积木代码需遵守以下事项：\n- 数组下标从1开始\n- 对变量名对大小写不敏感，勿用大小写区分变量\n- 导入 DSL 模块请使用代码 `import Gen from 'Agent/BlocklyGen';`\n- 确保最后给我的回答只包含纯粹的 TypeScript 代码，不要包含任何非代码的说明\n- 坐标计算均使用左手系坐标，包括所有绘图 API 中的坐标\n- 程序块请放在`const root`变量中，函数定义放在`const funcs`变量中\n- 最后输出的 jsonCode 变量请原样补充如下的处理代码：\nimport * as Dora from 'Dora';\nDora.Content.save(\"") .. filename) .. "\"), jsonCode);\n" -- 63
end -- 56
local ChatNode = __TS__Class() -- 78
ChatNode.name = "ChatNode" -- 78
__TS__ClassExtends(ChatNode, Node) -- 78
function ChatNode.prototype.prep(self, shared) -- 79
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 79
		return ____awaiter_resolve( -- 79
			nil, -- 79
			__TS__New( -- 80
				__TS__Promise, -- 80
				function(____, resolve) -- 80
					root:slot( -- 81
						"Input", -- 81
						function(message) -- 81
							local systemContent = getSystemPrompt() -- 82
							local userContent = ("\n你是一名经验丰富的 TypeScript 代码专家。\n\n任务目标：\n1. 阅读「Blockly DSL 框架 API 与示例用法」以及需求描述。\n2. 将需求拆分为具体的积木块功能，并规划对应的 TypeScript 代码结构。\n3. 编写完整的积木块实现代码，使其符合需求并能够正确运行。\n\n回答格式必须分两部分：\n\n1.思考过程\n逐步阐述你的推理：先研读 API 与示例 → 拆解需求 → 规划积木块功能 → 制定代码结构 → 编写实现代码。\n用条目或小节清晰列出，不要省略中间推理步骤。\n\n2.最终答案\n完整的 TypeScript 积木块实现代码（用 ```typescript``` 代码块包裹）。\n期望的功能行为或输出结果，用简要文字或示例说明。\n注意：先完整写出思考过程，再给出最终代码；不要在思考过程中提前透露最终代码或结果。\n\n需求如下：\n\n" .. message) .. "\n" -- 83
							shared.messages = {{role = "system", content = systemContent}, {role = "user", content = userContent}} -- 106
							resolve(nil, nil) -- 110
						end -- 81
					) -- 81
				end -- 80
			) -- 80
		) -- 80
	end) -- 80
end -- 79
local LLMCode = __TS__Class() -- 116
LLMCode.name = "LLMCode" -- 116
__TS__ClassExtends(LLMCode, Node) -- 116
function LLMCode.prototype.prep(self, shared) -- 117
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 117
		return ____awaiter_resolve(nil, shared.messages) -- 117
	end) -- 117
end -- 117
function LLMCode.prototype.exec(self, messages) -- 120
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 120
		return ____awaiter_resolve( -- 120
			nil, -- 120
			__TS__New( -- 121
				__TS__Promise, -- 121
				function(____, resolve, reject) -- 121
					return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 121
						local allContent = "" -- 122
						local allReasoning = "" -- 123
						llmWorking = true -- 124
						local result = callLLM( -- 125
							messages, -- 125
							{temperature = 0}, -- 125
							{ -- 125
								id = nil, -- 126
								onData = function(data) -- 127
									local ____data_choices__1_delta_1 = data.choices[1].delta -- 128
									local reasoning_content = ____data_choices__1_delta_1.reasoning_content -- 128
									local content = ____data_choices__1_delta_1.content -- 128
									if reasoning_content ~= nil then -- 128
										allReasoning = allReasoning .. reasoning_content -- 130
									end -- 130
									if content ~= nil then -- 130
										allContent = allContent .. content -- 133
									end -- 133
									root:emit("Update", "Coder: " .. allReasoning .. (allContent ~= "" and "\n" .. allContent or "")) -- 135
									return not running -- 136
								end, -- 127
								onCancel = function(reason) -- 138
									llmWorking = false -- 139
									reject(nil, reason) -- 140
								end, -- 138
								onDone = function() -- 142
									resolve(nil, allContent) -- 143
								end -- 142
							} -- 142
						) -- 142
						if not result.success then -- 142
							reject(nil, result.message) -- 147
						else -- 147
							root:emit("Output", "Coder: ") -- 149
						end -- 149
					end) -- 149
				end -- 121
			) -- 121
		) -- 121
	end) -- 121
end -- 120
function LLMCode.prototype.post(self, shared, _prepRes, execRes) -- 153
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 153
		local code = extractTSBlocks(execRes) -- 154
		local ____shared_messages_2 = shared.messages -- 154
		____shared_messages_2[#____shared_messages_2 + 1] = {role = "system", content = code} -- 155
		return ____awaiter_resolve(nil, nil) -- 155
	end) -- 155
end -- 153
local function compileTS(file, content) -- 165
	local data = {name = "TranspileTS", file = file, content = content} -- 166
	return __TS__New( -- 167
		__TS__Promise, -- 167
		function(____, resolve) -- 167
			if HttpServer.wsConnectionCount == 0 then -- 167
				resolve(nil, {success = false, result = "Web IDE not connected"}) -- 169
				return -- 170
			end -- 170
			local node = DoraNode() -- 172
			node:gslot( -- 173
				"AppWS", -- 173
				function(eventType, msg) -- 173
					if eventType == "Receive" then -- 173
						node:removeFromParent() -- 175
						local res = json.decode(msg) -- 176
						if res and res.name == "TranspileTS" then -- 176
							if res.success then -- 176
								resolve(nil, {success = true, result = res.luaCode}) -- 179
							else -- 179
								resolve(nil, {success = false, result = res.message}) -- 181
							end -- 181
						end -- 181
					end -- 181
				end -- 173
			) -- 173
			local str = json.encode(data) -- 186
			if str then -- 186
				emit("AppWS", "Send", str) -- 188
			end -- 188
		end -- 167
	) -- 167
end -- 165
local CompileNode = __TS__Class() -- 193
CompileNode.name = "CompileNode" -- 193
__TS__ClassExtends(CompileNode, Node) -- 193
function CompileNode.prototype.prep(self, shared) -- 194
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 194
		return ____awaiter_resolve(nil, shared.messages[#shared.messages].content) -- 194
	end) -- 194
end -- 194
function CompileNode.prototype.exec(self, code) -- 197
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 197
		return ____awaiter_resolve( -- 197
			nil, -- 197
			__TS__Await(compileTS( -- 198
				Path( -- 198
					Content.writablePath, -- 198
					Path:getPath(outputFile.text), -- 198
					"__code__.ts" -- 198
				), -- 198
				code -- 198
			)) -- 198
		) -- 198
	end) -- 198
end -- 197
function CompileNode.prototype.post(self, shared, prepRes, execRes) -- 200
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 200
		if execRes.success then -- 200
			local ____shared_messages_3 = shared.messages -- 200
			____shared_messages_3[#____shared_messages_3 + 1] = {role = "user", content = prepRes} -- 202
			logs[#logs + 1] = "代码编译成功！" -- 203
			return ____awaiter_resolve(nil, "Success") -- 203
		else -- 203
			local ____shared_messages_4 = shared.messages -- 203
			____shared_messages_4[#____shared_messages_4 + 1] = {role = "user", content = (prepRes .. "\n\n编译错误信息如下：\n") .. execRes.result} -- 206
			logs[#logs + 1] = "代码编译失败！" -- 207
			logs[#logs + 1] = execRes.result -- 208
			return ____awaiter_resolve(nil, "Failed") -- 208
		end -- 208
	end) -- 208
end -- 200
local FixNode = __TS__Class() -- 214
FixNode.name = "FixNode" -- 214
__TS__ClassExtends(FixNode, Node) -- 214
function FixNode.prototype.prep(self, shared) -- 215
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 215
		local codeAndError = shared.messages[#shared.messages].content -- 216
		local systemContent = getSystemPrompt() -- 217
		local userContent = ("\n你是一名经验丰富的 TypeScript 代码专家。\n\n任务目标：\n1. 阅读「相关代码模块信息」、原始代码片段，以及随后的编译错误信息。\n2. 找出导致编译失败的根本原因，并给出修正后的完整代码。\n3. 展示修正后代码运行的正确输出结果或关键行为。\n\n回答格式必须分两部分：\n1. 思考过程\n逐步阐述你的推理：先定位错误 → 分析原因 → 制定修复策略 → 说明为何这样修改。\n用条目或小节清晰列出，不要省略中间推理步骤。\n\n2. 最终答案\n修正后的完整代码（用 ```typescript``` 代码块包裹）。\n期望输出或结果说明，用简要文字或示例输出展示。\n注意：先完整写出思考过程，再给出最终答案；不要在思考过程中提前透露最终代码或结果。\n\n原始代码及编译错误信息：\n\n" .. codeAndError) .. "\n" -- 218
		shared.messages = {{role = "system", content = systemContent}, {role = "user", content = userContent}} -- 240
	end) -- 240
end -- 215
function FixNode.prototype.exec(self) -- 245
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 245
		logs[#logs + 1] = "开始修复代码！" -- 246
	end) -- 246
end -- 245
local SaveNode = __TS__Class() -- 250
SaveNode.name = "SaveNode" -- 250
__TS__ClassExtends(SaveNode, Node) -- 250
function SaveNode.prototype.prep(self, shared) -- 251
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 251
		return ____awaiter_resolve(nil, shared.messages[#shared.messages].content) -- 251
	end) -- 251
end -- 251
function SaveNode.prototype.exec(self, code) -- 254
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 254
		llmWorking = false -- 255
		local filename = Path( -- 256
			Content.writablePath, -- 256
			Path:getPath(outputFile.text), -- 256
			Path:getFilename(Path:replaceExt(outputFile.text, "")) .. "Gen.ts" -- 256
		) -- 256
		if Content:save(filename, code) then -- 256
			logs[#logs + 1] = "保存代码成功！" .. filename -- 258
		else -- 258
			logs[#logs + 1] = "保存代码失败！" .. filename -- 260
		end -- 260
		local res = __TS__Await(compileTS(filename, code)) -- 262
		if res.success then -- 262
			local luaFile = Path:replaceExt(filename, "lua") -- 264
			if Content:save(luaFile, res.result) then -- 264
				logs[#logs + 1] = "保存代码成功！" .. luaFile -- 266
			else -- 266
				logs[#logs + 1] = "保存代码失败！" .. luaFile -- 268
			end -- 268
			local ____try = __TS__AsyncAwaiter(function() -- 268
				local func = load(res.result, luaFile) -- 271
				if func then -- 271
					func() -- 272
				end -- 272
				logs[#logs + 1] = "生成代码成功！" -- 273
			end) -- 273
			__TS__Await(____try.catch( -- 270
				____try, -- 270
				function(____, e) -- 270
					logs[#logs + 1] = "生成代码失败！" -- 275
					Log( -- 276
						"Error", -- 276
						tostring(e) -- 276
					) -- 276
				end -- 276
			)) -- 276
		end -- 276
	end) -- 276
end -- 254
local chatNode = __TS__New(ChatNode) -- 282
local llmCode = __TS__New(LLMCode, 2, 1) -- 283
local compileNode = __TS__New(CompileNode) -- 284
local saveNode = __TS__New(SaveNode) -- 285
local fixNode = __TS__New(FixNode) -- 286
chatNode:next(llmCode) -- 287
llmCode:next(compileNode) -- 288
compileNode:on("Success", saveNode) -- 289
compileNode:on("Failed", fixNode) -- 290
fixNode:next(llmCode) -- 291
saveNode:next(chatNode) -- 292
local flow = __TS__New(Flow, chatNode) -- 294
local runFlow -- 295
runFlow = function() -- 295
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 295
		local chatInfo = {messages = {}} -- 296
		local ____try = __TS__AsyncAwaiter(function() -- 296
			__TS__Await(flow:run(chatInfo)) -- 300
		end) -- 300
		__TS__Await(____try.catch( -- 299
			____try, -- 299
			function(____, err) -- 299
				llmWorking = false -- 302
				root:emit( -- 303
					"Output", -- 303
					"Coder: " .. tostring(err) -- 303
				) -- 303
				runFlow() -- 304
			end -- 304
		)) -- 304
	end) -- 304
end -- 295
runFlow() -- 307
logs = {} -- 309
local inputBuffer = Buffer(5000) -- 310
local function ChatButton() -- 312
	ImGui.PushItemWidth( -- 313
		-80, -- 313
		function() -- 313
			if ImGui.InputText(zh and "描述需求" or "Desc", inputBuffer, {"EnterReturnsTrue"}) then -- 313
				local command = inputBuffer.text -- 315
				if command ~= "" then -- 315
					logs = {} -- 317
					logs[#logs + 1] = "User: " .. command -- 318
					root:emit("Input", command) -- 319
				end -- 319
				inputBuffer.text = "" -- 321
			end -- 321
		end -- 313
	) -- 313
end -- 312
local windowsFlags = { -- 326
	"NoMove", -- 327
	"NoCollapse", -- 328
	"NoResize", -- 329
	"NoDecoration", -- 330
	"NoNav", -- 331
	"NoSavedSettings", -- 332
	"NoBringToFrontOnFocus", -- 333
	"NoFocusOnAppearing" -- 334
} -- 334
root:loop(function() -- 336
	local ____App_visualSize_5 = App.visualSize -- 337
	local width = ____App_visualSize_5.width -- 337
	local height = ____App_visualSize_5.height -- 337
	ImGui.SetNextWindowPos(Vec2.zero, "Always", Vec2.zero) -- 338
	ImGui.SetNextWindowSize( -- 339
		Vec2(width, height - 40), -- 339
		"Always" -- 339
	) -- 339
	ImGui.Begin( -- 340
		"Blockly Coder", -- 340
		windowsFlags, -- 340
		function() -- 340
			ImGui.Text(zh and "Blockly 编程家" or "Blockly Coder") -- 341
			ImGui.SameLine() -- 342
			ImGui.TextDisabled("(?)") -- 343
			if ImGui.IsItemHovered() then -- 343
				ImGui.BeginTooltip(function() -- 345
					ImGui.PushTextWrapPos( -- 346
						400, -- 346
						function() -- 346
							ImGui.Text(zh and "请先在 Web IDE 配置大模型 API 密钥，然后输入自然语言需求，Agent 将自动生成 TypeScript 积木代码，编译成 Blockly 积木并翻译为 Lua 脚本运行。遇到编译失败会自动修正，无需手动干预。" or "First, configure the API key for the large language model in Web IDE. Then, input your natural language requirements. The Agent will automatically generate TypeScript building block code, compile it into Blockly blocks, and translate it into Lua scripts for execution. If any compilation errors occur, they will be automatically corrected without requiring manual intervention.") -- 347
						end -- 346
					) -- 346
				end) -- 345
			end -- 345
			ImGui.SameLine() -- 352
			ImGui.Dummy(Vec2(width - 290, 0)) -- 353
			ImGui.SameLine() -- 354
			if ImGui.CollapsingHeader(zh and "配置" or "Config") then -- 354
				if ImGui.InputText(zh and "输出文件" or "Output File", outputFile) then -- 354
					config.output = outputFile.text -- 357
				end -- 357
			end -- 357
			ImGui.Separator() -- 360
			ImGui.BeginChild( -- 361
				"LogArea", -- 361
				Vec2(0, -40), -- 361
				function() -- 361
					for ____, log in ipairs(logs) do -- 362
						ImGui.TextWrapped(log) -- 363
					end -- 363
					if ImGui.GetScrollY() >= ImGui.GetScrollMaxY() then -- 363
						ImGui.SetScrollHereY(1) -- 366
					end -- 366
				end -- 361
			) -- 361
			if llmWorking or config.output == "" then -- 361
				ImGui.BeginDisabled(function() -- 370
					ChatButton() -- 371
				end) -- 370
			else -- 370
				ChatButton() -- 374
			end -- 374
		end -- 340
	) -- 340
	return false -- 377
end) -- 336
root:slot( -- 380
	"Output", -- 380
	function(message) -- 380
		logs[#logs + 1] = message -- 381
	end -- 380
) -- 380
root:slot( -- 384
	"Update", -- 384
	function(message) -- 384
		logs[#logs] = message -- 385
	end -- 384
) -- 384
return ____exports -- 384