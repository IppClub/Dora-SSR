import type { MonacoTypeScript } from './MonacoRuntimeAccess';
import * as monaco from 'monaco-editor/esm/vs/editor/editor.api.js';

// Register only the language contributions we need to keep the bundle smaller.
import * as tsContribution from 'monaco-editor/esm/vs/language/typescript/monaco.contribution.js';
import 'monaco-editor/esm/vs/basic-languages/xml/xml.contribution.js';
import 'monaco-editor/esm/vs/basic-languages/markdown/markdown.contribution.js';
import 'monaco-editor/esm/vs/basic-languages/ini/ini.contribution.js';
import 'monaco-editor/esm/vs/basic-languages/typescript/typescript.contribution.js';

// The ESM contribution ships empty declarations; its exports implement the
// public TypeScript API declared by monaco-editor's top-level namespace.
export const monacoTypescript = tsContribution as MonacoTypeScript;

export default monaco;
export { monaco };
