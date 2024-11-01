// @preview-file on
import { React, toNode, useRef } from 'DoraX';
import { TileNode, Node, App, Vec2, threadLoop } from 'Dora';
import { SetCond, WindowFlag } from 'ImGui';
import * as ImGui from 'ImGui';

let current: Node.Type | null = null;

function TMX(file: string) {
	if (current) {
			current.removeFromParent();
	}
	const tileNodeRef = useRef<TileNode.Type>();
	current = toNode(
		<align-node windowRoot onTapMoved={touch => {
				if (tileNodeRef.current) {
					tileNodeRef.current.position = tileNodeRef.current.position.add(touch.delta);
				}
			}}>
			<tile-node ref={tileNodeRef} file={file}/>
		</align-node>
	);
}

const files = [
	'TMX/platform.tmx',
	'TMX/demo.tmx'
];

TMX(files[0]);

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
	ImGui.Begin("Tilemap", windowFlags, () => {
		ImGui.Text("Tilemap (TSX)");
		ImGui.Separator();
		ImGui.TextWrapped("Drag to view the whole scene.");
		let changed = false;
		[changed, currentTest] = ImGui.Combo("File", currentTest, files);
		if (changed) {
			TMX(files[currentTest - 1]);
		}
	});
	return false;
});
