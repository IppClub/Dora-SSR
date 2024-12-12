// @preview-file on clear
import { React, toNode } from 'DoraX';
import { App, Color, TypeName, Vec2, threadLoop, tolua } from 'Dora';
import { WindowFlag, SetCond } from "ImGui";
import * as ImGui from "ImGui";

toNode(
	<draw-node>
		<rect-shape width={5000} height={5000} fillColor={0xff000000}/>
	</draw-node>
);

let outlineColor = Color(0xffff0088);
let outlineWidth = 0.16;
let scale = 3;

const start = App.elapsedTime;

const node = toNode(
	<label
		fontName='sarasa-mono-sc-regular' sdf fontSize={50} textWidth={800}
		color3={0xfbc400} outlineColor={outlineColor.toARGB()} outlineWidth={outlineWidth}
		scaleX={scale} scaleY={scale} showDebug
	>
		Dora SSR is a game engine for rapid development of games on various devices. It has a built-in easy-to-use Web IDE development tool chain that supports direct game development on mobile phones, open source handhelds and other devices. Dora SSR 是一个用于多种设备上快速开发游戏的游戏引擎。它内置易用的 Web IDE 开发工具链，支持在手机、开源掌机等设备上直接进行游戏开发。
	</label>
);

print(`label bake time: ${App.elapsedTime - start} s`);

const label = tolua.cast(node, TypeName.Label);
if (!label) error("failed");
let {x: edgeA, y: edgeB} = label.smooth;

const windowFlags = [
	WindowFlag.NoResize,
	WindowFlag.NoSavedSettings
];
threadLoop(() => {
	const {width} = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.FirstUseEver, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(240, 520), SetCond.FirstUseEver);
	ImGui.Begin("SDF", windowFlags, () => {
		ImGui.Text("SDF Label");
		let changed = false;
		[changed, edgeA, edgeB] = ImGui.DragFloat2("Edge", edgeA, edgeB, 0.01, 0, 1, "%.2f");
		if (changed) {
			label.smooth = Vec2(edgeA, edgeB);
		}
		[changed, scale] = ImGui.DragFloat("Scale", scale, 0.1, 0.5, 20);
		if (changed) {
			label.scaleX = label.scaleY = scale;
		}
		if (ImGui.ColorEdit4("LColor", outlineColor)) {
			label.outlineColor = outlineColor;
		}
		[changed, outlineWidth] = ImGui.DragFloat("LWidth", outlineWidth, 0.01, 0, 0.3);
		if (changed) {
			label.outlineWidth = outlineWidth;
		}
	});
	return false;
});
