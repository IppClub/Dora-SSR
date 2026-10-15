import {createServer} from 'node:https';
import {readFileSync} from 'node:fs';

const key=readFileSync(process.env.STUDIO_FIXTURE_TLS_KEY),cert=readFileSync(process.env.STUDIO_FIXTURE_TLS_CERT);
const seed='// Dora Studio · TypeScript\nimport { Vec2 } from "Dora";\n\nexport const start = Vec2(0, 0);\n';
const header='import { App, DrawNode, Director, Vec2, Color, Size } from "Dora";\nconst stage = DrawNode();\nstage.size = Size(640, 360);\nstage.position = Vec2(App.visualSize.width / 2, App.visualSize.height / 2);\n';
const background='stage.drawPolygon([Vec2(-320,-180),Vec2(320,-180),Vec2(320,180),Vec2(-320,180)],Color(0xff14251c));\nstage.drawPolygon([Vec2(-320,-150),Vec2(320,-150),Vec2(320,-105),Vec2(-320,-105)],Color(0xff39845a));\n';
const platforms='stage.drawPolygon([Vec2(-180,-65),Vec2(-35,-65),Vec2(-35,-42),Vec2(-180,-42)],Color(0xff82918a));\nstage.drawPolygon([Vec2(55,-5),Vec2(205,-5),Vec2(205,18),Vec2(55,18)],Color(0xff82918a));\n';
const player='stage.drawPolygon([Vec2(-255,-105),Vec2(-215,-105),Vec2(-215,-55),Vec2(-255,-55)],Color(0xffff8a3d));\n';
const rain='stage.drawPolygon([Vec2(-270,85),Vec2(-262,85),Vec2(-275,42),Vec2(-283,42)],Color(0xff3b82f6));\nstage.drawPolygon([Vec2(-150,145),Vec2(-142,145),Vec2(-155,95),Vec2(-163,95)],Color(0xff3b82f6));\nstage.drawPolygon([Vec2(-20,110),Vec2(-12,110),Vec2(-25,60),Vec2(-33,60)],Color(0xff3b82f6));\nstage.drawPolygon([Vec2(105,155),Vec2(113,155),Vec2(100,105),Vec2(92,105)],Color(0xff3b82f6));\nstage.drawPolygon([Vec2(235,95),Vec2(243,95),Vec2(230,45),Vec2(222,45)],Color(0xff3b82f6));\n';
const stars='stage.drawPolygon([Vec2(-95,70),Vec2(-82,55),Vec2(-95,40),Vec2(-108,55)],Color(0xffffc857));\nstage.drawPolygon([Vec2(130,100),Vec2(143,85),Vec2(130,70),Vec2(117,85)],Color(0xffffc857));\nstage.drawPolygon([Vec2(255,45),Vec2(268,30),Vec2(255,15),Vec2(242,30)],Color(0xffffc857));\nstage.drawPolygon([Vec2(245,-105),Vec2(285,-105),Vec2(285,-25),Vec2(245,-25)],Color(0xffb56cff));\n';
const interaction='stage.onTapBegan(() => { print("RICH_GAME_TAPPED"); });\nDirector.ui.addChild(stage);\n';
const initial=header+background+platforms+player+interaction+'print("RICH_GAME_ROUND1_READY");\n';
const rainy=header+background+platforms+player+rain+interaction+'print("RICH_GAME_RAIN_READY");\n';
const finalGame=header+background+platforms+player+rain+stars+interaction+'print("RICH_GAME_FINAL_READY");\n';
const rounds={initial:{calls:0,buildSucceeded:false,previewSucceeded:false,previewFrameCount:0},rain:{calls:0,buildSucceeded:false,previewSucceeded:false,previewFrameCount:0},stars:{calls:0,buildSucceeded:false,previewSucceeded:false,previewFrameCount:0}};
let calls=0;

const server=createServer({key,cert},async(request,response)=>{
  if(request.method==='GET'&&request.url==='/stats'){response.setHeader('Content-Type','application/json');response.end(JSON.stringify({calls,rounds}));return;}
  if(request.method!=='POST'||request.url!=='/v1/chat/completions'){response.statusCode=404;response.end();return;}
  if(request.headers.authorization!=='Bearer test-only-browser-provider-key'){response.statusCode=401;response.end();return;}
  let raw='',size=0;for await(const part of request){size+=part.length;if(size>1024*1024){response.statusCode=413;response.end();return;}raw+=part;}
  let body;try{body=JSON.parse(raw);}catch{response.statusCode=400;response.end();return;}
  if(body.model!=='fixture-model'||!Array.isArray(body.messages)){response.statusCode=400;response.end();return;}
  calls++;
  const userIndex=body.messages.findLastIndex(message=>message?.role==='user');
  const prompt=String(body.messages[userIndex]?.content??'');
  const round=prompt.includes('星光')?'stars':prompt.includes('雨滴')?'rain':'initial';
  const toolResults=body.messages.slice(userIndex+1).filter(message=>message?.role==='tool');
  const step=rounds[round].calls++;
  if(step===2){try{const result=JSON.parse(toolResults.at(-1).content);rounds[round].buildSucceeded=result.success===true;rounds[round].buildReport=result;}catch(error){rounds[round].buildReport={parseError:String(error),content:toolResults.at(-1)?.content};}}
  if(step===3){try{const result=JSON.parse(toolResults.at(-1).content);rounds[round].previewSucceeded=result.success===true&&result.previewGame?.success===true;rounds[round].previewFrameCount=Number(result.previewGame?.frameCount??0);rounds[round].previewReport=result;}catch(error){rounds[round].previewReport={parseError:String(error),content:toolResults.at(-1)?.content};}}
  const oldSource=round==='stars'?rainy:round==='rain'?initial:seed;
  const newSource=round==='stars'?finalGame:round==='rain'?rainy:initial;
  const edit={index:0,id:`rich_game_edit_${round}`,type:'function',function:{name:'edit_file',arguments:JSON.stringify({path:'main.ts',old_str:oldSource,new_str:newSource})}};
  const build={index:0,id:`rich_game_build_${round}`,type:'function',function:{name:'build',arguments:JSON.stringify({paths:['main.ts']})}};
  const preview={index:0,id:`rich_game_preview_${round}`,type:'function',function:{name:'execute_command',arguments:JSON.stringify({mode:'lua',code:'previewGame({entry="main.ts",captureAtSeconds={0.5}})',timeoutSeconds:40})}};
  const next=step===0?edit:step===1?build:step===2?preview:undefined;
  const content=round==='stars'?'星光目标、雨景、平台与点击反馈已经完成。':round==='rain'?'雨滴层和场景反馈已经完成。':'基础平台、角色和点击玩法已经完成。';
  const choice=next?{index:0,delta:{tool_calls:[next]},finish_reason:'tool_calls'}:{index:0,delta:{role:'assistant',content},finish_reason:'stop'};
  const usage={prompt_tokens:24,completion_tokens:12,total_tokens:36};
  response.setHeader('Content-Type','text/event-stream');response.setHeader('Cache-Control','no-store');
  response.write('data: '+JSON.stringify({choices:[choice]})+'\n\n');
  response.write('data: '+JSON.stringify({choices:[],usage})+'\n\n');
  response.end('data: [DONE]\n\n');
});
const port=Number(process.env.STUDIO_FIXTURE_PORT??8962);
server.listen(port,'127.0.0.1',()=>process.stdout.write(`Rich game fixture provider listening on https://127.0.0.1:${port}\n`));
for(const signal of ['SIGINT','SIGTERM'])process.once(signal,()=>server.close(()=>process.exit(0)));
