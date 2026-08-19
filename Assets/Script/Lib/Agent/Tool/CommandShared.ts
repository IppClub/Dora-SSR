// @preview-file off clear
export function toCommandString(v: unknown): string {
	if (v === false || v === undefined) return "";
	return tostring(v);
}

const EXECUTE_COMMAND_OUTPUT_MAX = 12000;
const EXECUTE_COMMAND_ERROR_MAX = 4000;

export function truncateCommandOutput(output: string): string {
	if (output.length <= EXECUTE_COMMAND_OUTPUT_MAX) return output;
	return `${output.slice(0, EXECUTE_COMMAND_OUTPUT_MAX)}\n... output truncated ...`;
}

export function truncateCommandError(message: string): string {
	if (message.length <= EXECUTE_COMMAND_ERROR_MAX) return message;
	return `${message.slice(0, EXECUTE_COMMAND_ERROR_MAX)}\n... error message truncated ...`;
}
