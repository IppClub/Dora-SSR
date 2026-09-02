import { React, reference, toNode } from "DoraX";
import { App, DB, Director, HttpServer, Node, Vec2 } from "Dora";
import { mobileFontScale } from "Dev/Mobile/Accessibility";
import { RoundedSurface } from "Dev/Mobile/Visual";

interface PlayOverlayOptions {
	onExit: (this: void) => void;
	onRuntimeError?: (this: void, message: string) => void;
}

const fontName = "sarasa-mono-sc-regular";
const expandedWidth = 108;
const collapsedTouchWidth = 26;
const handleWidth = 6;
const controlHeight = 44;
const collapseDelay = 3;
const dragThreshold = 5;

export function resolvePlayHandleY(startControlY: number, startPointerY: number, pointerY: number, height: number) {
	return math.max(0, math.min(math.max(0, height - controlHeight), startControlY + pointerY - startPointerY));
}

function loadHandleRatio(portrait: boolean) {
	const name = portrait ? "mobilePlayHandlePortrait" : "mobilePlayHandleLandscape";
	const rows = DB.query(`select value_num from Config where name = '${name}' limit 1`) as unknown[][] | undefined;
	const ratio = rows && rows.length > 0 ? tonumber(rows[0][0]) : undefined;
	return ratio === undefined ? 0.62 : math.max(0.12, math.min(0.88, ratio));
}

function saveHandleRatio(portrait: boolean, ratio: number) {
	const name = portrait ? "mobilePlayHandlePortrait" : "mobilePlayHandleLandscape";
	DB.exec("insert or replace into Config(name, value_num, value_str, value_bool) values(?, ?, NULL, NULL)", [name, ratio]);
}

export function startMobilePlayOverlay(options: PlayOverlayOptions) {
	const onExit = options.onExit;
	let zh = string.match(App.locale, "^zh")[0] !== undefined;
	const host = Node();
	host.tag = "mobile-play-overlay";
	host.order = 10000;
	host.renderGroup = true;
	host.scaleX = App.devicePixelRatio;
	host.scaleY = App.devicePixelRatio;
	host.addTo(Director.systemUI);
	let exiting = false;
	let expanded = false;
	let expandedTime = 0;
	let dragDistance = 0;
	let pointerDown = false;
	let dragStartPointer = Vec2.zero;
	let dragStartControlY = 0;
	let portrait = App.visualSize.height >= App.visualSize.width;
	let handleRatio = loadHandleRatio(portrait);
	let controlRef = reference<Node.Type>();
	let sceneRef = reference<Node.Type>();

	const exit = () => {
		if (exiting || !host.visible || HttpServer.wsConnectionCount > 0) return;
		exiting = true;
		host.removeFromParent(true);
		onExit();
	};
	const fail = (message: string) => {
		if (exiting || !host.visible || HttpServer.wsConnectionCount > 0) return;
		exiting = true;
		host.removeFromParent(true);
		if (options.onRuntimeError) options.onRuntimeError(message);
		else onExit();
	};
	const controlPosition = (controlWidth: number, width: number, height: number) => {
		const y = math.max(0, height - controlHeight) * handleRatio;
		return Vec2(width - controlWidth, y);
	};
	const persistPosition = () => saveHandleRatio(portrait, handleRatio);
	const render = () => {
		host.removeAllChildren();
		host.scaleX = App.devicePixelRatio;
		host.scaleY = App.devicePixelRatio;
		const { width, height } = App.visualSize;
		const nextPortrait = height >= width;
		if (nextPortrait !== portrait) {
			portrait = nextPortrait;
			handleRatio = loadHandleRatio(portrait);
		}
		const controlWidth = expanded ? expandedWidth : collapsedTouchWidth;
		const position = controlPosition(controlWidth, width, height);
		controlRef = reference<Node.Type>();
		sceneRef = reference<Node.Type>();
		const scene = toNode(<node ref={sceneRef} x={-width / 2} y={-height / 2} width={width} height={height} anchorX={0} anchorY={0}>
			<node tag={expanded ? "mobile-play-exit" : "mobile-play-handle"} ref={controlRef}
				x={position.x} y={position.y} width={controlWidth} height={controlHeight} anchorX={0} anchorY={0}
				touchEnabled={true} swallowTouches={true}
				onTapBegan={touch => {
					const point = sceneRef.current?.convertToNodeSpace(touch.worldLocation) ?? touch.location;
					dragStartPointer = point;
					dragStartControlY = controlRef.current?.y ?? position.y;
					dragDistance = 0;
					pointerDown = true;
					expandedTime = 0;
				}}
				onTapMoved={touch => {
					const point = sceneRef.current?.convertToNodeSpace(touch.worldLocation) ?? touch.location;
					dragDistance = math.max(dragDistance, point.distance(dragStartPointer));
					const control = controlRef.current;
					const y = resolvePlayHandleY(dragStartControlY, dragStartPointer.y, point.y, height);
					handleRatio = y / math.max(1, height - controlHeight);
					if (control) control.y = y;
				}}
				onTapEnded={() => {
					pointerDown = false;
					if (dragDistance > dragThreshold) persistPosition();
				}}
				onTapped={() => {
					if (dragDistance > dragThreshold) return;
					if (expanded) exit();
					else { expanded = true; expandedTime = 0; render(); }
				}}>
				{expanded ? <node>
					<RoundedSurface width={controlWidth} height={controlHeight} radius={12}
						topColor={0xe82b3442} bottomColor={0xe811151d}
						borderWidth={1} borderColor={0x88ffffff} shadow={true} />
					<label x={controlWidth / 2} y={controlHeight / 2} fontName={fontName}
						fontSize={math.floor(14 * mobileFontScale)} text={zh ? "退出试玩" : "Exit"} color3={0xf4f1e8} />
				</node> : <RoundedSurface x={collapsedTouchWidth - handleWidth} y={5} width={handleWidth} height={controlHeight - 10}
					radius={3} fillColor={0x99ffffff} />}
			</node>
		</node>);
		if (scene) host.addChild(scene);
	};

	host.schedule(dt => {
		if (!expanded || exiting || pointerDown) return false;
		expandedTime += dt;
		if (expandedTime >= collapseDelay) {
			expanded = false;
			expandedTime = 0;
			render();
		}
		return false;
	});
	host.onAppChange(setting => {
		if (setting === "Locale") zh = string.match(App.locale, "^zh")[0] !== undefined;
		if (setting === "Size" || setting === "Locale") render();
	});
	host.onAppEvent(event => { if (event === "BackButton") exit(); });
	host.gslot("ScriptError", fail);
	render();
	return host;
}
