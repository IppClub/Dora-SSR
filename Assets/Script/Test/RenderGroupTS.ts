/*
const function Item(): Node.Type
	const node = Node()
	node.width = 144
	node.height = 144
	node.anchor = Vec2.zero

	const sprite = Sprite("Image/logo.png")
	sprite.scaleX = 0.3
	sprite.scaleY = 0.3
	sprite.renderOrder = 1
	sprite:addTo(node)

	const drawNode = DrawNode()
	drawNode:drawPolygon({
		Vec2(-60, -60),
		Vec2(60, -60),
		Vec2(60, 60),
		Vec2(-60, 60)
	}, Color(App.themeColor:toColor3(), 0x30))
	drawNode.renderOrder = 2
	drawNode.angle = 45
	drawNode:addTo(node)

	const line = Line({
		Vec2(-60, -60),
		Vec2(60, -60),
		Vec2(60, 60),
		Vec2(-60, 60),
		Vec2(-60, -60)
	}, Color(0xffff0080))
	line.renderOrder = 3
	line.angle = 45
	line:addTo(node)

	node:runAction(Angle(5, 0, 360))
	node:slot("ActionEnd", function(action: Action.Type)
		node:runAction(action)
	end)
	return node
end

const currentEntry = Node()
currentEntry.renderGroup = true
currentEntry.size = Size(750, 750)
for _i = 1, 16 do
	currentEntry:addChild(Item())
end
currentEntry:alignItems()

-- example codes ends here, some test ui below --

const ImGui <const> = require("ImGui")

const renderGroup = currentEntry.renderGroup
const windowFlags = {
	"NoDecoration",
	"AlwaysAutoResize",
	"NoSavedSettings",
	"NoFocusOnAppearing",
	"NoNav",
	"NoMove"
}
threadLoop(function(): boolean
	const width = App.visualSize.width
	ImGui.SetNextWindowBgAlpha(0.35)
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), "Always", Vec2(1, 0))
	ImGui.SetNextWindowSize(Vec2(240, 0), "FirstUseEver")
	ImGui.Begin("Render Group", windowFlags, function()
		ImGui.Text("Render Group")
		ImGui.Separator()
		ImGui.TextWrapped("When render group is enabled, the nodes in the sub render tree will be grouped by \"renderOrder\" property, and get rendered in ascending order!\nNotice the draw call changes in stats window.")
		const changed = true
		changed, renderGroup = ImGui.Checkbox("Grouped", renderGroup)
		if changed then
			currentEntry.renderGroup = renderGroup
		end
	end)
end)
*/

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
