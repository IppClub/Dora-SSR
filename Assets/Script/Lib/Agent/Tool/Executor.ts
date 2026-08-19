// @preview-file off clear
import { compileJsonSchema } from 'Agent/JsonSchema';
import { getToolDefinition } from 'Agent/Tool/Registry';
import { runAgentToolGuards } from 'Agent/Tool/Guards';
import type { AgentToolGuard } from 'Agent/Tool/Guards';
import type {
	AgentToolDefinition,
	AgentToolExecutionContext,
	AgentToolHandlerResult,
	AgentToolSchemaContext,
} from 'Agent/Tool/Types';

export interface AgentToolExecutionRequest {
	tool: string;
	input: unknown;
	context: AgentToolExecutionContext;
	schemaContext: AgentToolSchemaContext;
}

function failure(code: string, message: string): AgentToolHandlerResult {
	return {
		output: {
			success: false,
			code,
			message,
		},
	};
}

function formatValidationErrors(errors: { instancePath: string; message: string }[]): string {
	return errors.map(error => `${error.instancePath !== "" ? error.instancePath : "/"}: ${error.message}`).join("; ");
}

function getCancellationReason(context: AgentToolExecutionContext): string {
	return context.cancellation.reason() ?? "tool execution cancelled";
}

export async function executeAgentToolDefinition(
	definition: AgentToolDefinition,
	input: unknown,
	context: AgentToolExecutionContext,
	schemaContext: AgentToolSchemaContext,
	guards?: AgentToolGuard[]
): Promise<AgentToolHandlerResult> {
	if (context.cancellation.isCancelled()) {
		return failure("TOOL_CANCELLED", getCancellationReason(context));
	}

	const inputValidator = compileJsonSchema(definition.inputSchema(schemaContext));
	if (!inputValidator.success) {
		return failure("INVALID_TOOL_SCHEMA", `Invalid input schema for ${definition.name}`);
	}
	const inputResult = inputValidator.validator.validate(input);
	if (!inputResult.valid) {
		return failure("INVALID_TOOL_INPUT", formatValidationErrors(inputResult.errors));
	}
	let normalizedInput = input as Record<string, unknown>;
	const validateInput = definition.validateInput;
	if (validateInput !== undefined) {
		const semanticResult = validateInput(normalizedInput);
		if (!semanticResult.success) {
			return failure("INVALID_TOOL_INPUT", semanticResult.message);
		}
		normalizedInput = semanticResult.value;
	}

	const denial = runAgentToolGuards({ definition, context, input: normalizedInput }, guards);
	if (denial !== undefined) {
		return failure(denial.code, denial.message);
	}
	if (context.cancellation.isCancelled()) {
		return failure("TOOL_CANCELLED", getCancellationReason(context));
	}
	if (definition.handler === undefined) {
		return failure("TOOL_HANDLER_MISSING", `No handler is registered for ${definition.name}`);
	}

	let result: AgentToolHandlerResult;
	try {
		result = await definition.handler(context, normalizedInput);
	} catch (error) {
		return failure("TOOL_EXECUTION_FAILED", tostring(error));
	}
	if (context.cancellation.isCancelled()) {
		return failure("TOOL_CANCELLED", getCancellationReason(context));
	}

	const outputValidator = compileJsonSchema(definition.outputSchema);
	if (!outputValidator.success) {
		return failure("INVALID_TOOL_SCHEMA", `Invalid output schema for ${definition.name}`);
	}
	const outputResult = outputValidator.validator.validate(result.output);
	if (!outputResult.valid) {
		return failure("INVALID_TOOL_OUTPUT", formatValidationErrors(outputResult.errors));
	}
	return result;
}

export async function executeRegisteredAgentTool(request: AgentToolExecutionRequest): Promise<AgentToolHandlerResult> {
	const definition = getToolDefinition(request.tool);
	if (definition === undefined) {
		return failure("UNKNOWN_TOOL", `Unknown Agent tool: ${request.tool}`);
	}
	return executeAgentToolDefinition(definition, request.input, request.context, request.schemaContext);
}
