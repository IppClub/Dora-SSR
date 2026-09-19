import { isProjectPath, validateSnapshot, type ProjectFile, type ProjectSnapshot } from '@dora-studio/contracts';
export class DoraSourceRecognitionError extends Error {}

export function restoreStudioArchive(files: readonly { path: string; data: Uint8Array }[]) {
  const metadata = files.find(file => file.path === '.studio/project.json');
  if (!metadata || metadata.data.length > 65536) throw new Error('缺少有效的 Studio 备份元数据');
  const decoder = new TextDecoder('utf-8', { fatal: true, ignoreBOM: true });
  const value = JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(metadata.data));
  if (!value || value.format !== 'dora-studio-project' || value.version !== 1 ||
      typeof value.name !== 'string' || !value.name.trim() || value.name.length > 200 ||
      typeof value.entry !== 'string' || !Array.isArray(value.files) || value.files.length !== files.length - 1) {
    throw new Error('Studio 备份元数据无效或版本不支持');
  }
  const remaining = new Map(files.filter(file => file !== metadata).map(file => [file.path, file.data]));
  if (remaining.size !== files.length - 1) throw new Error('备份包含重复路径');
  const restored: ProjectFile[] = value.files.map((file: { path?: unknown; kind?: unknown }) => {
    if (!file || typeof file.path !== 'string' || !['text', 'binary'].includes(String(file.kind))) throw new Error('备份文件类型无效');
    const bytes = remaining.get(file.path);
    if (!bytes) throw new Error('备份文件清单不一致');
    remaining.delete(file.path);
    return file.kind === 'text' ? { path: file.path, kind: 'text', text: decoder.decode(bytes) } :
      { path: file.path, kind: 'binary', bytes: new Uint8Array(bytes) };
  });
  const snapshot: ProjectSnapshot = { version: 1, projectId: crypto.randomUUID(), revision: 0, entry: value.entry, files: restored };
  const errors = validateSnapshot(snapshot);
  if (errors.length || remaining.size) throw new Error(errors.join('; ') || '备份文件清单不完整');
  return { name: value.name, snapshot };
}

export async function importStudioBackup(file: File) {
  if (file.size > 256 * 1024 * 1024) throw new Error('ZIP 超过 256 MiB');
  await import(/* @vite-ignore */ `${import.meta.env.BASE_URL}web-package.js`);
  const api = (globalThis as unknown as { DoraWebPackage: { inspectArchive(file: File, options: { projectBackup: true }): Promise<{ files: { path: string; data: Uint8Array }[] }> } }).DoraWebPackage;
  return restoreStudioArchive((await api.inspectArchive(file, { projectBackup: true })).files);
}

/** Convert a package already validated and root-normalized by the shared Dora reader. */
export function restoreDoraPackage(pack: { manifest: { title: string }; files: readonly { path: string; data: Uint8Array }[] }) {
  const decoder = new TextDecoder('utf-8', { fatal: true, ignoreBOM: true });
  const entry = ['init.ts', 'init.tsx', 'init.tl', 'init.yue', 'init.xml', 'init.lua'].find(path => pack.files.some(file => file.path === path));
  if (!entry) throw new Error('当前 Studio 尚不支持仅含 Wasm 入口的项目导入');
  const files: ProjectFile[] = pack.files.map(file => /\.(lua|yue|tl|xml|tsx?|json|md|txt|csv|svg|vert|frag)$/i.test(file.path)
    ? { path: file.path, kind: 'text', text: decoder.decode(file.data) }
    : { path: file.path, kind: 'binary', bytes: new Uint8Array(file.data) });
  const snapshot: ProjectSnapshot = { version: 1, projectId: crypto.randomUUID(), revision: 0, entry, files };
  const errors = validateSnapshot(snapshot);
  if (errors.length) throw new Error(errors.join('; '));
  return { name: pack.manifest.title, snapshot };
}

export async function importDoraProject(file: File) {
  if (file.size > 256 * 1024 * 1024) throw new Error('游戏包超过 256 MiB');
  await import(/* @vite-ignore */ `${import.meta.env.BASE_URL}web-package.js`);
  const api = (globalThis as unknown as { DoraWebPackage: {
    inspectArchive(file: File, options: {projectBackup: true}): Promise<{files: {path:string;data:Uint8Array}[]}>;
  } }).DoraWebPackage;
  return restoreDoraArchive((await api.inspectArchive(file,{projectBackup:true})).files,file.name);
}

/** Editor import is not player compatibility validation. Keep manifest bytes
 * unchanged; no runtime execution occurs while recognizing the source root. */
export function restoreDoraArchive(archive: readonly {path:string;data:Uint8Array}[],filename:string) {
  if(!archive.length||archive.some(file=>!isProjectPath(file.path)))throw new Error('源码包为空或包含非法路径');
  const entries=['init.ts','init.tsx','init.tl','init.yue','init.xml','init.lua'];
  let files=archive;
  while(!entries.some(entry=>files.some(file=>file.path===entry))){
    const roots=new Set(files.map(file=>file.path.split('/')[0]));
    if(roots.size!==1||files.some(file=>!file.path.includes('/')))throw new DoraSourceRecognitionError('未找到明确的源码入口，请检查游戏包目录结构');
    const root=[...roots][0]!+'/';
    files=files.map(file=>({path:file.path.slice(root.length),data:file.data}));
  }
  const entry=entries.find(entry=>files.some(file=>file.path===entry));
  if(!entry)throw new DoraSourceRecognitionError('未找到明确的源码入口，请检查游戏包目录结构');
  const decoder=new TextDecoder('utf-8',{fatal:true,ignoreBOM:true});
  const snapshot:ProjectSnapshot={version:1,projectId:crypto.randomUUID(),revision:0,entry,files:files.map(file=>/\.(lua|yue|tl|xml|tsx?|json|md|txt|csv|svg|vert|frag)$/i.test(file.path)
    ?{path:file.path,kind:'text' as const,text:decoder.decode(file.data)}
    :{path:file.path,kind:'binary' as const,bytes:new Uint8Array(file.data)})};
  const errors=validateSnapshot(snapshot);if(errors.length)throw new Error(errors.join('; '));
  let name=filename.replace(/\.(dora|zip)$/i,'').trim().slice(0,200)||'导入项目';
  const manifest=snapshot.files.find(file=>file.path==='dora-package.json'&&file.kind==='text');
  if(manifest?.kind==='text'&&manifest.text.length<=65536){
    try{
      const value=JSON.parse(manifest.text);
      if(value?.format==='dora-game'&&value.version===1&&typeof value.title==='string'&&value.title.trim()&&value.title.length<=200&&value.title.isWellFormed()&&!/[\u0000-\u001f\u007f]/.test(value.title))name=value.title.trim();
    }catch{/* Malformed metadata does not prevent source-only import. */}
  }
  return {name,snapshot};
}
