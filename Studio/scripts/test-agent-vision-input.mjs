import {mkdtemp,readFile,writeFile,mkdir,rm} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join,dirname} from 'node:path';
import {execFileSync} from 'node:child_process';
import {compileAgentCommand} from './compile-agent.mjs';

const temp=await mkdtemp(join(tmpdir(),'dora-vision-input-'));
try{
 for(const file of await compileAgentCommand({fullAgent:true})){
  const path=join(temp,file.path);await mkdir(dirname(path),{recursive:true});await writeFile(path,file.text);
 }
 await writeFile(join(temp,'lualib_bundle.lua'),await readFile('../Assets/Script/Lib/lualib_bundle.lua'));
 let output='';
 for(const fixture of ['agent-vision-input.lua','agent-vision-failures.lua']){
  await writeFile(join(temp,'test.lua'),`package.path=${JSON.stringify(temp+'/?.lua;')}..package.path\n`+await readFile('scripts/fixtures/'+fixture,'utf8'));
  const result=execFileSync(process.env.LUA||'lua',[join(temp,'test.lua')],{encoding:'utf8'});output+=result;process.stdout.write(result);
 }
 await mkdir('../build/agent-vision-input-qa',{recursive:true});await writeFile('../build/agent-vision-input-qa/regression.log',output);
}finally{await rm(temp,{recursive:true,force:true});}
