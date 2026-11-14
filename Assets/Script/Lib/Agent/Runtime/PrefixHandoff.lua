-- [ts]: PrefixHandoff.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIncludes = ____lualib.__TS__ArrayIncludes -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__ArrayEvery = ____lualib.__TS__ArrayEvery -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local ____Dora = require("Dora") -- 3
local Content = ____Dora.Content -- 3
local Path = ____Dora.Path -- 3
local json = ____Dora.json -- 3
local ____Utils = require("Agent.Utils") -- 4
local safeJsonDecode = ____Utils.safeJsonDecode -- 4
local safeJsonEncode = ____Utils.safeJsonEncode -- 4
____exports.HANDOFF_TOOL = {type = "function", ["function"] = {name = "context_handoff", description = "Record a checkpoint for the next model. Preserve current constraints, verified evidence, failures and every open next action. This does not execute development work.", parameters = {type = "object", properties = {goal_constraints = {type = "string"}, progress_evidence = {type = "string"}, open_work_next_action = {type = "string"}}, required = {"goal_constraints", "progress_evidence", "open_work_next_action"}, additionalProperties = false}}} -- 6
function ____exports.parseToolHandoff(finishReason, message) -- 31
	local calls = message.tool_calls or ({}) -- 32
	local result = {calls = {}, complete = false} -- 33
	if finishReason ~= "stop" and finishReason ~= "tool_calls" then -- 33
		result.error = "Incomplete provider response" -- 36
		return result -- 37
	end -- 37
	local ids = {} -- 39
	for ____, call in ipairs(calls) do -- 40
		if not call.id or __TS__ArrayIncludes(ids, call.id) then -- 40
			result.error = "Missing or duplicate tool call id" -- 42
			return result -- 43
		end -- 43
		ids[#ids + 1] = call.id -- 45
	end -- 45
	result.complete = true -- 47
	local handoffs = __TS__ArrayFilter( -- 48
		calls, -- 48
		function(____, call) -- 48
			local ____opt_0 = call["function"] -- 48
			return (____opt_0 and ____opt_0.name) == "context_handoff" -- 48
		end -- 48
	) -- 48
	result.calls = __TS__ArrayFilter( -- 49
		calls, -- 49
		function(____, call) -- 49
			local ____opt_2 = call["function"] -- 49
			return (____opt_2 and ____opt_2.name) ~= "context_handoff" -- 49
		end -- 49
	) -- 49
	if #handoffs == 1 then -- 49
		local ____safeJsonDecode_6 = safeJsonDecode -- 51
		local ____opt_4 = handoffs[1]["function"] -- 51
		local value, ____error = ____safeJsonDecode_6(____opt_4 and ____opt_4.arguments or "") -- 51
		if not ____error and value and type(value) == "table" then -- 51
			local fields = value -- 53
			local required = {"goal_constraints", "progress_evidence", "open_work_next_action"} -- 54
			if __TS__ArrayEvery( -- 54
				required, -- 55
				function(____, field) return type(fields[field]) == "string" and __TS__StringTrim(fields[field]) ~= "" end -- 55
			) then -- 55
				result.summary = (((("## Goal and constraints\n" .. tostring(fields.goal_constraints)) .. "\n## Progress and evidence\n") .. tostring(fields.progress_evidence)) .. "\n## Open work and next action\n") .. tostring(fields.open_work_next_action) -- 56
			end -- 56
		end -- 56
	end -- 56
	if not result.summary then -- 56
		result.error = "Checkpoint fields missing; development calls are retained" -- 60
	end -- 60
	return result -- 61
end -- 31
local function encode(value) -- 64
	local encoded, ____error = safeJsonEncode(value) -- 65
	if ____error or not encoded then -- 65
		error( -- 66
			__TS__New(Error, ____error or "Cannot encode journal"), -- 66
			0 -- 66
		) -- 66
	end -- 66
	return encoded -- 67
end -- 64
local function canonical(value) -- 70
	if __TS__ArrayIsArray(value) then -- 70
		return ("[" .. table.concat( -- 71
			__TS__ArrayMap( -- 71
				value, -- 71
				function(____, item) return canonical(item) end -- 71
			), -- 71
			"," -- 71
		)) .. "]" -- 71
	end -- 71
	if value ~= nil and value ~= json.null and type(value) == "table" then -- 71
		local object = value -- 73
		return ("{" .. table.concat( -- 74
			__TS__ArrayMap( -- 74
				__TS__ArraySort(__TS__ObjectKeys(object)), -- 74
				function(____, key) return (encode(key) .. ":") .. canonical(object[key]) end -- 74
			), -- 74
			"," -- 74
		)) .. "}" -- 74
	end -- 74
	return encode(value) -- 76
end -- 70
____exports.HandoffRecoveryLedger = __TS__Class() -- 91
local HandoffRecoveryLedger = ____exports.HandoffRecoveryLedger -- 91
HandoffRecoveryLedger.name = "HandoffRecoveryLedger" -- 91
function HandoffRecoveryLedger.prototype.____constructor(self, dir) -- 95
	Content:mkdir(dir) -- 96
	self.path = Path(dir, "recovery-operations.json") -- 97
	if Content:exist(self.path) then -- 97
		local value, ____error = safeJsonDecode(Content:load(self.path)) -- 99
		if ____error or not value then -- 99
			error( -- 100
				__TS__New(Error, ____error or "Invalid ledger"), -- 100
				0 -- 100
			) -- 100
		end -- 100
		self.state = value -- 101
	else -- 101
		self.state = {operations = {}, ids = {}} -- 103
		self:save() -- 104
	end -- 104
end -- 95
function HandoffRecoveryLedger.prototype.save(self) -- 108
	if not Content:save( -- 108
		self.path, -- 109
		encode(self.state) -- 109
	) then -- 109
		error( -- 109
			__TS__New(Error, "Failed to persist recovery operation ledger"), -- 109
			0 -- 109
		) -- 109
	end -- 109
end -- 108
function HandoffRecoveryLedger.prototype.execute(self, call, handler) -- 112
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 112
		local ____safeJsonDecode_9 = safeJsonDecode -- 113
		local ____opt_7 = call["function"] -- 113
		local args, ____error = ____safeJsonDecode_9(____opt_7 and ____opt_7.arguments or "") -- 113
		local ____temp_12 = ____error or not call.id -- 114
		if not ____temp_12 then -- 114
			local ____opt_10 = call["function"] -- 114
			____temp_12 = not (____opt_10 and ____opt_10.name) -- 114
		end -- 114
		if ____temp_12 then -- 114
			return ____awaiter_resolve(nil, {success = false, code = "INVALID_TOOL_ARGUMENTS", message = ____error or "Missing call identity"}) -- 114
		end -- 114
		local key = (call["function"].name .. ":") .. canonical(args) -- 117
		local previousKey = self.state.ids[call.id] -- 118
		if previousKey ~= nil and previousKey ~= key then -- 118
			return ____awaiter_resolve(nil, {success = false, code = "RECOVERY_CALL_ID_CONFLICT", message = "The same call id was reused for different arguments"}) -- 118
		end -- 118
		local receipt = self.state.operations[key] -- 122
		if receipt ~= nil then -- 122
			self.state.ids[call.id] = key -- 124
			self:save() -- 125
			if receipt.status ~= "done" then -- 125
				return ____awaiter_resolve(nil, {success = false, code = "RECOVERY_RECONCILIATION_REQUIRED", message = "Prior execution status uncertain; do not replay automatically"}) -- 125
			end -- 125
			return ____awaiter_resolve( -- 125
				nil, -- 125
				__TS__ObjectAssign({}, receipt.output, {recoveryReplay = true, originalToolCallId = receipt.id}) -- 129
			) -- 129
		end -- 129
		self.state.ids[call.id] = key -- 131
		self.state.operations[key] = {id = call.id, status = "started"} -- 132
		self:save() -- 133
		local output = __TS__Await(handler(call)) -- 134
		self.state.operations[key] = {id = call.id, status = "done", output = output} -- 135
		self:save() -- 136
		return ____awaiter_resolve(nil, output) -- 136
	end) -- 136
end -- 112
return ____exports -- 112