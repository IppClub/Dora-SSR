// @preview-file on
import { React, toNode } from 'dora-x';
import { App, Vec2, threadLoop, Node } from 'dora';
import { SetCond, WindowFlag } from 'ImGui';
import * as ImGui from 'ImGui';

let current: Node.Type | null = null;

function Test(this: void, name: string, jsx: React.Element) {
	return {name, test: () => {
		current = toNode(jsx);
	}};
}

const tests = [

	Test("Laser",
		<effek-node scaleX={50} scaleY={50} x={-300} angleY={-90}>
			<effek file='Particle/effek/Laser01.efk'/>
		</effek-node>
	),

	Test("Simple Model UV",
		<effek-node scaleX={50} scaleY={50} y={-200}>
			<effek file='Particle/effek/Simple_Model_UV.efkefc'/>
		</effek-node>
	),

	Test("Sword Lightning",
		<effek-node scaleX={50} scaleY={50} y={-300}>
			<effek file='Particle/effek/sword_lightning.efkefc'/>
		</effek-node>
	),
];

tests[0].test();

const testNames = tests.map(t => t.name);

let currentTest = 1;
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
	ImGui.Begin("Effekseer", windowFlags, () => {
		ImGui.Text("Effekseer (TSX)");
		ImGui.Separator();
		let changed = false;
		[changed, currentTest] = ImGui.Combo("Test", currentTest, testNames);
		if (changed) {
			if (current) {
				current.removeFromParent();
			}
			tests[currentTest - 1].test();
		}
	});
	return false;
});
