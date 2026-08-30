import { React, toNode } from "DoraX";
import { App, Director, HttpServer, Node } from "Dora";
import { mobileFontScale } from "Dev/Mobile/Accessibility";

interface PlayOverlayOptions {
	onExit: (this: void) => void;
	onRuntimeError?: (this: void, message: string) => void;
}

const fontName = "sarasa-mono-sc-regular";

export function startMobilePlayOverlay(options: PlayOverlayOptions) {
	const onExit = options.onExit;
	const zh = string.match(App.locale, "^zh")[0] !== undefined;
	const host = Node();
	host.tag = "mobile-play-overlay";
	host.scaleX = App.devicePixelRatio;
	host.scaleY = App.devicePixelRatio;
	host.addTo(Director.systemUI);
	let exiting = false;

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
	const render = () => {
		host.removeAllChildren();
		host.scaleX = App.devicePixelRatio;
		host.scaleY = App.devicePixelRatio;
		const { width, height } = App.visualSize;
		const safe = App.safeArea;
		const buttonWidth = 92;
		const scene = toNode(<node x={-width / 2} y={-height / 2} width={width} height={height} anchorX={0} anchorY={0}>
			<node tag="mobile-play-exit" x={safe.x + safe.width - buttonWidth - 12} y={safe.y + safe.height - 50} width={buttonWidth} height={38}
				anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true} onTapped={exit}>
				<draw-node x={buttonWidth / 2} y={19}>
					<rect-shape width={buttonWidth} height={38} fillColor={0xcc11151d} borderWidth={1} borderColor={0x66ffffff} />
				</draw-node>
				<label x={buttonWidth / 2} y={19} fontName={fontName} fontSize={math.floor(14 * mobileFontScale)} text={zh ? "退出试玩" : "Exit"} color3={0xf4f1e8} />
			</node>
		</node>);
		if (scene) host.addChild(scene);
	};

	host.onAppChange(setting => { if (setting === "Size" || setting === "Locale") render(); });
	host.onAppEvent(event => { if (event === "BackButton") exit(); });
	host.gslot("ScriptError", fail);
	render();
	return host;
}
