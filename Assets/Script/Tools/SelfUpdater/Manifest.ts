// @preview-file off
import { App, Content, json, Path, PlatformType } from "Dora";

export type UpdatePlatform = "android" | "windows-x86" | "macos-universal";

export interface UpdatePackage {
	ref: string;
	commit: string;
	file: string;
	size: number;
	sha256: string;
	github: string;
}

export interface UpdateManifest {
	schemaVersion: 1;
	channel: "stable";
	version: string;
	revision: number;
	publishedAt: string;
	packages: Record<UpdatePlatform, UpdatePackage>;
}

export interface ManifestParseResult {
	manifest?: UpdateManifest;
	message?: string;
}

const versionPattern = "^v%d+%.%d+%.%d+$";
const matches = (value: string, pattern: string) => string.match(value, pattern)[0] !== undefined;
const isLowerHex = (value: string, length: number) => value.length === length && matches(value, "^[0-9a-f]+$");
const hasOnlyKeys = (value: object, allowed: string[]) => {
	for (const key in value) {
		let found = false;
		for (const allowedKey of allowed) {
			if (key === allowedKey) {
				found = true;
				break;
			}
		}
		if (!found) return false;
	}
	return true;
};

interface PackageParseResult {
	item?: UpdatePackage;
	message?: string;
}

const parsePackage = (
	value: unknown,
	platform: UpdatePlatform,
	version: string,
	revision: number,
): PackageParseResult => {
	if (typeof value !== "object" || value === undefined) {
		return { message: `${platform} package is missing` };
	}
	if (!hasOnlyKeys(value as object, ["ref", "commit", "file", "size", "sha256", "github"])) {
		return { message: `${platform} package contains unsupported fields` };
	}
	const item = value as Partial<UpdatePackage>;
	if (typeof item.ref !== "string"
		|| item.ref !== `refs/tags/${version}-${revision}-${platform}`) {
		return { message: `${platform} package ref is invalid` };
	}
	if (typeof item.commit !== "string" || !isLowerHex(item.commit, 40)) {
		return { message: `${platform} package commit is invalid` };
	}
	if (typeof item.file !== "string"
		|| item.file !== `dora-ssr-${version}-${platform}.zip`
		|| Path.getFilename(item.file) !== item.file) {
		return { message: `${platform} package file is invalid` };
	}
	if (typeof item.size !== "number" || item.size < 1 || item.size > 2 * 1024 * 1024 * 1024) {
		return { message: `${platform} package size is invalid` };
	}
	if (typeof item.sha256 !== "string" || !isLowerHex(item.sha256, 64)) {
		return { message: `${platform} package SHA-256 is invalid` };
	}
	const github = `https://github.com/IppClub/Dora-SSR/releases/download/${version}/${item.file}`;
	if (typeof item.github !== "string" || item.github !== github) {
		return { message: `${platform} GitHub URL is invalid` };
	}
	return { item: item as UpdatePackage };
};

export const parseUpdateManifest = (text: string): ManifestParseResult => {
	if (text.length > 128 * 1024) return { message: "update manifest is too large" };
	const [decoded, err] = json.decode(text);
	if (err !== undefined || typeof decoded !== "object" || decoded === undefined) {
		return { message: "update manifest is not valid JSON" };
	}
	if (!hasOnlyKeys(decoded as object, ["$schema", "schemaVersion", "channel", "version", "revision", "publishedAt", "packages"])) {
		return { message: "update manifest contains unsupported fields" };
	}
	if ((decoded as Record<string, unknown>)["$schema"] !== "./schema/stable-v1.schema.json") {
		return { message: "update manifest schema reference is invalid" };
	}
	const value = decoded as Partial<UpdateManifest>;
	if (value.schemaVersion !== 1 || value.channel !== "stable") {
		return { message: "unsupported update manifest schema" };
	}
	if (typeof value.version !== "string" || !matches(value.version, versionPattern)) {
		return { message: "update manifest version is invalid" };
	}
	if (typeof value.revision !== "number" || value.revision < 0 || math.floor(value.revision) !== value.revision) {
		return { message: "update manifest revision is invalid" };
	}
	if (typeof value.publishedAt !== "string" || value.publishedAt.length > 64) {
		return { message: "update manifest publication time is invalid" };
	}
	if (typeof value.packages !== "object" || value.packages === undefined) {
		return { message: "update manifest packages are missing" };
	}
	if (!hasOnlyKeys(value.packages as object, ["android", "windows-x86", "macos-universal"])) {
		return { message: "update manifest contains unsupported platforms" };
	}
	const packages = {} as Record<UpdatePlatform, UpdatePackage>;
	for (const platform of ["android", "windows-x86", "macos-universal"] as UpdatePlatform[]) {
		const packageResult = parsePackage(
			(value.packages as Partial<Record<UpdatePlatform, UpdatePackage>>)[platform],
			platform,
			value.version,
			value.revision,
		);
		if (!packageResult.item) return { message: packageResult.message };
		packages[platform] = packageResult.item;
	}
	return {
		manifest: {
			schemaVersion: 1,
			channel: "stable",
			version: value.version,
			revision: value.revision,
			publishedAt: value.publishedAt,
			packages,
		},
	};
};

export const loadUpdateManifest = (repoPath: string) => {
	const file = Path(repoPath, "stable.json");
	if (!Content.exist(file)) return { message: "stable.json is missing" } as ManifestParseResult;
	return parseUpdateManifest(Content.load(file));
};

export const updatePlatformForApp = (): UpdatePlatform | undefined => {
	switch (App.platform) {
		case PlatformType.Android:
			return "android";
		case PlatformType.Windows:
			return "windows-x86";
		case PlatformType.macOS:
			return "macos-universal";
		default:
			return undefined;
	}
};

export const compareVersions = (left: string, right: string) => {
	const parse = (value: string) => {
		const [major, minor, patch] = string.match(value, "^v(%d+)%.(%d+)%.(%d+)$");
		return [tonumber(major) ?? 0, tonumber(minor) ?? 0, tonumber(patch) ?? 0];
	};
	const leftParts = parse(left);
	const rightParts = parse(right);
	for (let i = 0; i < 3; i++) {
		if (leftParts[i] !== rightParts[i]) return leftParts[i] < rightParts[i] ? -1 : 1;
	}
	return 0;
};
