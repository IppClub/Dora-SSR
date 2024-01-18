import { SetCond, WindowFlag } from "ImGui";
import * as ImGui from 'ImGui';
import { App, Delay, Label, Node, Opacity, Scale, Sequence, Vec2, threadLoop } from "dora"

const node = Node();

const label = Label("sarasa-mono-sc-regular", 40)?.addTo(node);
if (label) {
	label.batched = false;
	label.text = "你好，Dora SSR！";
	for (let i = 1; i <= label.characterCount; i++) {
		const char = label.getCharacter(i);
		if (char !== null) {
			char.runAction(
				Sequence(
					Delay(i / 5),
					Scale(0.2, 1, 2),
					Scale(0.2, 2, 1)
				)
			);
		}
	}
}

const labelS = Label("sarasa-mono-sc-regular", 30)?.addTo(node);
if (labelS) {
	labelS.text = "-- from Jin.";
	labelS.color = App.themeColor;
	labelS.opacity = 0;
	labelS.position = Vec2(120, -70);
	labelS.runAction(
		Sequence(
			Delay(2),
			Opacity(0.2, 0, 1)
		)
	);
}

const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.AlwaysAutoResize,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove
];
threadLoop(() => {
	const size = App.visualSize;
	ImGui.SetNextWindowBgAlpha(0.35);
	ImGui.SetNextWindowPos(Vec2(size.width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(240, 0), SetCond.FirstUseEver);
	ImGui.Begin("Label", windowFlags, () => {
		ImGui.Text("Label");
		ImGui.Separator();
		ImGui.TextWrapped("Render labels with unbatched and batched methods!");
	});
	return false;
});
