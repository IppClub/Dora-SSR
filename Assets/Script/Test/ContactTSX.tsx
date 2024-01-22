// @preview-file on
import { React, toNode, useRef } from 'dora-x';
import { SetCond, WindowFlag } from "ImGui";
import * as ImGui from 'ImGui';
import { App, Body, BodyMoveType, Label, Line, Vec2, threadLoop } from "dora";

const gravity = Vec2(0, -10);
const anchor = useRef<Line.Type>();
const label = useRef<Label.Type>();
const disk = useRef<Body.Type>();

toNode(
	<physics-world showDebug>
		<contact groupA={0} groupB={0} enabled/>

		<label ref={label} fontName='sarasa-mono-sc-regular' fontSize={30}/>

		<body type={BodyMoveType.Static}>
			<chain-fixture
				verts={(() => {
					const count = 50;
					const radius = 300;
					const vertices = [];
					for (let i of $range(0, count + 1)) {
						const angle = 2 * math.pi * i / count;
						vertices.push(Vec2(radius * math.cos(angle), radius * math.sin(angle)));
					}
					return vertices;
				})()}
				friction={0.4}
				restitution={0}
			/>
			<disk-fixture radius={30} centerY={-270} friction={0} restitution={1}/>
		</body>

		<body type={BodyMoveType.Static} onContactFilter={(other) => {
				return other.velocityY < 0;
		}}>
			<rect-fixture width={120} height={30} centerY={-60} friction={0} restitution={1}/>
		</body>

		<line ref={anchor} verts={[
			Vec2(-20, 0),
			Vec2(20, 0),
			Vec2.zero,
			Vec2(0, -20),
			Vec2(0, 20)
		]} lineColor={App.themeColor.toARGB()}/>

		<body
			ref={disk}
			type={BodyMoveType.Dynamic}
			linearAcceleration={gravity}
			angularRate={-2200}
			x={100} y={200}
			onContactStart={(_other, point, _normal) => {
				if (anchor.current) {
					anchor.current.position = point;
				}
				if (label.current) {
					label.current.text = string.format("Contact: [%.0f,%.0f]", point.x, point.y);
				}
			}}
		>
			<disk-fixture radius={20} density={5} friction={0.8} restitution={1}/>
		</body>
	</physics-world>
);

const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.AlwaysAutoResize,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove,
];
let receivingContact = disk.current?.receivingContact ?? true;
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
			if (disk.current) {
				print(receivingContact);
				disk.current.receivingContact = receivingContact;
			}
			if (label.current) {
				label.current.text = "";
			}
		}
	});
	return false;
});
