import { React, reference, toNode } from "DoraX";
import { App, Director, Ease, HttpServer, Move, Node, sleep, Sprite, TextAlign, thread, Vec2 } from "Dora";
import { DoraMascot } from "Dev/Mobile/Mascot";
import { mobileFontScale } from "Dev/Mobile/Accessibility";
import { getCoverScales, getReusableCardIndices, normalizeFeedIndex, resolveDiscoverRefreshTab, resolveFeedGesture, resolveFeedLocation, stableCoverColor, type FeedAction, type FeedEntry as ModelFeedEntry, type FeedTab } from "Dev/Mobile/FeedModel";
import { createTextInput } from "Dev/Mobile/TextInput";
import { MobileButton, MobilePanelSurface } from "Dev/Mobile/Controls";
import { RoundedStencil, RoundedSurface, VerticalGradient } from "Dev/Mobile/Visual";

interface FeedEntry extends ModelFeedEntry {
	resource?: unknown;
	catalogCommit?: string;
	launchError?: string;
}

interface MobileFeedOptions {
	initialEntry?: FeedEntry;
	initialEntries?: { local?: FeedEntry; discover?: FeedEntry };
	getLocalEntries: (this: void) => FeedEntry[];
	getDiscoverEntries: (this: void) => FeedEntry[];
	syncDiscover?: (this: void, onProgress: (this: void, message: string) => void, onDone: (this: void, success: boolean, message?: string) => void) => void;
	onPlay: (this: void, entry: FeedEntry) => void;
	onRemix: (this: void, entry: FeedEntry) => void;
	onCurrentEntryChanged?: (this: void, entry: FeedEntry) => void;
	createProject?: (this: void, name: string) => { success: true; entry: FeedEntry } | { success: false; error: string };
	onSwitchMode?: (this: void) => void;
	prepare: (this: void, entry: FeedEntry, repairIncomplete: boolean, onProgress: (this: void, progress: number, message: string) => void, onDone: (this: void, success: boolean, ready?: { fileName: string; workDir: string }, message?: string, repairable?: boolean) => void) => void;
}

const colors = {
	background: 0xff0b0d12,
	panel: 0xff151922,
	panelRaised: 0xff202632,
	text: 0xfff4f1e8,
	muted: 0xffa8afbd,
	brand: 0xffffcc33,
	border: 0xff343b48,
	danger: 0xffff6b6b,
};

const fontName = "sarasa-mono-sc-regular";
const createSheetHeight = 260;
const createInputHeight = 44;
const createInputTop = 96;

function conciseDescription(text: string, limit: number) {
	const length = utf8.len(text)[0] ?? 0;
	if (length <= limit) return text;
	const stop = utf8.offset(text, limit + 1) ?? text.length + 1;
	return string.sub(text, 1, stop - 1) + "…";
}

function Cover(props: { key?: string; entry: FeedEntry; x: number; y: number; width: number; height: number }) {
	const file = props.entry.bannerFile;
	const scaleSprite = (sprite: Sprite.Type, mode: "contain" | "cover") => {
		const scales = getCoverScales(sprite.width, sprite.height, props.width, props.height);
		sprite.scaleX = scales[mode];
		sprite.scaleY = scales[mode];
	};
	return <node x={props.x} y={props.y} width={props.width} height={props.height} anchorX={0} anchorY={0}>
		<RoundedSurface width={props.width} height={props.height} radius={22}
			topColor={stableCoverColor(props.entry.id)} bottomColor={0xff111723} shadow={true} />
		{file ? <clip-node width={props.width} height={props.height} anchorX={0} anchorY={0} stencil={<RoundedStencil width={props.width} height={props.height} radius={22} />}>
			<sprite file={file} x={props.width / 2 - 5} y={props.height / 2} opacity={0.08} onMount={sprite => scaleSprite(sprite, "cover")} />
			<sprite file={file} x={props.width / 2 + 5} y={props.height / 2} opacity={0.08} onMount={sprite => scaleSprite(sprite, "cover")} />
			<sprite file={file} x={props.width / 2} y={props.height / 2 - 5} opacity={0.08} onMount={sprite => scaleSprite(sprite, "cover")} />
			<draw-node x={props.width / 2} y={props.height / 2}>
				<rect-shape width={props.width} height={props.height} fillColor={0xb00b0d12} />
			</draw-node>
			<sprite file={file} x={props.width / 2} y={props.height / 2} onMount={sprite => scaleSprite(sprite, "contain")} />
		</clip-node> : <label
			x={props.width / 2}
			y={props.height / 2 + 10}
			fontName={fontName}
			fontSize={math.floor(math.max(22, math.min(34, props.width / 12)))}
			text={props.entry.title}
			textWidth={props.width - 40}
			color3={0xf4f1e8}
		/>}
		{file ? undefined : <label
			x={props.width / 2}
			y={30}
			fontName={fontName}
			fontSize={14}
			text="DORA SSR · REMIXABLE"
			color3={0xffcc33}
		/>}
		{file ? undefined : <DoraMascot state="idle" x={props.width - 46} y={64} size={42} />}
		<RoundedSurface width={props.width} height={props.height} radius={22} fillColor={0x00000000} borderWidth={1} borderColor={0xff3b4556} />
	</node>;
}

export function startMobileFeed(options: MobileFeedOptions) {
	const getLocalEntries = options.getLocalEntries;
	const getDiscoverEntries = options.getDiscoverEntries;
	const onPlay = options.onPlay;
	const onRemix = options.onRemix;
	const prepare = options.prepare;
	const syncDiscover = options.syncDiscover;
	let zh = string.match(App.locale, "^zh")[0] !== undefined;
	let tab: FeedTab = "local";
	let index = 0;
	let drag = Vec2.zero;
	let dragAxis: "none" | "horizontal" | "vertical" = "none";
	let discoverError = "";
	let preparing = false;
	let transitioning = false;
	let prepareStatus = "";
	let repairResourceId = "";
	let userSelectedTab = false;
	let active = true;
	let leaving = false;
	let createOpen = false;
	let creating = false;
	let createName = "";
	let dismissedCreateComposition = false;
	let createError = "";
	let returnEntry = options.initialEntry;
	const rememberedEntries: { local?: FeedEntry; discover?: FeedEntry } = {
		local: options.initialEntries?.local,
		discover: options.initialEntries?.discover,
	};
	const cardRef = reference<Node.Type>();
	const indexRef = reference<Node.Type>();
	let createInputRef = reference<Node.Type>();
	let discover = getDiscoverEntries();
	let local = getLocalEntries();

	if (discover.length === 0) {
		discoverError = zh ? "资源目录暂不可用" : "Catalog is unavailable";
	}
	const initialLocation = resolveFeedLocation(local, discover, returnEntry);
	tab = initialLocation.tab;
	index = initialLocation.index;

	const host = Node();
	host.tag = "mobile-feed";
	host.scaleX = App.devicePixelRatio;
	host.scaleY = App.devicePixelRatio;
	host.addTo(Director.systemUI);
	// Cleanup is posted for a later frame; detachment must invalidate callbacks now.
	const isActive = () => active && !leaving && host.parent !== undefined;

	const entries = () => tab === "discover" ? discover : local;
	const current = () => entries()[normalizeFeedIndex(index, entries().length)];
	let rememberedEntryKey = "";
	const rememberCurrent = () => {
		const item = current();
		if (!item || !options.onCurrentEntryChanged) return;
		const key = `${item.kind}\n${item.id}\n${item.workDir ?? ""}\n${item.fileName ?? ""}`;
		if (key === rememberedEntryKey) return;
		rememberedEntryKey = key;
		rememberedEntries[item.kind] = item;
		options.onCurrentEntryChanged(item);
	};
	const canEditCreate = () => createOpen && !creating && isActive() && host.visible && HttpServer.wsConnectionCount === 0;
	const createInput = createTextInput({
		fontSize: math.floor(16 * mobileFontScale),
		singleLine: true,
		background: colors.background,
		getText: () => createName,
		setText: text => { createName = text; },
		getPlaceholder: () => zh ? "例如：星际花园" : "For example: Star Garden",
		isEnabled: canEditCreate,
		onReturn: () => { submitCreate(); return true; },
	});
	const blurCreateInput = createInput.blur;
	const closeCreate = () => {
		if (creating) return;
		blurCreateInput();
		createOpen = false;
		createName = "";
		createError = "";
		render();
	};
	const createErrorText = (error: string) => {
		switch (error) {
			case "invalid-name": return zh ? "请输入不含路径分隔符的项目名称" : "Enter a project name without path separators";
			case "target-existed": return zh ? "已有同名项目，请换一个名称" : "A project with that name already exists";
			case "create-folder-failed": return zh ? "无法创建项目目录，请检查工作目录后重试" : "Could not create the project folder; check the workspace and retry";
			case "create-entry-failed": return zh ? "无法写入项目入口，未完成项目已回滚" : "Could not write the project entry; the incomplete project was rolled back";
			case "created-project-not-found": return zh ? "项目已创建，但本地列表未能找到它，请返回后重试" : "The project was created but could not be found in Local; return and retry";
			default: return zh ? "创建失败，请重试" : "Project creation failed; try again";
		}
	};
	const submitCreate = () => {
		if (!options.createProject || creating || !createOpen || !isActive() || !host.visible || HttpServer.wsConnectionCount > 0) return;
		if (createInput.isComposing()) return;
		creating = true;
		createError = "";
		blurCreateInput();
		render();
		const result = options.createProject(createName);
		if (!isActive()) return;
		creating = false;
		if (!result.success) {
			createError = createErrorText(result.error);
			render();
			return;
		}
		createOpen = false;
		createName = "";
		local = getLocalEntries();
		returnEntry = result.entry;
		const location = resolveFeedLocation(local, discover, result.entry);
		tab = location.tab;
		index = location.index;
		render();
		onRemix(result.entry);
	};

	const setTab = (next: FeedTab) => {
		if (!isActive() || !host.visible || HttpServer.wsConnectionCount > 0 || preparing || creating) return;
		userSelectedTab = true;
		returnEntry = undefined;
		if (tab === next) return;
		if (createOpen) {
			blurCreateInput();
			createOpen = false;
			createName = "";
			createError = "";
		}
		tab = next;
		const target = rememberedEntries[next];
		const location = target === undefined ? undefined : resolveFeedLocation(local, discover, target);
		index = location?.tab === next ? location.index : 0;
		render();
	};
	const activate = (action: "play" | "remix") => {
		const item = current();
		if (!isActive() || !host.visible || HttpServer.wsConnectionCount > 0 || !item || preparing) return;
		item.launchError = undefined;
		const done = () => { returnEntry = item; return action === "play" ? onPlay(item) : onRemix(item); };
		if (item.kind === "local" || item.installed) { done(); return; }
		preparing = true;
		prepareStatus = zh ? "准备安装…" : "Preparing install…";
		render();
		const repairIncomplete = repairResourceId === item.id;
		repairResourceId = "";
		prepare(item, repairIncomplete, (progress, message) => {
			if (!isActive()) return;
			prepareStatus = `${math.floor(progress * 100)}% · ${message}`;
			render();
		}, (success, ready, message, repairable) => {
			if (!isActive()) return;
			preparing = false;
			if (!success || !ready) {
				repairResourceId = repairable ? item.id : "";
				prepareStatus = message ?? (zh ? "安装失败，点击按钮重试" : "Install failed; tap to retry");
				render();
				return;
			}
			item.fileName = ready.fileName;
			item.workDir = ready.workDir;
			item.installed = true;
			prepareStatus = "";
			if (HttpServer.wsConnectionCount === 0 && host.visible) done();
			else render();
		});
	};

	const commit = (action: FeedAction) => {
		if (!isActive() || !host.visible || HttpServer.wsConnectionCount > 0 || preparing || transitioning) return;
		if (action === "play" || action === "remix") {
			const card = cardRef.current;
			if (card) card.position = Vec2.zero;
		}
		switch (action) {
			case "previous":
			case "next": {
				returnEntry = undefined;
				const target = normalizeFeedIndex(index + (action === "next" ? 1 : -1), entries().length);
				if (target === index) {
					const card = cardRef.current;
					if (card) card.perform(Move(App.reducedMotion ? 0 : 0.16, card.position, Vec2.zero, Ease.OutQuad));
					return;
				}
				const duration = App.reducedMotion ? 0 : 0.18;
				const finish = () => {
					if (!isActive()) return;
					index = target;
					transitioning = false;
					App.vibrate(0.012);
					render();
				};
				const card = cardRef.current;
				if (duration > 0 && card) {
					transitioning = true;
					card.perform(Move(duration, card.position, Vec2(0, (action === "next" ? 1 : -1) * App.safeArea.height), Ease.OutQuad));
					thread(() => { sleep(duration); finish(); });
				} else finish();
				return;
			}
			case "play": activate("play"); return;
			case "remix": activate("remix"); return;
			default: return;
		}
	};

	const switchMode = () => {
		if (!isActive() || !host.visible || HttpServer.wsConnectionCount > 0 || preparing || creating || createOpen || transitioning || !options.onSwitchMode) return;
		leaving = true;
		options.onSwitchMode();
	};
	host.slot("SwitchUIMode", switchMode);
	const render = () => {
		if (!isActive()) return;
		// Catalog updates must not replace an active IME target or discard its preedit.
		const safeContentWidth = App.safeArea.width - 40;
		const shortLandscapeInputWidth = safeContentWidth - 12 - math.min(300, math.floor(safeContentWidth * 0.42));
		const expectedInputWidth = App.safeArea.width >= 760 && App.safeArea.height < 500 ? shortLandscapeInputWidth : safeContentWidth;
		const keptInput = createOpen && createInputRef.current?.width === expectedInputWidth ? createInputRef.current : undefined;
		const restoreFocus = createInput.isFocused();
		keptInput?.removeFromParent(false);
		if (!keptInput) {
			createInput.unmount();
			createInputRef = reference<Node.Type>();
		}
		const createPanelRef = reference<Node.Type>();
		host.removeAllChildren();
		host.scaleX = App.devicePixelRatio;
		host.scaleY = App.devicePixelRatio;
		const { width, height } = App.visualSize;
		const safe = App.safeArea;
		const left = safe.left;
		const bottom = safe.bottom;
		const usableWidth = safe.width;
		const usableHeight = safe.height;
		const wide = usableWidth >= 760;
		const shortLandscape = wide && usableHeight < 500;
		const compact = !wide && usableHeight < 700;
		const compactLandscape = compact && usableWidth > usableHeight && usableHeight < 520;
		const landscapeTopLift = shortLandscape ? 28 : 0;
		const data = entries();
		index = normalizeFeedIndex(index, data.length);
		const item = current();
		rememberCurrent();
		const coverWidth = wide ? math.min(usableWidth * 0.54, 680) : usableWidth - 32;
		const coverHeight = wide
			? math.min(usableHeight - 118, coverWidth * 0.72)
			: compact
				? math.min(usableHeight * (compactLandscape ? 0.43 : 0.49), coverWidth * 0.72)
				: math.min(usableHeight * 0.54, coverWidth * 1.12);
		const coverX = left + 16;
		const coverY = wide ? bottom + (usableHeight - coverHeight) / 2 - 12 + landscapeTopLift : bottom + usableHeight - coverHeight - 82;
		const infoX = wide ? coverX + coverWidth + 28 : left + 20;
		const infoWidth = wide ? usableWidth - coverWidth - 72 : usableWidth - 40;
		const infoTop = wide ? bottom + usableHeight - 122 + landscapeTopLift : coverY - (compactLandscape ? 28 : 30);
		const descriptionY = infoTop - (compactLandscape ? 38 : 58);
		const actionsY = bottom + (compactLandscape ? 18 : 24);
		const gestureHintY = bottom + (compactLandscape ? 88 : 92);
		const buttonWidth = wide ? math.min(190, (infoWidth - 12) / 2) : (infoWidth - 12) / 2;
		const fontScale = mobileFontScale;
		const cardIndices = getReusableCardIndices(index, data.length);
		const headerRenderOrder = 1000;

		const scene = toNode(<node
			tag="mobile-feed-scene"
			x={-width / 2}
			y={-height / 2}
			width={width}
			height={height}
				anchorX={0}
				anchorY={0}
			touchEnabled={true}
			onTapBegan={() => {
				drag = Vec2.zero;
				dragAxis = "none";
				cardRef.current?.stopAllActions();
				if (indexRef.current) indexRef.current.opacity = 1;
			}}
			onTapMoved={touch => {
				drag = drag.add(touch.delta);
				if (dragAxis === "none" && math.max(math.abs(drag.x), math.abs(drag.y)) >= 12) {
					dragAxis = math.abs(drag.x) > math.abs(drag.y) * 1.2 ? "horizontal" : "vertical";
				}
				if (cardRef.current) {
					const offset = dragAxis === "horizontal" ? Vec2(drag.x * 0.18, 0) : dragAxis === "vertical" ? Vec2(0, drag.y * 0.12) : Vec2.zero;
					cardRef.current.position = offset;
					if (indexRef.current) {
						const headerBottom = bottom + usableHeight - 72;
						const indexTop = coverY + coverHeight - 14 + offset.y;
						indexRef.current.opacity = dragAxis === "vertical"
							? math.max(0, math.min(1, (headerBottom - indexTop) / 16))
							: 1;
					}
				}
			}}
			onTapEnded={() => {
				const action = resolveFeedGesture(drag.x, drag.y, usableWidth, usableHeight);
				drag = Vec2.zero;
				dragAxis = "none";
				if (indexRef.current) indexRef.current.opacity = 1;
				if (action === "none" && cardRef.current) {
					const card = cardRef.current;
					card.perform(Move(App.reducedMotion ? 0 : 0.16, card.position, Vec2.zero, Ease.OutQuad));
				}
				commit(action);
			}}
			onMouseWheel={delta => commit(delta.y > 0 ? "previous" : "next")}
		>
			<VerticalGradient width={width} height={height} topColor={0xff111725} bottomColor={0xff080a0f} />
				{createOpen ? undefined : item !== undefined ? <node tag={`mobile-feed-card-${item.id}`} ref={cardRef} key={`${tab}-${item.id}`}>
					{cardIndices.map(cardIndex => <Cover
						key={`${tab}-${data[cardIndex].id}`}
						entry={data[cardIndex]}
						x={coverX}
						y={coverY + (index - cardIndex) * usableHeight}
						width={coverWidth}
						height={coverHeight}
					/>)}
					<node tag="mobile-feed-index" ref={indexRef} x={coverX + coverWidth - 62} y={coverY + coverHeight - 40} width={48} height={26} anchorX={0} anchorY={0}>
						<RoundedSurface width={48} height={26} radius={13} topColor={0xe028303d} bottomColor={0xe012161e} borderWidth={1} borderColor={0x88505a6c} />
						<label x={24} y={13} fontName={fontName} fontSize={11} text={`${index + 1} / ${data.length}`} color3={0xd7dbe3} />
					</node>
					<label tag="mobile-feed-current-title" x={infoX} y={infoTop} anchorX={0} anchorY={0.5} fontName={fontName} fontSize={math.floor((wide ? 30 : 25) * fontScale)}
						text={item.title} textWidth={infoWidth} alignment={TextAlign.Left} color3={0xf4f1e8} />
					<label tag="mobile-feed-description" x={infoX} y={descriptionY} anchorX={0} anchorY={0.5} fontName={fontName} fontSize={math.floor(15 * fontScale)}
						text={conciseDescription(item.description, wide ? 80 : compact ? 28 : 42)} textWidth={infoWidth} alignment={TextAlign.Left} color3={0xa8afbd} />
					{compact || shortLandscape ? undefined : <node x={infoX} y={infoTop - 118} width={wide ? 176 : 164} height={28} anchorX={0} anchorY={0}>
						<RoundedSurface width={wide ? 176 : 164} height={28} radius={14} topColor={0x66303a4b} bottomColor={0x6618202b} borderWidth={1} borderColor={0x88606b7d} />
						<label x={12} y={14} anchorX={0} fontName={fontName} fontSize={12}
							text={item.kind === "local" ? (zh ? "本地作品  ·  可 Remix" : "Local  ·  Remixable") : item.installed ? (zh ? "发现  ·  已安装" : "Discover  ·  Installed") : (zh ? "发现  ·  可安装" : "Discover  ·  Installable")}
							textWidth={(wide ? 176 : 164) - 24} alignment={TextAlign.Left} color3={0xdce1ea} />
					</node>}
				<MobileButton tag="mobile-feed-remix" x={infoX} y={actionsY} width={buttonWidth} text={zh ? "Remix 作品" : "Remix game"} fontSize={math.floor(16 * fontScale)}
					primary={true} onTapped={() => activate("remix")} />
				<MobileButton tag="mobile-feed-play" x={infoX + buttonWidth + 12} y={actionsY} width={buttonWidth} text={zh ? "试玩" : "Play"} fontSize={math.floor(17 * fontScale)}
					onTapped={() => activate("play")} />
					<label tag="mobile-feed-gesture-hint" x={infoX} y={gestureHintY} anchorX={0} anchorY={0.5} fontName={fontName} fontSize={14}
					text={prepareStatus !== "" ? prepareStatus : item.launchError !== undefined ? item.launchError : (zh ? "上滑浏览  ·  右滑 Remix  ·  左滑试玩" : "Swipe up  ·  right Remix  ·  left Play")}
						textWidth={infoWidth} alignment={TextAlign.Left} color3={item.launchError !== undefined ? 0xff6b6b : 0xa8afbd} />
			</node> : <node>
				<label x={left + usableWidth / 2} y={bottom + usableHeight / 2 + 20} fontName={fontName} fontSize={22}
					text={tab === "discover" ? (zh ? "暂无移动作品" : "No mobile games yet") : (zh ? "没有可运行的本地作品" : "No runnable local games")}
					color3={0xf4f1e8} />
				<label x={left + usableWidth / 2} y={bottom + usableHeight / 2 - 28} fontName={fontName} fontSize={14}
					text={tab === "discover" && discoverError !== "" ? discoverError : (zh ? "切换标签或稍后重试" : "Switch tabs or retry later")}
					textWidth={usableWidth - 48} color3={tab === "discover" && discoverError !== "" ? 0xff6b6b : 0xa8afbd} />
			</node>}
			<node tag="mobile-feed-header" order={headerRenderOrder}>
				{options.onSwitchMode ? <node tag="mobile-ui-mode-switch" x={left + 12} y={bottom + usableHeight - 58 + landscapeTopLift} width={72} height={48}
					anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true} onTapped={switchMode}>
					<label x={0} y={30} anchorX={0} fontName={fontName} fontSize={16} text="DORA" color3={preparing ? 0x777e8c : 0xffcc33} />
					<label x={0} y={10} anchorX={0} fontName={fontName} fontSize={10} text={zh ? "切换传统界面" : "Classic UI"} color3={0x777e8c} />
				</node> : undefined}
				<label tag="mobile-feed-discover-tab" x={left + usableWidth / 2 - 44} y={bottom + usableHeight - 34 + landscapeTopLift} fontName={fontName} fontSize={math.floor(17 * fontScale)}
					text={zh ? "发现" : "Discover"} color3={tab === "discover" ? 0xffcc33 : 0xa8afbd}
					touchEnabled={true} swallowTouches={true} onTapped={() => setTab("discover")} />
				<label tag="mobile-feed-local-tab" x={left + usableWidth / 2 + 44} y={bottom + usableHeight - 34 + landscapeTopLift} fontName={fontName} fontSize={math.floor(17 * fontScale)}
					text={zh ? "本地" : "Local"} color3={tab === "local" ? 0xffcc33 : 0xa8afbd}
					touchEnabled={true} swallowTouches={true} onTapped={() => { local = getLocalEntries(); setTab("local"); }} />
				<RoundedSurface x={left + usableWidth / 2 + (tab === "discover" ? -58 : 30)} y={bottom + usableHeight - 56 + landscapeTopLift} width={28} height={3} radius={1.5} fillColor={colors.brand} renderOrder={headerRenderOrder + 1} />
				{tab === "local" && options.createProject ? <node tag="mobile-feed-create" x={left + usableWidth - 82} y={bottom + usableHeight - 56 + landscapeTopLift} width={70} height={44}
					anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true} onTapped={() => {
						if (preparing || transitioning || creating || createOpen || HttpServer.wsConnectionCount > 0) return;
						createOpen = true;
						createName = "";
						dismissedCreateComposition = false;
						createError = "";
						render();
						createInput.deferFocus();
					}}>
					<RoundedSurface width={70} height={44} radius={22} topColor={0x332c3442} bottomColor={0x33121921} borderWidth={1} borderColor={colors.brand} renderOrder={headerRenderOrder + 1} />
					<label x={35} y={22} fontName={fontName} fontSize={14} text={zh ? "+ 新建" : "+ New"} color3={0xffcc33} />
				</node> : undefined}
			</node>
			{createOpen ? (() => {
				const sheetHeight = math.min(createSheetHeight, usableHeight - 64);
				const sheetWidth = usableWidth;
				const contentWidth = sheetWidth - 40;
				const actionGap = 12;
				const actionsWidth = shortLandscape ? math.min(300, math.floor(contentWidth * 0.42)) : contentWidth;
				const inputWidth = shortLandscape ? contentWidth - actionGap - actionsWidth : contentWidth;
				const actionX = shortLandscape ? 20 + inputWidth + actionGap : 20;
				const actionY = shortLandscape ? sheetHeight - createInputTop - createInputHeight : 20;
				const cancelWidth = math.floor((actionsWidth - actionGap) * (shortLandscape ? 0.34 : 0.38));
					return <node tag="mobile-project-create-sheet" order={10000} width={width} height={height} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true}>
					<node tag="mobile-project-create-focus-observer" order={1000} width={width} height={height} anchorX={0} anchorY={0}
						touchEnabled={true} swallowTouches={false} swallowMouseWheel={false} onTapFilter={touch => {
							touch.enabled = false;
							if (!canEditCreate()) return;
							const input = createInputRef.current;
							const point = input?.convertToNodeSpace(touch.worldLocation);
							const inside = input && point && point.x >= 0 && point.y >= 0 && point.x <= input.width && point.y <= input.height;
							dismissedCreateComposition = !inside && createInput.isComposing();
							if (!inside) blurCreateInput();
						}} />
					<draw-node tag="mobile-project-create-backdrop" order={0} renderOrder={0} x={width / 2} y={bottom + sheetHeight + (height - bottom - sheetHeight) / 2}>
						<rect-shape width={width} height={height - bottom - sheetHeight} fillColor={0x8c000000} />
					</draw-node>
					<node ref={createPanelRef} order={10} renderOrder={10} x={left} y={bottom} width={sheetWidth} height={sheetHeight} anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true}>
						<MobilePanelSurface width={sheetWidth} height={sheetHeight} renderOrder={10} />
						<label x={20} y={sheetHeight - 24} anchorX={0} anchorY={1} fontName={fontName} fontSize={22} text={zh ? "新建项目" : "New project"} color3={0xf4f1e8} />
						<label x={20} y={sheetHeight - 66} anchorX={0} anchorY={1} fontName={fontName} fontSize={14} text={zh ? "项目名称" : "Project name"} color3={0xa8afbd} />
							{keptInput ? undefined : <node tag="mobile-project-create-input" ref={createInputRef} renderOrder={10} x={20} y={sheetHeight - createInputTop - createInputHeight} width={inputWidth} height={createInputHeight} anchorX={0} anchorY={0}
							onMount={createInput.mount} />}
						<label tag="mobile-project-create-error" x={20} y={shortLandscape ? sheetHeight - createInputTop + 12 : sheetHeight - createInputTop - createInputHeight - 12} anchorX={0} anchorY={1} fontName={fontName} fontSize={12}
							text={createError !== "" ? createError : (zh ? "将创建可运行的 TypeScript 起始项目" : "Creates a runnable TypeScript starter project")}
							textWidth={inputWidth} alignment={TextAlign.Left} color3={createError !== "" ? 0xff6b6b : 0xa8afbd} />
							<MobileButton tag="mobile-project-create-cancel" x={actionX} y={actionY} width={cancelWidth} text={zh ? "取消" : "Cancel"} renderOrder={10} onTapped={closeCreate} />
							<MobileButton tag="mobile-project-create-submit" x={actionX + cancelWidth + actionGap} y={actionY} width={actionsWidth - cancelWidth - actionGap}
								text={creating ? (zh ? "创建中…" : "Creating…") : (zh ? "创建并进入 Remix" : "Create and Remix")} primary={true} renderOrder={10} onTapped={() => { if (!dismissedCreateComposition) submitCreate(); dismissedCreateComposition = false; }} />
					</node>
				</node>;
			})() : undefined}
		</node>);
		if (scene !== undefined) host.addChild(scene);
		if (keptInput && createPanelRef.current) {
			keptInput.position = Vec2(20, math.min(createSheetHeight, usableHeight - 64) - createInputTop - createInputHeight);
			createPanelRef.current.addChild(keptInput);
		}
		createInput.refresh();
		if (restoreFocus && !keptInput && createOpen) createInput.focus(false);
	};

	host.onAppChange(setting => {
		if (setting === "Locale") {
			const activeEntry = current();
			zh = string.match(App.locale, "^zh")[0] !== undefined;
			local = getLocalEntries();
			discover = getDiscoverEntries();
			const location = resolveFeedLocation(local, discover, activeEntry);
			tab = location.tab;
			index = location.index;
			render();
		} else if (setting === "Size") render();
	});
	host.onAppEvent(event => {
		if (event === "BackButton") {
			if (createOpen && !creating) closeCreate();
		} else if (event === "WillEnterBackground" || event === "DidEnterBackground") blurCreateInput();
	});
	host.onCleanup(() => { blurCreateInput(); active = false; });
	host.slot("RestoreFeedEntry", (entry: FeedEntry) => {
		if (!isActive() || HttpServer.wsConnectionCount > 0) return;
		returnEntry = entry;
		local = getLocalEntries();
		discover = getDiscoverEntries();
		const location = resolveFeedLocation(local, discover, entry);
		tab = location.tab;
		index = location.index;
		render();
	});
	host.slot("SuspendLocalUI", blurCreateInput);
	host.slot("ResumeLocalUI", () => { leaving = false; render(); });
	render();
	if (syncDiscover) {
		if (discover.length === 0) {
			discoverError = zh ? "正在同步资源目录…" : "Syncing Catalog…";
			render();
		}
		syncDiscover(message => {
			if (!isActive() || discover.length > 0) return;
			discoverError = message;
			render();
		}, (success, message) => {
			if (!isActive()) return;
			const selected = returnEntry ?? rememberedEntries[tab] ?? current();
			const previousCount = discover.length;
			discover = getDiscoverEntries();
			discoverError = success
				? (discover.length === 0 ? (zh ? "目录中暂无可运行作品" : "No runnable Catalog games") : "")
				: (message ?? (zh ? "资源目录同步失败" : "Catalog sync failed"));
			tab = resolveDiscoverRefreshTab(tab, userSelectedTab, previousCount, discover.length, local.length);
			if (selected !== undefined) {
				const location = resolveFeedLocation(local, discover, selected);
				tab = location.tab;
				index = location.index;
			}
			if (tab === "discover") index = normalizeFeedIndex(index, discover.length);
			render();
		});
	}
	return host;
}
