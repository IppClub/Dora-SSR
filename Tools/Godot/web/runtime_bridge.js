// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
// Two independently linked heaps: only scalar values, copied resource bytes and
// shared WebGL objects cross this boundary. No pixel readback/upload here.
export class GodotWebBridge {
  constructor(host,godot,boundary) {this.host=host;this.godot=godot;this.boundary=boundary;this.targets=[];}
  initialize(canvas) {
    const g=this.godot;
    g.initConfig({canvas,locale:navigator.language||'en',resizeCanvasOnStart:false});
    if(!g._dora_web_context() || g.GL.currentContext.GLctx!==this.host.GL.currentContext.GLctx)
      throw new Error('Godot and Dora must use the same WebGL2 context');
    // Attribute pointers/enables belong to the VAO object, not merely the
    // context's binding. Give Godot's integer name0 a private default VAO so
    // it cannot mutate bgfx's default object across a state boundary.
    const gl=g.GL.currentContext.GLctx;
    this.defaultVAO=gl.createVertexArray();this.defaultVAO.name=0;g.GL.vaos[0]=this.defaultVAO;
    const initial=this.boundary.states.get('godot');
    if(initial)initial.VERTEX_ARRAY_BINDING=this.defaultVAO;
  }
  error() {return this.godot.UTF8ToString(this.godot._dora_web_error());}
  open(project,scene,width,height,buffers) {
    const g=this.godot,p=g.stringToNewUTF8(project),s=g.stringToNewUTF8(scene||'');
    try {return Boolean(g._dora_web_open(p,s,width,height,buffers));}
    finally {g._free(p);g._free(s);}
  }
  bindTargets(width,height,hostIds) {
    const {godot:g,host:h,boundary:b}=this,next=[];
    try {
      for(const hostId of hostIds) {
        const texture=h.GL.textures[hostId];if(!texture)throw new Error('Missing host target texture');
        // Creating a second borrowed name for the same owner would leave stale
        // C++ slot IDs. Target replacement uses a fresh, drained generation.
        if(this.targets.some(target=>target.texture===texture))throw new Error('Target generation must be distinct');
        b.registerTexture('host',texture,hostId);
        next.push({hostId,texture,id:b.importTexture('godot',g,texture)});
      }
      const ids=g._malloc(next.length*4);let success;
      try {g.HEAPU32.set(next.map(target=>target.id),ids/4);success=g._dora_web_bind_targets(width,height,ids,next.length);}
      finally {g._free(ids);}
      if(!success)throw new Error('Godot target binding failed: '+this.error());
      for(const target of this.targets)b.releaseImport('godot',g,target.id);
      this.targets=next;return true;
    }catch(error){for(const target of next)b.releaseImport('godot',g,target.id);throw error;}
    finally {b.activate('host');}
  }
  releaseTargets() {
    // Caller drains all host readers and calls the native close first. The
    // native runtime borrows these names and must never delete their GL objects.
    for(const target of this.targets)this.boundary.releaseImport('godot',this.godot,target.id);
    this.targets=[];this.boundary.activate('host');
  }
}

// Must run before Dora creates the canvas context. The first clean state is
// captured at context creation, before bgfx caches its own bindings.
export function installDoraGodot(host,godot,canvas,Boundary) {
  let boundary=null,bridge=null;
  const original=canvas.getContext;
  canvas.getContext=function(type,attributes) {
    const gl=original.call(this,type,attributes);
    if(type==='webgl2' && gl && !boundary) {
      boundary=new Boundary(gl);boundary.states.set('godot',boundary.capture());boundary.activate('host');
      godot.doraBoundary=boundary;canvas.getContext=original;
    }
    return gl;
  };
  const facade={lastError:'',dispatch(...args) {
    try {
      const operation=args[0];
      // The canvas event is delivered before Dora's next native frame. Reject
      // any intervening graphics call deterministically instead of letting a
      // half-lost WebGL context mutate synchronization/error accounting. Close
      // and shutdown remain available for page-lifetime cleanup.
      if(boundary?.gl.isContextLost() && operation>=3 && operation<=16 && operation!==9 && operation!==10) {
        facade.lastError='Shared WebGL context lost; restart the runtime';
        return 0;
      }
      if(!bridge) {
        if(!boundary)throw new Error('Dora WebGL2 context has not been created');
        bridge=new GodotWebBridge(host,godot,boundary);bridge.initialize(canvas);
        bridge.scratch=godot._malloc(128);bridge.audioBuffer=godot._malloc(4096*2*4);
        if(!bridge.scratch||!bridge.audioBuffer)throw new Error('Cannot allocate Godot bridge buffers');
      }
      return bridge.dispatch(...args);
    }catch(error){facade.lastError=String(error);if(args[0]===2)writeString(host,args[1],args[2],facade.lastError);return 0;}
  }};
  host.doraGodotBridge=facade;
  return facade;
}
function writeString(host,pointer,capacity,value) {
  if(!pointer||!capacity)return;
  const bytes=new TextEncoder().encode(value),size=Math.min(bytes.length,capacity-1);
  host.HEAPU8.set(bytes.subarray(0,size),pointer);host.HEAPU8[pointer+size]=0;
}
GodotWebBridge.prototype.copyProject=function(path) {
  const source=this.host.FS,target=this.godot.FS,ancestors=new Set();
  const copy=path=>{
    const node=source.lookupPath(path,{follow:true}).node;
    if(source.isDir(node.mode)) {
      if(ancestors.has(node))throw new Error('Cyclic Godot project resource link');
      ancestors.add(node);target.mkdirTree(path);
      for(const name of source.readdir(path))if(name!=='.'&&name!=='..')copy(path.replace(/\/$/,'')+'/'+name);
      ancestors.delete(node);
    }else {
      target.mkdirTree(path.slice(0,path.lastIndexOf('/'))||'/');target.writeFile(path,source.readFile(path));
    }
  };
  copy(path);
};
// Operation numbers match Source/Godot/GodotWebAPI.cpp. Struct layout is asserted
// there for wasm32; pointer-bearing text is copied into the receiving heap.
GodotWebBridge.prototype.dispatch=function(operation,data,a,b,c,d) {
  const h=this.host,g=this.godot,view=new DataView(h.HEAPU8.buffer),scratch=this.scratch;
  const u32=offset=>view.getUint32(data+offset,true),text=pointer=>pointer?h.UTF8ToString(pointer):'';
  const ticket=BigInt(b)|(BigInt(c)<<32n);
  const copyResult=(size,invoke)=>{
    g.HEAPU32[scratch/4]=size;const ok=invoke(scratch);
    if(ok)h.HEAPU8.set(g.HEAPU8.subarray(scratch,scratch+size),data);return ok;
  };
  switch(operation) {
    case 0:return 1;
    case 1:writeString(h,data,a,g.UTF8ToString(g._dora_web_version()));return 1;
    case 2:writeString(h,data,a,this.host.doraGodotBridge.lastError||this.error());return 1;
    case 3:{const project=text(u32(20)),scene=text(u32(24));this.copyProject(project);return this.open(project,scene,u32(8),u32(12),u32(16))?1:0;}
    case 4:{const target=this.targets[a];if(!target || g._dora_web_slot(a)!==target.id)return 0;
      [28,this.width,this.height,1,target.hostId,0,0].forEach((value,i)=>view.setUint32(data+i*4,value,true));return 1;}
    case 5:{const value=g._dora_web_advance(a,ticket);view.setBigUint64(data,value,true);return value?1:0;}
    case 6:{g.HEAPU8.set(h.HEAPU8.subarray(data,data+56),scratch);const inputText=g.stringToNewUTF8(text(u32(32)));
      try{g.HEAPU32[(scratch+32)/4]=inputText;return g._dora_web_input(scratch);}finally{g._free(inputText);}}
    case 7:return g._dora_web_pause(a);
    case 8:{const scene=g.stringToNewUTF8(text(data));try{return g._dora_web_restart(scene);}finally{g._free(scene);}}
    case 9:{const stats=g._dora_web_close();if(data)h.HEAPU8.set(g.HEAPU8.subarray(stats,stats+40),data);this.releaseTargets();return 1;}
    case 10:this.shutdown();return 1;
    case 11:return g._dora_web_can_produce(a,ticket);
    case 12:return g._dora_web_consumer_begin(a,ticket);
    case 13:return g._dora_web_consumer_end(a,ticket);
    case 14:return g._dora_web_can_advance(a,ticket);
    case 15:{const ids=Array.from(h.HEAPU32.subarray(data/4,data/4+c));this.bindTargets(a,b,ids);this.width=a;this.height=b;return 1;}
    case 16:return copyResult(16,pointer=>g._dora_web_output(pointer));
    case 17:return copyResult(12,pointer=>g._dora_web_audio_format(pointer));
    case 18:return g._dora_web_audio_start();
    case 19:{const count=g._dora_web_audio_read(this.audioBuffer,a);if(count)h.HEAPF32.set(g.HEAPF32.subarray(this.audioBuffer/4,this.audioBuffer/4+count*2),data/4);return count;}
    case 20:return copyResult(40,pointer=>g._dora_web_audio_stats(pointer));
    case 21:return copyResult(24,pointer=>g._dora_web_ime(pointer));
    default:throw new Error('Unknown Dora/Godot Web operation '+operation);
  }
};

GodotWebBridge.prototype.shutdown=function() {
  const g=this.godot;g._dora_web_shutdown();
  g.GL.currentContext.GLctx.deleteVertexArray(this.defaultVAO);g.GL.vaos[0]=null;
  this.boundary.states.delete('godot');
  if(this.scratch)g._free(this.scratch);if(this.audioBuffer)g._free(this.audioBuffer);
  this.scratch=0;this.audioBuffer=0;
};
