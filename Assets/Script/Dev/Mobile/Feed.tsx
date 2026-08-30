import { React, reference, toNode } from "DoraX";
import { App, Director, Ease, HttpServer, Move, Node, sleep, Sprite, TextAlign, thread, Vec2 } from "Dora";
import { DoraMascot } from "Dev/Mobile/Mascot";
import { mobileFontScale } from "Dev/Mobile/Accessibility";
import { getCoverScales, getReusableCardIndices, normalizeFeedIndex, resolveDiscoverRefreshTab, resolveFeedGesture, resolveFeedLocation, stableCoverColor, type FeedAction, type FeedEntry as ModelFeedEntry, type FeedTab } from "Dev/Mobile/FeedModel";

interface FeedEntry extends ModelFeedEntry {
	resource?: unknown;
	catalogCommit?: string;
	launchError?: string;
}

interface MobileFeedOptions {
	initialEntry?: FeedEntry;
	getLocalEntries: (this: void) => FeedEntry[];
	getDiscoverEntries: (this: void) => FeedEntry[];
	syncDiscover?: (this: void, onProgress: (this: void, message: string) => void, onDone: (this: void, success: boolean, message?: string) => void) => void;
	onPlay: (this: void, entry: FeedEntry) => void;
	onRemix: (this: void, entry: FeedEntry) => void;
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

function Button(props: {
	tag?: string;
	x: number;
	y: number;
	width: number;
	text: string;
	fontSize?: number;
	primary?: boolean;
	onTapped(): void;
}) {
	return <node
		tag={props.tag}
		x={props.x}
		y={props.y}
		anchorX={0}
		anchorY={0}
		width={props.width}
		height={48}
		touchEnabled={true}
		swallowTouches={true}
		onTapped={props.onTapped}
	>
		<draw-node x={props.width / 2} y={24}>
			<rect-shape
				width={props.width}
				height={48}
				fillColor={props.primary ? colors.brand : colors.panelRaised}
				borderWidth={1}
				borderColor={props.primary ? colors.brand : colors.border}
			/>
		</draw-node>
		<label
			x={props.width / 2}
			y={24}
			fontName={fontName}
			fontSize={props.fontSize ?? 17}
			text={props.text}
			color3={props.primary ? 0x17130a : 0xf4f1e8}
		/>
	</node>;
}

function Cover(props: { key?: string; entry: FeedEntry; x: number; y: number; width: number; height: number }) {
	const file = props.entry.bannerFile;
	const scaleSprite = (sprite: Sprite.Type, mode: "contain" | "cover") => {
		const scales = getCoverScales(sprite.width, sprite.height, props.width, props.height);
		sprite.scaleX = scales[mode];
		sprite.scaleY = scales[mode];
	};
	return <node x={props.x} y={props.y} width={props.width} height={props.height} anchorX={0} anchorY={0}>
		<draw-node x={props.width / 2} y={props.height / 2}>
			<rect-shape
				width={props.width}
				height={props.height}
				fillColor={stableCoverColor(props.entry.id)}
				borderWidth={1}
				borderColor={colors.border}
			/>
		</draw-node>
		{file ? <clip-node width={props.width} height={props.height} anchorX={0} anchorY={0} stencil={<draw-node x={props.width / 2} y={props.height / 2}>
			<rect-shape width={props.width} height={props.height} fillColor={0xffffffff} />
		</draw-node>}>
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
	</node>;
}

export function startMobileFeed(options: MobileFeedOptions) {
	const getLocalEntries = options.getLocalEntries;
	const getDiscoverEntries = options.getDiscoverEntries;
	const onPlay = options.onPlay;
	const onRemix = options.onRemix;
	const prepare = options.prepare;
	const syncDiscover = options.syncDiscover;
	const zh = string.match(App.locale, "^zh")[0] !== undefined;
	let tab: FeedTab = "local";
	let index = 0;
	let detailsOpen = false;
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
	let returnEntry = options.initialEntry;
	const cardRef = reference<Node.Type>();
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

	const setTab = (next: FeedTab) => {
		if (!isActive() || !host.visible || HttpServer.wsConnectionCount > 0 || preparing) return;
		userSelectedTab = true;
		returnEntry = undefined;
		if (tab === next) return;
		tab = next;
		index = 0;
		detailsOpen = false;
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
					detailsOpen = false;
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
		if (!isActive() || !host.visible || HttpServer.wsConnectionCount > 0 || preparing || transitioning || !options.onSwitchMode) return;
		leaving = true;
		options.onSwitchMode();
	};
	host.slot("SwitchUIMode", switchMode);
	const render = () => {
		if (!isActive()) return;
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
		const data = entries();
		index = normalizeFeedIndex(index, data.length);
		const item = current();
		const coverWidth = wide ? math.min(usableWidth * 0.54, 680) : usableWidth - 32;
		const coverHeight = wide ? math.min(usableHeight - 118, coverWidth * 0.72) : math.min(usableHeight * 0.49, coverWidth * 0.72);
		const coverX = left + 16;
		const coverY = wide ? bottom + (usableHeight - coverHeight) / 2 - 12 : bottom + usableHeight - coverHeight - 82;
		const infoX = wide ? coverX + coverWidth + 28 : left + 20;
		const infoWidth = wide ? usableWidth - coverWidth - 72 : usableWidth - 40;
		const infoTop = wide ? bottom + usableHeight - 122 : coverY - 30;
		const buttonWidth = wide ? math.min(190, (infoWidth - 12) / 2) : (infoWidth - 12) / 2;
		const fontScale = mobileFontScale;
		const cardIndices = getReusableCardIndices(index, data.length);

		const scene = toNode(<node
			tag="mobile-feed-scene"
			x={-width / 2}
			y={-height / 2}
			width={width}
			height={height}
				anchorX={0}
				anchorY={0}
			touchEnabled={true}
			onTapBegan={() => { drag = Vec2.zero; dragAxis = "none"; cardRef.current?.stopAllActions(); }}
			onTapMoved={touch => {
				drag = drag.add(touch.delta);
				if (dragAxis === "none" && math.max(math.abs(drag.x), math.abs(drag.y)) >= 12) {
					dragAxis = math.abs(drag.x) > math.abs(drag.y) * 1.2 ? "horizontal" : "vertical";
				}
				if (cardRef.current) {
					cardRef.current.position = dragAxis === "horizontal" ? Vec2(drag.x * 0.18, 0) : dragAxis === "vertical" ? Vec2(0, drag.y * 0.12) : Vec2.zero;
				}
			}}
			onTapEnded={() => {
				const action = resolveFeedGesture(drag.x, drag.y, usableWidth, usableHeight);
				drag = Vec2.zero;
				dragAxis = "none";
				if (action === "none" && cardRef.current) {
					const card = cardRef.current;
					card.perform(Move(App.reducedMotion ? 0 : 0.16, card.position, Vec2.zero, Ease.OutQuad));
				}
				commit(action);
			}}
			onMouseWheel={delta => commit(delta.y > 0 ? "previous" : "next")}
		>
			<draw-node x={width / 2} y={height / 2}>
				<rect-shape width={width} height={height} fillColor={colors.background} />
			</draw-node>
			{options.onSwitchMode ? <node tag="mobile-ui-mode-switch" x={left + 12} y={bottom + usableHeight - 56} width={72} height={44}
				anchorX={0} anchorY={0} touchEnabled={true} swallowTouches={true} onTapped={switchMode}>
				<draw-node x={36} y={22}><rect-shape width={72} height={44} fillColor={colors.panelRaised} borderWidth={1} borderColor={colors.border} /></draw-node>
				<label x={36} y={22} fontName={fontName} fontSize={13} text={zh ? "传统模式" : "Classic UI"} color3={preparing ? 0x777e8c : 0xf4f1e8} />
			</node> : undefined}
			<label tag="mobile-feed-discover-tab" x={left + usableWidth / 2 - (options.onSwitchMode ? 40 : 70)} y={bottom + usableHeight - 34} fontName={fontName} fontSize={math.floor(18 * fontScale)}
				text={zh ? "发现" : "Discover"} color3={tab === "discover" ? 0xffcc33 : 0xa8afbd}
				touchEnabled={true} swallowTouches={true} onTapped={() => setTab("discover")} />
			<label tag="mobile-feed-local-tab" x={left + usableWidth / 2 + (options.onSwitchMode ? 56 : 70)} y={bottom + usableHeight - 34} fontName={fontName} fontSize={math.floor(18 * fontScale)}
				text={zh ? "本地" : "Local"} color3={tab === "local" ? 0xffcc33 : 0xa8afbd}
				touchEnabled={true} swallowTouches={true} onTapped={() => { local = getLocalEntries(); setTab("local"); }} />
				{item !== undefined ? <node tag={`mobile-feed-card-${item.id}`} ref={cardRef} key={`${tab}-${item.id}`}>
					{cardIndices.map(cardIndex => <Cover
						key={`${tab}-${data[cardIndex].id}`}
						entry={data[cardIndex]}
						x={coverX}
						y={coverY + (index - cardIndex) * usableHeight}
						width={coverWidth}
						height={coverHeight}
					/>)}
					<label tag="mobile-feed-current-title" x={infoX} y={infoTop} anchorX={0} anchorY={0.5} fontName={fontName} fontSize={math.floor((wide ? 30 : 25) * fontScale)}
						text={item.title} textWidth={infoWidth} alignment={TextAlign.Left} color3={0xf4f1e8} />
					<label x={infoX} y={infoTop - 58} anchorX={0} anchorY={0.5} fontName={fontName} fontSize={math.floor(15 * fontScale)}
						text={item.description} textWidth={infoWidth} alignment={TextAlign.Left} color3={0xa8afbd} />
				<Button tag="mobile-feed-remix" x={infoX} y={bottom + 24} width={buttonWidth} text={zh ? "Remix" : "Remix"} fontSize={math.floor(17 * fontScale)}
					primary={true} onTapped={() => activate("remix")} />
				<Button tag="mobile-feed-play" x={infoX + buttonWidth + 12} y={bottom + 24} width={buttonWidth} text={zh ? "试玩" : "Play"} fontSize={math.floor(17 * fontScale)}
					onTapped={() => activate("play")} />
					<label x={infoX} y={bottom + 92} anchorX={0} anchorY={0.5} fontName={fontName} fontSize={14}
					text={prepareStatus !== "" ? prepareStatus : item.launchError !== undefined ? item.launchError : `${index + 1} / ${data.length}  ·  ${zh ? "上滑下一项 · 右滑 Remix · 左滑试玩" : "Swipe up next · right Remix · left Play"}`}
						textWidth={infoWidth} alignment={TextAlign.Left} color3={item.launchError !== undefined ? 0xff6b6b : 0xa8afbd} />
					<label x={infoX + infoWidth} y={infoTop} anchorX={1} anchorY={0.5} fontName={fontName} fontSize={14}
					text={zh ? "详情" : "Details"} color3={0xffcc33} touchEnabled={true} swallowTouches={true}
					onTapped={() => { detailsOpen = !detailsOpen; render(); }} />
				{detailsOpen ? <node x={left + 12} y={bottom + 10} width={usableWidth - 24} height={math.min(usableHeight * 0.48, 360)} anchorX={0} anchorY={0}
					touchEnabled={true} swallowTouches={true}>
					<draw-node x={(usableWidth - 24) / 2} y={math.min(usableHeight * 0.48, 360) / 2}>
						<rect-shape width={usableWidth - 24} height={math.min(usableHeight * 0.48, 360)} fillColor={colors.panelRaised} borderWidth={1} borderColor={colors.border} />
					</draw-node>
						<label x={20} y={math.min(usableHeight * 0.48, 360) - 36} anchorX={0} anchorY={0.5} fontName={fontName} fontSize={18}
							text={item.title} textWidth={usableWidth - 64} alignment={TextAlign.Left} color3={0xf4f1e8} />
						<label x={20} y={math.min(usableHeight * 0.48, 360) - 88} anchorX={0} anchorY={0.5} fontName={fontName} fontSize={15}
							text={item.description} textWidth={usableWidth - 64} alignment={TextAlign.Left} color3={0xa8afbd} />
				</node> : undefined}
			</node> : <node>
				<label x={left + usableWidth / 2} y={bottom + usableHeight / 2 + 20} fontName={fontName} fontSize={22}
					text={tab === "discover" ? (zh ? "暂无移动作品" : "No mobile games yet") : (zh ? "没有可运行的本地作品" : "No runnable local games")}
					color3={0xf4f1e8} />
				<label x={left + usableWidth / 2} y={bottom + usableHeight / 2 - 28} fontName={fontName} fontSize={14}
					text={tab === "discover" && discoverError !== "" ? discoverError : (zh ? "切换标签或稍后重试" : "Switch tabs or retry later")}
					textWidth={usableWidth - 48} color3={tab === "discover" && discoverError !== "" ? 0xff6b6b : 0xa8afbd} />
			</node>}
		</node>);
		if (scene !== undefined) host.addChild(scene);
	};

	host.onAppChange(setting => {
		if (setting === "Size" || setting === "Locale") render();
	});
	host.onAppEvent(event => {
		if (event === "BackButton" && detailsOpen) {
			detailsOpen = false;
			render();
		}
	});
	host.onCleanup(() => { active = false; });
	host.slot("RestoreFeedEntry", (entry: FeedEntry) => {
		if (!isActive() || HttpServer.wsConnectionCount > 0) return;
		returnEntry = entry;
		local = getLocalEntries();
		discover = getDiscoverEntries();
		const location = resolveFeedLocation(local, discover, entry);
		tab = location.tab;
		index = location.index;
		detailsOpen = false;
		render();
	});
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
			const selected = returnEntry ?? current();
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
