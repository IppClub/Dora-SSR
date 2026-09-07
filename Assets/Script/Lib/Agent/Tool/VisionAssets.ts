// @preview-file off clear
import { Content, DB, Path } from 'Dora';
import { resolveWorkspaceFilePath } from 'Agent/Tool/Workspace';

export const VISION_MAX_IMAGE_BYTES = 4 * 1024 * 1024;

/** Identify a PNG or JPEG payload within the size budget; PNG also yields dimensions. */
export function inspectImage(data: string): {format: "png" | "jpeg"; width?: number; height?: number} {
	if (data.length < 12 || data.length > VISION_MAX_IMAGE_BYTES) error("invalid or oversized image");
	if (string.byte(data, 1) === 0xFF && string.byte(data, 2) === 0xD8 && string.byte(data, 3) === 0xFF) {
		return {format: "jpeg"};
	}
	if (string.byte(data, 1) === 137 && string.sub(data, 2, 8) === "PNG\r\n\x1a\n") {
		if (data.length < 33) error("invalid PNG image");
		const integer = (offset: number) => {
			const [a, b, c, d] = string.byte(data, offset, offset + 3);
			return ((a * 256 + b) * 256 + c) * 256 + d;
		};
		const width = integer(17), height = integer(21);
		if (width < 1 || height < 1) error("invalid PNG dimensions");
		return {format: "png", width, height};
	}
	error("unsupported image format; use PNG or JPEG");
}

export function projectVisionDir(workDir: string): string {
	return Path(workDir, ".agent", "vision");
}

/** Recent capture files under .agent/vision for resume/compression context. */
export function listRecentProjectImages(workDir: string): Record<string, unknown>[] {
	const dir = projectVisionDir(workDir);
	if (!Content.exist(dir)) return [];
	const files: string[] = [];
	for (const file of Content.getFiles(dir)) {
		if (file.endsWith(".png") || file.endsWith(".jpg") || file.endsWith(".jpeg")) files.push(file);
	}
	files.sort((a, b) => a < b ? 1 : a > b ? -1 : 0);
	return files.slice(0, 6).map(file => ({path: `.agent/vision/${file}`}));
}

function encodeDataUrl(data: string): string {
	const mime = require("mime") as { b64(this: void, value: string): LuaMultiReturn<[string | undefined, string | undefined]> };
	const [encoded] = mime.b64(data);
	if (!encoded) error("Unable to encode image");
	const inspected = inspectImage(data);
	const prefix = inspected.format === "jpeg" ? "data:image/jpeg;base64," : "data:image/png;base64,";
	return `${prefix}${encoded}`;
}

// Resolve the project on the server; clients never supply a filesystem path.
function sessionProjectRoot(sessionId: number): string {
	if (typeof sessionId !== "number" || sessionId < 1 || sessionId !== math.floor(sessionId)) error("invalid session");
	const rows = DB.query("SELECT project_root FROM agent.AgentSession WHERE id=?", [sessionId]);
	if (!rows || rows.length !== 1 || typeof rows[0][0] !== "string") error("vision session is unavailable");
	return rows[0][0] as string;
}

/** Load any project-relative PNG/JPEG image for UI display. */
export function getSessionVisionImageFromPath(sessionId: number, path: string): Record<string, unknown> {
	try {
		if (typeof path !== "string" || path.trim() === "") error("invalid image path");
		const projectRoot = sessionProjectRoot(sessionId);
		const fullPath = resolveWorkspaceFilePath(projectRoot, path.trim());
		if (!fullPath) error("path escapes the project");
		const data = Content.load(fullPath);
		if (!data) error("image is unavailable");
		const inspected = inspectImage(data);
		return {success: true, path: path.trim(), format: inspected.format, width: inspected.width, height: inspected.height, dataUrl: encodeDataUrl(data)};
	} catch (_) {
		return {success: false, message: "Vision image is unavailable, invalid, or outside the project"};
	}
}

