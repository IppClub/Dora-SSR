export interface CodeWireData {
	getScript: () => string;
	getVisualScript: () => string;
	setVisualScript: (script: string) => void;
	reportVisualScriptError: (message: string) => void;
};

export interface CodeWireProps {
	title: string;
	width: number;
	height: number;
	defaultValue?: string;
	onLoad: (data: CodeWireData) => void;
	onChange: () => void;
	onKeydown: (event: KeyboardEvent) => void;
};

const CodeWire = (props: CodeWireProps) => {
	return <iframe
		width={props.width}
		height={props.height}
		title={props.title}
		onLoad={(e) => {
			if (e.currentTarget.contentWindow === null) {
				return;
			}
			const win = e.currentTarget.contentWindow as any;
			win.document.addEventListener("mouseup", () => {
				props.onChange();
			});
			if (props.defaultValue !== undefined && props.defaultValue !== "") {
				win.setVisualScript(props.defaultValue);
			}
			props.onLoad(win as CodeWireData);
			win.document.addEventListener("keydown", (event: KeyboardEvent) => {
				if (event.ctrlKey || event.altKey || event.metaKey) {
					switch (event.key) {
						case 'N': case 'n':
						case 'D': case 'd':
						case 'S': case 's':
						case 'W': case 'w':
						case 'R': case 'r':
						case 'P': case 'p':
						case 'Q': case 'q': {
							event.preventDefault();
							props.onKeydown(event);
							break;
						}
					}
				} else {
					props.onChange();
				}
			});
		}}
		src="code-wire/index.html"
		style={{
			border: 'none',
			overflowY: 'hidden',
		}}/>;
};

export default CodeWire;
