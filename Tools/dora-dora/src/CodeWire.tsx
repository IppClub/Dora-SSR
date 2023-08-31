export interface CodeWireProps {
	title: string;
	width: number;
	height: number;
	defaultValue?: string;
};

const CodeWire = (props: CodeWireProps) => {
	return <iframe
		width={props.width}
		height={props.height}
		title={props.title}
		onLoad={(e) => {
			console.log(e);
		}}
		src="code-wire/index.html"
		style={{
			border: 'none',
			overflowY: 'hidden',
		}}/>;
};

export default CodeWire;
