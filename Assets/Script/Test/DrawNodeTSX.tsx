// @preview-file on
import { React, toNode } from 'dora-x';
import { SetCond, WindowFlag } from "ImGui";
import * as ImGui from "ImGui";
import { App, Vec2, threadLoop } from "dora"

function CircleVertices(this: void, radius: number, verts?: number): Vec2.Type[] {
	const v = verts ?? 20;
	function newV(this: void, index: number, r: number): Vec2.Type {
		const angle = 2 * math.pi * index / v;
		return Vec2(r * math.cos(angle), radius * math.sin(angle)).add(Vec2(r, radius));
	}
	const vs = [];
	for (let index = 0; index <= v; index++) {
		vs.push(newV(index, radius));
	}
	return vs;
}

function StarVertices(this: void, radius: number): Vec2.Type[] {
	const a = math.rad(36);
	const c = math.rad(72);
	const f = math.sin(a) * math.tan(c) + math.cos(a);
	const R = radius;
	const r = R / f;
	const vs = [];
	for (let i = 9; i >= 0; i--) {
		const angle = i * a;
		const cr = i % 2 == 1 ? r : R;
		vs.push(Vec2(cr * math.sin(angle), cr * math.cos(angle)));
	}
	return vs;
}

const themeColor = App.themeColor.toARGB();

toNode(
	<>
		<draw-node x={200} y={200}>
			<polygon-shape verts={StarVertices(60)} fillColor={0x80ff0080} borderWidth={1} borderColor={0xffff0080}/>
		</draw-node>

		<line verts={CircleVertices(60)} lineColor={themeColor} x={-200} y={200}/>

		<node color3={themeColor} scaleX={2} scaleY={2}>
			<draw-node opacity={0.5}>
				<polygon-shape verts={[
					Vec2(-20, -10),
					Vec2(20, -10),
					Vec2(20, 10),
					Vec2(-20, 10)
				]}/>
				<polygon-shape verts={[
					Vec2(20, 3),
					Vec2(32, 10),
					Vec2(32, -10),
					Vec2(20, -3)
				]}/>
				<dot-shape x={-11} y={20} radius={10}/>
				<dot-shape x={11} y={20} radius={10}/>
			</draw-node>

			<line verts={CircleVertices(10)} x={-21} y={10}/>
			<line verts={CircleVertices(10)} x={1} y={10}/>
			<line verts={[
				Vec2(20, 3),
				Vec2(32, 10),
				Vec2(32, -10),
				Vec2(20, -3)
			]}/>
		</node>
	</>
);

const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.AlwaysAutoResize,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove
];
threadLoop(() => {
	const { width } = App.visualSize;
	ImGui.SetNextWindowBgAlpha(0.35);
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(240, 0), SetCond.FirstUseEver);
	ImGui.Begin("Draw Node", windowFlags, () => {
		ImGui.Text("Draw Node");
		ImGui.Separator();
		ImGui.TextWrapped("Draw shapes and lines!");
	});
	return false;
});
