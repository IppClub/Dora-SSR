// @preview-file on
import { React, toNode } from 'dora-x';
import { App, BodyMoveType, Vec2, threadLoop } from "dora";
import * as ImGui from 'ImGui';
import { WindowFlag, SetCond } from "ImGui";

const gravity = Vec2(0, -10);
const groupA = 0;
const groupB = 1;
const groupTerrain = 2;

toNode(
	<physics-world y={-200} showDebug>
		<contact groupA={groupA} groupB={groupB} enabled={false}/>
		<contact groupA={groupA} groupB={groupTerrain} enabled/>
		<contact groupA={groupB} groupB={groupTerrain} enabled/>

		<body
			type={BodyMoveType.Dynamic}
			group={groupA}
			linearAcceleration={gravity}
			y={500}
			angle={15}
		>
			<polygon-fixture
				verts={[
					Vec2(60, 0),
					Vec2(30, -30),
					Vec2(-30, -30),
					Vec2(-60, 0),
					Vec2(-30, 30),
					Vec2(30, 30),
				]}
				density={1}
				friction={0.4}
				restitution={0.4}/>
		</body>

		<body
			type={BodyMoveType.Dynamic}
			group={groupB}
			linearAcceleration={gravity}
			x={50}
			y={800}
			angularRate={90}
		>
			<disk-fixture
				radius={60}
				density={1}
				friction={0.4}
				restitution={0.4}
			/>
		</body>

		<body type={BodyMoveType.Static} group={groupTerrain}>
			<rect-fixture width={800} height={10} friction={0.8} restitution={0.2}/>
		</body>
	</physics-world>
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
	const {width} = App.visualSize
	ImGui.SetNextWindowBgAlpha(0.35);
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(240, 0), SetCond.FirstUseEver);
	ImGui.Begin("Body", windowFlags, () => {
		ImGui.Text("Body");
		ImGui.Separator();
		ImGui.TextWrapped("Basic usage to create physics bodies!");
	});
	return false;
});
