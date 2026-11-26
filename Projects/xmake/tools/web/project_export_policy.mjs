// File policy shared by the browser exporter and the xmake Web tools.
export function projectPathIsSafe(path) {
	return !/[\\:\x00-\x1f\x7f]/.test(path) && !path.split("/").some(part => !part || part === "." || part === "..");
}

export function projectFileAllowed(path, policy, includeGodotCache = false) {
	const parts = path.split("/");
	return !parts.some(part =>
		(part.startsWith(".") && !(includeGodotCache && part === ".godot"))
		|| policy.excludedNames.includes(part.toLowerCase())
	) && !policy.excludedSuffixes.some(suffix => path.toLowerCase().endsWith(suffix));
}
