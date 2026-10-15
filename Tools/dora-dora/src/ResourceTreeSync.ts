import type { TreeDataType } from "./FileTree";

export interface ResourceTreePathOps {
	dirname(path: string): string;
	isAbsolute(path: string): boolean;
	relative(from: string, to: string): string;
}

const findTreeNode = (node: TreeDataType, key: string): TreeDataType | null => {
	if (node.key === key) return node;
	if (node.children === undefined) return null;
	for (let i = 0; i < node.children.length; i++) {
		const found = findTreeNode(node.children[i], key);
		if (found !== null) return found;
	}
	return null;
};

const isWithinRoot = (root: string, target: string, pathOps: ResourceTreePathOps) => {
	const relative = pathOps.relative(root, target);
	return relative === "" || (!pathOps.isAbsolute(relative)
		&& relative !== ".."
		&& !relative.startsWith("../")
		&& !relative.startsWith("..\\"));
};

export const getResourceTreeReconcileDirectory = (
	root: TreeDataType,
	file: string,
	pathOps: ResourceTreePathOps,
): string => {
	let directory = pathOps.dirname(file);
	while (isWithinRoot(root.key, directory, pathOps)) {
		const node = findTreeNode(root, directory);
		if (node !== null && node.dir) return directory;
		if (directory === root.key) break;
		const parent = pathOps.dirname(directory);
		if (parent === directory) break;
		directory = parent;
	}
	return root.key;
};

export const getResourceTreeReconcileDirectories = (
	root: TreeDataType,
	files: string[],
	pathOps: ResourceTreePathOps,
): string[] => {
	const directories = new Set<string>();
	for (let i = 0; i < files.length; i++) {
		directories.add(getResourceTreeReconcileDirectory(root, files[i], pathOps));
	}
	const result = [...directories];
	return result.filter(candidate => !result.some(other => {
		if (candidate === other) return false;
		const relative = pathOps.relative(other, candidate);
		return relative !== ""
			&& !pathOps.isAbsolute(relative)
			&& relative !== ".."
			&& !relative.startsWith("../")
			&& !relative.startsWith("..\\");
	}));
};
