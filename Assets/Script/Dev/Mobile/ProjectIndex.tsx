import { React } from "DoraX";
import { Color, Color3, DrawNode, Label, Node, Size, Vec2 } from "Dora";
import * as ScrollArea from "UI/Control/Basic/ScrollArea";
import { attachGamepad, selectGamepadNode } from "Dev/Mobile/Gamepad";
import { groupFeedProjects, type FeedEntry } from "Dev/Mobile/FeedModel";

const fontName = "sarasa-mono-sc-regular";
const headerHeight = 72;
const footerHeight = 36;
const railWidth = 48;
const groupHeight = 36;
const rowHeight = 48;

type Scroll = ReturnType<typeof ScrollArea> & {
	offset: Vec2.Type;
	resetSize(this: Scroll, width: number, height: number, viewWidth: number, viewHeight: number): void;
};

function ellipsize(text: string, limit: number) {
	const length = utf8.len(text)[0] ?? 0;
	if (length <= limit) return text;
	const stop = utf8.offset(text, math.max(2, limit)) ?? text.length;
	return string.sub(text, 1, stop - 1) + "…";
}

function addLabel(parent: Node.Type, text: string, size: number, color: number, x: number, y: number, anchor = Vec2(0, 0.5)) {
	const label = Label(fontName, size, true)!;
	label.text = text; label.color3 = Color3(color); label.position = Vec2(x, y); label.anchor = anchor;
	label.renderOrder = 15002;
	label.addTo(parent);
	return label;
}

function roundedVerts(x: number, y: number, width: number, height: number, radius: number) {
	const verts: Vec2.Type[] = [];
	const r = math.max(0, math.min(radius, width / 2, height / 2));
	const corners = [
		{ x: x + width - r, y: y + r, start: -math.pi / 2 },
		{ x: x + width - r, y: y + height - r, start: 0 },
		{ x: x + r, y: y + height - r, start: math.pi / 2 },
		{ x: x + r, y: y + r, start: math.pi },
	];
	for (const corner of corners) {
		for (let step = 0; step <= 6; step++) {
			const angle = corner.start + step * math.pi / 12;
			verts.push(Vec2(corner.x + math.cos(angle) * r, corner.y + math.sin(angle) * r));
		}
	}
	return verts;
}

export function ProjectIndex(props: {
	entries: FeedEntry[];
	current?: FeedEntry;
	x: number;
	y: number;
	width: number;
	height: number;
	zh: boolean;
	onClose(): void;
	onSelect(entry: FeedEntry): void;
}) {
	const onCreate = () => {
		const root = Node();
		root.tag = "mobile-project-index";
		root.anchor = Vec2.zero;
		root.size = Size(props.width, props.height);
		root.renderGroup = true;
		root.renderOrder = 15000;
		root.touchEnabled = true;
		root.swallowTouches = true;
		const base = DrawNode();
		base.drawPolygon([Vec2.zero, Vec2(props.width, 0), Vec2(props.width, props.height), Vec2(0, props.height)],
			Color(0xff080a0f), 0, Color(0xff080a0f));
		base.addTo(root);
		addLabel(root, `${props.zh ? "本地作品" : "LOCAL"} · ${props.entries.length}`, 18, 0xfff4f1e8,
			16, props.height - 34);
		const back = Node(); back.tag = "mobile-project-index-back"; back.anchor = Vec2.zero;
		back.position = Vec2(props.width - 96, props.height - 62); back.size = Size(80, 44); back.touchEnabled = true; back.swallowTouches = true;
		back.onTapped(props.onClose); back.addTo(root);
		addLabel(back, props.zh ? "返回 ›" : "Back ›", 18, 0xffffcc33, 80, 22, Vec2(1, 0.5));

		const groups = groupFeedProjects(props.entries);
		const listX = railWidth + 8;
		const listWidth = math.max(40, props.width - listX - 14);
		const listHeight = math.max(40, props.height - headerHeight - footerHeight);
		const scroll = ScrollArea({ width: listWidth, height: listHeight, paddingX: 0, paddingY: 28, scrollBar: false }) as Scroll;
		scroll.tag = "mobile-project-index-scroll"; scroll.position = Vec2(listX + listWidth / 2, footerHeight + listHeight / 2); scroll.addTo(root);
		const flat: { entry: FeedEntry; node: Node.Type; groupIndex: number; centerFromTop: number }[] = [];
		const groupOffsets: number[] = [];
		let total = 0;
		for (let groupIndex = 0; groupIndex < groups.length; groupIndex++) {
			const group = groups[groupIndex];
			groupOffsets.push(total);
			const heading = Node(); heading.tag = `mobile-project-index-group-${group.key}`;
			heading.anchor = Vec2(0, 1); heading.position = Vec2(0, listHeight - total);
			heading.size = Size(listWidth, groupHeight); heading.addTo(scroll.view);
			const groupTitle = group.key === "#" ? (props.zh ? "其它" : "Other") : group.key;
			const headingBg = DrawNode();
			headingBg.drawSegment(Vec2(38, 18), Vec2(listWidth - 4, 18), 0.5, Color(0xff343b48));
			headingBg.addTo(heading);
			addLabel(heading, groupTitle, 12, 0xffffcc33, 8, 18);
			total += groupHeight;
			for (const entry of group.entries) {
				const row = Node(); row.tag = `mobile-project-index-entry-${flat.length}`; row.anchor = Vec2(0, 1);
				row.position = Vec2(0, listHeight - total); row.size = Size(listWidth, rowHeight);
				row.touchEnabled = true; row.swallowTouches = true; row.onTapped(() => props.onSelect(entry)); row.addTo(scroll.view);
				const selected = entry === props.current || (entry.fileName !== undefined && entry.fileName === props.current?.fileName)
					|| (entry.workDir !== undefined && entry.workDir === props.current?.workDir);
				const rowBg = DrawNode();
				rowBg.drawSegment(Vec2(8, 1), Vec2(listWidth - 8, 1), 0.5, Color(0xff242b37));
				if (selected) rowBg.drawSegment(Vec2(5, 13), Vec2(5, rowHeight - 13), 1.5, Color(0xffffcc33));
				rowBg.addTo(row);
				addLabel(row, ellipsize(entry.title, math.max(8, math.floor((listWidth - 54) / 9))), 14,
					selected ? 0xffffcc33 : 0xfff4f1e8, 16, rowHeight / 2);
				flat.push({ entry, node: row, groupIndex, centerFromTop: total + rowHeight / 2 });
				total += rowHeight;
			}
		}
		if (groups.length === 0) {
			addLabel(scroll.view, props.zh ? "还没有本地作品" : "No local games yet", 14, 0xff777e8c,
				listWidth / 2, listHeight / 2, Vec2(0.5, 0.5));
		}
		scroll.resetSize(listWidth, listHeight, listWidth, total);
		const maxOffset = () => math.max(0, total - listHeight);
		const scrollTo = (centerFromTop: number) => {
			scroll.unschedule(); scroll.offset = Vec2(0, math.max(0, math.min(maxOffset(), centerFromTop - listHeight / 2)));
			scroll.view.moveAndCullItems(Vec2.zero);
		};
		let selectedIndex = math.max(0, flat.findIndex(item => item.entry === props.current
			|| (item.entry.fileName !== undefined && item.entry.fileName === props.current?.fileName)
			|| (item.entry.workDir !== undefined && item.entry.workDir === props.current?.workDir)));
		if (flat[selectedIndex] !== undefined) scrollTo(flat[selectedIndex].centerFromTop);

		const popup = Node(); popup.visible = false; popup.position = Vec2(railWidth + 48, props.height / 2); popup.addTo(root);
		const popupShape = DrawNode();
		popupShape.drawPolygon(roundedVerts(-28, -28, 56, 56, 16), Color(0xff171c26), 1, Color(0xff806b1c)); popupShape.addTo(popup);
		const popupLabel = addLabel(popup, "", 18, 0xffffcc33, 0, 0, Vec2(0.5, 0.5));
		popupLabel.tag = "mobile-project-index-popup-label";
		const rail = Node(); rail.tag = "mobile-project-index-rail"; rail.anchor = Vec2.zero;
		rail.position = Vec2(0, footerHeight); rail.size = Size(railWidth, listHeight);
		rail.touchEnabled = groups.length > 0; rail.swallowTouches = true; rail.addTo(root);
		const railLabels: Label.Type[] = [];
		for (let i = 0; i < groups.length; i++) {
			const y = listHeight - (i + 0.5) * listHeight / groups.length;
			railLabels.push(addLabel(rail, groups[i].key, groups.length > 20 ? 9 : 11, 0xff777e8c, railWidth / 2, y, Vec2(0.5, 0.5)));
		}
		let activeGroup = flat[selectedIndex]?.groupIndex ?? 0;
		const selectGroup = (groupIndex: number, showPopup: boolean, jump = true) => {
			if (groups.length === 0) return;
			activeGroup = math.max(0, math.min(groups.length - 1, groupIndex));
			if (jump) {
				scroll.unschedule(); scroll.offset = Vec2(0, math.max(0, math.min(maxOffset(), groupOffsets[activeGroup])));
				scroll.view.moveAndCullItems(Vec2.zero);
			}
			for (let i = 0; i < railLabels.length; i++) railLabels[i].color3 = Color3(i === activeGroup ? 0xffffcc33 : 0x777e8c);
			popupLabel.text = groups[activeGroup].key === "#" ? (props.zh ? "其它" : "Other") : groups[activeGroup].key;
			popup.visible = showPopup;
		};
		selectGroup(activeGroup, false, false);
		const groupAt = (worldLocation: Vec2.Type) => {
			if (groups.length === 0) return 0;
			const point = rail.convertToNodeSpace(worldLocation);
			popup.y = footerHeight + math.max(32, math.min(listHeight - 32, point.y));
			return math.max(0, math.min(groups.length - 1, math.floor((listHeight - point.y) / listHeight * groups.length)));
		};
		rail.onTapBegan(touch => selectGroup(groupAt(touch.worldLocation), true));
		rail.onTapMoved(touch => selectGroup(groupAt(touch.worldLocation), true));
		rail.onTapEnded(() => { popup.visible = false; });

		const hint = props.zh ? "拖动左侧刻度快速定位" : "Drag the index to jump";
		addLabel(root, hint, 9, 0xff777e8c, props.width / 2, footerHeight / 2, Vec2(0.5, 0.5));
		const moveSelection = (delta: number) => {
			if (flat.length === 0) return;
			selectedIndex = math.max(0, math.min(flat.length - 1, selectedIndex + delta));
			activeGroup = flat[selectedIndex].groupIndex; scrollTo(flat[selectedIndex].centerFromTop);
			selectGroup(activeGroup, false, false); selectGamepadNode(root, flat[selectedIndex].node.tag);
		};
		const gamepadOptions = {
			initialTag: flat[selectedIndex]?.node.tag ?? "mobile-project-index-back",
			onBack: () => props.onClose(),
			onScroll: (amount: number) => { scroll.unschedule(); scroll.offset = Vec2(0, math.max(0, math.min(maxOffset(), scroll.offset.y + amount))); scroll.view.moveAndCullItems(Vec2.zero); },
			onButton: (button: string) => {
				if (button === "dpup") { moveSelection(-1); return true; }
				if (button === "dpdown") { moveSelection(1); return true; }
				if (button === "dpleft" || button === "dpright") {
					const nextGroup = math.max(0, math.min(groups.length - 1, activeGroup + (button === "dpright" ? 1 : -1)));
					const next = flat.findIndex(item => item.groupIndex === nextGroup);
					if (next >= 0) { selectedIndex = next; moveSelection(0); }
					return true;
				}
				if (button === "a" && flat[selectedIndex]) { props.onSelect(flat[selectedIndex].entry); return true; }
				return false;
			},
		};
		// A custom-node is parented after onCreate returns. Defer registration so
		// the gamepad router does not discard this screen as detached.
		root.schedule(() => { attachGamepad(root, gamepadOptions); return true; });
		return root;
	};
	return <custom-node tag="mobile-project-index-container" x={props.x} y={props.y} width={props.width} height={props.height}
		order={15000} renderOrder={15000} onCreate={onCreate} />;
}
