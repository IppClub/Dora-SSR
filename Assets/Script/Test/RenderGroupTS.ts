import { WindowFlag, SetCond } from "ImGui";
import * as ImGui from 'ImGui';
import { Angle, App, Color, DrawNode, Line, Node, Size, Slot, Sprite, Vec2, threadLoop } from "dora";

function Item(this: void) {
	const node = Node();
	node.width = 144;
	node.height = 144;
	node.anchor = Vec2.zero;

	const sprite = Sprite("Image/logo.png").addTo(node);
	sprite.scaleX = 0.1;
	sprite.scaleY = 0.1;
	sprite.renderOrder = 1;

	const drawNode = DrawNode().addTo(node);
	drawNode.drawPolygon([
		Vec2(-60, -60),
		Vec2(60, -60),
		Vec2(60, 60),
		Vec2(-60, 60)
	], Color(0x30ff0080));
	drawNode.renderOrder = 2;
	drawNode.angle = 45;

	const line = Line([
		Vec2(-60, -60),
		Vec2(60, -60),
		Vec2(60, 60),
		Vec2(-60, 60),
		Vec2(-60, -60)
	], Color(0xffff0080)).addTo(node);
	line.renderOrder = 3;
	line.angle = 45;

	node.runAction(Angle(5, 0, 360));
	node.slot(Slot.ActionEnd, action => {
		node.runAction(action);
	});
	return node;
}

const currentEntry = Node();
currentEntry.renderGroup = true;
currentEntry.size = Size(750, 750);
for (let _i = 1; _i <= 16; _i++) {
	currentEntry.addChild(Item());
}

currentEntry.alignItems();

let renderGroup = currentEntry.renderGroup;
const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.AlwaysAutoResize,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove
];
threadLoop(() => {
	const {width} = App.visualSize;
	ImGui.SetNextWindowBgAlpha(0.35);
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(240, 0), SetCond.FirstUseEver);
	ImGui.Begin("Render Group", windowFlags, () => {
		ImGui.Text("Render Group");
		ImGui.Separator();
		ImGui.TextWrapped("When render group is enabled, the nodes in the sub render tree will be grouped by \"renderOrder\" property, and get rendered in ascending order!\nNotice the draw call changes in stats window.");
		let changed = false;
		[changed, renderGroup] = ImGui.Checkbox("Grouped", renderGroup);
		if (changed) {
			currentEntry.renderGroup = renderGroup;
		}
	});
	return false;
})
