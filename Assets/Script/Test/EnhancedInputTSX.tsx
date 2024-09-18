// @preview-file on
import { React, toNode } from 'DoraX';
import { App, ButtonName, KeyName, Node, Vec2, loop, threadLoop } from 'Dora';
import * as ImGui from "ImGui";
import { SetCond, WindowFlag } from 'ImGui';
import { GamePad, CreateManager, Trigger, TriggerState, InputContext } from 'InputManager';

const enum QTE {
	None = "None",
	Phase1 = "Phase1",
	Phase2 = "Phase2",
	Phase3 = "Phase3"
}

function QTEContext(contextName: QTE, keyName: KeyName, buttonName: ButtonName, timeWindow: number): InputContext {
	return {name: contextName,
		actions: [{
			name: "QTE", trigger:
			Trigger.Sequence([
				Trigger.Selector([
					Trigger.Selector([
						Trigger.KeyPressed(keyName),
						Trigger.Block(Trigger.AnyKeyPressed()),
					]),
					Trigger.Selector([
						Trigger.ButtonPressed(buttonName),
						Trigger.Block(Trigger.AnyButtonPressed()),
					]),
				]),
				Trigger.Selector([
					Trigger.KeyTimed(keyName, timeWindow),
					Trigger.ButtonTimed(buttonName, timeWindow),
				]),
			])
		}]
	};
}

const inputManager = CreateManager([
	{name: "Default", actions: [
		{name: "Confirm", trigger:
			Trigger.Selector([
				Trigger.ButtonHold(ButtonName.Y, 1),
				Trigger.KeyHold(KeyName.Return, 1),
			])
		},
		{name: "MoveDown", trigger:
			Trigger.Selector([
				Trigger.ButtonPressed(ButtonName.Down),
				Trigger.KeyPressed(KeyName.S)
			])
		},
	]},
	{name: "Test", actions: [
		{name: "Confirm", trigger: 
			Trigger.Selector([
				Trigger.ButtonHold(ButtonName.X, 0.3),
				Trigger.KeyHold(KeyName.LCtrl, 0.3),
			])
		},
	]},
	QTEContext(QTE.Phase1, KeyName.J, ButtonName.A, 3),
	QTEContext(QTE.Phase2, KeyName.K, ButtonName.B, 2),
	QTEContext(QTE.Phase3, KeyName.L, ButtonName.X, 1)
]);

inputManager.pushContext("Default");

toNode(
	<GamePad inputManager={inputManager}/>
);

let phase = QTE.None;
let text = "";

let holdTime = 0;
const node = Node();
node.gslot("Input.Confirm", (state: TriggerState, progress: number) => {
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

node.gslot("Input.QTE", (state: TriggerState, progress: number) => {
	switch (phase) {
		case QTE.Phase1:
			switch (state) {
				case TriggerState.Canceled:
					phase = QTE.None;
					inputManager.popContext();
					text = "Failed!";
					holdTime = progress;
					break;
				case TriggerState.Completed:
					phase = QTE.Phase2;
					inputManager.pushContext(QTE.Phase2);
					text = "Button B or Key K"
					break;
				case TriggerState.Ongoing:
					holdTime = progress;
					break;
			}
			break;
		case QTE.Phase2:
			switch (state) {
				case TriggerState.Canceled:
					phase = QTE.None;
					inputManager.popContext(2);
					text = "Failed!";
					holdTime = progress;
					break;
				case TriggerState.Completed:
					phase = QTE.Phase3;
					inputManager.pushContext(QTE.Phase3);
					text = "Button X or Key L"
					break;
				case TriggerState.Ongoing:
					holdTime = progress;
					break;
			}
			break;
		case QTE.Phase3:
			switch (state) {
				case TriggerState.Canceled:
				case TriggerState.Completed:
					phase = QTE.None;
					inputManager.popContext(3);
					text = state === TriggerState.Completed ? "Success!" : "Failed!";
					holdTime = progress;
					break;
				case TriggerState.Ongoing:
					holdTime = progress;
					break;
			}
			break;
	}
});

function QTEButton() {
	if (ImGui.Button("Start QTE")) {
		phase = QTE.Phase1;
		text = "Button A or Key J"
		inputManager.pushContext(QTE.Phase1);
	}
}
const countDownFlags = [
	WindowFlag.NoResize,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoTitleBar,
	WindowFlag.NoMove,
	WindowFlag.AlwaysAutoResize,
];
node.schedule(loop(() => {
	const {width, height} = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(width / 2 - 160, height / 2 - 100));
	ImGui.SetNextWindowSize(Vec2(300, 100), SetCond.Always);
	ImGui.Begin("CountDown", countDownFlags, () => {
		if (phase === QTE.None) {
			QTEButton();
		} else {
			ImGui.BeginDisabled(QTEButton);
		}
		ImGui.SameLine();
		ImGui.Text(text);
		ImGui.ProgressBar(holdTime, Vec2(-1, 30));
	});
	return false;
}));

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
		if (phase === QTE.None) {
			let [changed, result] = ImGui.Checkbox("hold X to Confirm (instead Y)", checked);
			if (changed) {
				if (checked) {
					inputManager.popContext();
				} else {
					inputManager.pushContext("Test");
				}
				checked = result;
			}
		}
	});
	return false;
});
