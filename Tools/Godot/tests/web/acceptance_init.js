// Shared browser instrumentation for Playwright and native Safari WebDriver.
(()=>{
 const evidence=window.__doraAcceptance={logs:[],errors:[],warnings:[]};
 for(const level of ['log','info','warn','error']){
  const original=console[level].bind(console);
  console[level]=(...args)=>{
   const text=args.map(value=>{try{return typeof value==='string'?value:JSON.stringify(value);}catch{return String(value);}}).join(' ');
   evidence.logs.push(text);
   if(level==='error'||text.includes('[error]'))evidence.errors.push(text);
   if(level==='warn')evidence.warnings.push(text);
   original(...args);
  };
 }
 window.addEventListener('error',event=>evidence.errors.push(event.message||String(event.error)));
 window.addEventListener('unhandledrejection',event=>evidence.errors.push(String(event.reason)));
   const create=AudioContext.prototype.createScriptProcessor;
   AudioContext.prototype.createScriptProcessor=function(...args){const node=create.apply(this,args);(window.__doraOutputSources ||= []).push({context:this,node});return node;};
   window.addEventListener('dora-statechange',event=>console.log('DORA_STATE '+JSON.stringify(event.detail)));
   let godotFactory;
   Object.defineProperty(window,'Godot',{configurable:true,get:()=>godotFactory,set:factory=>{
    console.log('GODOT_FACTORY loaded');
    godotFactory=async(...args)=>{
     console.log('GODOT_FACTORY begin');
     const runtime=await factory(...args);console.log('GODOT_FACTORY ready');
     const initFS=runtime.initFS;
     if(initFS)runtime.initFS=async(...paths)=>{console.log('GODOT_FS begin');const result=await initFS.apply(runtime,paths);console.log('GODOT_FS ready');return result;};
     return runtime;
    };
   }});
   let value;
   Object.defineProperty(window,'Module',{configurable:true,get:()=>value,set:module=>{
    value=module;if(!module||module.__godotTestConfigured)return;module.__godotTestConfigured=true;
    module.doraGodotStartupTrace=stage=>console.log('GODOT_STARTUP '+stage);
    module.monitorRunDependencies=count=>console.log('DORA_DEPENDENCIES '+count);
    const metrics={requests:{},underruns:[],operations:[],pcm_calls:0,pcm_total_ms:0,pcm_max_ms:0};module.doraTestAudioMetrics=metrics;
    let bridge;
    Object.defineProperty(module,'doraGodotBridge',{configurable:true,get:()=>bridge,set:facade=>{
      bridge=facade;const original=facade.dispatch.bind(facade);
      facade.dispatch=(...args)=>{
        const before=performance.now(),result=original(...args),after=performance.now();
        if([3,8,9,15].includes(args[0]))metrics.operations.push({operation:args[0],at:before,duration:after-before});
        if(args[0]===19){const duration=after-before;metrics.pcm_calls++;metrics.pcm_total_ms+=duration;metrics.pcm_max_ms=Math.max(metrics.pcm_max_ms,duration);const requested=args[2];metrics.requests[requested]=(metrics.requests[requested]||0)+1;if(result<requested)metrics.underruns.push({at:before,requested,received:result});}
        return result;
      };
    }});
    module.preRun=module.preRun||[];module.preRun.push(()=>{if(typeof ENV!=='undefined'){ENV.DORA_GODOT_TEST_AUDIO='1';ENV.DORA_GODOT_TEST_CONTROLLER='1';}});
   }});

})();
