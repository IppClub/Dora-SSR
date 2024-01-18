import * as monaco from 'monaco-editor';
import { MonacoJsxSyntaxHighlight } from 'monaco-jsx-syntax-highlight';

export const jsxSyntaxHighlight = new MonacoJsxSyntaxHighlight("/jsx-worker.js", monaco);
