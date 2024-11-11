// @preview-file on
import { React, toNode, toAction, useRef } from 'DoraX';
import { Ease, Size, sleep, thread, tolua, TypeName, Vec2 } from 'Dora';
import { Struct } from 'Utils'

import * as LineRectCreate from 'UI/View/Shape/LineRect';
import * as ButtonCreate from 'UI/Control/Basic/Button';
import { Button } from 'UI/Control/Basic/Button';
import * as ScrollAreaCreate from 'UI/Control/Basic/ScrollArea';
import { ScrollArea, AlignMode } from 'UI/Control/Basic/ScrollArea';

interface ButtonProps {
	ref?: JSX.Ref<Button.Type>;
	text: string;
	width: number;
	height: number;
	children?: any[];
	onClick: (this: void) => void;
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
	}} children={props.children}/>;
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
items.__added = (index, item) => {
	const {current} = scrollArea;
	if (!current) return;
	const node = toNode(
		<Button text={item.name} width={50} height={50} onClick={() => {
			thread(() => {
				sleep(0.5);
				items.remove(item);
			});
		}}/>
	);
	if (node) {
		tolua.cast(node.children?.first, TypeName.Node)?.perform(toAction(
			<scale time={0.3} start={0} stop={1} easing={Ease.OutBack}/>
		));
		node.addTo(current.view, index);
		current.adjustSizeWithAlign(AlignMode.Auto);
	}
};
items.__removed = (index) => {
	const {current} = scrollArea;
	const children = current?.view.children;
	if (!children) return;
	const child = tolua.cast(children.get(index), TypeName.Node);
	if (child) child.removeFromParent();
	for (let i = 1; i <= children.count; i++) {
		const child = tolua.cast(children[i], TypeName.Node);
		if (child) child.order = i;
	}
	current.adjustSizeWithAlign(AlignMode.Auto);
};

toNode(
	<align-node windowRoot style={{alignItems: 'center', justifyContent: 'center'}}>
		<align-node style={{width: "50%", height: "50%"}} onLayout={(width, height) => {
			const {current} = scrollArea;
			if (!current) return;
			current.position = Vec2(width / 2, height / 2);
			current.adjustSizeWithAlign(AlignMode.Auto, 10, Size(width, height));
			current.getChildByTag("border")?.removeFromParent();
			const border = LineRectCreate({x: -width / 2, y: -height / 2, width, height, color: 0xffffffff});
			current.addChild(border, 0, "border");
		}}>
			<ScrollArea ref={scrollArea} width={250} height={300} paddingX={0}/>
		</align-node>
	</align-node>
);

thread(() => {
	for (let i of $range(1, 30)) {
		items.insert(Item({name: `btn ${i}`, value: i}));
		sleep(1);
	}
});
