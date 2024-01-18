import * as CircleButton from "UI/Control/Basic/CircleButton";
import * as AlignNode from "UI/Control/Basic/AlignNode";
import { HAlignMode, VAlignMode } from "UI/Control/Basic/AlignNode";
import * as ScrollArea from "UI/Control/Basic/ScrollArea";
import { AlignMode } from "UI/Control/Basic/ScrollArea";
import * as LineRect from 'UI/View/Shape/LineRect';
import * as YarnRunner from "YarnRunner";
import { App, Content, Label, Menu, Path, Size, Slot, TextAlign, TypeName, Vec2, View, thread, threadLoop, tolua } from "dora";
import { SetCond, WindowFlag } from "ImGui";
import * as ImGui from 'ImGui';

const testFile = Path("Test", "tutorial.yarn");

const {width: viewWidth, height: viewHeight} = View.size;

const width = viewWidth - 200;
const height = viewHeight - 20;

const fontSize = math.floor(20 * App.devicePixelRatio);

let texts: string[] = [];

const alignNode = AlignNode({isRoot: true, inUI: false});
const root = AlignNode({alignWidth: "w", alignHeight: "h"}).addTo(alignNode);
const scroll = ScrollArea({
	width,
	height,
	paddingX: 0,
	paddingY: 50,
	viewWidth: height,
	viewHeight: height
});
scroll.addTo(root);

let border = LineRect({width, height, color: 0xffffffff});
scroll.area.addChild(border);
scroll.slot("AlignLayout", (w: number, h: number) => {
	scroll.position = Vec2(w / 2, h / 2);
	w -= 200;
	h -= 20;
	const label = tolua.cast(scroll.view.children.first, TypeName.Label);
	if (label !== null) {
		label.textWidth = w - fontSize;
	}
	scroll.adjustSizeWithAlign(AlignMode.Auto, 10, Size(w, h));
	scroll.area.removeChild(border);
	border = LineRect({width: w, height: h, color: 0xffffffff});
	scroll.area.addChild(border);
});
const label = Label("sarasa-mono-sc-regular", fontSize)?.addTo(scroll.view);
if (label) {
	label.alignment = TextAlign.Left;
	label.textWidth = width - fontSize;
	label.text = "";
}

const control = AlignNode({
	hAlign: HAlignMode.Center,
	vAlign: VAlignMode.Bottom,
	alignOffset: Vec2(0, 200)
}).addTo(alignNode);

const commands = setmetatable({}, {
	__index: (name: string) => (...args: any) => {
		const argStrs = [];
		for (let i = 1; i <= select('#', args); i++) {
			argStrs.push(tostring(select(i, args)));
		}
		const msg = "[command]: " + name + " " + table.concat(argStrs, ', ');
		coroutine.yield("Command", msg);
	}
});

let runner = YarnRunner(testFile, "Start", {}, commands, true);

const menu = Menu().addTo(control);

const setButtons = (options?: number) => {
	menu.removeAllChildren();
	const buttons = options ?? 1;
	menu.size = Size(140 * buttons, 140);
	for (let i = 1; i <= buttons; i++) {
		const circleButton = CircleButton({
			text: options ? i.toString() : "Next",
			radius: 60,
			fontSize: 40
		}).addTo(menu);
		circleButton.slot(Slot.Tapped, () => {
			advance(options);
		});
	}
	menu.alignItems();
};

const advance = (option?: number) => {
	const [action, result] = runner.advance(option);
	if (action === "Text") {
		let charName = "";
		if (result.marks !== null) {
			for (let mark of result.marks) {
				if (mark.name === "char" && mark.attrs !== undefined) {
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
	if (!label) return;
	label.text = table.concat(texts, "\n")
	root.alignLayout();
	thread(() => {
		scroll.scrollToPosY(label.y - label.height / 2);
		return true;
	});
};

alignNode.alignLayout();
advance();

const testFiles = [testFile];
const files = [testFile];
for (let file of Content.getAllFiles(Content.writablePath)) {
	if ("yarn" !== Path.getExt(file)) {
		continue;
	}
	testFiles.push(Path(Content.writablePath, file));
	files.push(Path.getFilename(file));
}

let currentFile = 1;
const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove
];
threadLoop(() => {
	const {width} = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(200, 0), SetCond.Always);
	ImGui.Begin("Yarn Test", windowFlags, () => {
		ImGui.Text("Yarn Tester");
		ImGui.Separator();
		let changed = false;
		[changed, currentFile] = ImGui.Combo("File", currentFile, files);
		if (changed) {
			runner = YarnRunner(testFiles[currentFile], "Start", {}, commands, true);
			texts = [];
			advance();
		}
		ImGui.Text("Variables");
		ImGui.Separator();
		for (let [k, v] of pairs(runner.state)) {
			ImGui.Text(`${k}: ${v}`);
		}
	});
	return false;
});
