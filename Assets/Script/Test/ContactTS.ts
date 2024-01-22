import { SetCond, WindowFlag } from "ImGui";
import * as ImGui from 'ImGui';
import { App, Body, BodyDef, BodyMoveType, Label, Line, PhysicsWorld, Slot, Vec2, threadLoop } from "dora";

const gravity = Vec2(0, -10);

const world = PhysicsWorld();
world.setShouldContact(0, 0, true);
world.showDebug = true;

const label = Label("sarasa-mono-sc-regular", 30)?.addTo(world);

const terrainDef = BodyDef();
const count = 50;
const radius = 300;
const vertices = [];
for (let i of $range(0, count + 1)) {
	const angle = 2 * math.pi * i / count;
	vertices.push(Vec2(radius * math.cos(angle), radius * math.sin(angle)));
}
terrainDef.attachChain(vertices, 0.4, 0);
terrainDef.attachDisk(Vec2(0, -270), 30, 1, 0, 1.0);
terrainDef.attachPolygon(Vec2(0, 80), 120, 30, 0, 1, 0, 1.0);

const terrain = Body(terrainDef, world);
terrain.addTo(world);

const drawNode = Line([
	Vec2(-20, 0),
	Vec2(20, 0),
	Vec2.zero,
	Vec2(0, -20),
	Vec2(0, 20)
], App.themeColor);
drawNode.addTo(world);

const diskDef = BodyDef();
diskDef.type = BodyMoveType.Dynamic;
diskDef.linearAcceleration = gravity;
diskDef.attachDisk(20, 5, 0.8, 1);

const disk = Body(diskDef, world, Vec2(100, 200));
disk.addTo(world);
disk.angularRate = -1800;
disk.receivingContact = true;
disk.slot(Slot.ContactStart, (_, point) => {
	drawNode.position = point
	if (label !== undefined) {
		label.text = string.format("Contact: [%.0f,%.0f]", point.x, point.y);
	}
});
const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.AlwaysAutoResize,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove,
];
let receivingContact = disk.receivingContact;
threadLoop(() => {
	const { width } = App.visualSize;
	ImGui.SetNextWindowBgAlpha(0.35);
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(240, 0), SetCond.FirstUseEver);
	ImGui.Begin("Contact", windowFlags, () => {
		ImGui.Text("Contact");
		ImGui.Separator();
		ImGui.TextWrapped("Receive events when physics bodies contact.");
		let changed = false;
		[changed, receivingContact] = ImGui.Checkbox("Receiving Contact", receivingContact);
		if (changed) {
			disk.receivingContact = receivingContact;
			if (label !== undefined) label.text = "";
		}
	});
	return false;
});
