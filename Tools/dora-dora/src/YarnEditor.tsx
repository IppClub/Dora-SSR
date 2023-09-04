export interface YarnEditorData {
	warpToFocusedNode: () => void;
	getJSONData: () => Promise<string>;
};

export interface YarnEditorProps {
	title: string;
	width: number;
	height: number;
	defaultValue?: string;
	onLoad: (data: YarnEditorData) => void;
	onChange: () => void;
	onKeydown: (event: KeyboardEvent) => void;
};

const YarnEditor = (props: YarnEditorProps) => {
	return <iframe
		width={props.width}
		height={props.height}
		title={props.title}
		onLoad={(e) => {
			if (e.currentTarget.contentWindow !== null) {
				const win = e.currentTarget.contentWindow as any;
				win.addEventListener("yarnSavedStateToLocalStorage", () => {
					props.onChange();
				});
				win.app.data.startNewFile(props.title, props.defaultValue);
				props.onLoad(win.app.data as YarnEditorData);
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
					}
				});
			}
		}}
		src="yarn-editor/index.html"
		style={{
			border: 'none',
			overflowY: 'hidden',
		}}/>;
};

export default YarnEditor;
