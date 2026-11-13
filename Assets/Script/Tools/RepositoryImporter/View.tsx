// @preview-file off
import { React, toNode } from "DoraX";
import { App, Color3, Director, Label, Node, Path, Size, TextAlign, Vec2, emit } from "Dora";
import { MobileButton, MobilePanelSurface } from "Tools/RepositoryImporter/Controls";
import * as ScrollArea from "UI/Control/Basic/ScrollArea";
import { RoundedSurface } from "Tools/RepositoryImporter/Controls";
import { createTextInput } from "Dev/Mobile/TextInput";
import { attachGamepad } from "Dev/Mobile/Gamepad";
import { getTargets, openProject, IDETarget } from "Dev/ImportIDE";
import { importRepository, ImportOperation, ImportedProject, normalizeRepository } from "Tools/RepositoryImporter/Import";

export function start(repository?: string) {
	const host = Node(); host.tag = "repository-importer"; host.renderGroup = false; host.order = 16000; host.renderOrder = 16000; host.addTo(Director.entry);
	const zh = string.match(App.locale, "^zh")[0] !== undefined;
	let url = repository ?? "";
	let phase: "input" | "busy" | "ready" | "error" | "opening" = "input";
	let message = "", project: ImportedProject | undefined;
	let operation: ImportOperation | undefined;
	let disposed = false, details = false, targetKey = "";
	let progressBucket = -1;
	let lastRefresh = 0, shownPhase = "";
	type Scroll = ReturnType<typeof ScrollArea> & {offset: Vec2.Type};
	let scroll: Scroll | undefined;
	const finish = () => emit("RepositoryImportDone");
	const input = createTextInput({fontSize: 14, singleLine: true, nativeSurface: true, getText: () => url, setText: value => {url = value;},
		getPlaceholder: () => "https://github.com/owner/project", isEnabled: () => !disposed && phase === "input",
		onReturn: () => { begin(); return true; }});
	const begin = () => {
		const normalized = normalizeRepository(url);
		if (!normalized) { message = zh ? "请输入 GitHub、AtomGit、Gitee 或 GitCode 的公开 HTTPS 仓库地址。" : "Enter a public HTTPS repository on GitHub, AtomGit, Gitee or GitCode."; render(); return; }
		input.blur(); url = normalized; phase = "busy"; message = ""; project = undefined;
		const current: ImportOperation = {canceled: false, phase: "clone"}; operation = current;
		render();
		importRepository(url, current).then(result => {
			if (disposed || current.canceled) return;
			project = result; phase = "ready"; emit("RepositoryImported", result.entry); render();
		}).catch(error => {
			if (disposed || current.canceled) return;
			phase = "error"; message = tostring(error); render();
		});
	};
	const open = (target: IDETarget) => {
		if (!project || phase !== "ready") return;
		phase = "opening"; message = ""; render();
		openProject(target, project.root).then(success => {
			if (disposed) return;
			phase = "ready";
			if (!success) { message = zh ? "IDE 未响应，请重试或重新连接 IDE。" : "The IDE did not respond. Retry or reconnect it."; render(); return; }
			if (target.embedded) { finish(); emit("AppWebView", "/ide/show", true); }
			else { message = zh ? "已在浏览器 IDE 中打开，请切换到浏览器。" : "Opened in the browser IDE. Switch to your browser."; render(); }
		});
	};
	const render = () => {
		if (disposed) return;
		const offset = scroll?.offset.y ?? 0;
		input.unmount(); host.removeAllChildren();
		host.scaleX = App.devicePixelRatio; host.scaleY = App.devicePixelRatio;
		const safe = App.safeArea, width = math.max(160, math.min(540, safe.width - 24));
		const availableHeight = math.max(180, safe.height - 64);
		const height = math.max(180, math.min(480, availableHeight - 24));
		const left = safe.left + (safe.width - width) / 2 - App.visualSize.width / 2;
		const bottom = safe.bottom + 64 + (availableHeight - height) / 2 - App.visualSize.height / 2;
		const targets = getTargets();
		targetKey = targets.map(target => target.id).join(","); shownPhase = operation?.phase ?? "";
		const title = phase === "ready" ? (project?.existing ? (zh ? "项目已在本地" : "Already imported") : (zh ? "项目已导入" : "Project imported"))
			: phase === "error" ? (zh ? "导入未完成" : "Import failed") : phase === "opening" ? (zh ? "正在打开项目…" : "Opening project…")
			: phase === "busy" ? (operation?.phase === "verify" ? (zh ? "正在校验项目…" : "Verifying project…") : (zh ? "正在下载项目…" : "Cloning project…")) : (zh ? "从仓库导入" : "Import repository");
		const buttonWidth = (width - 60) / 2, contentWidth = width - 66;
		const hasFooterPrimary = phase === "input" || phase === "error" || (phase === "ready" && targets.length === 0);
		const name = url !== "" ? Path.getFilename(url) : (zh ? "公开开源仓库" : "Public repository");
		const p = math.max(0, math.min(1, operation?.status?.progress ?? 0)); progressBucket = math.floor(p * 100);
		const items: {node: Node.Type; top: number; label: boolean}[] = [];
		let top = 0;
		const add = (node: Node.Type | undefined, height: number) => {if (node) {items.push({node, top, label: false}); top += height + 12;}};
		const text = (value: string, size = 14, color = 0xa8afbd) => {
			const node = Label("sarasa-mono-sc-regular", size, true)!;
			node.textWidth = contentWidth; node.alignment = TextAlign.Left; node.anchor = Vec2(0, 1);
			node.text = value; node.color3 = Color3(color);
			items.push({node, top, label: true}); top += node.height + 14;
		};
		text(name, 20, 0xffffcc33);
		if (phase === "input") {
			const field = Node(); field.tag = "repository-input"; field.anchor = Vec2.zero; field.size = Size(contentWidth, 44); input.mount(field); add(field, 44);
			add(toNode(<MobileButton tag="import-paste" x={0} y={0} width={contentWidth} height={36} text={zh ? "粘贴仓库地址" : "Paste repository URL"} fontSize={13} onTapped={() => {input.pasteFromClipboard(true);}} />), 36);
			text(zh ? "支持 GitHub、AtomGit、Gitee 和 GitCode 的公开 HTTPS 仓库。" : "Public HTTPS repositories on GitHub, AtomGit, Gitee and GitCode.", 12);
		} else text(url, 12);
		if (phase === "busy") {
			text(zh ? "下载 → 校验 → 导入" : "Clone → Verify → Import", 13);
			add(toNode(<node width={contentWidth} height={10} anchorX={0} anchorY={0}>
				<RoundedSurface width={contentWidth} height={10} radius={5} topColor={0xff111620} bottomColor={0xff111620} />
				{p > 0 ? <RoundedSurface width={math.max(10, contentWidth * p)} height={10} radius={5} topColor={0xffffdf6b} bottomColor={0xffffbd2e} /> : undefined}
			</node>), 10);
			text(`${math.floor(p * 100)}%${operation?.status?.transferredBytes ? `  ${string.format("%.1f", operation.status.transferredBytes / 1048576)} MiB` : ""}`, 13);
		}
		if (phase === "ready") {
			text(zh ? "源码已就绪，选择下一步。" : "Source is ready. Choose what to do next.", 13);
			if (targets.length > 1) text(zh ? "选择打开位置" : "Choose an IDE", 12);
			for (let i = 0; i < targets.length; i++) {
				const target = targets[i];
				const caption = target.embedded ? (zh ? "在内置 IDE 中打开" : "Open in embedded IDE") : `${zh ? "在浏览器 IDE 中打开" : "Open in browser IDE"}${targets.filter(t => !t.embedded).length > 1 ? ` (${target.id.slice(-4)})` : ""}`;
				add(toNode(<MobileButton tag={`import-ide-${i}`} x={0} y={0} width={contentWidth} height={42} fontSize={14} primary={i === 0} text={caption} onTapped={() => open(target)} />), 42);
			}
		}
		if (message !== "") text(details ? message : message.substring(0, 130), 12, phase === "error" ? 0xff8585 : 0xa8afbd);
		if (phase === "error") add(toNode(<MobileButton tag="import-details" x={0} y={0} width={contentWidth} height={32} fontSize={12} text={details ? (zh ? "收起详情" : "Hide details") : (zh ? "查看详情" : "Show details")} onTapped={() => {details = !details; render();}} />), 32);
		const viewHeight = height - 154, contentHeight = math.max(viewHeight, top);
		scroll = ScrollArea({width: width - 48, height: viewHeight, viewWidth: width - 48, viewHeight: contentHeight, paddingX: 0, paddingY: 0, scrollBar: true}) as Scroll;
		scroll.offset = Vec2(0, math.min(offset, math.max(0, contentHeight - viewHeight)));
		const body = Node(); body.anchor = Vec2.zero; body.size = Size(contentWidth, contentHeight); body.y = viewHeight - contentHeight;
		for (const item of items) {item.node.y = contentHeight - item.top - (item.label ? 0 : item.node.height); body.addChild(item.node);}
		body.addTo(scroll.view);
		const scene = toNode(<node>
			<draw-node><rect-shape width={App.visualSize.width} height={App.visualSize.height} fillColor={0xff10151d} /></draw-node>
			<node x={left} y={bottom} width={width} height={height} anchorX={0} anchorY={0}>
				<MobilePanelSurface width={width} height={height} />
				<label x={24} y={height - 24} anchorX={0} anchorY={1} fontName="sarasa-mono-sc-regular" fontSize={22} text={title} color3={0xf4f1e8} />
				<custom-node x={width / 2} y={86 + viewHeight / 2} onCreate={() => scroll} />
				<MobileButton tag="import-close" x={24} y={24} width={hasFooterPrimary ? buttonWidth : width - 48} text={phase === "busy" || phase === "opening" ? (zh ? "取消" : "Cancel") : (zh ? "完成" : "Done")} fontSize={14} onTapped={finish} />
				{phase === "input" || phase === "error" ? <MobileButton tag="import-primary" x={36 + buttonWidth} y={24} width={buttonWidth} primary={true} text={phase === "error" ? (zh ? "重试" : "Retry") : (zh ? "导入项目" : "Import")} fontSize={14} onTapped={begin} /> : undefined}
				{phase === "ready" && targets.length === 0 ? <MobileButton tag="import-primary" x={36 + buttonWidth} y={24} width={buttonWidth} primary={true} text={zh ? "查看项目" : "View project"} fontSize={14} onTapped={() => {emit("RepositoryImportReveal", project!.entry);}} /> : undefined}
			</node>
		</node>);
		scene?.addTo(host);
	};
	host.onCleanup(() => {disposed = true; if (operation) operation.canceled = true; input.unmount();});
	host.onAppChange(setting => {if (setting === "Size") render();});
	host.onAppEvent(event => {if (event === "BackButton") finish();});
	host.schedule(() => {
		if (App.runningTime - lastRefresh < 0.15) return false;
		lastRefresh = App.runningTime;
		if ((phase === "busy" && (shownPhase !== operation?.phase || progressBucket !== math.floor((operation?.status?.progress ?? 0) * 100))) || (phase === "ready" && targetKey !== getTargets().map(t => t.id).join(","))) render();
		return false;
	});
	attachGamepad(host, {initialTag: "import-primary", onBack: finish, onScroll: amount => {if (scroll) scroll.offset = Vec2(0, math.max(0, math.min(scroll.view.height - scroll.height, scroll.offset.y + amount)));}});
	render(); if (repository) begin();
}
