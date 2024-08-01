// @preview-file on
import { React, toNode, useRef } from 'DoraX';
import { App, BlendFunc, BlendOp, Buffer, Cache, Color, Content, Label, Line, Node, Opacity, Path, RenderTarget, Sprite, TextureFilter, TypeName, Vec2, View, thread, threadLoop, tolua } from 'Dora';
import { InputTextFlag, SetCond, WindowFlag } from "ImGui";
import * as ImGui from 'ImGui';
import Packer, { Block } from './TexturePacker/Packer';
import * as Ruler from 'UI/Control/Basic/Ruler';

function getAllClipFolders(this: void) {
	const folders: string[] = [];
	function visitFolders(this: void, parent: string) {
		for (let dir of Content.getDirs(parent)) {
			const path = Path(parent, dir);
			if (Path.getExt(path) === 'clips') {
				folders.push(path);
			} else {
				visitFolders(path);
			}
		}
	}
	visitFolders(Content.writablePath);
	return folders;
}

const clipFolders = getAllClipFolders();
const clipNames = clipFolders.map(f => Path.getFilename(f));

let currentDisplay: Node.Type | null = null;
let currentFolder: string | null = null;

const pixelRatio = App.devicePixelRatio;
let scaledSize = 1;
const ruler = Ruler({y: -150 * pixelRatio, width: pixelRatio * 300, height: 75 * pixelRatio, fontSize: 15 * pixelRatio});
ruler.order = 2;

let filterMode = 1;

if (clipFolders.length > 0) {
	displayClips(clipFolders[0]);
}

function getLabel(this: void, text: string) {
	const label = Label("sarasa-mono-sc-regular", math.tointeger(24 * pixelRatio));
	if (label) {
		label.text = text;
	}
	return label;
}

function displayClips(this: void, folder: string) {
	if (currentFolder === folder) {
		return;
	}
	scaledSize = 1;
	ruler.value = 1;
	currentFolder = folder;
	const name = Path.getName(folder);
	const path = Path.getPath(folder);
	const clipFile = Path(path, name + '.clip');
	const pngFile = Path(path, name + '.png');
	currentDisplay?.removeFromParent();
	if (Content.exist(clipFile) && Content.exist(pngFile)) {
		Cache.load(clipFile);
		const sprite = Sprite(clipFile);
		if (sprite) {
			sprite.filter = filterMode === 1 ? TextureFilter.Anisotropic : TextureFilter.Point;
			const frame = Line([
				Vec2.zero,
				Vec2(sprite.width, 0),
				Vec2(sprite.width, sprite.height),
				Vec2(0, sprite.height),
				Vec2.zero
			], Color(0x44ffffff)).addTo(sprite);
			const rects = Sprite.getClips(clipFile);
			if (rects) {
				for (let [, rc] of rects) {
					frame.addChild(Line([
						Vec2(rc.left, rc.bottom),
						Vec2(rc.right, rc.bottom),
						Vec2(rc.right, rc.top),
						Vec2(rc.left, rc.top),
						Vec2(rc.left, rc.bottom)
					], Color(0xffffffff)));
				}
			}
			frame.scaleY = -1;
			frame.y = sprite.height;
			currentDisplay = sprite;
		} else {
			currentDisplay = getLabel("Failed to load clip file.");
		}
		Cache.unload(clipFile);
	} else {
		currentDisplay = getLabel("Needs generating.");
	}
}

function generateClips(this: void, folder: string) {
	scaledSize = 1;
	ruler.value = 1;
	const padding = 2;
	const blocks: Block[] = [];
	const blendFunc = BlendFunc(BlendOp.One, BlendOp.Zero);
	for (let file of Content.getAllFiles(folder)) {
		switch (Path.getExt(file)) {
			case "png": case "jpg": case "dds": case "pvr": case "ktx": {
				const path = Path(folder, file);
				Cache.unload(path);
				const sp = Sprite(path);
				if (!sp) continue;
				sp.filter = TextureFilter.Point;
				sp.blendFunc = blendFunc;
				sp.anchor = Vec2.zero;
				blocks.push({
					w: sp.width + padding * 2,
					h: sp.height + padding * 2,
					sp,
					name: Path.getName(file)
				});
				Cache.unload(path);
			}
		}
	}
	currentDisplay?.removeFromParent();
	if (blocks.length === 0) {
		currentDisplay = getLabel("No content.");
		return;
	}
	const packer = Packer();
	packer.fit(blocks);
	if (packer.root === undefined) {
		return;
	}
	const {w: width, h: height} = packer.root;
	const frame = Line([
		Vec2.zero,
		Vec2(width, 0),
		Vec2(width, height),
		Vec2(0, height),
		Vec2.zero
	], Color(0x44ffffff));

	const node = Node();
	for (let block of blocks) {
		if (block.fit && block.sp) {
			const x = block.fit.x + padding;
			const y = height - block.fit.y - block.h + padding;
			const w = block.sp.width;
			const h = block.sp.height;
			frame.addChild(Line([
				Vec2(x, y),
				Vec2(x + w, y),
				Vec2(x + w, y + h),
				Vec2(x, y + h),
				Vec2(x, y)
			]));
			block.sp.position = Vec2(x, y);
			node.addChild(block.sp);
		}
	}
	if (!node.hasChildren) {
		node.cleanup();
		return;
	}

	const target = RenderTarget(math.tointeger(width), math.tointeger(height));
	target.renderWithClear(node, Color(0x0));
	node.visible = false;
	node.cleanup();

	const outputName = Path.getName(folder);

	let xml = `<A A="${Path.getName(folder)}.png">`
	for (let block of blocks) {
		if (block.fit === undefined) continue;
		xml += `<B A="${block.name}" B="${block.fit.x + padding},${block.fit.y + padding},${block.w - padding * 2},${block.h - padding * 2}"/>`;
	}
	xml += "</A>";

	const textureFile = Path(Path.getPath(folder), outputName + ".png");
	const clipFile = Path(Path.getPath(folder), outputName + ".clip");
	thread(() => {
		Content.saveAsync(clipFile, xml);
		target.saveAsync(textureFile);
	});

	const displaySprite = Sprite(target.texture);
	displaySprite.filter = filterMode === 1 ? TextureFilter.Anisotropic : TextureFilter.Point;
	displaySprite.addChild(frame);
	displaySprite.runAction(Opacity(0.3, 0, 1));
	currentDisplay = displaySprite;
}

const length = Vec2(App.visualSize).length;
let tapCount = 0;
toNode(
	<node order={1}
		onTapBegan={() => {
			tapCount++;
		}}
		onTapEnded={() => {
			tapCount--;
		}}
		onTapMoved={(touch) => {
			if (currentDisplay) {
				currentDisplay.position = currentDisplay.position.add(touch.delta);
			}
		}}
		onGesture={(_center, fingers, deltaDist, _deltaAngle) => {
			if (tapCount > 0) return;
			if (currentDisplay && tolua.cast(currentDisplay, TypeName.Sprite) && fingers === 2) {
				const {width, height} = currentDisplay;
				const size = Vec2(width, height).length;
				scaledSize += deltaDist * length * 10 / size;
				scaledSize = math.max(0.5, scaledSize);
				scaledSize = math.min(5, scaledSize);
				currentDisplay.scaleX = currentDisplay.scaleY = scaledSize;
			}
		}}
	/>
);

let current = 1;
const filterBuf = Buffer(20);
const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove
];
const inputTextFlags = [InputTextFlag.AutoSelectAll];
let filteredNames = clipNames;
let filteredFolders = clipFolders;
let scaleChecked = false;
threadLoop(() => {
	const {width} = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(200, 0), SetCond.Always);
	ImGui.Begin("Texture Packer", windowFlags, () => {
		ImGui.Text("Texture Packer");
		ImGui.Separator();
		if (ImGui.InputText('Filter', filterBuf, inputTextFlags)) {
			const filterText = filterBuf.text;
			if (filterText === "") {
				filteredNames = clipNames;
				filteredFolders = clipFolders;
				current = 1;
				if (filteredFolders.length > 0) {
					displayClips(filteredFolders[current - 1]);
				}
			} else {
				const filtered = clipNames.map((n, i) => [n, clipFolders[i]]).filter((it, i) => {
					const [matched] = string.match(it[0].toLowerCase(), filterText);
					if (matched !== undefined) {
						return true;
					}
					return false;
				});
				filteredNames = filtered.map(f => f[0]);
				filteredFolders = filtered.map(f => f[1]);
				current = 1;
				if (filteredFolders.length > 0) {
					displayClips(filteredFolders[current - 1]);
				}
			}
		}
		if (filteredNames.length > 0) {
			let changed = false;
			[changed, current] = ImGui.Combo("File", current, filteredNames);
			if (changed) {
				displayClips(filteredFolders[current - 1]);
			}
			if (ImGui.Button("Generate")) {
				generateClips(filteredFolders[current - 1]);
			}
		}
		ImGui.Separator();
		ImGui.Text("Display");
		let changed = false;
		[changed, filterMode] = ImGui.RadioButton("Anisotropic", filterMode, 1);
		if (changed) {
			const sprite = tolua.cast(currentDisplay, TypeName.Sprite);
			if (sprite) {
				sprite.filter = filterMode === 1 ? TextureFilter.Anisotropic : TextureFilter.Point;
			}
		}
		[changed, filterMode] = ImGui.RadioButton("Point", filterMode, 2);
		if (changed) {
			const sprite = tolua.cast(currentDisplay, TypeName.Sprite);
			if (sprite) {
				sprite.filter = filterMode === 1 ? TextureFilter.Anisotropic : TextureFilter.Point;
			}
		}
		ImGui.Separator();
		changed = false;
		[changed, scaleChecked] = ImGui.Checkbox("Scale Helper", scaleChecked);
		if (changed) {
			if (scaleChecked) {
				ruler.show(scaledSize, 0.5, 5.0, 1, (value) => {
					scaledSize = value;
					if (currentDisplay && tolua.cast(currentDisplay, TypeName.Sprite)) {
						currentDisplay.scaleX = currentDisplay.scaleY = scaledSize;
					}
				});
			} else {
				ruler.hide();
			}
		}
	});
	return false;
});
