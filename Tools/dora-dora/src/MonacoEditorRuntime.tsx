import { useLayoutEffect, useRef } from 'react';
import type * as Monaco from 'monaco-editor/esm/vs/editor/editor.api.js';
import MonacoEditor, { loader, type EditorProps } from '@monaco-editor/react';
import monaco, { monacoTypescript } from './monacoBase';
import './Editor';
import { setMonacoRuntime } from './MonacoRuntimeAccess';

setMonacoRuntime({
	monaco,
	typescript: monacoTypescript,
});
loader.config({ monaco });

type MonacoEditorRuntimeProps = Omit<EditorProps, 'path'> & {
	filePath: string;
	onUnmount?: (editor: Monaco.editor.IStandaloneCodeEditor) => void;
};

export default function MonacoEditorRuntime(props: MonacoEditorRuntimeProps) {
	const { filePath, onUnmount, onMount, ...editorProps } = props;
	const editorRef = useRef<Monaco.editor.IStandaloneCodeEditor | null>(null);
	const onUnmountRef = useRef(onUnmount);
	onUnmountRef.current = onUnmount;
	// Preserve view state before Monaco's passive unmount cleanup disposes it.
	useLayoutEffect(() => () => {
		if (editorRef.current) onUnmountRef.current?.(editorRef.current);
		editorRef.current = null;
	}, []);
	const handleMount: NonNullable<EditorProps['onMount']> = (editor, api) => {
		editorRef.current = editor;
		onMount?.(editor, api);
	};
	return (
		<MonacoEditor
			{...editorProps}
			onMount={handleMount}
			path={monaco.Uri.file(filePath).toString()}
		/>
	);
}
