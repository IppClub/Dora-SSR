import { SetCond, WindowFlag } from "ImGui";
import * as ImGui from 'ImGui';
import { App, Director, Ease, Model, Node, Sprite, TypeName, Vec2, cycle, once, threadLoop, tolua } from "dora";

const node = Node();

const model = Model("Model/xiaoli.model");
if (model !== null) {
	model.look = "happy";
	model.play("idle", true);
	node.addChild(model);
}

const sprite = Sprite("Image/logo.png");
if (sprite !== null) {
	sprite.scaleX = 0.4;
	sprite.scaleY = 0.4;
	sprite.position = Vec2(200, -100);
	sprite.angleY = 45;
	sprite.z = -300;
	node.addChild(sprite);
}

node.schedule(once(() => {
	const camera = tolua.cast(Director.currentCamera, TypeName.Camera2D);
	if (camera === null) return;
	cycle(1.5, dt => {
		camera.position = Vec2(200 * Ease.func(Ease.InOutQuad, dt), 0);
	});
	cycle(0.1, dt => {
		camera.rotation = 25 * Ease.func(Ease.OutSine, dt)
	});
	cycle(0.2, dt => {
		camera.rotation = 25 - 50 * Ease.func(Ease.InOutQuad, dt);
	});
	cycle(0.1, dt => {
		camera.rotation = -25 + 25 * Ease.func(Ease.OutSine, dt);
	});
	cycle(1.5, dt => {
		camera.position = Vec2(200 * Ease.func(Ease.InOutQuad, 1 - dt), 0);
	})
	const { zoom } = camera;
	cycle(2.5, dt => {
		camera.zoom = zoom + Ease.func(Ease.InOutQuad, dt);
	});
}));

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
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(240, 0), SetCond.FirstUseEver);
	ImGui.Begin("Camera", windowFlags, () => {
		ImGui.Text("Camera");
		ImGui.Separator();
		ImGui.TextWrapped("View camera motions, use 3D camera as default!");
	});
	return false;
});