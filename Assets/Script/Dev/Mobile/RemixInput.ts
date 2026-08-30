import { App, ClipNode, Color, Color3, DrawNode, Label, Node, Size, TextAlign, Vec2 } from "Dora";

export const inputLength = (text: string) => utf8.len(text)[0] ?? 0;
export const inputSlice = (text: string, start: number, end = inputLength(text)) => {
	const first = utf8.offset(text, start + 1) ?? text.length + 1;
	const last = (utf8.offset(text, end + 1) ?? text.length + 1) - 1;
	return string.sub(text, first, last);
};
export const insertInputText = (text: string, at: number, inserted: string) => inputSlice(text, 0, at) + inserted + inputSlice(text, at);

// Explicit wrapping preserves whitespace and a source-index -> caret mapping.
// Sarasa is monospaced; widths come from the same engine font, not byte counts.
export function layoutInput(text: string, width: number, advance: (this: void, char: string) => number) {
	let x = 0, row = 0;
	const stops = [{ x: 0, row: 0 }];
	const display: string[] = [];
	for (const [, code] of utf8.codes(text)) {
		const char = utf8.char(code);
		if (char === "\n") { display.push(char); row++; x = 0; }
		else {
			const step = advance(char);
			if (x > 0 && x + step > width) {
				display.push("\n"); row++; x = 0;
				stops[stops.length - 1] = { x, row };
			}
			display.push(char); x += step;
		}
		stops.push({ x, row });
	}
	return { text: display.join(""), stops, rows: row + 1 };
}

export function createRemixInputView(input: Node.Type, fontSize: number) {
	const insetX = 12, insetY = 8;
	const width = math.max(1, input.width - insetX * 2 - 2);
	const height = math.max(1, input.height - insetY * 2);
	const lineHeight = fontSize + 4;
	const makeLabel = () => {
		const label = Label("sarasa-mono-sc-regular", fontSize, true);
		if (!label) throw new Error("Missing Remix input font");
		label.alignment = TextAlign.Left; label.anchor = Vec2(0, 1); label.textWidth = -1;
		return label;
	};
	const measure = makeLabel(); measure.batched = false; measure.text = "M";
	// Lua-facing getCharacter is 1-based (the C++ method itself is 0-based).
	const markerX = measure.getCharacter(1)?.x ?? 0;
	const singleHeight = measure.height;
	measure.text = "M\nM";
	const gap = measure.lineGap + lineHeight - (measure.height - singleHeight);
	const widths: Record<string, number> = {};
	const advance = (char: string) => {
		if (widths[char] !== undefined) return widths[char];
		measure.text = char + "M";
		const step = math.max(1, (measure.getCharacter(2)?.x ?? markerX + fontSize) - markerX);
		widths[char] = step;
		return step;
	};
	const stencil = DrawNode();
	stencil.drawPolygon([Vec2.zero, Vec2(width + 2, 0), Vec2(width + 2, height), Vec2(0, height)], Color(0xffffffff));
	const clip = ClipNode(stencil); clip.tag = "remix-input-clip";
	clip.anchor = Vec2.zero; clip.position = Vec2(insetX, insetY); clip.size = Size(width + 2, height);
	input.addChild(clip, 1);
	const content = Node(); content.tag = "remix-input-content"; clip.addChild(content);
	const label = makeLabel(); label.tag = "remix-input-text"; label.lineGap = gap; label.color3 = Color3(0xf4f1e8); content.addChild(label);
	const placeholder = makeLabel(); placeholder.tag = "remix-input-placeholder"; placeholder.lineGap = gap;
	placeholder.textWidth = width; placeholder.y = height; placeholder.color3 = Color3(0xa8afbd); clip.addChild(placeholder);
	const caret = DrawNode(); caret.tag = "remix-input-caret";
	caret.drawPolygon([Vec2.zero, Vec2(1, 0), Vec2(1, fontSize + 2), Vec2(0, fontSize + 2)], Color(0xffffcc33));
	content.addChild(caret);
	let layout = layoutInput("", width, advance);
	let lastText = "", active = false, blink = 0, offset = 0, index = 0;
	const maxOffset = () => math.max(0, layout.rows * lineHeight - height);
	const position = () => {
		content.y = offset; label.y = height;
		const stop = layout.stops[index];
		caret.position = Vec2(math.min(width, stop.x), height - stop.row * lineHeight - fontSize - 2);
	};
	const follow = () => {
		const stop = layout.stops[index];
		const top = stop.row * lineHeight;
		if (top < offset) offset = top;
		if (top + lineHeight > offset + height) offset = top + lineHeight - height;
		offset = math.max(0, math.min(maxOffset(), offset)); position();
	};
	caret.schedule(dt => { blink += dt; caret.visible = active && (blink % 1 < 0.5 || App.reducedMotion); return false; });
	const nearest = (x: number, row: number) => {
		let closest = 0, distance = math.huge;
		layout.stops.forEach((stop, i) => {
			const d = math.abs(stop.row - row) * (width + 1) + math.abs(stop.x - x);
			if (d < distance) { distance = d; closest = i; }
		});
		return closest;
	};
	return {
		label, caret, placeholder, clip,
		update: (text: string, hint: string, focused: boolean, cursor: number) => {
			if (lastText !== text) { layout = layoutInput(text, width, advance); label.text = layout.text; lastText = text; }
			placeholder.text = hint; placeholder.visible = text === "" && !focused;
			active = focused; index = math.max(0, math.min(layout.stops.length - 1, cursor));
			blink = 0; caret.visible = active; follow();
		},
		caretPosition: () => Vec2(insetX + caret.x, insetY + caret.y + offset),
		indexAt: (point: Vec2.Type) => nearest(point.x - insetX, math.max(0, math.floor((height + offset - (point.y - insetY)) / lineHeight))),
		verticalIndex: (cursor: number, direction: number) => { const stop = layout.stops[math.min(cursor, layout.stops.length - 1)]; return nearest(stop.x, stop.row + direction); },
		scroll: (delta: number) => { offset = math.max(0, math.min(maxOffset(), offset + delta)); position(); },
	};
}
