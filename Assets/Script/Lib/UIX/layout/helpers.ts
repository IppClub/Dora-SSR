import type { AlignStyle } from "UIX/types";

export function mergeStyle(this: void, base: AlignStyle, override?: AlignStyle): AlignStyle {
	const style: AlignStyle = {};
	for (const [k, v] of pairs(base as unknown as AnyTable)) {
		(style as unknown as AnyTable)[k as string] = v;
	}
	if (override !== undefined) {
		for (const [k, v] of pairs(override as unknown as AnyTable)) {
			(style as unknown as AnyTable)[k as string] = v;
		}
	}
	return style;
}

export function textFromChildren(this: void, children: unknown, fallback?: string): string {
	if (children === undefined) return fallback ?? "";
	if (type(children) === "string" || type(children) === "number") return tostring(children);
	if (type(children) === "table") {
		const list = children as unknown[];
		let text = "";
		for (let i of $range(1, list.length)) {
			const item = list[i - 1];
			if (type(item) === "string" || type(item) === "number") {
				text += tostring(item);
			}
		}
		return text !== "" ? text : fallback ?? "";
	}
	return fallback ?? "";
}
