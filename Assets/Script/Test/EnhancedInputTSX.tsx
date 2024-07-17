// @preview-file on
import { React, toNode } from 'DoraX';
import { App, ButtonName, KeyName, Node, Vec2, loop, threadLoop } from 'Dora';
import * as ImGui from "ImGui";
import { SetCond, WindowFlag } from 'ImGui';
import { GamePad, CreateInputManager, Trigger, TriggerState } from 'InputManager';

const inputManager = CreateInputManager([
	{
		name: "Default",
		actions: [
			{name: "Confirm", trigger:
				Trigger.Selector([
					Trigger.ButtonHold(ButtonName.a, 1),
					Trigger.KeyHold(KeyName.Return, 1),
				])
			},
			{name: "MoveDown", trigger:
				Trigger.Selector([
					Trigger.ButtonPressed(ButtonName.dpdown),
					Trigger.KeyPressed(KeyName.S)
				])
			},
		]
	},
	{
		name: "Test",
		actions: [
			{name: "Confirm", trigger: 
				Trigger.Selector([
					Trigger.ButtonHold(ButtonName.x, 0.5),
					Trigger.KeyHold(KeyName.LCtrl, 0.5),
				])
			},
		]
	},
]);

toNode(
	<GamePad inputManager={inputManager}/>
);

let holdTime = 0;
const node = Node();
node.gslot("Input.Confirm", (state: TriggerState, progress: number, value: any) => {
	if (state === TriggerState.Completed) {
		holdTime = 1;
	} else if (state === TriggerState.Ongoing) {
		holdTime = progress;
	}
});

node.gslot("Input.MoveDown", (state: TriggerState, progress: number, value: any) => {
	if (state === TriggerState.Completed) {
		print(state, progress, value);
	}
});
node.schedule(loop(() => {
	const {width, height} = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(width / 2 - 150, height / 2 - 50));
	ImGui.SetNextWindowSize(Vec2(300, 50), SetCond.FirstUseEver);
	ImGui.Begin("CountDown", [WindowFlag.NoResize, WindowFlag.NoSavedSettings, WindowFlag.NoTitleBar,WindowFlag.NoMove], () => {
		ImGui.ProgressBar(holdTime, Vec2(-1, 30));
	});
	return false;
}))

let checked = false;

const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.AlwaysAutoResize,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove
];
threadLoop(() => {
	const {width} = App.visualSize
	ImGui.SetNextWindowBgAlpha(0.35);
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(240, 0), SetCond.FirstUseEver);
	ImGui.Begin("EnhancedInput", windowFlags, () => {
		ImGui.Text("Enhanced Input (TSX)");
		ImGui.Separator();
		ImGui.TextWrapped("Change input context to alter input mapping");
		let [changed, result] = ImGui.Checkbox("X to Confirm (not A)", checked);
		if (changed) {
			if (checked) {
				inputManager.popContext();
			} else {
				inputManager.pushContext(["Test"]);
			}
			checked = result;
		}
	});
	return false;
});