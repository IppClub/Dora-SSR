/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// @preview-file on

import { React, toNode } from 'DoraX';
import { App, BlendFunc, BlendOp, Buffer, Cache, Color, Content, Label, Line, Node, Opacity, Path, RenderTarget, Sprite, TextureFilter, TypeName, Vec2, thread, threadLoop, tolua, Mouse } from 'Dora';
import { InputTextFlag, SetCond, WindowFlag } from "ImGui";
import * as ImGui from 'ImGui';
import Packer, { Block } from 'Script/Tools/TexturePacker/Packer';
import * as Ruler from 'UI/Control/Basic/Ruler';

let zh = false;
{
	const [res] = string.match(App.locale, "^zh");
	zh = res !== null;
}

function getAllClipFolders() {
	const folders: string[] = [];
	function visitFolders(parent: string) {
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

let anisotropic = true;
let clipHover = "-";

if (clipFolders.length > 0) {
	displayClips(clipFolders[0]);
}

function getLabel(text: string) {
	const label = Label("sarasa-mono-sc-regular", math.floor(24 * pixelRatio));
	if (label) {
		label.text = text;
	}
	return label;
}

function displayClips(folder: string) {
	if (currentFolder === folder) {
		return;
	}
	scaledSize = 1;
	ruler.value = 1;
	clipHover = "-";
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
			sprite.filter = anisotropic ? TextureFilter.Anisotropic : TextureFilter.Point;
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
			if (rects) {
				frame.schedule(() => {
					const {width: bw, height: bh} = App.bufferSize;
					const {width: vw} = App.visualSize;
					let pos = Mouse.position.mul(bw / vw);
					pos = Vec2(pos.x - bw / 2, bh / 2 - pos.y);
					const localPos = frame.convertToNodeSpace(pos);
					clipHover = "-";
					for (let [name, rc] of rects) {
						if (rc.containsPoint(localPos)) {
							clipHover = name;
						}
					}
					return false;
				});
			}
			currentDisplay = sprite;
		} else {
			currentDisplay = getLabel(zh ? "加载 .clip 文件失败。" : "Failed to load .clip file.");
		}
	} else {
		currentDisplay = getLabel(zh ? "未生成文件。" : "Needs generating.");
	}
}

function generateClips(folder: string) {
	scaledSize = 1;
	ruler.value = 1;
	clipHover = "-";
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
		currentDisplay = getLabel(zh ? "没有文件。" : "No content.");
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

	const target = RenderTarget(math.floor(width), math.floor(height));
	target.renderWithClear(node, Color(0x0));
	node.visible = false;
	node.removeAllChildren();
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
		Cache.unload(textureFile);
		Cache.unload(clipFile);
		const rects = Sprite.getClips(clipFile);
		if (rects) {
			frame.schedule(() => {
				const {width: bw, height: bh} = App.bufferSize;
				const {width: vw} = App.visualSize;
				let pos = Mouse.position.mul(bw / vw);
				pos = Vec2(pos.x - bw / 2, bh / 2 - pos.y);
				const localPos = frame.convertToNodeSpace(pos);
				clipHover = "-";
				for (let [name, rc] of rects) {
					if (rc.containsPoint(Vec2(localPos.x, height - localPos.y))) {
						clipHover = name;
					}
				}
				return false;
			});
		}
	});

	const displaySprite = Sprite(target.texture);
	displaySprite.filter = anisotropic ? TextureFilter.Anisotropic : TextureFilter.Point;
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
	WindowFlag.NoMove,
	WindowFlag.NoScrollWithMouse
];
const inputTextFlags = [InputTextFlag.AutoSelectAll];
let filteredNames = clipNames;
let filteredFolders = clipFolders;
let scaleChecked = false;
const themeColor = App.themeColor;
threadLoop(() => {
	const {width} = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(230, 0), SetCond.Always);
	ImGui.Begin("Texture Packer", windowFlags, () => {
		ImGui.Text(zh ? "纹理打包工具" : "Texture Packer");
		ImGui.SameLine();
		ImGui.TextDisabled("(?)");
		if (ImGui.IsItemHovered()) {
			ImGui.BeginTooltip(() => {
				ImGui.PushTextWrapPos(300, () => {
					ImGui.Text(zh ? "将图像文件（png、jpg、ktx、pvr）放入一个以 '.clips' 结尾的文件夹中，然后重新加载纹理打包工具以找到该文件夹并创建一个打包图像文件。打包后的图像将保存为 '.png' 文件，并生成一个对应的描述文件，保存为 '.clip' 文件。例如，'items.clips' 会变成 'items.png' 和 'items.clip'。" : "Place image files (png, jpg, ktx, pvr) in a folder named with a '.clips' suffix. Reload the texture packer to locate the folder and create a packed image file. The packed image will be saved as a '.png' file, and a corresponding description file will be saved as a '.clip' file. For example, 'items.clips' becomes 'items.png' and 'items.clip'.");
				});
			});
		}
		ImGui.Separator();
		ImGui.InputText('##FilterInput', filterBuf, inputTextFlags);
		ImGui.SameLine();
		if (ImGui.Button(zh ? "筛选" : "Filter")) {
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
			[changed, current] = ImGui.Combo(zh ? "文件" : "File", current, filteredNames);
			if (changed) {
				displayClips(filteredFolders[current - 1]);
			}
			if (ImGui.Button(zh ? "生成切片图集" : "Generate Clip")) {
				generateClips(filteredFolders[current - 1]);
			}
		}
		ImGui.Separator();
		ImGui.Text(zh ? "预览" : "Preview");
		const sprite = tolua.cast(currentDisplay, TypeName.Sprite);
		if (sprite) {
			ImGui.TextColored(themeColor, zh ? "尺寸：" : "Size:");
			ImGui.SameLine();
			ImGui.Text(`${math.floor(sprite.width)} x ${math.floor(sprite.height)}`);
			ImGui.TextColored(themeColor, zh ? "切片名称：" : "Clip Name:");
			ImGui.SameLine();
			ImGui.Text(clipHover);
		}
		let changed = false;
		[changed, anisotropic] = ImGui.Checkbox(zh ? "各向异性过滤" : "Anisotropic", anisotropic);
		if (changed) {
			if (sprite) {
				sprite.filter = anisotropic ? TextureFilter.Anisotropic : TextureFilter.Point;
			}
		}
		ImGui.Separator();
		changed = false;
		[changed, scaleChecked] = ImGui.Checkbox(zh ? "缩放工具" : "Scale Helper", scaleChecked);
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
