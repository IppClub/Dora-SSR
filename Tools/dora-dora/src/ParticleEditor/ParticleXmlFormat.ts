import { ParticleDiagnostic, ParticleDocument, ParticleFields, ParticleRect, ParticleVec2, ParticleVec4, createFireParticleFields, createParticleDocument, validateParticleDocument } from "./ParticleDocument";

export type ParticleLoadResult = {
	document: ParticleDocument;
	diagnostics: ParticleDiagnostic[];
	canSave: boolean;
};

type ScalarField = keyof Pick<ParticleFields,
	"angle" | "angleVariance" | "blendFuncDestination" | "blendFuncSource" | "duration" | "emissionRate" |
	"rotationStart" | "rotationStartVariance" | "rotationEnd" | "rotationEndVariance" |
	"finishParticleSize" | "finishParticleSizeVariance" | "maxParticles" | "particleLifespan" |
	"particleLifespanVariance" | "startParticleSize" | "startParticleSizeVariance"
>;

const scalarTags: Record<string, ScalarField> = {
	B: "angle",
	C: "angleVariance",
	D: "blendFuncDestination",
	E: "blendFuncSource",
	F: "duration",
	G: "emissionRate",
	J: "rotationStart",
	K: "rotationStartVariance",
	L: "rotationEnd",
	M: "rotationEndVariance",
	N: "finishParticleSize",
	O: "finishParticleSizeVariance",
	P: "maxParticles",
	Q: "particleLifespan",
	R: "particleLifespanVariance",
	W: "startParticleSize",
	X: "startParticleSizeVariance",
};

const formatNumber = (value: number) => {
	if (!Number.isFinite(value)) return "0";
	const rounded = Math.round(value * 1000000) / 1000000;
	return Object.is(rounded, -0) ? "0" : String(rounded);
};

const escapeAttr = (value: string) => value
	.replace(/&/g, "&amp;")
	.replace(/"/g, "&quot;")
	.replace(/</g, "&lt;")
	.replace(/>/g, "&gt;");

const parseNumber = (value: string, path: string, diagnostics: ParticleDiagnostic[]) => {
	const trimmed = value.trim();
	if (trimmed === "") {
		diagnostics.push({ severity: "error", path, message: "Missing numeric value." });
		return 0;
	}
	const result = Number(trimmed);
	if (!Number.isFinite(result)) {
		diagnostics.push({ severity: "error", path, message: `Invalid number: ${value}` });
		return 0;
	}
	return result;
};

const parseVec = (value: string, count: 2 | 4, path: string, diagnostics: ParticleDiagnostic[]) => {
	const tokens = value.split(",").map((item) => item.trim());
	if (tokens.length !== count) {
		diagnostics.push({ severity: "error", path, message: `Expected ${count} comma-separated values.` });
	}
	const values = Array.from({ length: count }, (_, index) => parseNumber(tokens[index] ?? "0", `${path}[${index}]`, diagnostics));
	return values;
};

const vec2 = (value: string, path: string, diagnostics: ParticleDiagnostic[]): ParticleVec2 => {
	const values = parseVec(value, 2, path, diagnostics);
	return { x: values[0], y: values[1] };
};

const vec4 = (value: string, path: string, diagnostics: ParticleDiagnostic[]): ParticleVec4 => {
	const values = parseVec(value, 4, path, diagnostics);
	return { x: values[0], y: values[1], z: values[2], w: values[3] };
};

const rect = (value: string, path: string, diagnostics: ParticleDiagnostic[]): ParticleRect => {
	const values = parseVec(value, 4, path, diagnostics);
	return { x: values[0], y: values[1], width: values[2], height: values[3] };
};

const attr = (element: Element) => element.getAttribute("A") ?? "";

export const loadParticleDocumentFromXml = (xmlText: string): ParticleLoadResult => {
	const diagnostics: ParticleDiagnostic[] = [];
	const fields = createFireParticleFields();
	let xml: XMLDocument;
	try {
		xml = new DOMParser().parseFromString(xmlText, "application/xml");
	} catch (error) {
		return {
			document: createParticleDocument(),
			diagnostics: [{ severity: "error", path: "$", message: error instanceof Error ? error.message : "Failed to parse particle XML." }],
			canSave: false,
		};
	}
	const parserError = xml.querySelector("parsererror");
	if (parserError) {
		return {
			document: createParticleDocument(),
			diagnostics: [{ severity: "error", path: "$", message: parserError.textContent ?? "Failed to parse particle XML." }],
			canSave: false,
		};
	}
	const root = xml.documentElement;
	if (!root || root.tagName !== "A") {
		return {
			document: createParticleDocument(),
			diagnostics: [{ severity: "error", path: "$", message: "Particle XML root must be <A>." }],
			canSave: false,
		};
	}
	for (const element of Array.from(root.children)) {
		const tag = element.tagName;
		const value = attr(element);
		if (Object.prototype.hasOwnProperty.call(scalarTags, tag)) {
			(fields[scalarTags[tag]] as number) = parseNumber(value, tag, diagnostics);
			continue;
		}
		switch (tag) {
			case "H": fields.finishColor = vec4(value, tag, diagnostics); break;
			case "I": fields.finishColorVariance = vec4(value, tag, diagnostics); break;
			case "S": fields.startPosition = vec2(value, tag, diagnostics); break;
			case "T": fields.startPositionVariance = vec2(value, tag, diagnostics); break;
			case "U": fields.startColor = vec4(value, tag, diagnostics); break;
			case "V": fields.startColorVariance = vec4(value, tag, diagnostics); break;
			case "Y": fields.textureName = value; break;
			case "Z": fields.textureRect = rect(value, tag, diagnostics); break;
			case "a": fields.emitterMode = parseNumber(value, tag, diagnostics) === 1 ? "radius" : "gravity"; break;
			case "b": fields.gravity.rotationIsDir = parseNumber(value, tag, diagnostics) !== 0; break;
			case "c": fields.gravity.gravity = vec2(value, tag, diagnostics); break;
			case "d": fields.gravity.speed = parseNumber(value, tag, diagnostics); break;
			case "e": fields.gravity.speedVariance = parseNumber(value, tag, diagnostics); break;
			case "f": fields.gravity.radialAcceleration = parseNumber(value, tag, diagnostics); break;
			case "g": fields.gravity.radialAccelVariance = parseNumber(value, tag, diagnostics); break;
			case "h": fields.gravity.tangentialAcceleration = parseNumber(value, tag, diagnostics); break;
			case "i": fields.gravity.tangentialAccelVariance = parseNumber(value, tag, diagnostics); break;
			case "j": fields.radius.startRadius = parseNumber(value, tag, diagnostics); break;
			case "k": fields.radius.startRadiusVariance = parseNumber(value, tag, diagnostics); break;
			case "l": fields.radius.finishRadius = parseNumber(value, tag, diagnostics); break;
			case "m": fields.radius.finishRadiusVariance = parseNumber(value, tag, diagnostics); break;
			case "n": fields.radius.rotatePerSecond = parseNumber(value, tag, diagnostics); break;
			case "o": fields.radius.rotatePerSecondVariance = parseNumber(value, tag, diagnostics); break;
			default:
				diagnostics.push({ severity: "warning", path: tag, message: `Unknown particle tag <${tag}> was ignored.` });
				break;
		}
	}
	fields.maxParticles = Math.max(0, Math.trunc(fields.maxParticles));
	fields.blendFuncDestination = Math.trunc(fields.blendFuncDestination);
	fields.blendFuncSource = Math.trunc(fields.blendFuncSource);
	const document: ParticleDocument = {
		version: 1,
		source: "par",
		fields,
		dirty: false,
	};
	const allDiagnostics = [...diagnostics, ...validateParticleDocument(document)];
	return {
		document,
		diagnostics: allDiagnostics,
		canSave: diagnostics.every((item) => item.severity !== "error"),
	};
};

const tag = (name: string, value: string | number) => `<${name} A="${escapeAttr(String(value))}"/>`;
const tagVec2 = (name: string, value: ParticleVec2) => tag(name, `${formatNumber(value.x)},${formatNumber(value.y)}`);
const tagVec4 = (name: string, value: ParticleVec4) => tag(name, `${formatNumber(value.x)},${formatNumber(value.y)},${formatNumber(value.z)},${formatNumber(value.w)}`);
const tagRect = (name: string, value: ParticleRect) => tag(name, `${formatNumber(value.x)},${formatNumber(value.y)},${formatNumber(value.width)},${formatNumber(value.height)}`);

export const writeParticleDocumentToXml = (document: ParticleDocument) => {
	const f = document.fields;
	const parts = [
		"<A>",
		tag("B", formatNumber(f.angle)),
		tag("C", formatNumber(f.angleVariance)),
		tag("D", Math.trunc(f.blendFuncDestination)),
		tag("E", Math.trunc(f.blendFuncSource)),
		tag("F", formatNumber(f.duration)),
		tag("G", formatNumber(f.emissionRate)),
		tagVec4("H", f.finishColor),
		tagVec4("I", f.finishColorVariance),
		tag("J", formatNumber(f.rotationStart)),
		tag("K", formatNumber(f.rotationStartVariance)),
		tag("L", formatNumber(f.rotationEnd)),
		tag("M", formatNumber(f.rotationEndVariance)),
		tag("N", formatNumber(f.finishParticleSize)),
		tag("O", formatNumber(f.finishParticleSizeVariance)),
		tag("P", Math.max(0, Math.trunc(f.maxParticles))),
		tag("Q", formatNumber(f.particleLifespan)),
		tag("R", formatNumber(f.particleLifespanVariance)),
		tagVec2("S", f.startPosition),
		tagVec2("T", f.startPositionVariance),
		tagVec4("U", f.startColor),
		tagVec4("V", f.startColorVariance),
		tag("W", formatNumber(f.startParticleSize)),
		tag("X", formatNumber(f.startParticleSizeVariance)),
		tag("Y", f.textureName),
		tagRect("Z", f.textureRect),
		tag("a", f.emitterMode === "radius" ? 1 : 0),
	];
	if (f.emitterMode === "gravity") {
		parts.push(
			tag("b", f.gravity.rotationIsDir ? 1 : 0),
			tagVec2("c", f.gravity.gravity),
			tag("d", formatNumber(f.gravity.speed)),
			tag("e", formatNumber(f.gravity.speedVariance)),
			tag("f", formatNumber(f.gravity.radialAcceleration)),
			tag("g", formatNumber(f.gravity.radialAccelVariance)),
			tag("h", formatNumber(f.gravity.tangentialAcceleration)),
			tag("i", formatNumber(f.gravity.tangentialAccelVariance)),
		);
	} else {
		parts.push(
			tag("j", formatNumber(f.radius.startRadius)),
			tag("k", formatNumber(f.radius.startRadiusVariance)),
			tag("l", formatNumber(f.radius.finishRadius)),
			tag("m", formatNumber(f.radius.finishRadiusVariance)),
			tag("n", formatNumber(f.radius.rotatePerSecond)),
			tag("o", formatNumber(f.radius.rotatePerSecondVariance)),
		);
	}
	parts.push("</A>\n");
	return parts.join("");
};
