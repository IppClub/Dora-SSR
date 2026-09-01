import { App, Color, Color3, DrawNode, Label, Node, Size, TextAlign, Vec2 } from "Dora";
import * as ScrollArea from "UI/Control/Basic/ScrollArea";
import type { AgentSessionDetailResult } from "Agent/Session";
import { safeJsonEncode } from "Agent/Utils";
import { compactAgentActivity } from "Dev/Mobile/RemixModel";
import { parseLightMarkdown } from "Dev/Mobile/LightMarkdown";
import { remixHistory, REMIX_HISTORY_ROUNDS } from "Dev/Mobile/RemixHistory";

export interface RemixTranscriptAction {
	id: "continue" | "start-development";
	text: string;
	primary?: boolean;
	onTapped(this: void): void;
}

interface Item { id: string; title: string; text: string; user: boolean; activity: boolean; actions?: RemixTranscriptAction[]; }
type Scroll = ReturnType<typeof ScrollArea> & {
	offset: Vec2.Type;
	resetSize(this: Scroll, width: number, height: number, viewWidth: number, viewHeight: number): void;
};
const font = "sarasa-mono-sc-regular";

// Snapshot only visible state, never reasoning, tool parameters, credentials or diffs.
export function remixDisplayRevision(detail: AgentSessionDetailResult): string {
	if (!detail.success) return detail.message;
	const history = remixHistory(detail);
	return safeJsonEncode({
		status: detail.session.status, mode: detail.session.workMode, plan: detail.hasActivePlan,
		finalizing: detail.session.currentTaskFinalizing, questionnaire: detail.pendingQuestionnaire,
		currentTaskId: detail.session.currentTaskId, currentTaskStatus: detail.session.currentTaskStatus,
		hasEarlierMessages: history.hasEarlierMessages,
		messages: history.messages.map(m => [m.id, m.taskId ?? 0, m.role, m.displayContent ?? m.content]),
		steps: history.steps.map(s => [s.id, s.tool, s.status, s.reason, s.result?.progress, s.result?.stage, s.result?.message]),
	})[0] ?? "";
}

function itemsFor(detail: AgentSessionDetailResult, zh: boolean, actions: RemixTranscriptAction[]): Item[] {
	if (!detail.success) return [];
	const items: Item[] = [];
	const history = remixHistory(detail);
	if (history.hasEarlierMessages) items.push({ id: "remix-history-limit", title: zh ? "历史记录" : "History",
		text: zh ? `仅展示最近 ${REMIX_HISTORY_ROUNDS} 轮，更早记录可在 Web IDE 查看。`
			: `Showing the latest ${REMIX_HISTORY_ROUNDS} rounds. View earlier messages in Web IDE.`, user: false, activity: true });
	const activities = history.steps.map(s => {
		const state = s.status === "DONE" ? (zh ? "已完成" : "Done")
			: s.status === "FAILED" ? (zh ? "失败" : "Failed")
			: s.status === "STOPPED" ? (zh ? "已停止" : "Stopped")
			: s.status === "PENDING" ? (zh ? "等待中" : "Pending") : (zh ? "进行中" : "Working");
		const progress = s.status === "RUNNING" && typeof s.result?.progress === "number" ? ` · ${math.floor(s.result.progress * 100)}%` : "";
		const message = s.status === "RUNNING" && typeof s.result?.message === "string" ? s.result.message : "";
		const activity = compactAgentActivity(s.tool, "", zh);
		const title = s.status === "RUNNING" ? activity : string.gsub(activity, "正在", "")[0];
		return { id: `step-${s.id}`, title: `${state}${progress} · ${title}`,
			text: s.reason + (message !== "" ? `\n${message}` : ""), user: false, activity: true };
	});
	let inserted = false;
	for (const m of history.messages) {
		// Current task steps belong between its request and its final assistant reply.
		if (!inserted && m.role === "assistant" && m.taskId === detail.session.currentTaskId) {
			items.push(...activities); inserted = true;
		}
		items.push({ id: `message-${m.id}`, title: m.role === "user" ? (zh ? "你" : "You") : "Dora",
			text: m.displayContent ?? m.content, user: m.role === "user", activity: false });
	}
	if (!inserted) items.push(...activities);
	if (actions.length > 0) items.push({ id: "remix-terminal-actions", title: "", text: "", user: false, activity: true, actions });
	return items;
}

function drawCapsule(target: DrawNode.Type, width: number, height: number, color: number, inset = 0) {
	const radius = height / 2 - inset;
	const left = height / 2;
	const right = width - height / 2;
	target.drawPolygon([Vec2(left, inset), Vec2(right, inset), Vec2(right, height - inset), Vec2(left, height - inset)], Color(color));
	target.drawDot(Vec2(left, height / 2), radius, Color(color));
	target.drawDot(Vec2(right, height / 2), radius, Color(color));
}

function makeActionRow(actions: RemixTranscriptAction[], width: number, scale: number): Node.Type {
	const card = Node();
	card.tag = "remix-terminal-actions";
	card.anchor = Vec2(0, 1);
	card.width = width;
	card.height = 44;
	const gap = 10;
	const buttonWidth = actions.length > 1 ? math.min((width - gap) / 2, 184) : math.min(width, 184);
	for (let i = 0; i < actions.length; i++) {
		const action = actions[i];
		const button = Node();
		button.tag = `remix-action-${action.id}`;
		button.anchor = Vec2.zero;
		button.position = Vec2(i * (buttonWidth + gap), 3);
		button.size = Size(buttonWidth, 38);
		button.touchEnabled = true;
		button.swallowTouches = true;
		button.onTapped(action.onTapped);
		const bg = DrawNode();
		if (action.primary) drawCapsule(bg, buttonWidth, 38, 0xffffcc33);
		else {
			drawCapsule(bg, buttonWidth, 38, 0xff465064);
			drawCapsule(bg, buttonWidth, 38, 0xff171c26, 1);
		}
		button.addChild(bg);
		const label = Label(font, math.floor(14 * scale), true);
		if (label) {
			label.position = Vec2(buttonWidth / 2, 19);
			label.color3 = Color3(action.primary ? 0x17130a : 0xf4f1e8);
			label.text = action.text;
			button.addChild(label);
		}
		card.addChild(button);
	}
	return card;
}

function makeCard(item: Item, width: number, scale: number, zh: boolean): Node.Type {
	if (item.actions) return makeActionRow(item.actions, width, scale);
	const card = Node();
	card.tag = item.id;
	card.anchor = Vec2(0, 1);
	card.width = width;
	const labels: { label: Label.Type; top: number }[] = [];
	let top = 12;
	const add = (text: string, size: number, color: number) => {
		const l = Label(font, math.floor(size * scale), true);
		if (!l) return;
		l.anchor = Vec2(0, 1); l.x = 14; l.textWidth = math.max(20, width - 28);
		l.alignment = TextAlign.Left; l.lineGap = 4; l.color3 = Color3(color); l.text = text;
		labels.push({ label: l, top }); top += l.height + 8;
	};
	add(item.title, 13, item.user || item.activity ? 0xffcc33 : 0xa8afbd);
	for (const block of parseLightMarkdown(item.text)) {
		add(block.text, block.kind === "heading1" ? 17 : block.kind === "heading2" ? 16 : 14,
			block.kind === "code" ? 0xffcc33 : 0xf4f1e8);
	}
	if (!item.user && !item.activity) {
		add(zh ? "复制全文" : "Copy message", 13, 0xffcc33);
		const copy = labels[labels.length - 1]?.label;
		if (copy !== undefined) { copy.tag = "remix-copy"; copy.touchEnabled = true; copy.onTapped(() => App.setClipboardText(item.text)); }
	}
	card.height = top + 4;
	const bg = DrawNode();
	bg.drawPolygon([Vec2.zero, Vec2(width, 0), Vec2(width, card.height), Vec2(0, card.height)],
		Color(item.user ? 0xff202632 : 0xff171c26), 1, Color(0xff343b48));
	card.addChild(bg);
	for (const row of labels) { row.label.y = card.height - row.top; card.addChild(row.label); }
	return card;
}

export function createRemixTranscript() {
	const node = Node(); node.tag = "remix-transcript"; node.anchor = Vec2.zero;
	const scroll = ScrollArea({ width: 1, height: 1, paddingX: 0, paddingY: 40, scrollBar: false }) as Scroll;
	scroll.tag = "remix-scroll"; scroll.addTo(node);
	const latest = Label(font, 14, true)!;
	latest.tag = "remix-latest"; latest.color3 = Color3(0xffcc33); latest.touchEnabled = true;
	const hintBackground = DrawNode(); hintBackground.order = 1; hintBackground.addTo(node);
	latest.order = 2;
	latest.addTo(node);
	let width = 1, height = 1, scale = 1, zh = true, total = 0;
	let following = true, touching = false, layingOut = false, unread = false;
	let rows: { id: string; signature: string; node: Node.Type }[] = [];
	const maxOffset = () => math.max(0, total - height);
	const updateHint = () => {
		latest.visible = unread && !following;
		latest.text = zh ? "有新内容 · 回到最新 ↓" : "New activity · Latest ↓";
		hintBackground.visible = latest.visible;
		hintBackground.clear();
		const half = math.min(width / 2, latest.width / 2 + 10);
		hintBackground.drawPolygon([Vec2(width / 2 - half, 0), Vec2(width / 2 + half, 0), Vec2(width / 2 + half, 28), Vec2(width / 2 - half, 28)], Color(0xff202632));
	};
	scroll.slot("ScrollTouchBegan", () => { touching = true; });
	scroll.slot("ScrollTouchEnded", () => { touching = false; following = maxOffset() - scroll.offset.y <= 24; updateHint(); });
	scroll.slot("Scrolled", () => {
		if (layingOut) return;
		following = maxOffset() - scroll.offset.y <= 24;
		if (following) unread = false;
		updateHint();
	});
	latest.onTapped(() => {
		scroll.unschedule(); touching = false; following = true; unread = false;
		scroll.offset = Vec2(0, maxOffset()); updateHint();
	});
	return {
		node,
		update(detail: AgentSessionDetailResult, w: number, h: number, fontScale: number, chinese: boolean, actions: RemixTranscriptAction[] = []) {
			const anchor = rows.find(row => row.node.y > 0 && row.node.y - row.node.height < height);
			const anchorY = anchor?.node.y;
			const oldOffset = scroll.offset.y;
			const layoutChanged = width !== w || height !== h || scale !== fontScale || zh !== chinese;
			width = w; height = h; scale = fontScale; zh = chinese;
			node.size = Size(width, height); scroll.position = Vec2(width / 2, height / 2);
			latest.position = Vec2(width / 2, 14);
			const previous = rows;
			let changed = layoutChanged;
			rows = itemsFor(detail, zh, actions).map(item => {
				const signature = safeJsonEncode({ id: item.id, title: item.title, text: item.text, user: item.user,
					activity: item.activity, actions: item.actions?.map(action => [action.id, action.text, action.primary === true]) })[0] ?? "";
				const existing = previous.find(row => row.id === item.id);
				if (!layoutChanged && existing?.signature === signature) return existing;
				changed = true;
				const card = makeCard(item, width, scale, zh); scroll.view.addChild(card);
				return { id: item.id, signature, node: card };
			});
			for (const row of previous) if (!rows.some(next => next.node === row.node)) { row.node.removeFromParent(true); changed = true; }
			if (!changed) return;
			layingOut = true;
			scroll.offset = Vec2.zero;
			total = 0;
			for (const row of rows) { row.node.position = Vec2(0, height - total); total += row.node.height + 10; }
			if (rows.length > 0) total -= 10;
			scroll.resetSize(width, height, width, total);
			const pinned = following && !touching;
			const replacement = anchor ? rows.find(row => row.id === anchor.id) : undefined;
			const offset = pinned ? maxOffset() : replacement && anchorY !== undefined ? anchorY - replacement.node.y : oldOffset;
			scroll.offset = Vec2(0, math.max(0, math.min(maxOffset(), offset)));
			scroll.view.moveAndCullItems(Vec2.zero);
			layingOut = false;
			if (!pinned) unread = true;
			updateHint();
		},
	};
}
