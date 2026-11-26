// @preview-file off
import {Content, Path, json} from "Dora";

const [decoded] = json.decode(Content.load(Path(Content.assetPath, "Script", "Dev", "ExportPolicy.json")));
const policy = (decoded as {
	projectFiles: {excludedNames: string[]; excludedSuffixes: string[]; remixFiles: string[]};
}).projectFiles;

export function projectFileAllowed(file: string, includeRemix = false): boolean {
	const [name] = string.gsub(file, "\\", "/");
	if (name.indexOf(":") >= 0 || string.find(name, "%c")[0] !== undefined) return false;
	const parts = name.split("/");
	if (parts.some(part => part === "" || part === "." || part === "..")) return false;
	if (includeRemix && policy.remixFiles.includes(name)) return true;
	const lower = name.toLowerCase();
	return !parts.some(part => part.startsWith(".") || policy.excludedNames.includes(part.toLowerCase()))
		&& !policy.excludedSuffixes.some(suffix => lower.endsWith(suffix));
}
