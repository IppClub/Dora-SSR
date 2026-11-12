// @preview-file off clear
import { compileJsonSchema } from 'Agent/Tool/JsonSchema';
import { getToolDefinition } from 'Agent/Tool/Registry';
import { runAgentToolGuards } from 'Agent/Tool/Guards';
import type { AgentToolGuard } from 'Agent/Tool/Guards';
import type {
	AgentToolDefinition,
	AgentToolExecutionContext,
	AgentToolHandlerResult,
	AgentToolExecutionResult,
	AgentToolSchemaContext,
} from 'Agent/Tool/Types';

export interface AgentToolExecutionRequest {
	tool: string;
	input: unknown;
	context: AgentToolExecutionContext;
	schemaContext: AgentToolSchemaContext;
}

function failure(code: string, message: string): AgentToolExecutionResult {
	return {
		execution: { status: code === "TOOL_CANCELLED" ? "STOPPED" : "FAILED" },
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
): Promise<AgentToolExecutionResult> {
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
		if (context.cancellation.isCancelled()) {
			return failure("TOOL_CANCELLED", getCancellationReason(context));
		}
		return failure("TOOL_EXECUTION_FAILED", tostring(error));
	}
	if (context.cancellation.isCancelled()) {
		const stopped = failure("TOOL_CANCELLED", getCancellationReason(context));
		// A cancellation stops publication, not accounting for already-issued work.
		if (definition.name === "analyze_image" && result.output.requestIssued === true) {
			stopped.output.requestIssued = true;
			const usage = result.output.usage as {prompt_tokens?: number; completion_tokens?: number; total_tokens?: number} | undefined;
			// VisionAnalysis already normalized these provider accounting fields.
			if (usage) stopped.output.usage = {prompt_tokens: usage.prompt_tokens, completion_tokens: usage.completion_tokens, total_tokens: usage.total_tokens};
		} else if (definition.name === "execute_command") {
			const capture = result.output.visionCapture as {batchCount?: number; frameCount?: number} | undefined;
			if (capture && typeof capture.batchCount === "number" && Number.isFinite(capture.batchCount)
				&& typeof capture.frameCount === "number" && Number.isFinite(capture.frameCount)) {
				stopped.output.visionCapture = {batchCount: capture.batchCount, frameCount: capture.frameCount};
			}
		}
		return stopped;
	}

	const outputValidator = compileJsonSchema(definition.outputSchema);
	if (!outputValidator.success) {
		return failure("INVALID_TOOL_SCHEMA", `Invalid output schema for ${definition.name}`);
	}
	const outputResult = outputValidator.validator.validate(result.output);
	if (!outputResult.valid) {
		return failure("INVALID_TOOL_OUTPUT", formatValidationErrors(outputResult.errors));
	}
	return { ...result, execution: { status: "DONE" } };
}

export async function executeRegisteredAgentTool(request: AgentToolExecutionRequest): Promise<AgentToolExecutionResult> {
	const definition = getToolDefinition(request.tool);
	if (definition === undefined) {
		return failure("UNKNOWN_TOOL", `Unknown Agent tool: ${request.tool}`);
	}
	return executeAgentToolDefinition(definition, request.input, request.context, request.schemaContext);
}
