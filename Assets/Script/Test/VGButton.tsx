// @preview-file on
import { React, toNode } from 'DoraX';
import { Color, Node, Size } from 'Dora';
import * as nvg from 'nvg';

interface ButtonProps {
	text: string;
	onClick: () => void
	children: any;
}

const Button = (props: ButtonProps) => {
	const fontId = nvg.CreateFont("sarasa-mono-sc-regular");
	const light = nvg.LinearGradient(0, 80, 0, 0, Color(0xffffffff), Color(0xff00ffff));
	const dark = nvg.LinearGradient(0, 80, 0, 0, Color(0xffffffff), Color(0xfffbc400));
	let paint = light;
	const onCreate = () => {
		const node = Node();
		node.size = Size(100, 100);
		node.onRender(() => {
			nvg.ApplyTransform(node);
			nvg.BeginPath();
			nvg.RoundedRect(0, 0, 100, 100, 10);
			nvg.StrokeColor(Color(0xffffffff));
			nvg.StrokeWidth(5);
			nvg.Stroke();
			nvg.FillPaint(paint);
			nvg.Fill();
			nvg.ClosePath();
			nvg.FontFaceId(fontId);
			nvg.FontSize(32);
			nvg.FillColor(Color(0xff000000));
			nvg.Scale(1, -1);
			nvg.Text(50, -30, props.text);
			return false;
		});
		return node;
	};
	return (
		<custom-node
			onCreate={onCreate}
			onTapBegan={() => paint = dark}
			onTapEnded={() => paint = light}
			onTapped={props.onClick}
			children={props.children}
		/>
	);
}

toNode(
	<Button text='OK' onClick={() => print("Clicked")}>
		<sequence>
			<move-x time={1} start={0} stop={200}/>
			<angle time={1} start={0} stop={360}/>
			<scale time={1} start={1} stop={4}/>
		</sequence>
	</Button>
);
