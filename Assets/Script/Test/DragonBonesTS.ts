import { SetCond, WindowFlag } from "ImGui";
import * as ImGui from 'ImGui';
import { App, Delay, DragonBone, Ease, Event, Label, Opacity, Scale, Sequence, Slot, Spawn, Vec2, threadLoop } from "dora";

const boneStr = "DragonBones/NewDragon";
const animations = DragonBone.getAnimations(boneStr);
const looks = DragonBone.getLooks(boneStr);

p(animations, looks);

const bone = DragonBone(boneStr);
if (bone !== null) {
	bone.look = looks[0];
	bone.play(animations[0], true);
	bone.slot(Slot.AnimationEnd, (name) => {
		print(name + " end!");
	});

	bone.y = -200;
	bone.touchEnabled = true;
	bone.slot(Slot.TapBegan, (touch) => {
		const { x, y } = touch.location;
		const name = bone.containsPoint(x, y);
		if (name !== undefined) {
			const label = Label("sarasa-mono-sc-regular", 30);
			if (label !== null) {
				label.text = name;
				label.color = App.themeColor;
				label.position = Vec2(x, y);
				label.order = 100;
				label.perform(
					Sequence(
						Spawn(
							Scale(1, 0, 2, Ease.OutQuad),
							Sequence(
								Delay(0.5),
								Opacity(0.5, 1, 0)
							)
						),
						Event("Stop")
					)
				)
				label.slot("Stop", () => {
					label.removeFromParent();
				});
				bone.addChild(label);
			}
		}
	});
}

const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.AlwaysAutoResize,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove
];
let showDebug = bone?.showDebug ?? false;
threadLoop(() => {
	const { width } = App.visualSize;
	ImGui.SetNextWindowBgAlpha(0.35);
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(240, 0), SetCond.FirstUseEver);
	ImGui.Begin("DragonBones", windowFlags, () => {
		ImGui.Text("DragonBones");
		ImGui.Separator();
		ImGui.TextWrapped("Basic usage to create dragonBones! Tap it for a hit test.");
		let changed = false;
		[changed, showDebug] = ImGui.Checkbox("BoundingBox", showDebug);
		if (changed && bone) {
			bone.showDebug = showDebug;
		}
	});
	return false;
});
