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
};

export default function MonacoEditorRuntime(props: MonacoEditorRuntimeProps) {
	const { filePath, ...editorProps } = props;
	return (
		<MonacoEditor
			{...editorProps}
			path={monaco.Uri.file(filePath).toString()}
		/>
	);
}
