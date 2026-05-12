const normalizeResourcePath = (path: string) => path.replace(/\\/g, "/");

const isChildPath = (child: string, parent: string) => {
	const normalizedChild = normalizeResourcePath(child);
	const normalizedParent = normalizeResourcePath(parent);
	if (!normalizedChild.startsWith(normalizedParent)) return false;
	const next = normalizedChild.charAt(normalizedParent.length);
	return next === "" || next === "/";
};

export const toServedResourcePath = (filePath: string, resourceBasePath?: string) => {
	const normalizedPath = normalizeResourcePath(filePath);
	const normalizedBase = resourceBasePath ? normalizeResourcePath(resourceBasePath) : "";
	if (normalizedBase && isChildPath(normalizedPath, normalizedBase)) {
		const relative = normalizedPath.slice(normalizedBase.length);
		return relative.startsWith("/") ? relative.slice(1) : relative;
	}
	return normalizedPath.startsWith("/") ? normalizedPath.slice(1) : normalizedPath;
};

export const toServedResourceUrl = (filePath: string, resourceBasePath?: string) => {
	const servedPath = toServedResourcePath(filePath, resourceBasePath);
	return `/${servedPath}`;
};
