import assert from 'node:assert/strict';
import {createRequire} from 'node:module';
import {mkdtemp,readdir,rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {resolve,join,relative,basename} from 'node:path';
import {build} from 'esbuild';
const require=createRequire(import.meta.url);

// Shared production/test compilation of the original Agent, not a second copy.
export async function compileAgentCommand({fullAgent=false,lineComments=false}={}) {
  const temp=await mkdtemp(join(tmpdir(),'studio-command-compile-'));
  const initialDirectory=process.cwd();
  try {
    const outfile=join(temp,'tstl.cjs');
    await build({entryPoints:[require.resolve('@dora-studio/tstl')],outfile,bundle:true,format:'cjs',platform:'node',logLevel:'silent'});
    const tstl=require(outfile);
    const lib=resolve('../Assets/Script/Lib');
    const declarations=(await readdir(join(lib,'Dora/en'))).filter(name=>name.endsWith('.d.ts')).map(name=>join(lib,'Dora/en',name));
    const output=new Map();
    const agentSources=[];
    async function collect(directory) {
      for(const item of await readdir(directory,{withFileTypes:true})) {
        const path=join(directory,item.name);
        if(item.isDirectory()) await collect(path);
        else if(item.name.endsWith('.ts')) agentSources.push(path);
      }
    }
    if(fullAgent) await collect(join(lib,'Agent'));
    process.chdir(lib); // Native lualib resolution is relative to the library root.
    const result=tstl.transpileFiles([
      join(lib,'Agent/Tool/Command.ts'),join(lib,'Agent/Tool/WebIDESync.ts'),...agentSources,...declarations,
    ],{noLib:true,strict:true,skipLibCheck:true,target:99,module:1,moduleResolution:2,
      baseUrl:lib,paths:{'*':['*','Dora/en/*']},luaTarget:'5.4',luaLibImport:'require',noHeader:true,
      noImplicitSelf:true,luaExternalModules:['Dora'],sourceMap:lineComments,
    },(path,text)=>output.set(path,text));
    const errors=result.diagnostics.filter(d=>d.category===1);
    assert.deepEqual(errors.map(d=>({file:d.file?.fileName,code:d.code,message:d.messageText})),[]);
    const command=[...output].find(([path])=>path.endsWith('/Command.lua'))?.[1];
    const preview=[...output].find(([path])=>path.endsWith('/CommandPreview.lua'))?.[1];
    assert.match(command,/registerCleanup/);
    assert.match(command,/restorePrint/);
    assert.match(preview,/registerCleanup/);
    assert.equal(result.emitSkipped,false);
    for(const source of agentSources.filter(path=>!path.endsWith('.d.ts'))) {
      assert.ok(output.has(source.replace(/\.ts$/,'.lua')),`Missing generated module: ${source}`);
    }
    const files=[...output].filter(([path])=>path.endsWith('.lua')).map(([path,text])=>({path:relative(lib,path),kind:'text',text}));
    if(lineComments) {
      const {SourceMapConsumer}=createRequire(require.resolve('@dora-studio/tstl'))('source-map');
      for(const file of files) {
        if(file.path==='lualib_bundle.lua')continue;
        const map=output.get(join(lib,file.path)+'.map');
        assert.ok(map,`Missing source map: ${file.path}`);
        // Match the existing Web IDE's TranspileTS annotation convention.
        await SourceMapConsumer.with(map,null,consumer=>{
          let lastLine=1;
          file.text='-- [ts]: '+basename(file.path,'.lua')+'.ts\n'+file.text.split('\n').map((line,index)=>{
            const original=consumer.originalPositionFor({line:index+1,column:line.search(/\S|$/)});
            if(original.line!==null)lastLine=original.line;
            if(line.trim()==='')return '';
            return line.includes('--')?line:line+' -- '+lastLine;
          }).filter(Boolean).join('\n');
        });
      }
    }
    return files;
  } finally {process.chdir(initialDirectory);await rm(temp,{recursive:true,force:true});}
}
