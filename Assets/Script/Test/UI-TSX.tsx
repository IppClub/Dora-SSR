// @preview-file on
import { React, toNode, useRef } from 'DoraX';
import { Node, Size, sleep, thread, Move, Vec2 } from 'Dora';
import { Struct, ArrayEvent } from 'Utils'

import * as ButtonCreate from 'UI/Control/Basic/Button';
import { Button } from 'UI/Control/Basic/Button';
import * as LineRectCreate from 'UI/View/Shape/LineRect';
import * as ScrollAreaCreate from 'UI/Control/Basic/ScrollArea';
import { ScrollArea, AlignMode } from 'UI/Control/Basic/ScrollArea';

interface ButtonProps {
	ref?: JSX.Ref<Button.Type>;
	text: string;
	width: number;
	height: number;
	onClick: () => void;
}

const Button = (props: ButtonProps) => {
	return <custom-node onCreate={() => {
		const btn = ButtonCreate({
			text: props.text,
			width: props.width,
			height: props.height
		});
		btn.onTapped(() => {
			props.onClick();
		});
		if (props.ref) {
			(props.ref.current as any) = btn;
		}
		return btn;
	}}/>;
};

interface ScrollAreaProps {
	ref?: JSX.Ref<ScrollArea.Type>;
	x?: number;
	y?: number;
	width: number;
	height: number;
	viewWidth?: number;
	viewHeight?: number;
	paddingX?: number; // default 200
	paddingY?: number; // default 200
	scrollBar?: boolean; // default true
	scrollBarColor3?: number; // default App.themeColor.toARGB()
	clipping?: boolean; // default true
	children?: React.Element[];
};

const ScrollArea = (props: ScrollAreaProps) => {
	return <custom-node onCreate={() => {
		const {width, height} = props;
		const scrollArea = ScrollAreaCreate(props);
		if (props.ref) {
			(props.ref.current as any) = scrollArea;
		}
		if (props.children) {
			for (let child of props.children) {
				toNode(child)?.addTo(scrollArea.view);
			}
			scrollArea.adjustSizeWithAlign(AlignMode.Auto, 10, Size(width, height));
		}
		const border = LineRectCreate({x: 1, y: 1, width: width - 2, height: height - 2, color: 0xffffffff});
		scrollArea.area.addChild(border, 0, "border");
		return scrollArea;
	}}/>;
};

interface ItemProps {
	name: string;
	value: number;
};

const Array = Struct.Array<ItemProps>();
const Item = Struct.Item<ItemProps>('name', 'value');

const scrollArea = useRef<ScrollArea.Type>();

const items = Array();
items.__notify = (event, index, item) => {
	switch (event) {
		case ArrayEvent.Added: {
			const {current} = scrollArea;
			if (current) {
				toNode(
					<Button text={item.name} width={50} height={50} onClick={() => {
						thread(() => {
							sleep(0.5);
							items.remove(item);
						});
					}}/>
				)?.addTo(current.view);
			}
			break;
		}
		case ArrayEvent.Removed: {
			const {current} = scrollArea;
			if (current) {
				const child = current.view.children?.get(index);
				if (child) {
					(child as Node.Type).removeFromParent();
				}
			}
			break;
		}
		case ArrayEvent.Updated: {
			const {current} = scrollArea;
			if (current) {
				current.adjustSizeWithAlign(AlignMode.Auto);
			}
			break;
		}
	}
};

toNode(
	<align-node windowRoot style={{alignItems: 'center', justifyContent: 'center'}}>
		<align-node style={{width: "50%", height: "50%"}} onLayout={(width, height) => {
			const {current} = scrollArea;
			if (current) {
				current.position = Vec2(width / 2, height / 2);
				current.adjustSizeWithAlign(AlignMode.Auto, 10, Size(width, height));
				const border = LineRectCreate({x: 1, y: 1, width: width - 2, height: height - 2, color: 0xffffffff});
				current.area.getChildByTag("border")?.removeFromParent();
				current.area.addChild(border, 0, "border");
			}
		}}>
			<ScrollArea ref={scrollArea} width={250} height={300} paddingX={0}/>
		</align-node>
	</align-node>
);

for (let i of $range(1, 30)) {
	items.insert(Item({name: `btn ${i}`, value: i}));
}