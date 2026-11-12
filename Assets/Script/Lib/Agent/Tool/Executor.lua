-- [ts]: Executor.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local ____exports = {} -- 1
local ____JsonSchema = require("Agent.Tool.JsonSchema") -- 2
local compileJsonSchema = ____JsonSchema.compileJsonSchema -- 2
local ____Registry = require("Agent.Tool.Registry") -- 3
local getToolDefinition = ____Registry.getToolDefinition -- 3
local ____Guards = require("Agent.Tool.Guards") -- 4
local runAgentToolGuards = ____Guards.runAgentToolGuards -- 4
local function failure(code, message) -- 21
	return {execution = {status = code == "TOOL_CANCELLED" and "STOPPED" or "FAILED"}, output = {success = false, code = code, message = message}} -- 22
end -- 21
local function formatValidationErrors(errors) -- 32
	return table.concat( -- 33
		__TS__ArrayMap( -- 33
			errors, -- 33
			function(____, ____error) return ((____error.instancePath ~= "" and ____error.instancePath or "/") .. ": ") .. ____error.message end -- 33
		), -- 33
		"; " -- 33
	) -- 33
end -- 32
local function getCancellationReason(context) -- 36
	return context.cancellation:reason() or "tool execution cancelled" -- 37
end -- 36
function ____exports.executeAgentToolDefinition(definition, input, context, schemaContext, guards) -- 40
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 40
		if context.cancellation:isCancelled() then -- 40
			return ____awaiter_resolve( -- 40
				nil, -- 40
				failure( -- 48
					"TOOL_CANCELLED", -- 48
					getCancellationReason(context) -- 48
				) -- 48
			) -- 48
		end -- 48
		local inputValidator = compileJsonSchema(definition:inputSchema(schemaContext)) -- 51
		if not inputValidator.success then -- 51
			return ____awaiter_resolve( -- 51
				nil, -- 51
				failure("INVALID_TOOL_SCHEMA", "Invalid input schema for " .. definition.name) -- 53
			) -- 53
		end -- 53
		local inputResult = inputValidator.validator:validate(input) -- 55
		if not inputResult.valid then -- 55
			return ____awaiter_resolve( -- 55
				nil, -- 55
				failure( -- 57
					"INVALID_TOOL_INPUT", -- 57
					formatValidationErrors(inputResult.errors) -- 57
				) -- 57
			) -- 57
		end -- 57
		local normalizedInput = input -- 59
		local validateInput = definition.validateInput -- 60
		if validateInput ~= nil then -- 60
			local semanticResult = validateInput(normalizedInput) -- 62
			if not semanticResult.success then -- 62
				return ____awaiter_resolve( -- 62
					nil, -- 62
					failure("INVALID_TOOL_INPUT", semanticResult.message) -- 64
				) -- 64
			end -- 64
			normalizedInput = semanticResult.value -- 66
		end -- 66
		local denial = runAgentToolGuards({definition = definition, context = context, input = normalizedInput}, guards) -- 69
		if denial ~= nil then -- 69
			return ____awaiter_resolve( -- 69
				nil, -- 69
				failure(denial.code, denial.message) -- 71
			) -- 71
		end -- 71
		if context.cancellation:isCancelled() then -- 71
			return ____awaiter_resolve( -- 71
				nil, -- 71
				failure( -- 74
					"TOOL_CANCELLED", -- 74
					getCancellationReason(context) -- 74
				) -- 74
			) -- 74
		end -- 74
		if definition.handler == nil then -- 74
			return ____awaiter_resolve( -- 74
				nil, -- 74
				failure("TOOL_HANDLER_MISSING", "No handler is registered for " .. definition.name) -- 77
			) -- 77
		end -- 77
		local result -- 80
		local ____hasReturned, ____returnValue -- 80
		local ____try = __TS__AsyncAwaiter(function() -- 80
			result = __TS__Await(definition.handler(context, normalizedInput)) -- 82
		end) -- 82
		____try = ____try.catch( -- 82
			____try, -- 82
			function(____, ____error) -- 82
				return __TS__AsyncAwaiter(function() -- 82
					if context.cancellation:isCancelled() then -- 82
						____hasReturned = true -- 85
						____returnValue = failure( -- 85
							"TOOL_CANCELLED", -- 85
							getCancellationReason(context) -- 85
						) -- 85
						return -- 85
					end -- 85
					____hasReturned = true -- 87
					____returnValue = failure( -- 87
						"TOOL_EXECUTION_FAILED", -- 87
						tostring(____error) -- 87
					) -- 87
					return -- 87
				end) -- 87
			end -- 87
		) -- 87
		__TS__Await(____try) -- 81
		if ____hasReturned then -- 81
			return ____awaiter_resolve(nil, ____returnValue) -- 81
		end -- 81
		if context.cancellation:isCancelled() then -- 81
			local stopped = failure( -- 90
				"TOOL_CANCELLED", -- 90
				getCancellationReason(context) -- 90
			) -- 90
			if definition.name == "analyze_image" and result.output.requestIssued == true then -- 90
				stopped.output.requestIssued = true -- 93
				local usage = result.output.usage -- 94
				if usage then -- 94
					stopped.output.usage = {prompt_tokens = usage.prompt_tokens, completion_tokens = usage.completion_tokens, total_tokens = usage.total_tokens} -- 96
				end -- 96
			elseif definition.name == "execute_command" then -- 96
				local capture = result.output.visionCapture -- 98
				if capture and type(capture.batchCount) == "number" and __TS__NumberIsFinite(capture.batchCount) and type(capture.frameCount) == "number" and __TS__NumberIsFinite(capture.frameCount) then -- 98
					stopped.output.visionCapture = { -- 101
						batchCount = math.max( -- 101
							0, -- 101
							math.floor(capture.batchCount) -- 101
						), -- 101
						frameCount = math.max( -- 101
							0, -- 101
							math.floor(capture.frameCount) -- 101
						) -- 101
					} -- 101
				end -- 101
			end -- 101
			return ____awaiter_resolve(nil, stopped) -- 101
		end -- 101
		local outputValidator = compileJsonSchema(definition.outputSchema) -- 107
		if not outputValidator.success then -- 107
			return ____awaiter_resolve( -- 107
				nil, -- 107
				failure("INVALID_TOOL_SCHEMA", "Invalid output schema for " .. definition.name) -- 109
			) -- 109
		end -- 109
		local outputResult = outputValidator.validator:validate(result.output) -- 111
		if not outputResult.valid then -- 111
			return ____awaiter_resolve( -- 111
				nil, -- 111
				failure( -- 113
					"INVALID_TOOL_OUTPUT", -- 113
					formatValidationErrors(outputResult.errors) -- 113
				) -- 113
			) -- 113
		end -- 113
		return ____awaiter_resolve( -- 113
			nil, -- 113
			__TS__ObjectAssign({}, result, {execution = {status = "DONE"}}) -- 115
		) -- 115
	end) -- 115
end -- 40
function ____exports.executeRegisteredAgentTool(request) -- 118
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 118
		local definition = getToolDefinition(request.tool) -- 119
		if definition == nil then -- 119
			return ____awaiter_resolve( -- 119
				nil, -- 119
				failure("UNKNOWN_TOOL", "Unknown Agent tool: " .. request.tool) -- 121
			) -- 121
		end -- 121
		return ____awaiter_resolve( -- 121
			nil, -- 121
			____exports.executeAgentToolDefinition(definition, request.input, request.context, request.schemaContext) -- 123
		) -- 123
	end) -- 123
end -- 118
return ____exports -- 118