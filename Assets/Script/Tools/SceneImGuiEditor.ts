// @preview-file on clear
import { Content, Path, threadLoop } from 'Dora';
import { createEditorState, addNode, loadSceneFromFile } from 'Script/Tools/SceneEditor/Model';
import { drawEditor, drawRuntimeError } from 'Script/Tools/SceneEditor/Panels';

declare function pcall(fn: () => void): LuaMultiReturn<[boolean, unknown]>;
const editor = createEditorState();
if (!loadSceneFromFile(editor, Path(Content.writablePath, '.dora', 'imgui-editor.scene.json'))) {
	addNode(editor, 'Root', 'MainScene');
	addNode(editor, 'Camera', 'Camera2D', 'root');
}

let runtimeError: string | undefined = undefined;

threadLoop(() => {
	if (runtimeError !== undefined) {
		drawRuntimeError(runtimeError);
		return false;
	}
	const [ok, err] = pcall(() => drawEditor(editor));
	if (!ok) {
		runtimeError = tostring(err);
	}
	return false;
});

export default editor;
