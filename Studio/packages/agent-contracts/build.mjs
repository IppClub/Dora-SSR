import { mkdir, writeFile, readFile } from 'node:fs/promises';
import { buildAgentRegistry } from '../../scripts/agent-contracts.mjs';
import { build } from 'esbuild';
import ts from 'typescript';
import { buildAgentDocs } from '../../scripts/agent-docs.mjs';
import { buildAgentSessionTypes } from '../../scripts/agent-session-types.mjs';
import { buildAgentSessionSchema } from '../../scripts/agent-session-schema.mjs';

const output = new URL('./dist/', import.meta.url);
// Share the IDE's pure collection reducer without loading its Service runtime.
// Fail the build if an upstream change introduces a runtime dependency.
const sessionPatchBuild = await build({
  entryPoints: [new URL('../../../Tools/dora-dora/src/AgentPatchBatch.ts', import.meta.url).pathname],
  outfile: new URL('session-patches.js', output).pathname,
  bundle: true, format: 'esm', platform: 'neutral', metafile: true,
});
if (Object.keys(sessionPatchBuild.metafile.inputs).length !== 1) {
  throw new Error('AgentPatchBatch acquired runtime dependencies; review Studio isolation before sharing');
}
const sessionDeclarations = await buildAgentSessionTypes();
await writeFile(new URL('session-patches.d.ts', output), sessionDeclarations);
await writeFile(new URL('session-patch-schema.json', output), JSON.stringify(buildAgentSessionSchema(sessionDeclarations)));
await writeFile(new URL('session-detail-schema.json', output), JSON.stringify(buildAgentSessionSchema(sessionDeclarations, 'AgentSessionDetailResponse')));
const capturePath=new URL('../../../Assets/Script/Lib/Agent/Tool/CommandPreview.ts',import.meta.url);
const captureSource=ts.createSourceFile(capturePath.pathname,await readFile(capturePath,'utf8'),ts.ScriptTarget.Latest,true);
const pruneFunction=captureSource.statements.find(s=>ts.isFunctionDeclaration(s) && s.name?.text==='pruneVisionCaptures');
const captureLimit=captureSource.statements.find(s=>ts.isVariableStatement(s) && s.declarationList.declarations.some(d=>d.name.getText(captureSource)==='COMMAND_VISION_MAX_FILES'));
if (!pruneFunction || !captureLimit) throw new Error('Upstream capture retention changed');
await build({stdin:{contents:`${captureLimit.getText(captureSource)}
export function findPrunableCaptures(input) {
  const paths=[...input], removed=[];
  const Content={exist:dir=>paths.some(path=>path.startsWith(dir+'/')),
    getFiles:dir=>paths.filter(path=>path.startsWith(dir+'/') && !path.slice(dir.length+1).includes('/')).map(path=>path.slice(dir.length+1)),
    remove:path=>removed.push(path)};
  const Path=(dir,name)=>dir+'/'+name;
  const string={match:(value,pattern)=>{
    if(pattern!=='^%d+%-%d+%.png$') throw new Error('Unsupported capture filename pattern');
    return [/^[0-9]+-[0-9]+\\.png$/.test(value) ? value : undefined];
  }};
  ${pruneFunction.getText(captureSource).replace(/^export /,'')}
  pruneVisionCaptures('.agent/vision');
  return removed;
}`,loader:'ts'},outfile:new URL('vision-captures.js',output).pathname,format:'esm',platform:'neutral'});
await writeFile(new URL('vision-captures.d.ts',output),'export declare const COMMAND_VISION_MAX_FILES: number;\nexport declare function findPrunableCaptures(paths: readonly string[]): string[];\n');
const visionParts=[];
for (const [file,names] of [
  ['VisionResponse.ts',['tokenCount','normalizeVisionUsage']],
  ['VisionBudget.ts',['createEmptyVisionTaskUsage','nonNegativeInteger','getVisionTaskUsage','getVisionBudgetState']],
]) {
  const path=new URL(`../../../Assets/Script/Lib/Agent/Tool/${file}`,import.meta.url);
  const source=ts.createSourceFile(path.pathname,await readFile(path,'utf8'),ts.ScriptTarget.Latest,true);
  if (file === 'VisionBudget.ts') {
    const limits=source.statements.filter(statement=>ts.isVariableStatement(statement));
    if (limits.length !== 4) throw new Error('Upstream vision budget constants changed');
    visionParts.push(...limits.map(statement=>statement.getText(source).replace(/^export /,'')));
  }
  for (const name of names) {
    const fn=source.statements.find(statement=>ts.isFunctionDeclaration(statement) && statement.name?.text===name);
    if (!fn) throw new Error(`Upstream vision budget helper changed: ${name}`);
    visionParts.push(fn.getText(source).replace(/^export /,''));
  }
}
await build({stdin:{contents:`export function createVisionBudget(host) {
  const {DB,TABLE_STEP}=host;
  const math={max:Math.max,floor:Math.floor,huge:Infinity};
  const type=value=>value!==null && typeof value==='object' ? 'table' : typeof value;
  const error=message=>{throw new Error(message);};
  const safeJsonDecode=text=>{try{return [JSON.parse(text)];}catch{return [undefined];}};
  ${visionParts.join('\n')}
  return {createEmptyVisionTaskUsage,getVisionTaskUsage,getVisionBudgetState};
}`,loader:'ts'},outfile:new URL('vision-budget.js',output).pathname,format:'esm',platform:'neutral'});
await writeFile(new URL('vision-budget.d.ts',output),`export interface VisionUsage {captureBatchCount:number;captureFrameCount:number;requestCount:number;reportedRequests:number;inputTokens:number;outputTokens:number;totalTokens:number}
export interface VisionState extends VisionUsage {limits:{captureBatches:number;captureFrames:number;analysisRequests:number;reportedTokens:number};remaining:{captureBatches:number;captureFrames:number;analysisRequests:number;reportedTokens:number}}
export declare function createVisionBudget(host:{TABLE_STEP:string;DB:{query(sql:string,args:number[]):unknown}}):{createEmptyVisionTaskUsage():VisionUsage;getVisionTaskUsage(taskId:number):VisionUsage;getVisionBudgetState(usage:VisionUsage):VisionState};
`);
// Preserve upstream runtime ownership semantics, but scope mutable state to one
// Studio host instead of sharing it across unrelated browser projects.
const leasePath = new URL('../../../Assets/Script/Lib/Agent/Tool/EntryLease.ts', import.meta.url);
const leaseSource = ts.createSourceFile(leasePath.pathname, await readFile(leasePath, 'utf8'), ts.ScriptTarget.Latest, true);
const leaseNames = ['acquireEntryLease', 'recordEntryLeaseRun', 'ownsEntryLease', 'releaseEntryLease'];
const leaseFunctions = leaseNames.map(name => {
  const fn = leaseSource.statements.find(statement => ts.isFunctionDeclaration(statement) && statement.name?.text === name);
  if (!fn) throw new Error(`Upstream entry lease changed: ${name}`);
  return fn.getText(leaseSource).replace(/^export /, '');
});
const leaseState = leaseSource.statements.filter(statement => ts.isVariableStatement(statement));
if (leaseState.length !== 2) throw new Error('Upstream entry lease state changed');
await build({stdin:{contents:`export function createEntryLease() {
  const error = message => { throw new Error(message); };
  const tostring = value => value instanceof Error ? value.message : String(value);
  ${leaseState.map(statement => statement.getText(leaseSource)).join('\n')}
  ${leaseFunctions.join('\n')}
  return {${leaseNames.join(',')}};
}`,loader:'ts'},outfile:new URL('entry-lease.js',output).pathname,format:'esm',platform:'neutral'});
await build({ entryPoints: [new URL('./src/teal-project.js', import.meta.url).pathname],
  outfile: new URL('teal-project.js', output).pathname, format: 'esm', platform: 'neutral' });
await build({ entryPoints: [new URL('./src/teal-worker-client.js', import.meta.url).pathname],
  outfile: new URL('teal-worker-client.js', output).pathname, format: 'esm', platform: 'neutral' });
await build({ entryPoints: [new URL('./src/teal-compiler.js', import.meta.url).pathname],
  outfile: new URL('teal-compiler.js', output).pathname, format: 'esm', platform: 'neutral' });
await build({ entryPoints: [new URL('./src/snapshot-list.js', import.meta.url).pathname],
  outfile: new URL('snapshot-list.js', output).pathname, format: 'esm', platform: 'neutral' });
await build({ entryPoints: [new URL('./src/worker-build.js', import.meta.url).pathname],
  outfile: new URL('worker-build.js', output).pathname, format: 'esm', platform: 'neutral' });
await build({ entryPoints: [new URL('./src/snapshot-build.js', import.meta.url).pathname],
  outfile: new URL('snapshot-build.js', output).pathname, format: 'esm', platform: 'neutral' });
const replacementParts = [];
for (const [relative, names] of [
  ['Utils.ts', ['replaceFirst', 'getLeadingWhitespace', 'getCommonIndentPrefix', 'removeIndentPrefix', 'dedentLines', 'findWhitespaceTolerantReplacement', 'findIndentTolerantReplacement']],
  ['Runtime/Policy.ts', ['normalizeLineEndings', 'countOccurrences']]
]) {
  const file = new URL(`../../../Assets/Script/Lib/Agent/${relative}`, import.meta.url);
  const source = ts.createSourceFile(file.pathname, await readFile(file, 'utf8'), ts.ScriptTarget.Latest, true);
  for (const name of names) {
    const fn = source.statements.find(statement => ts.isFunctionDeclaration(statement) && statement.name?.text === name);
    if (!fn) throw new Error(`Upstream replacement helper changed: ${name}`);
    replacementParts.push(fn.getText(source));
  }
}
await build({ stdin: { contents: 'const math = Math;\n' + replacementParts.join('\n'), loader: 'ts' },
  outfile: new URL('text-edit.js', output).pathname, format: 'esm', platform: 'neutral' });
const code = await buildAgentRegistry();
await mkdir(output, { recursive: true });
await writeFile(new URL('index.js', output), code);
await buildAgentDocs(new URL('docs/', output));
await build({ entryPoints: [new URL('./src/documents.js', import.meta.url).pathname],
  outfile: new URL('documents.js', output).pathname, format: 'esm', platform: 'neutral' });
const workspacePath = new URL('../../../Assets/Script/Lib/Agent/Tool/Workspace.ts', import.meta.url);
const workspaceSource = ts.createSourceFile(workspacePath.pathname, await readFile(workspacePath, 'utf8'), ts.ScriptTarget.Latest, true);
const listFunctions = ['ensureSafeSearchGlobs', 'listFiles', 'toWorkspaceRelativeFileList'].map(name => {
  const fn = workspaceSource.statements.find(statement => ts.isFunctionDeclaration(statement) && statement.name?.text === name);
  if (!fn) throw new Error(`Upstream listing helper changed: ${name}`);
  return fn.getText(workspaceSource).replace(/^export /, '');
});
const extensionLevels = workspaceSource.statements.find(statement => ts.isVariableStatement(statement) &&
  statement.declarationList.declarations.some(declaration => declaration.name.getText(workspaceSource) === 'extensionLevels'));
if (!extensionLevels) throw new Error('Upstream source variant precedence changed');
await build({ stdin: { contents: `const math = Math; const tostring = String;
${extensionLevels.getText(workspaceSource)}
export function createWorkspaceList(host) {
  const {Content, resolveWorkspaceSearchPath, toWorkspaceRelativePath} = host;
  ${listFunctions.join('\n')}
  return listFiles;
}`, loader: 'ts' }, outfile: new URL('workspace-list.js', output).pathname, format: 'esm', platform: 'neutral' });
// Keep the original traversal, exclusions, cancellation and result accounting.
// Only platform operations are supplied by the Studio host.
const buildSourcePath = new URL('../../../Assets/Script/Lib/Agent/Tool/Build.ts', import.meta.url);
const buildSource = ts.createSourceFile(buildSourcePath.pathname, await readFile(buildSourcePath, 'utf8'), ts.ScriptTarget.Latest, true);
const buildFunctions = ['isDtsFile', 'isTiledEditorContent', 'getSupportedBuildKind', 'finalizeBuildResult', 'build'].map(name => {
  const fn = buildSource.statements.find(statement => ts.isFunctionDeclaration(statement) && statement.name?.text === name);
  if (!fn) throw new Error(`Upstream build function changed: ${name}`);
  return fn.getText(buildSource).replace(/^export /, '');
});
const extensions = workspaceSource.statements.find(statement => ts.isVariableStatement(statement) &&
  statement.declarationList.declarations.some(declaration => declaration.name.getText(workspaceSource) === 'codeExtensions'));
if (!extensions) throw new Error('Upstream build extensions changed');
await build({ stdin: { contents: `${extensions.getText(workspaceSource).replace(/^export /, '')}
export function createWorkspaceBuild(host) {
  const { Content, Path, resolveWorkspaceSearchPath, toWorkspaceRelativePath, listFiles,
    sendWebIDEFileUpdate, runSingleTsTranspile, runSingleNonTsBuild, Log } = host;
  ${buildFunctions.join('\n')}
  // Lua table fields assigned nil are absent. Preserve that wire representation.
  return async request => Object.fromEntries(Object.entries(await build(request)).filter(([, value]) => value !== undefined));
}`, loader: 'ts' }, outfile: new URL('workspace-build.js', output).pathname, format: 'esm', platform: 'neutral' });
const readSlice = workspaceSource.statements.find(statement => ts.isFunctionDeclaration(statement) && statement.name?.text === 'formatReadSlice');
if (!readSlice) throw new Error('Upstream read formatter changed; review required');
await build({ stdin: { contents: `const math = Math;\n${readSlice.getText(workspaceSource)}\nexport {formatReadSlice};`, loader: 'ts' },
  outfile: new URL('read-slice.js', output).pathname, format: 'esm', platform: 'neutral' });
await build({ entryPoints: [new URL('./src/snapshot-read.js', import.meta.url).pathname],
  outfile: new URL('snapshot-read.js', output).pathname, format: 'esm', platform: 'neutral' });
const handlerPath = new URL('../../../Assets/Script/Lib/Agent/Tool/Handlers.ts', import.meta.url);
const handlerSource = ts.createSourceFile(handlerPath.pathname, await readFile(handlerPath, 'utf8'), ts.ScriptTarget.Latest, true);
const readHandlerParts = handlerSource.statements.filter(statement =>
  (ts.isFunctionDeclaration(statement) && statement.name?.text === 'readOneFile') ||
  (ts.isVariableStatement(statement) && statement.declarationList.declarations.some(d => d.name.getText(handlerSource) === 'readFile')));
if (readHandlerParts.length !== 2) throw new Error('Upstream read handler changed; review required');
await build({ stdin: { contents: `import * as AgentConfig from 'Agent/Config';
export function createReadHandler(readBackend) {
  const Tools = {readFile: readBackend};
  ${readHandlerParts.map(statement => statement.getText(handlerSource)).join('\n')}
  return readFile;
}`, loader: 'ts' }, outfile: new URL('read-handler.js', output).pathname,
  bundle: true, format: 'esm', platform: 'neutral',
  plugins: [{ name: 'agent-read-handler-config', setup(builder) {
    builder.onResolve({ filter: /^Agent\/Config$/ }, () => ({ path: new URL('../../../Assets/Script/Lib/Agent/Config.ts', import.meta.url).pathname }));
  } }] });
const validationPath = new URL('../../../Assets/Script/Lib/Agent/Tool/Validation.ts', import.meta.url);
const validationSource = ts.createSourceFile(validationPath.pathname, await readFile(validationPath, 'utf8'), ts.ScriptTarget.Latest, true);
const editParser = validationSource.statements.find(statement => ts.isFunctionDeclaration(statement) && statement.name?.text === 'getAgentFileEditInputs');
if (!editParser) throw new Error('Upstream edit parser changed; migration review required');
const semanticFunction = validationSource.statements.find(statement => ts.isFunctionDeclaration(statement) && statement.name?.text === 'validateAgentToolInput');
const searchBranches = ['tool === "grep_files" || tool === "search_dora_doc"', 'tool === "glob_files"'].map(expression => {
  const branch = semanticFunction?.body?.statements.find(statement => ts.isIfStatement(statement) && statement.expression.getText(validationSource) === expression);
  if (!branch) throw new Error(`Upstream search validation changed: ${expression}`);
  return branch.getText(validationSource);
});
const clampInteger = validationSource.statements.find(statement => ts.isFunctionDeclaration(statement) && statement.name?.text === 'clampInteger');
if (!clampInteger) throw new Error('Upstream search clamp changed');
const searchHandlers = ['grepFiles', 'globFiles', 'searchDoraDoc'].map(name => {
  const statement = handlerSource.statements.find(statement => ts.isVariableStatement(statement) && statement.declarationList.declarations.some(d => d.name.getText(handlerSource) === name));
  if (!statement) throw new Error(`Upstream search handler changed: ${name}`);
  return statement.getText(handlerSource);
});
await build({ stdin: { contents: `import * as AgentConfig from 'Agent/Config';
const math = Math;
${clampInteger.getText(validationSource)}
export function validateSearchInput(tool, input) {
  const value = {...input};
  ${searchBranches.join('\n')}
  return {success: false, message: 'Unknown search tool'};
}
export function createSearchHandlers(Tools) {
  ${searchHandlers.join('\n')}
  return {grep_files: grepFiles, glob_files: globFiles, search_dora_doc: searchDoraDoc};
}`, loader: 'ts' }, outfile: new URL('search-tools.js', output).pathname, bundle: true, format: 'esm', platform: 'neutral',
  plugins: [{ name: 'agent-search-config', setup(builder) {
    builder.onResolve({ filter: /^Agent\/Config$/ }, () => ({ path: new URL('../../../Assets/Script/Lib/Agent/Config.ts', import.meta.url).pathname }));
  } }] });
const buildBranch = semanticFunction?.body?.statements.find(statement => ts.isIfStatement(statement) && statement.expression.getText(validationSource) === 'tool === "build"');
const buildHandler = handlerSource.statements.find(statement => ts.isVariableStatement(statement) && statement.declarationList.declarations.some(d => d.name.getText(handlerSource) === 'build'));
if (!buildBranch || !buildHandler) throw new Error('Upstream build tool changed');
await build({ stdin: { contents: `
export function validateBuild(input) { const value = {...input}; ${buildBranch.thenStatement.getText(validationSource)} }
export function createBuildHandler(buildBackend) {
  const Tools = {build: buildBackend};
  ${buildHandler.getText(handlerSource)}
  return build;
}`, loader: 'ts' }, outfile: new URL('build-tool.js', output).pathname, format: 'esm', platform: 'neutral' });
const editBranch = semanticFunction?.body?.statements.find(statement => ts.isIfStatement(statement) && statement.expression.getText(validationSource) === 'tool === "edit_file"');
if (!editBranch) throw new Error('Upstream edit validator changed; review required');
const deleteBranch = semanticFunction?.body?.statements.find(statement => ts.isIfStatement(statement) && statement.expression.getText(validationSource) === 'tool === "delete_file"');
const decisionPath = validationSource.statements.find(statement => ts.isFunctionDeclaration(statement) && statement.name?.text === 'getDecisionPath');
if (!deleteBranch || !decisionPath) throw new Error('Upstream delete validator changed');
await build({ stdin: { contents: `${decisionPath.getText(validationSource)}
export function validateDeleteFile(input) { const value = {...input}; ${deleteBranch.thenStatement.getText(validationSource)} }`, loader: 'ts' },
  outfile: new URL('delete-validation.js', output).pathname, format: 'esm', platform: 'neutral' });
await build({ stdin: { contents: `${editParser.getText(validationSource)}
export function validateEditFile(input) {
  const value = {...input};
  ${editBranch.thenStatement.getText(validationSource)}
}`, loader: 'ts' }, outfile: new URL('edit-validation.js', output).pathname, format: 'esm', platform: 'neutral' });
const readBranch = semanticFunction?.body?.statements.find(statement => ts.isIfStatement(statement) && statement.expression.getText(validationSource) === 'tool === "read_file"');
const readHelpers = ['parseReadLine', 'normalizeReadRange'].map(name => {
  const fn = validationSource.statements.find(statement => ts.isFunctionDeclaration(statement) && statement.name?.text === name);
  if (!fn) throw new Error(`Upstream read helper missing: ${name}`);
  return fn.getText(validationSource);
});
if (!readBranch) throw new Error('Upstream read validator changed; review required');
await build({ stdin: { contents: `import * as AgentConfig from 'Agent/Config';
const math = Math;
${readHelpers.join('\n')}
export function validateReadFile(input) {
  const value = {...input};
  ${readBranch.thenStatement.getText(validationSource)}
}`, loader: 'ts' }, outfile: new URL('read-validation.js', output).pathname,
  bundle: true, format: 'esm', platform: 'neutral',
  plugins: [{ name: 'agent-read-config', setup(builder) {
    builder.onResolve({ filter: /^Agent\/Config$/ }, () => ({ path: new URL('../../../Assets/Script/Lib/Agent/Config.ts', import.meta.url).pathname }));
  } }] });
await build({ stdin: { contents: editParser.getText(validationSource), loader: 'ts' },
  outfile: new URL('file-edits.js', output).pathname, format: 'esm', platform: 'neutral' });
const policyPath = new URL('../../../Assets/Script/Lib/Agent/Runtime/Policy.ts', import.meta.url);
const policySource = ts.createSourceFile(policyPath.pathname, await readFile(policyPath, 'utf8'), ts.ScriptTarget.Latest, true);
const requiredPolicy = new Set(['AGENT_PLAN_DIR', 'AGENT_PLAN_FILE', 'AGENT_PROGRESS_FILE',
  'trimText', 'normalizeAgentPath', 'getAgentDecisionPath', 'isMainAgentMemoryPath', 'isAgentPlanPath']);
const policyParts = [];
for (const statement of policySource.statements) {
  const names = ts.isFunctionDeclaration(statement) ? [statement.name?.text] : ts.isVariableStatement(statement)
    ? statement.declarationList.declarations.map(d => d.name.getText(policySource)) : [];
  if (names.some(name => requiredPolicy.has(name))) {
    policyParts.push(statement.getText(policySource));
    for (const name of names) requiredPolicy.delete(name);
  }
}
if (requiredPolicy.size) throw new Error('Upstream guard policy changed; review required');
const deleteHandler = handlerSource.statements.find(statement => ts.isVariableStatement(statement) && statement.declarationList.declarations.some(d => d.name.getText(handlerSource) === 'deleteFile'));
const internalPath = policySource.statements.find(statement => ts.isFunctionDeclaration(statement) && statement.name?.text === 'isAgentInternalDocumentPath');
if (!deleteHandler || !internalPath) throw new Error('Upstream delete handler changed');
let deleteCalls = 0;
const asyncDelete = ts.transform(deleteHandler, [context => root => {
  const visit = node => {
    if (ts.isCallExpression(node) && node.expression.getText(handlerSource) === 'Tools.deleteFile') {
      deleteCalls++; return ts.factory.createAwaitExpression(ts.visitEachChild(node, visit, context));
    }
    return ts.visitEachChild(node, visit, context);
  };
  return ts.visitNode(root, visit);
}]);
if (deleteCalls !== 1) throw new Error('Upstream delete commit boundary changed');
const deleteSource = ts.createPrinter().printNode(ts.EmitHint.Unspecified, asyncDelete.transformed[0], handlerSource);
asyncDelete.dispose();
await build({ stdin: { contents: `export function createDeleteHandler(Tools) {
 const string = {match: value => [value.replace(/^[\\t\\n\\v\\f\\r ]+|[\\t\\n\\v\\f\\r ]+$/g, '')]};
 ${[...policyParts, internalPath.getText(policySource)].map(part => part.replace(/^export /, '')).join('\n')}
 const AgentRuntimePolicy = {normalizeAgentPath, isAgentInternalDocumentPath};
 ${deleteSource}
 return async (...args) => {
   const result = await deleteFile(...args);
   return {...result, output: Object.fromEntries(Object.entries(result.output).filter(([, value]) => value !== undefined))};
 };
}`, loader: 'ts' }, outfile: new URL('delete-handler.js', output).pathname, format: 'esm', platform: 'neutral' });
const editHandler = handlerSource.statements.find(statement => ts.isVariableStatement(statement) && statement.declarationList.declarations.some(d => d.name.getText(handlerSource) === 'editFile'));
if (!editHandler) throw new Error('Upstream edit handler changed');
let commitCalls = 0;
const asyncEdit = ts.transform(editHandler, [context => root => {
  const visit = node => {
    if (ts.isCallExpression(node) && node.expression.getText(handlerSource) === 'Tools.applyFileChanges') {
      commitCalls++;
      return ts.factory.createAwaitExpression(ts.visitEachChild(node, visit, context));
    }
    return ts.visitEachChild(node, visit, context);
  };
  return ts.visitNode(root, visit);
}]);
if (commitCalls !== 1) throw new Error('Upstream edit commit boundary changed; review required');
const asyncEditSource = ts.createPrinter().printNode(ts.EmitHint.Unspecified, asyncEdit.transformed[0], handlerSource);
asyncEdit.dispose();
const editPolicyNames = ['normalizeLineEndings', 'countOccurrences', 'containsWholeFileDuplicate', 'isAgentInternalDocumentPath', 'successfulEditResult'];
const editPolicyParts = [...policyParts];
for (const name of editPolicyNames) {
  const fn = policySource.statements.find(statement => ts.isFunctionDeclaration(statement) && statement.name?.text === name);
  if (!fn) throw new Error(`Upstream edit policy changed: ${name}`);
  editPolicyParts.push(fn.getText(policySource));
}
await build({ stdin: { contents: `
import * as AgentUtils from './text-edit.js';
import {getAgentFileEditInputs} from './file-edits.js';
import {getAgentFileEditPlanGuardDenial} from './guards.js';
export function createEditHandler(Tools) {
  const sanitizeUTF8 = text => text.toWellFormed();
  const string = {match: value => [value.replace(/^[\\t\\n\\v\\f\\r ]+|[\\t\\n\\v\\f\\r ]+$/g, '')]};
  ${editPolicyParts.map(part => part.replace(/^export /, '')).join('\n')}
  const AgentRuntimePolicy = {normalizeAgentPath, normalizeLineEndings, countOccurrences, containsWholeFileDuplicate, isAgentInternalDocumentPath, successfulEditResult};
  ${asyncEditSource}
  return editFile;
}`, loader: 'ts' }, outfile: new URL('edit-handler.js', output).pathname, format: 'esm', platform: 'neutral' });
await build({ entryPoints: [new URL('../../../Assets/Script/Lib/Agent/Tool/Guards.ts', import.meta.url).pathname],
  outfile: new URL('guards.js', output).pathname, bundle: true, format: 'esm', platform: 'neutral',
  plugins: [{ name: 'agent-guard-dependencies', setup(builder) {
    builder.onResolve({ filter: /^Agent\/Tool\/Validation$/ }, () => ({ path: new URL('file-edits.js', output).pathname }));
    builder.onResolve({ filter: /^Agent\/Runtime\/Policy$/ }, () => ({ path: 'policy', namespace: 'studio-policy' }));
    builder.onLoad({ filter: /.*/, namespace: 'studio-policy' }, () => ({ loader: 'ts', contents:
      `const string = {match(value, pattern) {
        if (pattern !== '^%s*(.-)%s*$') throw new Error('Unsupported Lua pattern in guard policy');
        return [value.replace(/^[\\t\\n\\v\\f\\r ]+|[\\t\\n\\v\\f\\r ]+$/g, '')];
      }};\n` + policyParts.join('\n') }));
  } }] });
await build({
  entryPoints: [new URL('../../../Assets/Script/Lib/Agent/JsonSchema.ts', import.meta.url).pathname],
  outfile: new URL('json-schema.js', output).pathname,
  bundle: true, format: 'esm', platform: 'neutral',
  banner: { js: 'const math = Math; const tostring = String; const utf8 = {len: value => [Array.from(value).length]};' },
  plugins: [{ name: 'dora-json-null', setup(builder) {
    builder.onResolve({ filter: /^Dora$/ }, () => ({ path: 'json-null', namespace: 'studio-schema' }));
    builder.onLoad({ filter: /.*/, namespace: 'studio-schema' }, () => ({ contents: 'export const json = {null: null};', loader: 'js' }));
  } }],
});
await build({
  entryPoints: [new URL('../../../Assets/Script/Lib/Agent/Tool/Executor.ts', import.meta.url).pathname],
  outfile: new URL('executor.js', output).pathname,
  bundle: true, format: 'esm', platform: 'neutral', banner: { js: 'const tostring = String;' },
  plugins: [{ name: 'agent-executor-dependencies', setup(builder) {
    const modules = { 'Agent/JsonSchema': './json-schema.js', 'Agent/Tool/Registry': './index.js', 'Agent/Tool/Guards': './guards.js' };
    builder.onResolve({ filter: /^Agent\// }, args => {
      const path = modules[args.path];
      if (!path) throw new Error(`Unadapted Agent executor dependency: ${args.path}`);
      return { path, external: true };
    });
  } }],
});
