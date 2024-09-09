// @preview-file on
import { SetCond, WindowFlag } from 'ImGui';
import * as ImGui from 'ImGui';
import { App, Node, Sprite, Vec2, View, threadLoop } from 'Dora';
import * as nvg from 'nvg';

const texture = nvg.GetDoraSSR();
const sprite = Sprite(texture);
const length = Vec2(View.size).length;
const {width, height} = sprite;
const size = Vec2(width, height).length;
let scaledSize = size;

const node = Node();
node.addChild(sprite);
node.onGesture((center, _numFingers, deltaDist, deltaAngle) => {
	sprite.position = center;
	sprite.angle = sprite.angle + deltaAngle;
	scaledSize = scaledSize + (deltaDist * length);
	sprite.scaleX = scaledSize / size;
	sprite.scaleY = scaledSize / size;
});

const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.AlwaysAutoResize,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoMove,
	WindowFlag.NoMove
];
threadLoop(() => {
	const {width} = App.visualSize;
	ImGui.SetNextWindowBgAlpha(0.35);
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(240, 0), SetCond.FirstUseEver);
	ImGui.Begin("Gesture", windowFlags, () => {
		ImGui.Text("Gesture (Typescript)");
		ImGui.Separator();
		ImGui.TextWrapped("Interact with multi-touches!");
	});
	return false;
});
