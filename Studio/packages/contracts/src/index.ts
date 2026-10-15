/** Wire version, independent of the engine and compiler versions. */
export const PROTOCOL_VERSION = 1 as const;

export type ProjectFile =
  | { readonly path: string; readonly kind: "text"; readonly text: string }
  | { readonly path: string; readonly kind: "binary"; readonly bytes: Uint8Array };

export interface ProjectSnapshot {
  readonly version: typeof PROTOCOL_VERSION;
  readonly projectId: string;
  readonly revision: number;
  readonly entry: string;
  readonly files: readonly ProjectFile[];
}

/** Match the original Dora Content.glob source-variant precedence: a same-path
 * Lua sibling is generated output when a higher-level authored source exists. */
const LUA_SOURCE_VARIANT_EXTENSIONS = [".vs", ".bl", ".ts", ".tsx", ".tl", ".yue", ".xml"] as const;

/** Return the generated Lua sibling owned by an authored source file. Native
 * Lua files deliberately return undefined because they are author content. */
export function generatedLuaPathForSource(path: string): string | undefined {
  const lower = path.toLowerCase();
  const extension = LUA_SOURCE_VARIANT_EXTENSIONS.find(candidate => lower.endsWith(candidate));
  return extension ? `${path.slice(0, -extension.length)}.lua` : undefined;
}

export function generatedLuaSourcePath(path: string, files: readonly Pick<ProjectFile, "path">[]): string | undefined {
  if (!path.toLowerCase().endsWith(".lua")) return undefined;
  const base = path.slice(0, -4);
  const paths = new Map(files.map(file => [file.path.toLowerCase(), file.path]));
  return LUA_SOURCE_VARIANT_EXTENSIONS.map(extension => `${base}${extension}`)
    .map(candidate => paths.get(candidate.toLowerCase()))
    .find(candidate => candidate !== undefined);
}

export function isGeneratedLuaFile(path: string, files: readonly Pick<ProjectFile, "path">[]): boolean {
  return generatedLuaSourcePath(path, files) !== undefined;
}

export function authoredProjectFiles<T extends Pick<ProjectFile, "path">>(files: readonly T[]): T[] {
  return files.filter(file => !isGeneratedLuaFile(file.path, files));
}

/** Preserved source/archive data that is not eligible for compilation or play.
 * This is deliberately not assignable to ProjectSnapshot. */
export interface ProjectArchive {
  readonly version: typeof PROTOCOL_VERSION;
  readonly kind: "project-archive";
  readonly projectId: string;
  readonly revision: number;
  readonly entry: null;
  readonly files: readonly ProjectFile[];
}

export interface Correlation {
  readonly version: typeof PROTOCOL_VERSION;
  readonly sessionId: string;
  readonly projectId: string;
  readonly revision: number;
  readonly requestId: string;
}

export interface CompileRequest extends Correlation {
  readonly type: "compile";
  readonly buildId: string;
  readonly compilerVersion: string;
  readonly snapshot: ProjectSnapshot;
  readonly declarations: readonly ProjectFile[];
  /** Optional TS roots for a targeted build; imports still resolve from the full snapshot. */
  readonly rootNames?: readonly string[];
  readonly options: Readonly<Record<string, string | number | boolean>>;
  readonly timeoutMs: number;
}

export interface Diagnostic {
  readonly severity: "error" | "warning" | "info";
  readonly code: string;
  readonly message: string;
  readonly path?: string;
  /** Zero-based UTF-16 offsets, matching TypeScript and editor models. */
  readonly start?: number;
  readonly length?: number;
}

function diagnosticLineAndColumn(text: string, offset: number) {
  const bounded=Math.max(0,Math.min(offset,text.length));
  let line=1,column=1;
  for(let index=0;index<bounded;index++){
    if(text.charCodeAt(index)===10){line++;column=1;}else column++;
  }
  return {line,column};
}

/** Match the original Web IDE `getDiagnosticMessage` text without bundling the
 * TypeScript compiler into the Studio application. Offsets are UTF-16, as are
 * JavaScript string indexes and TypeScript diagnostic positions. */
export function formatTypeScriptDiagnostics(fileName:string,diagnostics:readonly Diagnostic[],files:readonly ProjectFile[]) {
  if(!diagnostics.length)return '';
  const lines=diagnostics.map(diagnostic=>{
    const path=diagnostic.path??fileName;
    const source=files.find(file=>file.path===path&&file.kind==='text');
    const position=source?.kind==='text'&&diagnostic.start!==undefined?diagnosticLineAndColumn(source.text,diagnostic.start):undefined;
    const location=diagnostic.path?`${diagnostic.path}${position?`(${position.line},${position.column})`:''}: `:'';
    return `${location}${diagnostic.severity} TS${diagnostic.code}: ${diagnostic.message}`;
  });
  return `Compiling error: ${fileName}\n${lines.join('\n')}\n`;
}

export interface BuildArtifact {
  readonly buildId: string;
  readonly projectId: string;
  readonly revision: number;
  readonly compilerVersion: string;
  readonly entry: string;
  readonly files: readonly ProjectFile[];
  readonly sourceMaps: Readonly<Record<string, string>>;
  readonly sha256: string;
}

/** Content identity shared by compiler and runtime; excludes request identity. */
export function serializeArtifactContent(artifact: Pick<BuildArtifact, "compilerVersion" | "entry" | "files" | "sourceMaps">): string {
  const files = [...artifact.files].sort((a, b) => a.path < b.path ? -1 : a.path > b.path ? 1 : 0);
  return JSON.stringify({ compilerVersion: artifact.compilerVersion, entry: artifact.entry,
    files: files.map(f => f.kind === "text" ? f : { ...f, bytes: [...f.bytes] }), sourceMaps: artifact.sourceMaps });
}

export type CompileResult = Correlation & { readonly buildId: string } & (
  | { readonly type: "compiled"; readonly artifact: BuildArtifact; readonly diagnostics: readonly Diagnostic[] }
  | { readonly type: "compileFailed"; readonly diagnostics: readonly Diagnostic[] }
  | { readonly type: "cancelled" }
);

/** Worker accepted the request and is about to enter synchronous compilation. */
export interface CompileStarted extends Correlation {
  readonly type: "compileStarted";
  readonly buildId: string;
}

export interface RuntimeCapabilities {
  readonly version: typeof PROTOCOL_VERSION;
  readonly engineBuild: string;
  readonly profile: string;
  readonly isolation: "iframe" | "worker" | "pthread";
  readonly screenshot: boolean;
  readonly suspend: boolean;
}

export type RuntimeCommand = Correlation & { readonly runId: string } & (
  | { readonly type: "loadSnapshot"; readonly artifact: BuildArtifact; readonly engineBuild: string; readonly profile: string }
  | { readonly type: "captureGame"; readonly captureId: string }
  | { readonly type: "readAgentCommand"; readonly commandId: string }
  | { readonly type: "start" | "stop" | "restart" | "suspend" | "releaseInput" }
);

export interface RequestFailure extends Correlation {
  readonly type: "requestFailed";
  readonly code: "unsupportedVersion" | "unsupportedCapability" | "invalidRequest" | "timeout" | "cancelled" | "internal";
  readonly message: string;
}

export type RuntimeEvent = Correlation & { readonly runId: string } & (
  | { readonly type: "gameCaptured"; readonly captureId: string; readonly png: Uint8Array; readonly width:number; readonly height:number }
  | { readonly type: "captureFailed"; readonly captureId: string; readonly message:string }
  | { readonly type: "agentCommandResult"; readonly commandId: string; readonly resultJSON:string;
      readonly files:readonly {readonly path:string;readonly bytes:Uint8Array}[];readonly deletedPaths:readonly string[] }
  | { readonly type: "state"; readonly state: "loading" | "ready" | "running" | "suspended" | "stopped" }
  | { readonly type: "log"; readonly level: "info" | "warning" | "error"; readonly message: string }
  | { readonly type: "error"; readonly code: "invalidSnapshot" | "unsupported" | "timeout" | "runtimeFailure"; readonly message: string }
  | { readonly type: "performance"; readonly frameMs: number }
);

/** Cancel targets one request, not a potentially newer task in the same project. */
export interface CancelRequest extends Correlation {
  readonly type: "cancel";
  readonly targetRequestId: string;
}

function record(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function identifier(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

/** Diagnostic paths may name compiler declarations outside the project root. */
export function isDiagnostic(value: unknown): value is Diagnostic {
  if (!record(value) || !["error", "warning", "info"].includes(value.severity as string) ||
    typeof value.code !== "string" || typeof value.message !== "string") return false;
  if (value.path !== undefined && typeof value.path !== "string") return false;
  for (const key of ["start", "length"] as const) {
    if (value[key] !== undefined && (!Number.isSafeInteger(value[key]) || (value[key] as number) < 0)) return false;
  }
  return value.start === undefined || value.length === undefined ||
    Number.isSafeInteger((value.start as number) + (value.length as number));
}

/** Check structured-cloned wire data before using the typed correlation helpers. */
export function isCorrelation(value: unknown): value is Correlation {
  return record(value) && value.version === PROTOCOL_VERSION &&
    identifier(value.sessionId) && identifier(value.projectId) && identifier(value.requestId) &&
    Number.isSafeInteger(value.revision) && (value.revision as number) >= 0;
}

export function isBuildArtifact(value: unknown): value is BuildArtifact {
  if (!record(value) || !identifier(value.buildId) || !identifier(value.compilerVersion) ||
    typeof value.sha256 !== "string" || !/^[a-f0-9]{64}$/.test(value.sha256) ||
    !record(value.sourceMaps)) return false;
  if (validateSnapshot({ ...value, version: PROTOCOL_VERSION }).length) return false;
  // Source maps belong to emitted text files, not arbitrary virtual paths.
  const textPaths = new Set((value.files as ProjectFile[])
    .filter(file => file.kind === "text").map(file => file.path));
  return Object.entries(value.sourceMaps).every(([path, map]) =>
    isProjectPath(path) && path.endsWith(".map") &&
    textPaths.has(path.slice(0, -4)) && typeof map === "string");
}

export function isRuntimeCommand(value: unknown): value is RuntimeCommand {
  if (!record(value) || !isCorrelation(value) || !identifier(value.runId)) return false;
  switch (value.type) {
    case "captureGame": return captureIdentifier(value.captureId);
    case "readAgentCommand": return captureIdentifier(value.commandId);
    case "loadSnapshot":
      return identifier(value.engineBuild) && identifier(value.profile) &&
        isBuildArtifact(value.artifact) && value.artifact.projectId === value.projectId &&
        value.artifact.revision === value.revision;
    case "start": case "stop": case "restart": case "suspend": case "releaseInput":
      return true;
    default: return false;
  }
}

export function isRuntimeEvent(value: unknown): value is RuntimeEvent {
  if (!record(value) || !isCorrelation(value) || !identifier(value.runId)) return false;
  switch (value.type) {
    case "gameCaptured":
      return captureIdentifier(value.captureId) && isBoundedCapturePNG(value.png, value.width, value.height);
    case "captureFailed":
      return captureIdentifier(value.captureId) && typeof value.message === 'string' && value.message.length <= 8192;
    case "agentCommandResult":
      if(!captureIdentifier(value.commandId)||typeof value.resultJSON!=='string'||value.resultJSON.length>262144
        ||!Array.isArray(value.files)||value.files.length>4096||!Array.isArray(value.deletedPaths)||value.deletedPaths.length>4096)return false;
      let total=0;const paths=new Set<string>();
      for(const file of value.files){
        if(!record(file)||!isProjectPath(file.path)||file.path==='.agent'||file.path.startsWith('.agent/')
          ||!(file.bytes instanceof Uint8Array)||file.bytes.byteLength>64*1024*1024||paths.has(file.path))return false;
        total+=file.bytes.byteLength;if(total>256*1024*1024)return false;paths.add(file.path);
      }
      for(const path of value.deletedPaths){
        if(!isProjectPath(path)||path==='.agent'||path.startsWith('.agent/')||paths.has(path))return false;
        paths.add(path);
      }
      return true;
    case "state":
      return ["loading", "ready", "running", "suspended", "stopped"].includes(value.state as string);
    case "log":
      return ["info", "warning", "error"].includes(value.level as string) && typeof value.message === "string";
    case "error":
      return ["invalidSnapshot", "unsupported", "timeout", "runtimeFailure"].includes(value.code as string) &&
        typeof value.message === "string";
    case "performance":
      return typeof value.frameMs === "number" && Number.isFinite(value.frameMs) && value.frameMs >= 0;
    default: return false;
  }
}

export const MAX_CAPTURE_BYTES = 8 * 1024 * 1024;
export const MAX_CAPTURE_DIMENSION = 1280;
function captureIdentifier(value:unknown): value is string {
  return typeof value === 'string' && /^[a-zA-Z0-9_-]{1,128}$/.test(value);
}
/** Envelope and IHDR bounds only. Consumers must still decode the PNG successfully. */
export function isBoundedCapturePNG(png:unknown, width:unknown, height:unknown): png is Uint8Array {
  if (!(png instanceof Uint8Array) || png.byteLength < 33 || png.byteLength > MAX_CAPTURE_BYTES ||
    !Number.isSafeInteger(width) || !Number.isSafeInteger(height) ||
    (width as number) < 1 || (height as number) < 1 ||
    (width as number) > MAX_CAPTURE_DIMENSION || (height as number) > MAX_CAPTURE_DIMENSION) return false;
  const signature = [137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82];
  if (!signature.every((value,index)=>png[index] === value)) return false;
  const header = new DataView(png.buffer,png.byteOffset,png.byteLength);
  return header.getUint32(16) === width && header.getUint32(20) === height;
}

export function matchesCaptureResult(command: Extract<RuntimeCommand,{type:'captureGame'}>, event:RuntimeEvent): boolean {
  return (event.type === 'gameCaptured' || event.type === 'captureFailed') &&
    matchesRuntimeEvent(command,event) && command.captureId === event.captureId;
}

export function isProjectPath(value: unknown): value is string {
  return typeof value === "string" && value.length > 0 &&
    !/[\\\x00-\x1f\x7f:]/u.test(value) &&
    value.split("/").every(part => part !== "" && part !== "." && part !== "..");
}

/** Validate before placing an untrusted snapshot into a virtual filesystem. */
export function validateSnapshot(value: unknown): string[] {
  return validateProjectData(value, false);
}

/** Same file safety rules, but no invented executable entry. */
export function validateProjectArchive(value: unknown): string[] {
  return validateProjectData(value, true);
}

function validateProjectData(value: unknown, archive: boolean): string[] {
  if (!value || typeof value !== "object") return ["snapshot must be an object"];
  const data = value as Record<string, unknown>;
  const errors: string[] = [];
  if (data.version !== PROTOCOL_VERSION) errors.push("unsupported snapshot version");
  if (typeof data.projectId !== "string" || !data.projectId.trim()) errors.push("missing projectId");
  if (!Number.isSafeInteger(data.revision) || (data.revision as number) < 0) errors.push("invalid revision");
  if (archive) {
    if (data.kind !== "project-archive" || data.entry !== null) errors.push("invalid archive state");
  } else {
    if (data.kind === "project-archive") errors.push("archive is not executable");
    if (!isProjectPath(data.entry)) errors.push("invalid entry path");
  }
  if (!Array.isArray(data.files)) return [...errors, "files must be an array"];
  if (archive && !data.files.length) errors.push("archive must contain files");
  const paths = new Set<string>();
  let entryFound = false;
  for (const file of data.files) {
    if (!file || typeof file !== "object" || !isProjectPath(file.path)) {
      errors.push("invalid file path");
      continue;
    }
    if (paths.has(file.path)) errors.push(`duplicate file: ${file.path}`);
    paths.add(file.path);
    if (file.kind === "text" && typeof file.text === "string") {
      if (file.path === data.entry) entryFound = true;
    } else if (!(file.kind === "binary" && file.bytes instanceof Uint8Array)) {
      errors.push(`invalid file content: ${file.path}`);
    }
  }
  for (const path of paths) {
    const parts = path.split("/");
    parts.pop();
    while (parts.length) {
      if (paths.has(parts.join("/"))) errors.push(`file/directory collision: ${path}`);
      parts.pop();
    }
  }
  if (!archive && !entryFound) errors.push("entry must reference a text file");
  return errors;
}

/** Results must match the full request identity, not just a revision counter. */
export function matchesRequest(expected: Correlation, received: Correlation): boolean {
  return received.version === PROTOCOL_VERSION && expected.version === received.version &&
    expected.sessionId === received.sessionId && expected.projectId === received.projectId &&
    expected.revision === received.revision && expected.requestId === received.requestId;
}

export function matchesCompileResult(request: CompileRequest, result: CompileResult): boolean {
  return matchesRequest(request, result) && request.buildId === result.buildId &&
    (result.type !== "compiled" || (
      result.artifact.buildId === request.buildId &&
      result.artifact.projectId === request.projectId &&
      result.artifact.revision === request.revision &&
      result.artifact.compilerVersion === request.compilerVersion
    ));
}

export function matchesRuntimeEvent(command: RuntimeCommand, event: RuntimeEvent): boolean {
  return matchesRequest(command, event) && command.runId === event.runId;
}

export function cancelsRequest(cancel: CancelRequest, request: Correlation): boolean {
  return cancel.version === PROTOCOL_VERSION && request.version === PROTOCOL_VERSION &&
    cancel.sessionId === request.sessionId && cancel.projectId === request.projectId &&
    cancel.revision === request.revision && cancel.targetRequestId === request.requestId;
}
