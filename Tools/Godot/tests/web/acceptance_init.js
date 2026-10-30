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
    const metrics={requests:{},underruns:[],operations:[],pcm_calls:0,pcm_total_ms:0,pcm_max_ms:0,sessions:[],protocol_errors:[]};module.doraTestAudioMetrics=metrics;
    let bridge;
    Object.defineProperty(module,'doraGodotBridge',{configurable:true,get:()=>bridge,set:facade=>{
      bridge=facade;const original=facade.dispatch.bind(facade);
      let session=null;
      const pending=()=>session?Object.values(session.pending).reduce((a,b)=>a+b,0):0;
      const stats=(pointer)=>{
        const view=new DataView(module.HEAPU8.buffer);
        if(view.getUint32(pointer,true)!==40)metrics.protocol_errors.push('Unexpected C ABI stats size');
        return [8,16,24,32].map(offset=>{
          const value=view.getBigUint64(pointer+offset,true);
          if(value>BigInt(Number.MAX_SAFE_INTEGER))metrics.protocol_errors.push('Stats exceed safe integer range');
          return Number(value);
        });
      };
      facade.dispatch=(...args)=>{
        const before=performance.now(),result=original(...args),after=performance.now();
        if([3,8,9,15].includes(args[0]))metrics.operations.push({operation:args[0],at:before,duration:after-before});
        if(args[0]===19){const duration=after-before;metrics.pcm_calls++;metrics.pcm_total_ms+=duration;metrics.pcm_max_ms=Math.max(metrics.pcm_max_ms,duration);const requested=args[2];metrics.requests[requested]=(metrics.requests[requested]||0)+1;if(result<requested)metrics.underruns.push({at:before,requested,received:result});}
        // Observe the unchanged production C ABI, without enabling native
        // diagnostics or adding calls. This covers Release builds whose Info
        // logs are compiled out. No GL pixels are transferred by this observer.
        const [operation,data,slot]=args;
        if(operation===3 && result){
          session={buffers:new DataView(module.HEAPU8.buffer).getUint32(data+16,true),
            pending:{},produced_slots:{},begins:0,ends:0,empty_ends:0,max_pending:0,bindings:0,pcm_frames:0,
            nonzero_consumed:0,tone_frames:0,tone_crossings:[0,0],last_samples:[0,0],audio_stats:null};
        }
        if(operation===5 && result && session)session.produced_slots[slot]=true;
        if((operation===12||operation===13) && session){
          if(!result)metrics.protocol_errors.push('Native reader operation failed: '+operation);
          else{
            if(operation===12){session.pending[slot]=(session.pending[slot]||0)+1;session.begins++;}
            else{
              session.ends++;
              if(session.pending[slot]>0)session.pending[slot]--;
              else if(!session.produced_slots[slot])session.empty_ends++;
              else metrics.protocol_errors.push('Produced slot reader ended without begin');
            }
            session.max_pending=Math.max(session.max_pending,pending());
          }
        }
        if(operation===15 && result && session){
          if(pending())metrics.protocol_errors.push('Target replacement with pending readers');
          session.bindings++;session.produced_slots={};
        }
        if(operation===19 && result>0 && session){
          const samples=module.HEAPF32;session.pcm_frames+=result;
          let nonzero=0;
          for(let sample=0;sample<result*2;sample++){
            const value=samples[data/4+sample];
            if(!Number.isFinite(value))metrics.protocol_errors.push('Nonfinite PCM');
            if(Math.abs(value)>0.00001)nonzero++;
          }
          session.nonzero_consumed+=nonzero;
          // Capture a complete continuous second of the known tone. Boot and
          // pause supply intentional silence; neither should count as a tone.
          if(!nonzero && session.tone_frames<48000){
            session.tone_frames=0;session.tone_crossings=[0,0];session.last_samples=[0,0];
          }
          for(let frame=0;frame<result && session.tone_frames<48000;frame++){
            const left=samples[data/4+frame*2],right=samples[data/4+frame*2+1];
            if(!session.tone_frames && Math.abs(left)<0.00001)continue;
            for(let channel=0;channel<2;channel++){
              const sample=channel?right:left;
              if(session.tone_frames && session.last_samples[channel]<=0 && sample>0)session.tone_crossings[channel]++;
              session.last_samples[channel]=sample;
            }
            session.tone_frames++;
          }
        }
        if(operation===20 && result && session)session.audio_stats=stats(data);
        if(operation===9 && result && session){
          session.close_stats=stats(data);session.pending_at_close=pending();
          metrics.sessions.push(session);session=null;
        }
        return result;
      };
    }});
    module.preRun=module.preRun||[];module.preRun.push(()=>{if(typeof ENV!=='undefined'){ENV.DORA_GODOT_TEST_AUDIO='1';ENV.DORA_GODOT_TEST_CONTROLLER='1';}});
   }});

})();
