// @preview-file on clear
import { React, toNode } from 'DoraX';
import { App, BodyMoveType, Node, Scheduler, Vec2, threadLoop } from 'Dora';
import { SetCond, WindowFlag } from 'ImGui';
import * as ImGui from 'ImGui';

const Item = (props: {x: number, y: number, scheduler?: Scheduler.Type}) => {
	return (
		<sprite file='Image/logo.png' x={props.x} y={props.y} width={100} height={100} scheduler={props.scheduler}>
			<loop>
				<angle time={3} start={0} stop={360}/>
			</loop>
		</sprite>
	);
};

const Scene = (props: {flip?: boolean, scheduler?: Scheduler.Type}) => {
	return (
		<node scaleX={props.flip ? -1 : 1}>
			<Item x={-100} y={100} scheduler={props.scheduler}/>
			<Item x={-100} y={0} scheduler={props.scheduler}/>
			<Item x={-100} y={-100} scheduler={props.scheduler}/>
			<physics-world showDebug x={-280} y={-100} scheduler={props.scheduler}>
				<body type={BodyMoveType.Static}>
					<rect-fixture width={200} height={10}/>
				</body>
				<body type={BodyMoveType.Dynamic} y={100}>
					<disk-fixture radius={50} restitution={1}/>
				</body>
			</physics-world>
		</node>
	);
};

const scheduler = Scheduler();
scheduler.timeScale = 0.1;

const node = Node();
node.schedule((deltaTime) => scheduler.update(deltaTime));

toNode(
	<>
		<Scene/>
		<Scene flip scheduler={scheduler}/>
	</>
);

let {timeScale} = scheduler;

const windowFlags = [
	WindowFlag.NoDecoration,
	WindowFlag.NoSavedSettings,
	WindowFlag.NoFocusOnAppearing,
	WindowFlag.NoNav,
	WindowFlag.NoMove
];
threadLoop(() => {
	const {width} = App.visualSize;
	ImGui.SetNextWindowPos(Vec2(width - 10, 10), SetCond.Always, Vec2(1, 0));
	ImGui.SetNextWindowSize(Vec2(200, 0), SetCond.Always);
	ImGui.Begin("Scheduler", windowFlags, () => {
		ImGui.Text("Scheduler (TSX)");
		ImGui.Separator();
		ImGui.TextWrapped("Using a custom scheduler to control update speed.");
		let changed = false;
		[changed, timeScale] = ImGui.DragFloat("Speed", timeScale, 0.01, 0.1, 3, "%.2f");
		if (changed) {
			scheduler.timeScale = timeScale;
		}
	});
	return false;
});
