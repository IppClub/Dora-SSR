// Bundle the production synchronous reader and signer for HTTP LAN acceptance.
import {readFile} from 'node:fs/promises';
import {build} from 'esbuild';
import ts from 'typescript';
const source=await readFile(new URL('../src/Service.ts',import.meta.url),'utf8');
const ast=ts.createSourceFile('Service.ts',source,ts.ScriptTarget.Latest,true);
const names=new Set(['getSync','parseSession','addr']);
const declarations=ast.statements.filter(s=>(ts.isFunctionDeclaration(s)&&names.has(s.name?.getText(ast)))||(ts.isVariableStatement(s)&&s.declarationList.declarations.some(d=>names.has(d.name.getText(ast)))));
if(declarations.length!==3)throw new Error('Synchronous reader boundary changed');
await build({stdin:{contents:`import {createAuthHeaders,signAuthPayload,authNonce} from './src/AuthSignature';\nlet authRequired=true;\n${declarations.map(s=>s.getText(ast)).join('\n')}\nexport {getSync,createAuthHeaders,signAuthPayload,authNonce};`,loader:'ts',resolveDir:new URL('../',import.meta.url).pathname},bundle:true,format:'esm',define:{'process.env.NODE_ENV':'"development"'},outfile:process.argv[2]});
