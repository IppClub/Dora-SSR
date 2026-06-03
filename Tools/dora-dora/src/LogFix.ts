export interface LogFixRequest {
	lineNumber: number;
	message: string;
}

export const logFixLineClassName = "dora-log-fix-line";
export const logFixContextLineCount = 20;
export const logFixMaxMessageLength = 1000;

export const buildLogFixMessage = (text: string, lineNumber: number) => {
	const lines = text.split(/\r?\n/);
	const startIndex = Math.max(lineNumber - 1, 0);
	const endIndex = Math.min(startIndex + logFixContextLineCount + 1, lines.length);
	const message = lines.slice(startIndex, endIndex).join("\n").trim();
	return Array.from(message).slice(0, logFixMaxMessageLength).join("");
};
