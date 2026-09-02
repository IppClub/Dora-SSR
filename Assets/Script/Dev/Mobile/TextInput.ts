import { App, ClipNode, Color, Color3, DrawNode, Keyboard, KeyName, Label, Node, Size, sleep, TextAlign, thread, Vec2 } from "Dora";
import * as nvg from "nvg";

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

export function createTextInputView(input: Node.Type, fontSize: number, singleLine = false, background = 0xff171c26) {
	const border = Node(); border.tag = `${input.tag}-border`;
	border.color3 = Color3(0x343b48); input.addChild(border, -1);
	input.onRender(() => {
		nvg.Save(); nvg.ApplyTransform(input);
		nvg.BeginPath(); nvg.RoundedRect(0, 0, input.width, input.height, 12);
		nvg.FillPaint(nvg.LinearGradient(0, input.height, 0, 0, Color(0xff242d3b), Color(background)));
		nvg.Fill();
		nvg.BeginPath(); nvg.RoundedRect(0.75, 0.75, input.width - 1.5, input.height - 1.5, 11.25);
		nvg.StrokeWidth(1.5); nvg.StrokeColor(Color(border.color3)); nvg.Stroke(); nvg.Restore();
		return false;
	});
	const insetX = 12, insetY = 8;
	const width = math.max(1, input.width - insetX * 2 - 2);
	const height = math.max(1, input.height - insetY * 2);
	const lineHeight = fontSize + 4;
	const makeLabel = () => {
		const label = Label("sarasa-mono-sc-regular", fontSize, true);
		if (!label) throw new Error("Missing mobile input font");
		label.alignment = TextAlign.Left; label.anchor = Vec2(0, 1); label.textWidth = -1;
		return label;
	};
	// Unparented Dora nodes are auto-attached to Director.entry on the next frame.
	// Own the metrics probe under the input so it never renders or outlives the UI.
	const measure = makeLabel(); measure.tag = "remix-input-measure"; measure.visible = false;
	input.addChild(measure);
	measure.batched = false; measure.text = "M";
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
	const textTop = singleLine ? (height + singleHeight) / 2 : height;
	placeholder.textWidth = singleLine ? -1 : width; placeholder.y = textTop; placeholder.color3 = Color3(0xa8afbd); clip.addChild(placeholder);
	const caret = DrawNode(); caret.tag = "remix-input-caret";
	caret.drawPolygon([Vec2.zero, Vec2(1, 0), Vec2(1, fontSize + 2), Vec2(0, fontSize + 2)], Color(0xffffcc33));
	content.addChild(caret);
	let layout = layoutInput("", width, advance);
	let lastText = "", active = false, blink = 0, offset = 0, index = 0;
	const maxOffset = () => math.max(0, singleLine ? layout.stops[layout.stops.length - 1].x - width : layout.rows * lineHeight - height);
	const position = () => {
		content.x = singleLine ? -offset : 0;
		content.y = singleLine ? 0 : offset; label.y = textTop;
		const stop = layout.stops[index];
		caret.position = Vec2(singleLine ? stop.x : math.min(width, stop.x), singleLine ? (height - fontSize - 2) / 2 : height - stop.row * lineHeight - fontSize - 2);
	};
	const follow = () => {
		const stop = layout.stops[index];
		if (singleLine) {
			if (stop.x < offset) offset = stop.x;
			if (stop.x > offset + width) offset = stop.x - width;
		} else {
			const top = stop.row * lineHeight;
			if (top < offset) offset = top;
			if (top + lineHeight > offset + height) offset = top + lineHeight - height;
		}
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
		label, caret, placeholder, clip, border,
		update: (text: string, hint: string, focused: boolean, cursor: number) => {
			if (singleLine) text = string.gsub(text, "[\r\n]", "")[0];
			if (lastText !== text) { layout = layoutInput(text, singleLine ? math.huge : width, advance); label.text = layout.text; lastText = text; }
			placeholder.text = hint; placeholder.visible = text === "" && !focused;
			border.color3 = Color3(focused ? 0xffcc33 : 0x343b48);
			active = focused; index = math.max(0, math.min(layout.stops.length - 1, cursor));
			blink = 0; caret.visible = active; follow();
		},
		caretPosition: () => Vec2(insetX + caret.x + content.x, insetY + caret.y + content.y),
		indexAt: (point: Vec2.Type) => nearest(point.x - insetX - content.x, singleLine ? 0 : math.max(0, math.floor((height + offset - (point.y - insetY)) / lineHeight))),
		verticalIndex: (cursor: number, direction: number) => { const stop = layout.stops[math.min(cursor, layout.stops.length - 1)]; return nearest(stop.x, stop.row + direction); },
		scroll: (delta: number) => { offset = math.max(0, math.min(maxOffset(), offset + delta)); position(); },
	};
}

export interface TextInputOptions {
	fontSize: number;
	singleLine?: boolean;
	background?: number;
	isSecure?(): boolean;
	getText(this: void): string;
	setText(this: void, text: string): void;
	getPlaceholder(this: void): string;
	isEnabled(this: void): boolean;
	// Return true to consume Return; otherwise multiline inputs insert a newline.
	onReturn?(this: void, modified: boolean): boolean;
}

// Shared editing/focus lifecycle. Callers own business state, not IME internals.
export function createTextInput(options: TextInputOptions) {
	let node: Node.Type | undefined;
	let view: ReturnType<typeof createTextInputView> | undefined;
	let focused = false, composition = "", compositionCursor = 0, cursor = 0, revision = 0, dragDistance = 0;
	const normalize = (text: string) => options.singleLine ? string.gsub(text, "[\r\n]", "")[0]
		: string.gsub(string.gsub(text, "\r\n", "\n")[0], "\r", "\n")[0];
	const updateIMEPos = (next?: (this: void) => void) => {
		const target = node;
		if (!target || !view) return;
		const captured = revision;
		const caret = view.caretPosition();
		target.convertToWindowSpace(Vec2(math.max(12, math.min(target.width - 12, caret.x)), math.max(8, math.min(target.height - 8, caret.y))), pos => {
			if (node !== target || captured !== revision || !options.isEnabled()) return;
			Keyboard.updateIMEPosHint(pos); next?.();
		});
	};
	const refresh = () => {
		const text = options.getText();
		cursor = math.min(cursor, inputLength(text));
		const editing = insertInputText(text, cursor, composition);
		const display = options.isSecure?.() ? string.rep("•", inputLength(editing)) : editing;
		view?.update(display, options.getPlaceholder(), focused, cursor + compositionCursor);
		if (focused) updateIMEPos();
	};
	const clearFocus = () => {
		revision++; focused = false; composition = ""; compositionCursor = 0;
		if (node) node.keyboardEnabled = false;
		refresh();
	};
	const blur = () => { if (focused) node?.detachIME(); clearFocus(); };
	const focus = (reopen = true) => {
		if (!options.isEnabled()) return;
		revision++;
		updateIMEPos(() => {
			if (reopen) node?.detachIME();
			node?.attachIME(); updateIMEPos();
		});
	};
	const setValue = (text: string, at: number) => { options.setText(text); cursor = at; refresh(); };
	const textInput = (text: string) => {
		if (!options.isEnabled()) return;
		composition = ""; compositionCursor = 0;
		const value = normalize(text);
		setValue(insertInputText(options.getText(), cursor, value), cursor + inputLength(value));
	};
	const keyInput = (key: KeyName) => {
		if (!options.isEnabled()) return;
		if (key === KeyName.Escape) { blur(); return; }
		if (composition !== "") return;
		const value = options.getText();
		if (key === KeyName.BackSpace && cursor > 0) setValue(inputSlice(value, 0, cursor - 1) + inputSlice(value, cursor), cursor - 1);
		else if (key === KeyName.Delete && cursor < inputLength(value)) setValue(inputSlice(value, 0, cursor) + inputSlice(value, cursor + 1), cursor);
		else if (key === KeyName.Home || key === KeyName.End || key === KeyName.Left || key === KeyName.Right || key === KeyName.Up || key === KeyName.Down) {
			cursor = key === KeyName.Home ? 0 : key === KeyName.End ? inputLength(value)
				: key === KeyName.Up || key === KeyName.Down ? view?.verticalIndex(cursor, key === KeyName.Up ? -1 : 1) ?? cursor
				: math.max(0, math.min(inputLength(value), cursor + (key === KeyName.Left ? -1 : 1)));
			refresh();
		} else if (key === KeyName.Return) {
			const modified = Keyboard.isKeyPressed(KeyName.LCtrl) || Keyboard.isKeyPressed(KeyName.RCtrl) || Keyboard.isKeyPressed(KeyName.LGui) || Keyboard.isKeyPressed(KeyName.RGui);
			if (!options.onReturn?.(modified) && !options.singleLine) textInput("\n");
		}
	};
	const unmount = () => { blur(); node = undefined; view = undefined; };
	return {
		refresh, focus, blur, unmount,
		pasteFromClipboard: (replace = false) => {
			if (!options.isEnabled()) return false;
			const value = normalize(App.getClipboardText());
			if (value === "") return false;
			if (replace) setValue(value, inputLength(value));
			else textInput(value);
			return true;
		},
		isFocused: () => focused,
		isComposing: () => composition !== "",
		deferFocus: () => {
			const captured = revision;
			thread(() => { sleep(0); if (captured === revision) focus(); });
		},
		mount: (target: Node.Type) => {
			unmount(); node = target;
			view = createTextInputView(target, options.fontSize, options.singleLine, options.background);
			target.touchEnabled = true; target.swallowTouches = true;
			target.onAttachIME(() => { focused = true; composition = ""; compositionCursor = 0; target.keyboardEnabled = true; refresh(); });
			target.onDetachIME(clearFocus);
			target.onTextInput(textInput);
			target.onTextEditing((text, start) => {
				if (!options.isEnabled()) return;
				composition = normalize(text); compositionCursor = math.max(0, math.min(inputLength(composition), start ?? inputLength(composition))); refresh();
			});
			target.onKeyDown(keyInput); target.keyboardEnabled = false;
			target.onTapBegan(() => { dragDistance = 0; });
			target.onTapMoved(touch => {
				if (!options.isEnabled()) return;
				dragDistance += math.abs(touch.delta.x) + math.abs(touch.delta.y);
				view?.scroll(options.singleLine ? -touch.delta.x : touch.delta.y); if (focused) updateIMEPos();
			});
			target.onMouseWheel(delta => { if (!options.isEnabled()) return; view?.scroll(-delta.y * 20); if (focused) updateIMEPos(); });
			target.onTapped(touch => {
				if (dragDistance > 5 || !options.isEnabled()) return;
				if (touch !== undefined && composition === "") cursor = view?.indexAt(touch.location) ?? cursor;
				refresh(); if (!focused) focus();
			});
			target.onCleanup(() => { if (node === target) unmount(); });
			refresh();
		},
	};
}
