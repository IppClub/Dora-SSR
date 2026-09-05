import { React, reference, toNode } from "DoraX";
import { App, Color, Director, DrawNode, HttpServer, Label, Node, TextAlign, Vec2, thread } from "Dora";
import { attachGamepad } from "Dev/Mobile/Gamepad";
import { discardPackage, exportPackage, inspectPackage, installPackage, type PackagePreview } from "Dev/Mobile/Package";
import type { FeedEntry } from "Dev/Mobile/FeedModel";

// SystemUI NanoVG is a background pass. Modal surfaces use DrawNode so they
// cover the Feed text and sprites as well as its background surfaces.
function PackageSurface(props: { width: number; height: number; color: number; radius: number }) {
	return <custom-node onCreate={() => {
		const draw = DrawNode();
		const vertices: Vec2.Type[] = [];
		const r = props.radius;
		for (const corner of [
			{ x: props.width - r, y: r, angle: -math.pi / 2 },
			{ x: props.width - r, y: props.height - r, angle: 0 },
			{ x: r, y: props.height - r, angle: math.pi / 2 },
			{ x: r, y: r, angle: math.pi },
		]) {
			for (let i = 0; i <= 8; i++) {
				const angle = corner.angle + i * math.pi / 16;
				vertices.push(Vec2(corner.x + math.cos(angle) * r, corner.y + math.sin(angle) * r));
			}
		}
		draw.drawPolygon(vertices, Color(props.color), 1, Color(0xff343b48));
		return draw;
	}} />;
}

function PackageButton(props: { tag: string; x: number; y: number; width: number; text: string; fontSize?: number; primary?: boolean; onTapped: (this: void) => void }) {
	return <node tag={props.tag} x={props.x} y={props.y} width={props.width} height={48} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true} onTapped={props.onTapped}>
		<PackageSurface width={props.width} height={48} radius={14} color={props.primary ? 0xffffd34b : 0xff242c3a} />
		<label x={props.width / 2} y={24} fontName="sarasa-mono-sc-regular" fontSize={props.fontSize ?? 17} text={props.text} color3={props.primary ? 0x17130a : 0xf4f1e8} />
	</node>;
}

export function startPackagePanel(options: {
	mode: "add" | "share" | "receive";
	entry?: Pick<FeedEntry, "title" | "workDir" | "fileName">;
	path?: string;
	onNew?: (this: void) => void;
	onImported?: (this: void, entry: FeedEntry, play: boolean) => void;
	onClosed: (this: void) => void;
}) {
	const host = Node();
	host.tag = "mobile-package-panel";
	host.order = 20000;
	host.addTo(Director.systemUI);
	let active = true;
	let busy = options.mode === "share" && options.entry !== undefined;
	let preview: PackagePreview | undefined;
	let exported: { path: string; bytes: number } | undefined;
	const detailRef = reference<Label.Type>();
	let message = options.mode === "share" ? (App.locale.toLowerCase().startsWith("zh") ? "接收者导入后可以试玩，也可以继续改编。" : "Recipients can import, play, and Remix this game.") : "";
	let failed = false;
	const zh = App.locale.toLowerCase().startsWith("zh");
	const enabled = () => active && host.parent !== undefined && host.visible && HttpServer.wsConnectionCount === 0 && !busy;
	const close = () => {
		if (busy || !active) return;
		active = false;
		if (preview) discardPackage(preview);
		preview = undefined;
		host.removeFromParent(true);
		options.onClosed();
	};
	const receive = (path: string) => {
		if (!active) return;
		busy = true; failed = false;
		message = zh ? "正在检查作品包…" : "Checking game package…";
		render();
		thread(() => {
			try {
				const result = inspectPackage(path);
				if (!active || !host.parent) { discardPackage(result); return; }
				preview = result;
				message = zh ? "包含代码与素材，导入后可试玩和 Remix。" : "Includes code and assets. Import to play or Remix.";
			} catch (e) { failed = true; message = string.match(tostring(e), ":%d+: (.*)$")[0] ?? tostring(e); }
			finally {
				busy = false; render();
			}
		});
	};
	const pick = () => {
		if (!enabled()) return;
		busy = true; message = zh ? "请选择 ZIP 作品包" : "Choose a ZIP game package"; render();
		App.openFileDialog(false, path => {
			busy = false;
			if (!active || !host.parent) return;
			if (path !== "") receive(path);
			else { message = ""; render(); }
		});
	};
	const install = (play: boolean) => {
		if (!enabled() || !preview) return;
		try {
			const entry = installPackage(preview);
			preview = undefined;
			close();
			options.onImported?.(entry, play);
		} catch (e) { failed = true; message = string.match(tostring(e), ":%d+: (.*)$")[0] ?? tostring(e); render(); }
	};
	const render = () => {
		if (!active || !host.parent) return;
		host.removeAllChildren();
		host.scaleX = App.devicePixelRatio; host.scaleY = App.devicePixelRatio;
		const safe = App.safeArea;
		const width = math.min(safe.width, 540);
		const title = preview ? preview.title : options.mode === "share" ? (zh ? "分享作品" : "Share game") : (zh ? "添加作品" : "Add game");
		const detail = preview ? `${preview.author ? preview.author + " · " : ""}${string.format("%.1f MB", preview.bytes / 1048576)}`
			: options.mode === "share" ? `${options.entry?.title ?? ""} · ${exported ? string.format("%.1f MB", exported.bytes / 1048576) : (zh ? "打包中…" : "Packaging…")}` : "";
		const textHeight = (text: string, fontSize: number) => {
			if (text === "") return 0;
			const label = Label("sarasa-mono-sc-regular", fontSize)!;
			label.textWidth = width - 40;
			label.text = text;
			const height = math.max(fontSize, math.ceil(label.height));
			// Unparented nodes are automatically adopted by Director.entry next frame.
			label.cleanup();
			return height;
		};
		const titleTop = 20;
		const detailTop = titleTop + textHeight(title, 22) + 12;
		// Reserve the same detail row while packaging and once the size is known.
		const detailHeight = options.mode === "share"
			? math.max(textHeight(`${options.entry?.title ?? ""} · ${zh ? "打包中…" : "Packaging…"}`, 14), textHeight(`${options.entry?.title ?? ""} · 256.0 MB`, 14))
			: textHeight(detail, 14);
		const messageTop = detail !== "" ? detailTop + detailHeight + 10 : detailTop;
		const contentBottom = message !== "" ? messageTop + textHeight(message, 14)
			: detail !== "" ? detailTop + detailHeight : detailTop - 12;
		const hasActions = options.mode === "share" || !busy;
		const height = math.min(safe.height - 16, contentBottom + 20 + (hasActions ? 126 : 66));
		const actionWidth = (width - 52) / 2;
		const node = toNode(<node x={-App.visualSize.width / 2} y={-App.visualSize.height / 2} anchorX={0} anchorY={0} width={App.visualSize.width} height={App.visualSize.height} touchEnabled={true} swallowTouches={true}>
			<draw-node><rect-shape centerX={App.visualSize.width / 2} centerY={App.visualSize.height / 2} width={App.visualSize.width} height={App.visualSize.height} fillColor={0xaa000000} /></draw-node>
			<node tag="mobile-package-sheet" x={safe.left + (safe.width - width) / 2} y={safe.bottom + 8} width={width} height={height} anchorX={0} anchorY={0}>
				<PackageSurface width={width} height={height} radius={24} color={0xff151d2b} />
				<label x={20} y={height - titleTop} anchorX={0} anchorY={1} fontName="sarasa-mono-sc-regular" fontSize={22} text={title} textWidth={width - 40} alignment={TextAlign.Left} />
				{detail === "" ? undefined : <label tag="mobile-package-detail" ref={detailRef} x={20} y={height - detailTop} anchorX={0} anchorY={1} fontName="sarasa-mono-sc-regular" fontSize={14} text={detail} color3={0xa8afbd} textWidth={width - 40} alignment={TextAlign.Left} />}
				<label tag="mobile-package-status" x={20} y={height - messageTop} anchorX={0} anchorY={1} fontName="sarasa-mono-sc-regular" fontSize={14} text={message} color3={failed ? 0xff6b6b : 0xa8afbd} textWidth={width - 40} alignment={TextAlign.Left} />
				{!busy && preview ? <node>
					<PackageButton tag="mobile-package-import-play" x={20} y={78} width={actionWidth} text={zh ? "导入并试玩" : "Import & play"} fontSize={15} primary={true} onTapped={() => install(true)} />
					<PackageButton tag="mobile-package-import" x={32 + actionWidth} y={78} width={actionWidth} text={zh ? "仅导入" : "Import"} fontSize={15} onTapped={() => install(false)} />
				</node> : options.mode === "share" ? <node>
					<PackageButton tag="mobile-package-share" x={20} y={78} width={actionWidth} text={zh ? "分享作品" : "Share game"} fontSize={15} primary={true} onTapped={() => { if (enabled() && exported && !App.shareFile(exported.path)) { failed = true; message = zh ? "无法打开分享面板" : "Could not open share sheet"; render(); } }} />
					<PackageButton tag="mobile-package-save" x={32 + actionWidth} y={78} width={actionWidth} text={zh ? "保存作品包" : "Save package"} fontSize={15} onTapped={() => { if (enabled() && exported && !App.saveFileDialog(exported.path)) { failed = true; message = zh ? "无法打开保存面板" : "Could not open save dialog"; render(); } }} />
				</node> : !busy ? <node>
					{options.onNew ? <PackageButton tag="mobile-package-new" x={20} y={78} width={actionWidth} text={zh ? "新建作品" : "New game"} fontSize={15} onTapped={() => { if (enabled()) { close(); options.onNew?.(); } }} /> : undefined}
					<PackageButton tag="mobile-package-pick" x={options.onNew ? 32 + actionWidth : 20} y={78} width={options.onNew ? actionWidth : width - 40} text={zh ? "导入作品包" : "Import package"} fontSize={15} primary={true} onTapped={pick} />
				</node> : undefined}
				<PackageButton tag="mobile-package-close" x={20} y={18} width={width - 40} text={zh ? "关闭" : "Close"} onTapped={close} />
			</node>
		</node>);
		if (node) host.addChild(node);
	};
	attachGamepad(host, { initialTag: "mobile-package-close", isEnabled: enabled, onBack: close });
	host.onAppChange(setting => { if (setting === "Size") render(); });
	host.onAppEvent(event => { if (event === "BackButton" && enabled()) close(); });
	host.onCleanup(() => { active = false; if (preview) discardPackage(preview); preview = undefined; });
	host.schedule(() => { host.visible = HttpServer.wsConnectionCount === 0; return false; });
	render();
	if (options.mode === "receive" && options.path) receive(options.path);
	if (options.mode === "share" && options.entry) {
		thread(() => {
			try {
				exported = exportPackage(options.entry!);
				busy = false;
				// Keep the surface, controls, and their geometry from the first frame.
				if (active && host.parent && detailRef.current) {
					detailRef.current.text = `${options.entry!.title} · ${string.format("%.1f MB", exported.bytes / 1048576)}`;
				}
			} catch (e) {
				failed = true; busy = false;
				message = string.match(tostring(e), ":%d+: (.*)$")[0] ?? tostring(e);
				render();
			}
		});
	}
	return host;
}
