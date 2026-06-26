import { React } from "DoraX";
import { ItemSlot } from "UIX/game/ItemSlot";
import { Column } from "UIX/layout/Column";
import { Row } from "UIX/layout/Row";
import { mergeStyle } from "UIX/layout/helpers";

type UiIcon = string | { kind: "sprite"; file: string } | { kind: "painter"; name: string };
type InventoryItemQuality = "empty" | "common" | "rare" | "epic" | "legendary";
interface UiNodeProps {
	key?: string | number;
	ref?: { readonly current?: unknown };
	style?: AnyTable;
	order?: number;
	renderOrder?: number;
	visible?: boolean;
	opacity?: number;
	disabled?: boolean;
	testId?: string;
	children?: unknown;
}

export interface InventoryItem {
	id: string;
	icon?: UiIcon;
	quality?: InventoryItemQuality;
	count?: number;
	disabled?: boolean;
	cooldown?: number;
	maxCooldown?: number;
}

export interface InventoryGridProps extends UiNodeProps {
	items: InventoryItem[];
	columns: number;
	rows?: number;
	slotSize?: number;
	gap?: number;
	selectedId?: string;
	slotSwallowTouches?: boolean;
	onSelect?: (this: void, id: string) => void;
}

function itemAt(this: void, items: InventoryItem[], index: number): InventoryItem | undefined {
	return items[index - 1];
}

export function InventoryGrid(this: void, props: InventoryGridProps): React.Element {
	const columns = math.max(1, props.columns);
	const rows = props.rows ?? math.max(1, math.ceil(props.items.length / columns));
	const slotSize = props.slotSize ?? 56;
	const gap = props.gap ?? 8;
	const width = columns * slotSize + (columns - 1) * gap;
	const height = rows * slotSize + (rows - 1) * gap;
	const rowElements: React.Element[] = [];
	for (let row of $range(1, rows)) {
		const slots: React.Element[] = [];
		for (let column of $range(1, columns)) {
			const index = (row - 1) * columns + column;
			const item = itemAt(props.items, index);
			slots.push(
				<ItemSlot
					key={item?.id ?? `empty-${index}`}
					id={item?.id}
					icon={item?.icon}
					quality={item?.quality}
					count={item?.count}
					disabled={props.disabled === true || item?.disabled === true}
					selected={item !== undefined && item.id === props.selectedId}
					cooldown={item?.cooldown}
					maxCooldown={item?.maxCooldown}
					swallowTouches={props.slotSwallowTouches}
					style={{ width: slotSize, height: slotSize }}
					onClick={(id) => {
						if (id !== undefined) props.onSelect?.(id);
					}}
				/>
			);
		}
		rowElements.push(
			<Row key={`row-${row}`} gap={gap} style={{ height: slotSize }}>
				{slots}
			</Row>
		);
	}
	return (
		<Column
			key={props.key}
			ref={props.ref as JSX.Ref<import("Dora").AlignNode.Type> | undefined}
			gap={gap}
			style={mergeStyle({ width, height }, props.style)}
			visible={props.visible}
			opacity={props.opacity}
		>
			{rowElements}
		</Column>
	);
}
