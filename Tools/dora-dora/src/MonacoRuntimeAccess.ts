import type * as Monaco from 'monaco-editor/esm/vs/editor/editor.api';

type MonacoTypeScript = typeof import(
	'monaco-editor/esm/vs/language/typescript/monaco.contribution'
);

export interface MonacoRuntime {
	monaco: typeof Monaco;
	typescript: MonacoTypeScript;
}

let runtime: MonacoRuntime | null = null;

export const setMonacoRuntime = (nextRuntime: MonacoRuntime) => {
	runtime = nextRuntime;
	if (typeof document === "undefined") return;
	const diagnostics = document.querySelector<HTMLElement>("[data-dora-perf-diagnostics]");
	if (diagnostics !== null) {
		diagnostics.dataset.doraPerfMonacoLoaded = "true";
	}
};

export const getMonacoRuntime = () => {
	if (runtime === null) {
		throw new Error("Monaco runtime is not loaded");
	}
	return runtime.monaco;
};

export const getMonacoTypeScript = () => {
	if (runtime === null) {
		throw new Error("Monaco runtime is not loaded");
	}
	return runtime.typescript;
};

export const peekMonacoRuntime = () => runtime;
