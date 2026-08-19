-- [ts]: AgentToolExecutor.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local ____exports = {} -- 1
local ____JsonSchema = require("Agent.JsonSchema") -- 2
local compileJsonSchema = ____JsonSchema.compileJsonSchema -- 2
local ____AgentToolRegistry = require("Agent.AgentToolRegistry") -- 3
local getToolDefinition = ____AgentToolRegistry.getToolDefinition -- 3
local ____AgentToolGuards = require("Agent.AgentToolGuards") -- 4
local runAgentToolGuards = ____AgentToolGuards.runAgentToolGuards -- 4
local function failure(code, message) -- 20
	return {output = {success = false, code = code, message = message}} -- 21
end -- 20
local function formatValidationErrors(errors) -- 30
	return table.concat( -- 31
		__TS__ArrayMap( -- 31
			errors, -- 31
			function(____, ____error) return ((____error.instancePath ~= "" and ____error.instancePath or "/") .. ": ") .. ____error.message end -- 31
		), -- 31
		"; " -- 31
	) -- 31
end -- 30
local function getCancellationReason(context) -- 34
	return context.cancellation:reason() or "tool execution cancelled" -- 35
end -- 34
function ____exports.executeAgentToolDefinition(definition, input, context, schemaContext, guards) -- 38
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 38
		if context.cancellation:isCancelled() then -- 38
			return ____awaiter_resolve( -- 38
				nil, -- 38
				failure( -- 46
					"TOOL_CANCELLED", -- 46
					getCancellationReason(context) -- 46
				) -- 46
			) -- 46
		end -- 46
		local inputValidator = compileJsonSchema(definition:inputSchema(schemaContext)) -- 49
		if not inputValidator.success then -- 49
			return ____awaiter_resolve( -- 49
				nil, -- 49
				failure("INVALID_TOOL_SCHEMA", "Invalid input schema for " .. definition.name) -- 51
			) -- 51
		end -- 51
		local inputResult = inputValidator.validator:validate(input) -- 53
		if not inputResult.valid then -- 53
			return ____awaiter_resolve( -- 53
				nil, -- 53
				failure( -- 55
					"INVALID_TOOL_INPUT", -- 55
					formatValidationErrors(inputResult.errors) -- 55
				) -- 55
			) -- 55
		end -- 55
		local normalizedInput = input -- 57
		local validateInput = definition.validateInput -- 58
		if validateInput ~= nil then -- 58
			local semanticResult = validateInput(normalizedInput) -- 60
			if not semanticResult.success then -- 60
				return ____awaiter_resolve( -- 60
					nil, -- 60
					failure("INVALID_TOOL_INPUT", semanticResult.message) -- 62
				) -- 62
			end -- 62
			normalizedInput = semanticResult.value -- 64
		end -- 64
		local denial = runAgentToolGuards({definition = definition, context = context, input = normalizedInput}, guards) -- 67
		if denial ~= nil then -- 67
			return ____awaiter_resolve( -- 67
				nil, -- 67
				failure(denial.code, denial.message) -- 69
			) -- 69
		end -- 69
		if context.cancellation:isCancelled() then -- 69
			return ____awaiter_resolve( -- 69
				nil, -- 69
				failure( -- 72
					"TOOL_CANCELLED", -- 72
					getCancellationReason(context) -- 72
				) -- 72
			) -- 72
		end -- 72
		if definition.handler == nil then -- 72
			return ____awaiter_resolve( -- 72
				nil, -- 72
				failure("TOOL_HANDLER_MISSING", "No handler is registered for " .. definition.name) -- 75
			) -- 75
		end -- 75
		local result -- 78
		local ____hasReturned, ____returnValue -- 78
		local ____try = __TS__AsyncAwaiter(function() -- 78
			result = __TS__Await(definition.handler(context, normalizedInput)) -- 80
		end) -- 80
		____try = ____try.catch( -- 80
			____try, -- 80
			function(____, ____error) -- 80
				return __TS__AsyncAwaiter(function() -- 80
					____hasReturned = true -- 82
					____returnValue = failure( -- 82
						"TOOL_EXECUTION_FAILED", -- 82
						tostring(____error) -- 82
					) -- 82
					return -- 82
				end) -- 82
			end -- 82
		) -- 82
		__TS__Await(____try) -- 79
		if ____hasReturned then -- 79
			return ____awaiter_resolve(nil, ____returnValue) -- 79
		end -- 79
		if context.cancellation:isCancelled() then -- 79
			return ____awaiter_resolve( -- 79
				nil, -- 79
				failure( -- 85
					"TOOL_CANCELLED", -- 85
					getCancellationReason(context) -- 85
				) -- 85
			) -- 85
		end -- 85
		local outputValidator = compileJsonSchema(definition.outputSchema) -- 88
		if not outputValidator.success then -- 88
			return ____awaiter_resolve( -- 88
				nil, -- 88
				failure("INVALID_TOOL_SCHEMA", "Invalid output schema for " .. definition.name) -- 90
			) -- 90
		end -- 90
		local outputResult = outputValidator.validator:validate(result.output) -- 92
		if not outputResult.valid then -- 92
			return ____awaiter_resolve( -- 92
				nil, -- 92
				failure( -- 94
					"INVALID_TOOL_OUTPUT", -- 94
					formatValidationErrors(outputResult.errors) -- 94
				) -- 94
			) -- 94
		end -- 94
		return ____awaiter_resolve(nil, result) -- 94
	end) -- 94
end -- 38
function ____exports.executeRegisteredAgentTool(request) -- 99
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 99
		local definition = getToolDefinition(request.tool) -- 100
		if definition == nil then -- 100
			return ____awaiter_resolve( -- 100
				nil, -- 100
				failure("UNKNOWN_TOOL", "Unknown Agent tool: " .. request.tool) -- 102
			) -- 102
		end -- 102
		return ____awaiter_resolve( -- 102
			nil, -- 102
			____exports.executeAgentToolDefinition(definition, request.input, request.context, request.schemaContext) -- 104
		) -- 104
	end) -- 104
end -- 99
return ____exports -- 99