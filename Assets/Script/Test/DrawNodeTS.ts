import { SetCond, WindowFlag } from "ImGui";
import * as ImGui from "ImGui";
import { App, Color, DrawNode, Line, Node, Vec2, threadLoop } from "dora"

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

const node = Node();

const star = DrawNode();
star.position = Vec2(200, 200);
star.drawPolygon(StarVertices(60), Color(0x80ff0080), 1, Color(0xffff0080));
star.addTo(node);

const { themeColor } = App;

const circle = Line(CircleVertices(60), themeColor);
circle.position = Vec2(-200, 200);
circle.addTo(node);

const camera = Node();
camera.color = themeColor;
camera.scaleX = 2;
camera.scaleY = 2;
camera.addTo(node);

const cameraFill = DrawNode();
cameraFill.opacity = 0.5;
cameraFill.drawPolygon([
	Vec2(-20, -10),
	Vec2(20, -10),
	Vec2(20, 10),
	Vec2(-20, 10)
]);
cameraFill.drawPolygon([
	Vec2(20, 3),
	Vec2(32, 10),
	Vec2(32, -10),
	Vec2(20, -3)
]);
cameraFill.drawDot(Vec2(-11, 20), 10);
cameraFill.drawDot(Vec2(11, 20), 10);
cameraFill.addTo(camera);

let cameraLine = Line(CircleVertices(10));
cameraLine.position = Vec2(-21, 10);
cameraLine.addTo(camera);

cameraLine = Line(CircleVertices(10));
cameraLine.position = Vec2(1, 10);
cameraLine.addTo(camera);

cameraLine = Line([
	Vec2(20, 3),
	Vec2(32, 10),
	Vec2(32, -10),
	Vec2(20, -3)
]);
cameraLine.addTo(camera);

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
