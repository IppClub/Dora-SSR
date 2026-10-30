// Optional independent LibGodot runtime. Included only by dora_web_godot builds.
(function() {
  const previous=Module.doraPrepareRuntime;
  Module.doraPrepareRuntime=async function() {
    if(previous)await previous();
    const files=Module.doraManifest?.files||[],roots=files.filter(file=>file.path==='project.godot'||file.path.endsWith('/project.godot')).map(file=>file.path.slice(0,-'project.godot'.length));
    const selected=files.filter(file=>file.path.endsWith('.pck')||roots.some(root=>file.path.startsWith(root)));
    let index=0;
    await Promise.all(Array.from({length:Math.min(4,selected.length)},async()=>{for(;;){const file=selected[index++];if(!file)return;await globalThis.DoraWebLoader.fetchPath(Module,file.path);}}));
  };
  Module.preRun=Module.preRun||[];
  Module.preRun.push(function() {
    const dependency='dora-godot-runtime';addRunDependency(dependency);
    const stage=name=>Module.doraGodotStartupTrace?.(name);
    stage('begin');
    const base=new URL(Module.doraGodotBaseUrl||'godot/',document.baseURI);
    (async()=>{
      if(!globalThis.crossOriginIsolated)throw new Error('Godot Web threads require COOP/COEP response headers');
      await new Promise((resolve,reject)=>{const script=document.createElement('script');script.src=new URL('dora-godot.js',base).href;script.onload=resolve;script.onerror=()=>reject(new Error('Cannot load LibGodot Web runtime'));document.head.append(script);});
      stage('script-loaded');
      const [{SharedGLBoundary},{installDoraGodot}]=await Promise.all([import(new URL('shared_gl.mjs',base).href),import(new URL('runtime_bridge.mjs',base).href)]);
      stage('bridge-loaded');
      const godot=await globalThis.Godot({canvas:Module.canvas,noInitialRun:true,mainScriptUrlOrBlob:new URL('dora-godot.js',base).href,locateFile:path=>new URL(path.endsWith('.wasm')?'dora-godot.wasm':path,base).href});
      stage('factory-ready');
      // The raw modularized factory does not run Godot's Engine wrapper. Mount
      // and populate the same persistent user:// path that wrapper normally
      // initializes before Main::setup.
      if(typeof godot.initFS!=='function')throw new Error('Godot persistent filesystem initializer is unavailable');
      const storageError=await godot.initFS(['/userfs']);
      stage('filesystem-ready');
      godot.doraStoragePersistent=!storageError;
      installDoraGodot(Module,godot,Module.canvas,SharedGLBoundary);
      Module.doraGodotRuntime=godot;removeRunDependency(dependency);
    })().catch(error=>{Module.doraStartupFailed=true;globalThis.doraSetState?.('faulted',String(error));abort(String(error));});
  });
})();
