import { WindowFlag, SetCond, ColorEditMode } from "ImGui";
import * as ImGui from "ImGui";
import { App, Size, Slot, Sprite, Vec2, threadLoop } from "dora";

let sprite = Sprite("Image/logo.png");
if (sprite) {
	sprite.scaleX = 0.5;
	sprite.scaleY = 0.5;
	sprite.touchEnabled = true;
	sprite.slot(Slot.TapMoved, touch => {
		if (!touch.first) {
			return;
		}
		if (!sprite) return;
		sprite.position = sprite.position.add(touch.delta);
	});
}

const windowFlags = [
	WindowFlag.NoResize,
	WindowFlag.NoSavedSettings
];
threadLoop(() => {
	const {width} = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(240, 520), SetCond.FirstUseEver);
	ImGui.Begin("Sprite", windowFlags, () => {
		ImGui.BeginChild("SpriteSetting", Vec2(-1, -40), () => {
			if (!sprite) return;
			let changed = false;
			let z = sprite.z;
			[changed, z] = ImGui.DragFloat("Z", z, 1, -1000, 1000, "%.2f");
			if (changed) {
				sprite.z = z;
			}
			let anchor = sprite.anchor;
			let [x, y] = [anchor.x, anchor.y];
			[changed, x, y] = ImGui.DragFloat2("Anchor", x, y, 0.01, 0, 1, "%.2f");
			if (changed) {
				sprite.anchor = Vec2(x, y);
			}
			let size = sprite.size;
			let [spriteW, height] = [size.width, size.height];
			[changed, spriteW, height] = ImGui.DragFloat2("Size", spriteW, height, 0.1, 0, 1000, "%.f");
			if (changed) {
				sprite.size = Size(spriteW, height);
			}
			let [scaleX, scaleY] = [sprite.scaleX, sprite.scaleY];
			[changed, scaleX, scaleY] = ImGui.DragFloat2("Scale", scaleX, scaleY, 0.01, -2, 2, "%.2f");
			if (changed) {
				[sprite.scaleX, sprite.scaleY] = [scaleX, scaleY];
			}
			ImGui.PushItemWidth(-60, () => {
				if (!sprite) return;
				let angle = sprite.angle;
				[changed, angle] = ImGui.DragInt("Angle", Math.floor(angle), 1, -360, 360);
				if (changed) {
					sprite.angle = angle;
				}
			});
			ImGui.PushItemWidth(-60, () => {
				if (!sprite) return;
				let angleX = sprite.angleX;
				[changed, angleX] = ImGui.DragInt("AngleX", Math.floor(angleX), 1, -360, 360);
				if (changed) {
					sprite.angleX = angleX;
				}
			});
			ImGui.PushItemWidth(-60, () => {
				if (!sprite) return;
				let angleY = sprite.angleY;
				[changed, angleY] = ImGui.DragInt("AngleY", Math.floor(angleY), 1, -360, 360);
				if (changed) {
					sprite.angleY = angleY;
				}
			});
			let [skewX, skewY] = [sprite.skewX, sprite.skewY];
			[changed, skewX, skewY] = ImGui.DragInt2("Skew", Math.floor(skewX), Math.floor(skewY), 1, -360, 360);
			if (changed) {
				[sprite.skewX, sprite.skewY] = [skewX, skewY];
			}
			ImGui.PushItemWidth(-70, () => {
				if (!sprite) return;
				let opacity = sprite.opacity;
				[changed, opacity] = ImGui.DragFloat("Opacity", opacity, 0.01, 0, 1, "%.2f");
				if (changed) {
					sprite.opacity = opacity;
				}
			});
			ImGui.PushItemWidth(-1, () => {
				if (!sprite) return;
				let color3 = sprite.color3;
				ImGui.SetColorEditOptions(ColorEditMode.RGB);
				if (ImGui.ColorEdit3("", color3)) {
					sprite.color3 = color3;
				}
			});
		});
		if (ImGui.Button("Reset", Vec2(140, 30))) {
			if (!sprite) return;
			let parent = sprite.parent;
			parent.removeChild(sprite);
			sprite = Sprite("Image/logo.png");
			if (sprite) parent.addChild(sprite);
		}
	});
	return false;
});
