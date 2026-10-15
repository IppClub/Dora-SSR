import {authoredProjectFiles,generatedLuaSourcePath,type Diagnostic,type ProjectSnapshot} from '@dora-studio/contracts';
type Result = {success:true; snapshot:ProjectSnapshot} | {success:false; message:string; interrupted?:boolean; diagnostics?:Diagnostic[]};
export class TealBuildError extends Error {
  constructor(message:string, readonly diagnostics:readonly Diagnostic[]) { super(message); }
}
type API = {
  createTealWorkerBuild(factory:()=>Worker, declarations:unknown, options:{signal:AbortSignal}): unknown;
  compileTealProject(snapshot:ProjectSnapshot, compileFile:unknown, options:{signal:AbortSignal;checkLua:boolean}): Promise<Result>;
};
/** Load the original Lua/Teal checking toolchain only when these sources exist. */
export async function prepareTealSnapshot(snapshot:ProjectSnapshot, signal:AbortSignal): Promise<ProjectSnapshot> {
  const files=authoredProjectFiles(snapshot.files);
  const sourceSnapshot={...snapshot,entry:generatedLuaSourcePath(snapshot.entry,snapshot.files)??snapshot.entry,files};
  const base = `${import.meta.env.BASE_URL}teal/`;
  const moduleURL = new URL(`${base}api.js`, location.href).href;
  const api = await import(/* @vite-ignore */ moduleURL) as API;
  const response = await fetch(`${base}declarations.json`, {signal});
  if (!response.ok) throw new Error('无法加载 Teal 编译声明');
  const declarations:unknown = await response.json();
  signal.throwIfAborted();
  const compileFile = api.createTealWorkerBuild(()=>new Worker(new URL(`${base}worker.mjs`,location.href),{type:'module'}), declarations, {signal});
  const result = await api.compileTealProject(sourceSnapshot, compileFile, {signal,checkLua:true});
  if (!result.success) throw new TealBuildError(result.message, result.diagnostics ?? []);
  return result.snapshot;
}
