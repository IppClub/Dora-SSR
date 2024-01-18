import { WindowFlag, SetCond } from "ImGui";
import * as ImGui from 'ImGui';
import { App, Model, Slot, Vec2, threadLoop } from "dora";

const modelFile = "Model/xiaoli.model";

const looks = Model.getLooks(modelFile);
if (looks.length === 0) {
	looks.push("");
}

const animations = Model.getAnimations(modelFile);
if (animations.length === 0) {
	animations.push("");
}

let currentLook = looks.indexOf("happy");
currentLook = math.max(currentLook, 0);
let currentAnim = animations.indexOf("idle");
currentAnim = math.max(currentAnim, 0);

const model = Model(modelFile);
if (model) {
	model.recovery = 0.2;
	model.look = looks[currentLook];
	model.play(animations[currentAnim], true);
	model.slot(Slot.AnimationEnd, name => {
		print(name, "end");
	});
}

currentLook++;
currentAnim++;

let loop = true;
const windowFlags = [
	WindowFlag.NoResize,
	WindowFlag.NoSavedSettings
];
threadLoop(() => {
	const {width} = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(width - 250, 10), SetCond.FirstUseEver);
	ImGui.SetNextWindowSize(Vec2(240, 325), SetCond.FirstUseEver);
	ImGui.Begin("Model", windowFlags, () => {
		if (!model) return;
		let changed = false;
		[changed, currentLook] = ImGui.Combo("Look", currentLook, looks);
		if (changed) {
			model.look = looks[currentLook - 1];
		}

		[changed, currentAnim] = ImGui.Combo("Anim", currentAnim, animations);
		if (changed) {
			model.play(animations[currentAnim - 1], loop);
		}

		[changed, loop] = ImGui.Checkbox("Loop", loop);
		if (changed) {
			model.play(animations[currentAnim - 1], loop);
		}

		ImGui.SameLine();
		[changed, model.reversed] = ImGui.Checkbox("Reversed", model.reversed);
		if (changed) {
			model.play(animations[currentAnim - 1], loop);
		}

		ImGui.PushItemWidth(-70, () => {
			[changed, model.speed] = ImGui.DragFloat("Speed", model.speed, 0.01, 0, 10, "%.2f");
			[changed, model.recovery] = ImGui.DragFloat("Recovery", model.recovery, 0.01, 0, 10, "%.2f");
		});

		let scale = model.scaleX;
		[changed, scale] = ImGui.DragFloat("Scale", scale, 0.01, 0.5, 2, "%.2f");
		model.scaleX = scale;
		model.scaleY = scale;

		if (ImGui.Button("Play", Vec2(140, 30))) {
			model.play(animations[currentAnim - 1], loop);
		}
	});

	return false;
});
