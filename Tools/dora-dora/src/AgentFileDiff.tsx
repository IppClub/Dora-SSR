import React from 'react';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import { DiffEditor } from '@monaco-editor/react';
import type { Monaco } from '@monaco-editor/react';
import type { IDisposable } from 'monaco-editor';
import type { editor as MonacoEditor } from 'monaco-editor';
import type { AgentCheckpointDiffFile } from './Service';
import { Color } from './Theme';
import { EditorTheme } from './Editor';

interface AgentFileDiffProps {
	file: AgentCheckpointDiffFile;
}

function getLanguage(filePath: string) {
	const ext = filePath.toLowerCase().split('.').pop() ?? "";
	switch (ext) {
		case "lua":
			return "lua";
		case "tl":
			return "tl";
		case "yue":
			return "yue";
		case "ts":
		case "tsx":
			return "typescript";
		case "xml":
			return "xml";
		case "md":
			return "markdown";
		case "wa":
			return "wa";
		case "yarn":
			return "yarn";
		case "mod":
			return "ini";
		default:
			return "txt";
	}
}

export default function AgentFileDiff(props: AgentFileDiffProps) {
	const { file } = props;
	const language = getLanguage(file.path);
	const originalModelPath = `file://${file.path}#before`;
	const modifiedModelPath = `file://${file.path}#after`;
	const editorRef = React.useRef<MonacoEditor.IStandaloneDiffEditor | null>(null);
	const disposablesRef = React.useRef<IDisposable[]>([]);
	const [height, setHeight] = React.useState(120);

	const updateHeight = React.useCallback(() => {
		const diffEditor = editorRef.current;
		if (diffEditor == null) return;
		const originalHeight = diffEditor.getOriginalEditor().getContentHeight();
		const modifiedHeight = diffEditor.getModifiedEditor().getContentHeight();
		setHeight(Math.max(originalHeight, modifiedHeight, 96));
	}, []);

	const handleMount = React.useCallback((editor: MonacoEditor.IStandaloneDiffEditor, _monaco: Monaco) => {
		editorRef.current = editor;
		const originalEditor = editor.getOriginalEditor();
		const modifiedEditor = editor.getModifiedEditor();
		disposablesRef.current.forEach(disposable => disposable.dispose());
		disposablesRef.current = [
			originalEditor.onDidContentSizeChange(updateHeight),
			modifiedEditor.onDidContentSizeChange(updateHeight),
		];
		updateHeight();
	}, [updateHeight]);

	React.useEffect(() => {
		updateHeight();
	}, [file.beforeContent, file.afterContent, updateHeight]);

	React.useEffect(() => {
		return () => {
			disposablesRef.current.forEach(disposable => disposable.dispose());
			disposablesRef.current = [];
			editorRef.current = null;
		};
	}, []);

	return (
		<Box sx={{
			border: `0.5px solid ${Color.Line}`,
			borderRadius: 1,
			overflow: "hidden",
		}}>
			<Box sx={{ px: 1.25, py: 1, backgroundColor: Color.BackgroundDark, borderBottom: `0.5px solid ${Color.Line}` }}>
				<Typography variant="caption" sx={{ color: Color.TextSecondary }}>
					{file.path} · {file.op}
				</Typography>
			</Box>
			<DiffEditor
				height={height}
				onMount={handleMount}
				theme={EditorTheme}
				language={language}
				original={file.beforeContent}
				modified={file.afterContent}
				originalModelPath={originalModelPath}
				modifiedModelPath={modifiedModelPath}
				options={{
					readOnly: true,
					renderSideBySide: false,
					useInlineViewWhenSpaceIsLimited: true,
					automaticLayout: true,
					minimap: { enabled: false },
					scrollbar: {
						alwaysConsumeMouseWheel: false,
					},
					scrollBeyondLastLine: false,
					wordWrap: 'on',
					fontSize: 13,
					lineNumbers: 'on',
					renderOverviewRuler: false,
					renderIndicators: true,
					originalEditable: false,
					diffWordWrap: 'on',
					stickyScroll: { enabled: false },
					hideUnchangedRegions: {
						enabled: true,
						contextLineCount: 3,
						minimumLineCount: 3,
						revealLineCount: 10,
					},
				}}
			/>
		</Box>
	);
}
