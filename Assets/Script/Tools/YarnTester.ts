/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// @preview-file on clear

import * as CircleButton from "UI/Control/Basic/CircleButton";
import * as ScrollArea from "UI/Control/Basic/ScrollArea";
import { AlignMode } from "UI/Control/Basic/ScrollArea";
import * as LineRect from 'UI/View/Shape/LineRect';
import * as YarnRunner from "YarnRunner";
import type { YarnRunner as Yarn } from "YarnRunner";
import { AlignNode, App, Buffer, Content, Label, Menu, Path, Size, TextAlign, Vec2, View, thread, threadLoop } from "Dora";
import { InputTextFlag, SetCond, WindowFlag } from "ImGui";
import * as ImGui from 'ImGui';

let zh = false;
{
	const [res] = string.match(App.locale, "^zh");
	zh = res !== null;
}

const testFilePaths: string[] = [];
const testFileNames: string[] = [];
for (let file of Content.getAllFiles(Content.writablePath)) {
	if ("yarn" !== Path.getExt(file)) {
		continue;
	}
	testFilePaths.push(Path(Content.writablePath, file));
	testFileNames.push(Path.getFilename(file));
}

let filteredPaths = testFilePaths;
let filteredNames = testFileNames;

let currentFile = 1;

const fontScale = App.devicePixelRatio;
const fontSize = math.floor(20 * fontScale);

let texts: string[] = [];

const root = AlignNode(true);
root.css('flex-direction: column-reverse');

const {width: viewWidth, height: viewHeight} = View.size;
const width = viewWidth - 100;
const height = viewHeight - 10;
const scroll = ScrollArea({
	width,
	height,
	paddingX: 0,
	paddingY: 50,
	viewWidth: height,
	viewHeight: height
});
scroll.addTo(root);

const label = Label("sarasa-mono-sc-regular", fontSize)?.addTo(scroll.view);
if (!label) {
	error("failed to create label!");
}
label.scaleX = 1 / fontScale;
label.scaleY = 1 / fontScale;
label.alignment = TextAlign.Left;

root.onAlignLayout((w: number, h: number) => {
	scroll.position = Vec2(w / 2, h / 2);
	w -= 100;
	h -= 10;
	label.textWidth = (w - fontSize) * fontScale;
	scroll.adjustSizeWithAlign(AlignMode.Auto, 10, Size(w, h));
	scroll.area.getChildByTag('border')?.removeFromParent();
	const border = LineRect({x: 1, y: 1, width: w - 2, height: h - 2, color: 0xffffffff});
	scroll.area.addChild(border, 0, 'border');
});

const control = AlignNode().addTo(root);
control.css("height: 140; margin-bottom: 40");

const menu = Menu().addTo(control);
control.onAlignLayout((w, h) => {
	menu.position = Vec2(w / 2, h / 2);
});

const commands = setmetatable({}, {
	__index(this: {}, name: string) {
		return (...args: any[]) => {
			const argStrs = [];
			for (let i = 0; i < args.length; i++) {
				argStrs.push(tostring(args[i]));
			}
			const msg = "[command]: " + name + " " + table.concat(argStrs, ', ');
			coroutine.yield("Command", msg);
		};
	}
});

let runner: Yarn.Type | null = null;
if (filteredPaths.length > 0) {
	runner = YarnRunner(filteredPaths[currentFile - 1], "Start", {}, commands, true);
}

const setButtons = (options?: number) => {
	menu.removeAllChildren();
	const buttons = options ?? 1;
	menu.size = Size(80 * buttons, 80);
	for (let i = 1; i <= buttons; i++) {
		const circleButton = CircleButton({
			text: options ? i.toString() : "Next",
			radius: 30,
			fontSize: 20
		}).addTo(menu);
		const choice = options ? i : undefined;
		circleButton.onTapped(() => {
			advance(choice);
		});
	}
	menu.alignItems();
};

const advance = (option?: number) => {
	if (!runner) return;
	const [action, result] = runner.advance(option);
	if (action === "Text") {
		let charName = "";
		if (result.marks !== null) {
			for (let mark of result.marks) {
				if ((mark.name === "Character" || mark.name === "char") && mark.attrs !== undefined) {
					charName = `${mark.attrs.name}: `;
				}
			}
		}
		texts.push(charName + result.text);
		if (result.optionsFollowed) {
			advance();
		} else {
			setButtons();
		}
	} else if (action === "Option") {
		for (let [i, op] of ipairs(result)) {
			if (typeof op !== "boolean") {
				texts.push(`[${i}]: ${op.text}`);
			}
		}
		setButtons(result.length);
	} else if (action === "Command") {
		texts.push(result);
		setButtons();
	} else {
		menu.removeAllChildren();
		texts.push(result);
	}
	label.text = table.concat(texts, "\n")
	scroll.adjustSizeWithAlign(AlignMode.Auto, 10);
	thread(() => {
		scroll.scrollToPosY(label.y - label.height / 2);
	});
};

advance();

const filterBuf = Buffer(20);
const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove
];
const inputTextFlags = [InputTextFlag.AutoSelectAll];
threadLoop(() => {
	const {width} = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(230, 0), SetCond.Always);
	ImGui.Begin("Yarn Tester", windowFlags, () => {
		ImGui.Text(zh ? "Yarn 测试工具" : "Yarn Tester");
		ImGui.SameLine();
		ImGui.TextDisabled("(?)");
		if (ImGui.IsItemHovered()) {
			ImGui.BeginTooltip(() => {
				ImGui.PushTextWrapPos(300, () => {
					ImGui.Text(zh ? "重新加载 Yarn 测试工具，以检测任何新添加的以 '.yarn' 结尾的 Yarn Spinner 文件。" : "Reload Yarn Tester to detect any newly added Yarn Spinner files with a '.yarn' extension.");
				});
			});
		}
		ImGui.Separator();
		ImGui.InputText("##FilterInput", filterBuf, inputTextFlags);
		ImGui.SameLine();
		const runFile = () => {
			try {
				runner = YarnRunner(filteredPaths[currentFile - 1], "Start", {}, commands, true);
				texts = [];
				advance();
			} catch (err) {
				label.text = `failed to load file ${filteredPaths[currentFile - 1]}\n${err}`;
				scroll.adjustSizeWithAlign(AlignMode.Auto, 10);
			}
		};
		if (ImGui.Button(zh ? "筛选" : "Filter")) {
			const filterText = filterBuf.text.toLowerCase();
			const filtered = testFileNames.map((n, i) => [n, testFilePaths[i]]).filter((it, i) => {
				const [matched] = string.match(it[0].toLowerCase(), filterText);
				if (matched !== undefined) {
					return true;
				}
				return false;
			});
			filteredNames = filtered.map(f => f[0]);
			filteredPaths = filtered.map(f => f[1]);
			currentFile = 1;
			if (filteredPaths.length > 0) {
				runFile();
			}
		}
		if (filteredNames.length === 0) {
			return;
		}
		let changed = false;
		[changed, currentFile] = ImGui.Combo(zh ? "文件" : "File", currentFile, filteredNames);
		if (changed) {
			runFile();
		}
		if (ImGui.Button(zh ? "重载" : "Reload")) {
			runFile();
		}
		if (runner) {
			ImGui.SameLine();
			ImGui.Text(zh ? "变量：" : "Variables:");
			ImGui.Separator();
			for (let [k, v] of pairs(runner.state)) {
				ImGui.Text(`${k}: ${v}`);
			}
		}
	});
	return false;
});
