-- [tsx]: PlatformerX.tsx
local ____lualib = require("lualib_bundle") -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local ____exports = {} -- 1
local Warn, visitBTree -- 1
local ____DoraX = require("DoraX") -- 9
local React = ____DoraX.React -- 9
local P = require("Platformer") -- 10
function Warn(msg) -- 187
	print("[Dora Warning] " .. msg) -- 188
end -- 188
function visitBTree(treeStack, node) -- 293
	if type(node) ~= "table" then -- 293
		return false -- 295
	end -- 295
	repeat -- 295
		local ____switch60 = node.name -- 295
		local ____cond60 = ____switch60 == "BTSelector" -- 295
		if ____cond60 then -- 295
			do -- 295
				local props = node.data -- 299
				local children = props.children -- 300
				if children and #children > 0 then -- 300
					local stack = {} -- 302
					do -- 302
						local i = 0 -- 303
						while i < #children do -- 303
							if not visitBTree(stack, children[i + 1].props) then -- 303
								Warn("unsupported BehaviorTree node with name " .. tostring(children[i + 1].props.name)) -- 305
							end -- 305
							i = i + 1 -- 303
						end -- 303
					end -- 303
					if #stack > 0 then -- 303
						treeStack[#treeStack + 1] = P.Behavior.Sel(stack) -- 309
					end -- 309
				end -- 309
				break -- 312
			end -- 312
		end -- 312
		____cond60 = ____cond60 or ____switch60 == "BTSequence" -- 312
		if ____cond60 then -- 312
			do -- 312
				local props = node.data -- 315
				local children = props.children -- 316
				if children and #children > 0 then -- 316
					local stack = {} -- 318
					do -- 318
						local i = 0 -- 319
						while i < #children do -- 319
							if not visitBTree(stack, children[i + 1].props) then -- 319
								Warn("unsupported BehaviorTree node with name " .. tostring(children[i + 1].props.name)) -- 321
							end -- 321
							i = i + 1 -- 319
						end -- 319
					end -- 319
					if #stack > 0 then -- 319
						treeStack[#treeStack + 1] = P.Behavior.Seq(stack) -- 325
					end -- 325
				end -- 325
				break -- 328
			end -- 328
		end -- 328
		____cond60 = ____cond60 or ____switch60 == "BTCondition" -- 328
		if ____cond60 then -- 328
			do -- 328
				local props = node.data -- 331
				treeStack[#treeStack + 1] = P.Behavior.Con(props.desc, props.onCheck) -- 332
				break -- 333
			end -- 333
		end -- 333
		____cond60 = ____cond60 or ____switch60 == "BTMatch" -- 333
		if ____cond60 then -- 333
			do -- 333
				local props = node.data -- 336
				local children = props.children -- 337
				if children and #children > 0 then -- 337
					local stack = {} -- 339
					do -- 339
						local i = 0 -- 340
						while i < #children do -- 340
							if not visitBTree(stack, children[i + 1].props) then -- 340
								Warn("unsupported BehaviorTree node with name " .. tostring(children[i + 1].props.name)) -- 342
							end -- 342
							i = i + 1 -- 340
						end -- 340
					end -- 340
					if #stack > 0 then -- 340
						treeStack[#treeStack + 1] = P.Behavior.Seq({ -- 346
							P.Behavior.Con(props.desc, props.onCheck), -- 348
							table.unpack(stack) -- 348
						}) -- 348
						break -- 351
					end -- 351
				end -- 351
				treeStack[#treeStack + 1] = P.Behavior.Con(props.desc, props.onCheck) -- 354
				break -- 355
			end -- 355
		end -- 355
		____cond60 = ____cond60 or ____switch60 == "BTAction" -- 355
		if ____cond60 then -- 355
			do -- 355
				local props = node.data -- 358
				treeStack[#treeStack + 1] = P.Behavior.Act(props.name) -- 359
				break -- 360
			end -- 360
		end -- 360
		____cond60 = ____cond60 or ____switch60 == "BTCommand" -- 360
		if ____cond60 then -- 360
			do -- 360
				local props = node.data -- 363
				treeStack[#treeStack + 1] = P.Behavior.Command(props.name) -- 364
				break -- 365
			end -- 365
		end -- 365
		____cond60 = ____cond60 or ____switch60 == "BTWait" -- 365
		if ____cond60 then -- 365
			do -- 365
				local props = node.data -- 368
				treeStack[#treeStack + 1] = P.Behavior.Wait(props.time) -- 369
				break -- 370
			end -- 370
		end -- 370
		____cond60 = ____cond60 or ____switch60 == "BTCountdown" -- 370
		if ____cond60 then -- 370
			do -- 370
				local props = node.data -- 373
				local children = props.children -- 374
				if children and #children >= 1 then -- 374
					local stack = {} -- 376
					if visitBTree(stack, children[1].props) then -- 376
						treeStack[#treeStack + 1] = P.Behavior.Countdown(props.time, stack[1]) -- 378
					else -- 378
						Warn("expects only one BehaviorTree child for BehaviorTree.Countdown") -- 380
					end -- 380
				else -- 380
					Warn("expects only one BehaviorTree child for BehaviorTree.Countdown") -- 383
				end -- 383
				break -- 385
			end -- 385
		end -- 385
		____cond60 = ____cond60 or ____switch60 == "BTTimeout" -- 385
		if ____cond60 then -- 385
			do -- 385
				local props = node.data -- 388
				local children = props.children -- 389
				if children and #children >= 1 then -- 389
					local stack = {} -- 391
					if visitBTree(stack, children[1].props) then -- 391
						treeStack[#treeStack + 1] = P.Behavior.Timeout(props.time, stack[1]) -- 393
					else -- 393
						Warn("expects only one BehaviorTree child for BehaviorTree.Timeout") -- 395
					end -- 395
				else -- 395
					Warn("expects only one BehaviorTree child for BehaviorTree.Timeout") -- 398
				end -- 398
				break -- 400
			end -- 400
		end -- 400
		____cond60 = ____cond60 or ____switch60 == "BTRepeat" -- 400
		if ____cond60 then -- 400
			do -- 400
				local props = node.data -- 403
				local children = props.children -- 404
				if children and #children >= 1 then -- 404
					local stack = {} -- 406
					if visitBTree(stack, children[1].props) then -- 406
						if props.times ~= nil then -- 406
							treeStack[#treeStack + 1] = P.Behavior.Repeat(props.times, stack[1]) -- 409
						else -- 409
							treeStack[#treeStack + 1] = P.Behavior.Repeat(stack[1]) -- 411
						end -- 411
					else -- 411
						Warn("expects only one BehaviorTree child for BehaviorTree.Repeat") -- 414
					end -- 414
				else -- 414
					Warn("expects only one BehaviorTree child for BehaviorTree.Repeat") -- 417
				end -- 417
				break -- 419
			end -- 419
		end -- 419
		____cond60 = ____cond60 or ____switch60 == "BTRetry" -- 419
		if ____cond60 then -- 419
			do -- 419
				local props = node.data -- 422
				local children = props.children -- 423
				if children and #children >= 1 then -- 423
					local stack = {} -- 425
					if visitBTree(stack, children[1].props) then -- 425
						if props.times ~= nil then -- 425
							treeStack[#treeStack + 1] = P.Behavior.Retry(props.times, stack[1]) -- 428
						else -- 428
							treeStack[#treeStack + 1] = P.Behavior.Retry(stack[1]) -- 430
						end -- 430
					else -- 430
						Warn("expects only one BehaviorTree child for BehaviorTree.Retry") -- 433
					end -- 433
				else -- 433
					Warn("expects only one BehaviorTree child for BehaviorTree.Retry") -- 436
				end -- 436
				break -- 438
			end -- 438
		end -- 438
		do -- 438
			return false -- 441
		end -- 441
	until true -- 441
	return true -- 443
end -- 443
____exports.BehaviorTree = {} -- 443
local BehaviorTree = ____exports.BehaviorTree -- 443
do -- 443
	BehaviorTree.Leaf = __TS__Class() -- 12
	local Leaf = BehaviorTree.Leaf -- 12
	Leaf.name = "Leaf" -- 27
	function Leaf.prototype.____constructor(self) -- 28
	end -- 28
	function BehaviorTree.Selector(props) -- 38
		return React.createElement("custom-element", {name = "BTSelector", data = props}) -- 39
	end -- 38
	function BehaviorTree.Sequence(props) -- 42
		return React.createElement("custom-element", {name = "BTSequence", data = props}) -- 43
	end -- 42
	function BehaviorTree.Condition(props) -- 51
		return React.createElement("custom-element", {name = "BTCondition", data = props}) -- 52
	end -- 51
	function BehaviorTree.Match(props) -- 61
		return React.createElement("custom-element", {name = "BTMatch", data = props}) -- 62
	end -- 61
	function BehaviorTree.Action(props) -- 69
		return React.createElement("custom-element", {name = "BTAction", data = props}) -- 70
	end -- 69
	function BehaviorTree.Command(props) -- 73
		return React.createElement("custom-element", {name = "BTCommand", data = props}) -- 74
	end -- 73
	function BehaviorTree.Wait(props) -- 81
		return React.createElement("custom-element", {name = "BTWait", data = props}) -- 82
	end -- 81
	function BehaviorTree.Countdown(props) -- 90
		return React.createElement("custom-element", {name = "BTCountdown", data = props}) -- 91
	end -- 90
	function BehaviorTree.Timeout(props) -- 94
		return React.createElement("custom-element", {name = "BTTimeout", data = props}) -- 95
	end -- 94
	function BehaviorTree.Repeat(props) -- 103
		return React.createElement("custom-element", {name = "BTRepeat", data = props}) -- 104
	end -- 103
	function BehaviorTree.Retry(props) -- 107
		return React.createElement("custom-element", {name = "BTRetry", data = props}) -- 108
	end -- 107
end -- 107
____exports.DecisionTree = {} -- 107
local DecisionTree = ____exports.DecisionTree -- 107
do -- 107
	DecisionTree.Leaf = __TS__Class() -- 112
	local Leaf = DecisionTree.Leaf -- 112
	Leaf.name = "Leaf" -- 124
	function Leaf.prototype.____constructor(self) -- 125
	end -- 125
	function DecisionTree.Selector(props) -- 135
		return React.createElement("custom-element", {name = "DTSelector", data = props}) -- 136
	end -- 135
	function DecisionTree.Sequence(props) -- 139
		return React.createElement("custom-element", {name = "DTSequence", data = props}) -- 140
	end -- 139
	function DecisionTree.Condition(props) -- 148
		return React.createElement("custom-element", {name = "DTCondition", data = props}) -- 149
	end -- 148
	function DecisionTree.Match(props) -- 158
		return React.createElement("custom-element", {name = "DTMatch", data = props}) -- 159
	end -- 158
	function DecisionTree.Action(props) -- 166
		return React.createElement("custom-element", {name = "DTAction", data = props}) -- 167
	end -- 166
	function DecisionTree.Accept() -- 170
		return React.createElement("custom-element", {name = "DTAccept", data = nil}) -- 171
	end -- 170
	function DecisionTree.Reject() -- 174
		return React.createElement("custom-element", {name = "DTReject", data = nil}) -- 175
	end -- 174
	function DecisionTree.Behavior(props) -- 182
		return React.createElement("custom-element", {name = "DTBehavior", data = props}) -- 183
	end -- 182
end -- 182
local function visitDTree(treeStack, node) -- 191
	if type(node) ~= "table" then -- 191
		return false -- 193
	end -- 193
	repeat -- 193
		local ____switch28 = node.name -- 193
		local ____cond28 = ____switch28 == "DTSelector" -- 193
		if ____cond28 then -- 193
			do -- 193
				local props = node.data -- 197
				local children = props.children -- 198
				if children and #children > 0 then -- 198
					local stack = {} -- 200
					do -- 200
						local i = 0 -- 201
						while i < #children do -- 201
							if not visitDTree(stack, children[i + 1].props) then -- 201
								Warn("unsupported DecisionTree node with name " .. tostring(children[i + 1].props.name)) -- 203
							end -- 203
							i = i + 1 -- 201
						end -- 201
					end -- 201
					if #stack > 0 then -- 201
						treeStack[#treeStack + 1] = P.Decision.Sel(stack) -- 207
					end -- 207
				end -- 207
				break -- 210
			end -- 210
		end -- 210
		____cond28 = ____cond28 or ____switch28 == "DTSequence" -- 210
		if ____cond28 then -- 210
			do -- 210
				local props = node.data -- 213
				local children = props.children -- 214
				if children and #children > 0 then -- 214
					local stack = {} -- 216
					do -- 216
						local i = 0 -- 217
						while i < #children do -- 217
							if not visitDTree(stack, children[i + 1].props) then -- 217
								Warn("unsupported DecisionTree node with name " .. tostring(children[i + 1].props.name)) -- 219
							end -- 219
							i = i + 1 -- 217
						end -- 217
					end -- 217
					if #stack > 0 then -- 217
						treeStack[#treeStack + 1] = P.Decision.Seq(stack) -- 223
					end -- 223
				end -- 223
				break -- 226
			end -- 226
		end -- 226
		____cond28 = ____cond28 or ____switch28 == "DTCondition" -- 226
		if ____cond28 then -- 226
			do -- 226
				local props = node.data -- 229
				treeStack[#treeStack + 1] = P.Decision.Con(props.desc, props.onCheck) -- 230
				break -- 231
			end -- 231
		end -- 231
		____cond28 = ____cond28 or ____switch28 == "DTMatch" -- 231
		if ____cond28 then -- 231
			do -- 231
				local props = node.data -- 234
				local children = props.children -- 235
				if children and #children > 0 then -- 235
					local stack = {} -- 237
					do -- 237
						local i = 0 -- 238
						while i < #children do -- 238
							if not visitDTree(stack, children[i + 1].props) then -- 238
								Warn("unsupported DecisionTree node with name " .. tostring(children[i + 1].props.name)) -- 240
							end -- 240
							i = i + 1 -- 238
						end -- 238
					end -- 238
					if #stack > 0 then -- 238
						treeStack[#treeStack + 1] = P.Decision.Seq({ -- 244
							P.Decision.Con(props.desc, props.onCheck), -- 246
							table.unpack(stack) -- 246
						}) -- 246
						break -- 249
					end -- 249
				end -- 249
				treeStack[#treeStack + 1] = P.Decision.Con(props.desc, props.onCheck) -- 252
				break -- 253
			end -- 253
		end -- 253
		____cond28 = ____cond28 or ____switch28 == "DTAction" -- 253
		if ____cond28 then -- 253
			do -- 253
				local props = node.data -- 256
				if type(props.name) == "string" then -- 256
					treeStack[#treeStack + 1] = P.Decision.Act(props.name) -- 258
				else -- 258
					treeStack[#treeStack + 1] = P.Decision.Act(props.name) -- 260
				end -- 260
				break -- 262
			end -- 262
		end -- 262
		____cond28 = ____cond28 or ____switch28 == "DTAccept" -- 262
		if ____cond28 then -- 262
			do -- 262
				treeStack[#treeStack + 1] = P.Decision.Accept() -- 265
				break -- 266
			end -- 266
		end -- 266
		____cond28 = ____cond28 or ____switch28 == "DTReject" -- 266
		if ____cond28 then -- 266
			do -- 266
				treeStack[#treeStack + 1] = P.Decision.Reject() -- 269
				break -- 270
			end -- 270
		end -- 270
		____cond28 = ____cond28 or ____switch28 == "DTBehavior" -- 270
		if ____cond28 then -- 270
			do -- 270
				local props = node.data -- 273
				local children = props.children -- 274
				if children and #children >= 1 then -- 274
					local stack = {} -- 276
					if visitBTree(stack, children[1].props) then -- 276
						treeStack[#treeStack + 1] = P.Decision.Behave(props.name, stack[1]) -- 278
					else -- 278
						Warn("expects only one BehaviorTree child for DecisionTree.Behavior") -- 280
					end -- 280
				else -- 280
					Warn("expects only one BehaviorTree child for DecisionTree.Behavior") -- 283
				end -- 283
				break -- 285
			end -- 285
		end -- 285
		do -- 285
			return false -- 288
		end -- 288
	until true -- 288
	return true -- 290
end -- 191
function ____exports.toAI(node) -- 446
	if type(node) ~= "table" then -- 446
		return nil -- 448
	end -- 448
	local treeStack = {} -- 450
	if visitDTree(treeStack, node.props) and #treeStack > 0 then -- 450
		return treeStack[1] -- 452
	end -- 452
	return nil -- 454
end -- 446
return ____exports -- 446