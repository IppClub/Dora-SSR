import {mkdir,readFile,writeFile} from 'node:fs/promises';
import {execFileSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {build} from 'esbuild';

const root=new URL('../../',import.meta.url),output=new URL('../packages/agent-contracts/dist/yarn/',import.meta.url);
await mkdir(output,{recursive:true});
execFileSync(process.env.STUDIO_EMXX||'em++',[
  fileURLToPath(new URL('yarn-host.cpp',import.meta.url)),
  fileURLToPath(new URL('Source/3rdParty/yarnflow/yarn_compiler.cpp',root)),
  fileURLToPath(new URL('Source/3rdParty/yuescript/parser.cpp',root)),
  fileURLToPath(new URL('Source/3rdParty/yuescript/ast.cpp',root)),
  '-I'+fileURLToPath(new URL('Source/3rdParty/',root)),'-I'+fileURLToPath(new URL('Source/3rdParty/Other/',root)),
  '-std=c++20','-DYUE_UTF8_IMPL','-O2','--no-entry',
  '-sMODULARIZE=1','-sEXPORT_ES6=1','-sSINGLE_FILE=1','-sENVIRONMENT=web,node','-sALLOW_MEMORY_GROWTH=1',
  '-sEXPORTED_FUNCTIONS=["_yarn_check_file","_yarn_error_message","_yarn_error_node","_yarn_error_line","_yarn_error_column","_malloc","_free"]',
  '-sEXPORTED_RUNTIME_METHODS=["cwrap","HEAPU8"]',
  '-o',fileURLToPath(new URL('compiler.mjs',output)),
],{stdio:'inherit'});
await build({entryPoints:[fileURLToPath(new URL('../packages/agent-contracts/src/yarn-worker.js',import.meta.url))],
  outfile:fileURLToPath(new URL('worker.mjs',output)),bundle:true,format:'esm',platform:'browser',external:['./compiler.mjs']});
await writeFile(new URL('YarnFlow-LICENSE',output),await readFile(new URL('Source/3rdParty/yarnflow/yarn_compiler.cpp',root),'utf8').then(text=>text.slice(0,text.indexOf('#include'))));
await writeFile(new URL('YueParser-LICENSE',output),await readFile(new URL('Source/3rdParty/yuescript/LICENSE',root)));
await writeFile(new URL('UTF8-LICENSE',output),await readFile(new URL('Source/3rdParty/Other/utf8cpp.h',root),'utf8').then(text=>text.slice(0,text.indexOf('#ifndef UTF8_FOR_CPP'))));
