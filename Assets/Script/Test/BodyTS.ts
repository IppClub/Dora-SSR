// @preview-file off
import { App, Body, BodyDef, BodyMoveType, PhysicsWorld, Vec2, threadLoop } from "Dora";
import * as ImGui from 'ImGui';
import { WindowFlag, SetCond } from "ImGui";

const gravity = Vec2(0, -10);
const groupZero = 0;
const groupOne = 1;
const groupTwo = 2;

const terrainDef = BodyDef();
terrainDef.type = BodyMoveType.Static;
terrainDef.attachPolygon(800, 10, 1, 0.8, 0.2);

const polygonDef = BodyDef();
polygonDef.type = BodyMoveType.Dynamic;
polygonDef.linearAcceleration = gravity;
polygonDef.attachPolygon([
	Vec2(60, 0),
	Vec2(30, -30),
	Vec2(-30, -30),
	Vec2(-60, 0),
	Vec2(-30, 30),
	Vec2(30, 30)
], 1, 0.4, 0.4);

const diskDef = BodyDef();
diskDef.type = BodyMoveType.Dynamic;
diskDef.linearAcceleration = gravity;
diskDef.attachDisk(60, 1, 0.4, 0.4);

const world = PhysicsWorld();
world.y = -200;
world.setShouldContact(groupZero, groupOne, false);
world.setShouldContact(groupZero, groupTwo, true);
world.setShouldContact(groupOne, groupTwo, true);
world.showDebug = true;

const body = Body(terrainDef, world, Vec2.zero);
body.group = groupTwo;
world.addChild(body);

const bodyP = Body(polygonDef, world, Vec2(0, 500), 15);
bodyP.group = groupOne;
world.addChild(bodyP);

const bodyD = Body(diskDef, world, Vec2(50, 800));
bodyD.group = groupZero;
bodyD.angularRate = 90;
world.addChild(bodyD);

const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.AlwaysAutoResize,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove
];
threadLoop(() => {
	const {width} = App.visualSize
	ImGui.SetNextWindowBgAlpha(0.35);
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(240, 0), SetCond.FirstUseEver);
	ImGui.Begin("Body", windowFlags, () => {
		ImGui.Text("Body (Typescript)");
		ImGui.Separator();
		ImGui.TextWrapped("Basic usage to create physics bodies!");
	});
	return false;
});
