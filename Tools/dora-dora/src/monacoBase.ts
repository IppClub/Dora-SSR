import * as monaco from 'monaco-editor/esm/vs/editor/editor.api';

// Register only the language contributions we need to keep the bundle smaller.
import * as tsContribution from 'monaco-editor/esm/vs/language/typescript/monaco.contribution';
import 'monaco-editor/esm/vs/basic-languages/xml/xml';
import 'monaco-editor/esm/vs/basic-languages/markdown/markdown';
import 'monaco-editor/esm/vs/basic-languages/ini/ini';
import 'monaco-editor/esm/vs/basic-languages/typescript/typescript.contribution';

// monaco-editor full builds expose monaco.languages.typescript; reattach the
// minimal API surface for our usage when using editor.api.
const languages = monaco.languages as any;
const tsAny = tsContribution as any;

if (!languages.typescript) {
  languages.typescript = {
    typescriptDefaults: tsAny.typescriptDefaults,
    javascriptDefaults: tsAny.javascriptDefaults,
    getTypeScriptWorker: tsAny.getTypeScriptWorker,
    getJavaScriptWorker: tsAny.getJavaScriptWorker,
    JsxEmit: tsAny.JsxEmit,
    ModuleKind: tsAny.ModuleKind,
    ModuleResolutionKind: tsAny.ModuleResolutionKind,
    ScriptTarget: tsAny.ScriptTarget,
  };
}

// Ensure base language IDs exist for TypeScript/JavaScript features.
monaco.languages.register({ id: 'typescript' });
monaco.languages.register({ id: 'javascript' });

export default monaco;
export { monaco };
export const monacoTypescript = languages.typescript;
