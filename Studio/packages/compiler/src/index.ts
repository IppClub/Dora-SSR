import type * as TS from "typescript";

export interface VirtualFile {
  readonly file: string;
  readonly content: string;
  readonly moduleName?: string;
}

/** Canonical in-memory paths, independent of the machine's operating system. */
export function normalizePath(path: string): string {
  const source = path.replace(/\\/g, "/");
  const absolute = source.startsWith("/");
  const parts: string[] = [];
  for (const part of source.split("/")) {
    if (!part || part === ".") continue;
    if (part === ".." && parts.length && parts.at(-1) !== "..") parts.pop();
    else if (part === ".." && absolute) continue;
    else parts.push(part);
  }
  return (absolute ? "/" : "") + parts.join("/");
}

function absolutePath(path: string, root: string): string {
  const normalized = normalizePath(path);
  return normalized.startsWith("/") || /^[A-Za-z]:\//.test(normalized)
    ? normalized : normalizePath(`${root}/${normalized}`);
}

// These modules are installed by the engine or packaged with its runtime.
// A declaration elsewhere in a project does not imply a runtime module.
const engineModuleDeclarations = {
  "Dora.d.ts": ["Dora"],
  "DoraX.d.ts": ["DoraX"],
  "ImGui.d.ts": ["ImGui"],
  "InputManager.d.ts": ["InputManager"],
  "nvg.d.ts": ["nvg"],
  "Platformer.d.ts": ["Platformer"],
  "bit32.d.ts": ["bit32"],
  "love.d.ts": ["love"],
  "socket.d.ts": ["ltn12", "mime", "mime.core"],
};
const engineModules = Object.values(engineModuleDeclarations).flat();
const nativeSocketModules = [
  "socket", "socket.core", "socket.ftp", "socket.headers", "socket.http", "socket.smtp", "socket.tp", "socket.url", "ssl.https",
];

export const studioCompilerResourcesPath = "declarations/compiler.json";
export const studioDeclarationFiles = [
  ...Object.keys(engineModuleDeclarations),
  "es6-subset.d.ts", "lua.d.ts", "jsx.d.ts", "tic80.d.ts",
];

export function doraCompilerOptions<L extends string, I extends string>(
  ts: typeof TS,
  luaTarget: L,
  luaLibImport: I,
  runtime: "native" | "studio" = "native",
): TS.CompilerOptions & { luaTarget: L; luaLibImport: I; noHeader: boolean; noImplicitSelf: boolean; noImplicitGlobalVariables: boolean; luaExternalModules: string[] } {
  return {
    strict: true,
    jsx: ts.JsxEmit.React,
    luaTarget,
    luaLibImport,
    luaExternalModules: runtime === "native" ? [...engineModules, ...nativeSocketModules] : [...engineModules],
    noHeader: true,
    sourceMap: true,
    noImplicitSelf: true,
    noImplicitGlobalVariables: true,
    moduleResolution: ts.ModuleResolutionKind.Classic,
    target: ts.ScriptTarget.ESNext,
    module: ts.ModuleKind.ESNext,
  };
}

/** Lua's package.loaded falls back to the engine's Dora table. */
export function registerDoraRuntimeExports(ts: typeof TS, program: TS.Program, declaration?: TS.SourceFile) {
  if (!declaration) return;
  const checker = program.getTypeChecker();
  const dora = checker.getAmbientModules().find(module =>
    module.name === '"Dora"' && module.declarations?.some(node => node.getSourceFile() === declaration));
  if (!dora) return;
  const options = program.getCompilerOptions() as TS.CompilerOptions & { luaExternalModules?: string[] };
  const runtime = new Set(options.luaExternalModules);
  for (const item of checker.getExportsOfModule(dora)) {
    if (!item.declarations?.some(node => node.getSourceFile() === declaration)) continue;
    const value = item.flags & ts.SymbolFlags.Alias ? checker.getAliasedSymbol(item) : item;
    if (value.flags & ts.SymbolFlags.Value) runtime.add(item.name);
  }
  options.luaExternalModules = [...runtime];
}

export interface SnapshotProgramInput {
  readonly rootNames: readonly string[];
  readonly projectRoot: string;
  readonly files: readonly VirtualFile[];
  readonly options: TS.CompilerOptions;
  readonly projectScriptRoot?: string;
  /** Exact path to the supplied Dora declaration, never an ambient disk lookup. */
  readonly defaultLibFileName: string;
}

export function resolveDoraModule(
  ts: typeof TS, name: string, containingFile: string, options: TS.CompilerOptions, host: TS.ModuleResolutionHost,
): TS.ResolvedModuleFull | undefined {
  const resolved = ts.resolveModuleName(name, containingFile, options, host).resolvedModule;
  if (resolved || name.startsWith(".") || name.startsWith("/") || /^[A-Za-z]:/.test(name)) return resolved;
  return ts.resolveModuleName(`${name}/index`, containingFile, options, host).resolvedModule;
}

/** All reads are closed over a copied snapshot; there is no fallback provider. */
export function createSnapshotProgram(ts: typeof TS, input: SnapshotProgramInput) {
  const root = normalizePath(input.projectRoot);
  if (!root || (!root.startsWith("/") && !/^[A-Za-z]:\//.test(root))) {
    throw new Error("projectRoot must be absolute");
  }
  const files = new Map<string, string>();
  const aliases = new Map<string, string>();
  const directories = new Set<string>();
  for (const source of input.files) {
    const file = absolutePath(source.file, root);
    if (files.has(file)) throw new Error(`Duplicate compiler file: ${file}`);
    files.set(file, source.content);
    if (source.moduleName) {
      const prior = aliases.get(source.moduleName);
      if (prior && prior !== file) throw new Error(`Ambiguous module alias: ${source.moduleName}`);
      aliases.set(source.moduleName, file);
    }
    let dir = file.slice(0, file.lastIndexOf("/"));
    while (dir) {
      directories.add(dir);
      dir = dir.slice(0, dir.lastIndexOf("/"));
    }
  }
  const luaProjectModuleRoot = input.projectScriptRoot && normalizePath(input.projectScriptRoot);
  const paths = {
    ...(luaProjectModuleRoot ? { "*": [`${luaProjectModuleRoot}/*`, "*"] } : {}),
    ...input.options.paths,
    ...Object.fromEntries([...aliases].map(([alias, file]) => [alias, [file]])),
  };
  const options = { ...input.options, paths, baseUrl: root, rootDir: root, luaProjectModuleRoot };
  const outputs = new Map<string, string>();
  const host: TS.CompilerHost = {
    getCurrentDirectory: () => root,
    getCanonicalFileName: normalizePath,
    getDefaultLibFileName: () => absolutePath(input.defaultLibFileName, root),
    getNewLine: () => "\n",
    useCaseSensitiveFileNames: () => true,
    fileExists: path => files.has(absolutePath(path, root)),
    directoryExists: path => directories.has(absolutePath(path, root)),
    readFile: path => files.get(absolutePath(path, root)),
    writeFile: (path, content) => { outputs.set(normalizePath(path), content); },
    getSourceFile: path => {
      const file = absolutePath(path, root);
      const content = files.get(file);
      return content === undefined ? undefined : ts.createSourceFile(file, content, ts.ScriptTarget.ESNext, false);
    },
    resolveModuleNames: (names, containingFile) => names.map(name => {
      const resolved = resolveDoraModule(ts, name, containingFile, options, host);
      if (resolved || name.startsWith(".") || name.startsWith("/") || /^[A-Za-z]:/.test(name)) return resolved;
      const file = aliases.get(name);
      if (!file) return undefined;
      return {
        resolvedFileName: file,
        extension: file.endsWith(".d.ts") ? ts.Extension.Dts : file.endsWith(".tsx") ? ts.Extension.Tsx : ts.Extension.Ts,
        isExternalLibraryImport: true,
      };
    }),
  };
  const program = ts.createProgram(input.rootNames.map(name => absolutePath(name, root)), options, host);
  registerDoraRuntimeExports(ts, program, program.getSourceFile(host.getDefaultLibFileName(options)));
  return { program, host, outputs };
}

export interface EmitHost {
  directoryExists(path: string): boolean;
  fileExists(path: string): boolean;
  getCurrentDirectory(): string;
  readFile(path: string): string | undefined;
  writeFile: TS.WriteFileCallback;
}

export type LuaEmitter = (program: TS.Program, host: EmitHost, writeFile: TS.WriteFileCallback) => readonly TS.Diagnostic[];

/** Inject the existing Dora TSTL emitter; do not fork or silently upgrade it. */
export function compileSnapshot(ts: typeof TS, input: SnapshotProgramInput, emit: LuaEmitter) {
  const { program, host } = createSnapshotProgram(ts, input);
  const output = new Map<string, { content: string; sourceFiles: readonly TS.SourceFile[] }>();
  const writeFile: TS.WriteFileCallback = (path, content, _bom, _error, sourceFiles) => {
    output.set(normalizePath(path), { content, sourceFiles: sourceFiles ?? [] });
  };
  const emitHost: EmitHost = {
    directoryExists: path => host.directoryExists?.(path) ?? false,
    fileExists: host.fileExists,
    getCurrentDirectory: host.getCurrentDirectory,
    readFile: host.readFile,
    writeFile,
  };
  const diagnostics = [...ts.getPreEmitDiagnostics(program), ...emit(program, emitHost, writeFile)]
    .filter(d => d.code !== 2497 && d.code !== 2666);
  return { diagnostics, output, program };
}
