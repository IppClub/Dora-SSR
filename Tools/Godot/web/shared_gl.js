/* Copyright (c) 2026 Dora SSR contributors. MIT license (see LICENSE).
 * One WebGL2 context, separate Emscripten heaps and GL object-name tables.
 * No pixels are copied here. Readback belongs only to the test oracle.
 */
export class SharedGLBoundary {
  constructor(gl) { this.gl=gl;this.states=new Map();this.textureNames=new Map();this.owner=null; }
  importTexture(owner,module,texture) {
    const id=module.GL.getNewId(module.GL.textures);module.GL.textures[id]=texture;
    let names=this.textureNames.get(texture);if(!names)this.textureNames.set(texture,names=new Map());
    names.set(owner,id);return id;
  }
  releaseImport(owner,module,id) {
    // Remove a borrowed name after the native owner has released the slot.
    // Do not unbind a live host-owned texture behind the host renderer's cache.
    const texture=module.GL.textures[id],names=this.textureNames.get(texture);
    if(!texture || !names || names.get(owner)!==id)throw new Error('Unknown borrowed texture name');
    const state=this.states.get(owner);
    if(state)for(const unit of state.textures)for(let i=0;i<4;i++)if(unit[i]===texture)unit[i]=null;
    module.GL.textures[id]=null;names.delete(owner);
    if(names.size<=1) {
      if(names.size)texture.name=names.values().next().value;
      this.textureNames.delete(texture);
    }else if(names.has(this.owner))texture.name=names.get(this.owner);
  }
  registerTexture(owner,texture,id) {
    let names=this.textureNames.get(texture);if(!names)this.textureNames.set(texture,names=new Map());names.set(owner,id);
  }
  forgetTexture(texture) {
    // Call outside a scope, after the consumer ledger drains, before its owner
    // deletes the texture. Saved state must never rebind a deleted GL object.
    for(const state of this.states.values())for(const unit of state.textures)for(let i=0;i<4;i++)if(unit[i]===texture)unit[i]=null;
    const g=this.gl,active=g.getParameter(g.ACTIVE_TEXTURE);
    for(let i=0;i<g.getParameter(g.MAX_COMBINED_TEXTURE_IMAGE_UNITS);i++) {
      g.activeTexture(g.TEXTURE0+i);
      for(const [target,binding] of [[g.TEXTURE_2D,g.TEXTURE_BINDING_2D],[g.TEXTURE_CUBE_MAP,g.TEXTURE_BINDING_CUBE_MAP],[g.TEXTURE_3D,g.TEXTURE_BINDING_3D],[g.TEXTURE_2D_ARRAY,g.TEXTURE_BINDING_2D_ARRAY]])if(g.getParameter(binding)===texture)g.bindTexture(target,null);
    }
    g.activeTexture(active);this.textureNames.delete(texture);
  }
  activate(owner) {
    for(const [texture,names] of this.textureNames)if(names.has(owner))texture.name=names.get(owner);
    this.owner=owner;
  }
  capture() {
    const g=this.gl,q=p=>g.getParameter(p),s={};
    // Once the shared context is lost, WebGL state queries return null/default
    // values. They are not a restorable snapshot and must never overwrite the
    // last valid per-engine state.
    if(g.isContextLost())return null;
    // Emscripten glUniform* and pixel transfers read these JS shadow fields,
    // not the native GL bindings. A raw WebGL restore must restore both.
    // Preserve absence too: another runtime may not have initialized a field.
    s.emscripten={};
    for(const key of ['currentProgram','currentPixelPackBufferBinding','currentPixelUnpackBufferBinding','currentArrayBufferBinding','currentElementArrayBufferBinding'])
      s.emscripten[key]={present:Object.hasOwn(g,key),value:g[key]};
    for(const key of ['CURRENT_PROGRAM','VERTEX_ARRAY_BINDING','TRANSFORM_FEEDBACK_BINDING','DRAW_FRAMEBUFFER_BINDING','READ_FRAMEBUFFER_BINDING','RENDERBUFFER_BINDING','ACTIVE_TEXTURE','VIEWPORT','SCISSOR_BOX','COLOR_WRITEMASK','COLOR_CLEAR_VALUE','DEPTH_CLEAR_VALUE','STENCIL_CLEAR_VALUE','DEPTH_WRITEMASK','DEPTH_FUNC','DEPTH_RANGE','CULL_FACE_MODE','FRONT_FACE','BLEND_COLOR','BLEND_EQUATION_RGB','BLEND_EQUATION_ALPHA','BLEND_SRC_RGB','BLEND_DST_RGB','BLEND_SRC_ALPHA','BLEND_DST_ALPHA','STENCIL_FUNC','STENCIL_REF','STENCIL_VALUE_MASK','STENCIL_WRITEMASK','STENCIL_FAIL','STENCIL_PASS_DEPTH_FAIL','STENCIL_PASS_DEPTH_PASS','STENCIL_BACK_FUNC','STENCIL_BACK_REF','STENCIL_BACK_VALUE_MASK','STENCIL_BACK_WRITEMASK','STENCIL_BACK_FAIL','STENCIL_BACK_PASS_DEPTH_FAIL','STENCIL_BACK_PASS_DEPTH_PASS','LINE_WIDTH','POLYGON_OFFSET_FACTOR','POLYGON_OFFSET_UNITS','SAMPLE_COVERAGE_VALUE','SAMPLE_COVERAGE_INVERT','READ_BUFFER'])s[key]=q(g[key]);
    if(q(g.TRANSFORM_FEEDBACK_ACTIVE))throw new Error('A GL boundary cannot interrupt active transform feedback');
    s.enables={};for(const key of ['BLEND','CULL_FACE','DEPTH_TEST','DITHER','POLYGON_OFFSET_FILL','SAMPLE_ALPHA_TO_COVERAGE','SAMPLE_COVERAGE','SCISSOR_TEST','RASTERIZER_DISCARD','STENCIL_TEST'])s.enables[key]=g.isEnabled(g[key]);
    s.buffers={};for(const [target,binding] of [['ARRAY_BUFFER','ARRAY_BUFFER_BINDING'],['ELEMENT_ARRAY_BUFFER','ELEMENT_ARRAY_BUFFER_BINDING'],['COPY_READ_BUFFER','COPY_READ_BUFFER_BINDING'],['COPY_WRITE_BUFFER','COPY_WRITE_BUFFER_BINDING'],['PIXEL_PACK_BUFFER','PIXEL_PACK_BUFFER_BINDING'],['PIXEL_UNPACK_BUFFER','PIXEL_UNPACK_BUFFER_BINDING'],['UNIFORM_BUFFER','UNIFORM_BUFFER_BINDING'],['TRANSFORM_FEEDBACK_BUFFER','TRANSFORM_FEEDBACK_BUFFER_BINDING']])s.buffers[target]=q(g[binding]);
    s.pixelStore={};for(const key of ['PACK_ALIGNMENT','PACK_ROW_LENGTH','PACK_SKIP_PIXELS','PACK_SKIP_ROWS','UNPACK_ALIGNMENT','UNPACK_ROW_LENGTH','UNPACK_IMAGE_HEIGHT','UNPACK_SKIP_PIXELS','UNPACK_SKIP_ROWS','UNPACK_SKIP_IMAGES','UNPACK_FLIP_Y_WEBGL','UNPACK_PREMULTIPLY_ALPHA_WEBGL','UNPACK_COLORSPACE_CONVERSION_WEBGL'])s.pixelStore[key]=q(g[key]);
    s.textures=[];
    for(let i=0;i<q(g.MAX_COMBINED_TEXTURE_IMAGE_UNITS);i++) {
      g.activeTexture(g.TEXTURE0+i);s.textures.push([q(g.TEXTURE_BINDING_2D),q(g.TEXTURE_BINDING_CUBE_MAP),q(g.TEXTURE_BINDING_3D),q(g.TEXTURE_BINDING_2D_ARRAY),q(g.SAMPLER_BINDING)]);
    }
    g.activeTexture(s.ACTIVE_TEXTURE);
    s.indexed={};for(const [target,binding,start,size,max] of [['UNIFORM_BUFFER','UNIFORM_BUFFER_BINDING','UNIFORM_BUFFER_START','UNIFORM_BUFFER_SIZE','MAX_UNIFORM_BUFFER_BINDINGS'],['TRANSFORM_FEEDBACK_BUFFER','TRANSFORM_FEEDBACK_BUFFER_BINDING','TRANSFORM_FEEDBACK_BUFFER_START','TRANSFORM_FEEDBACK_BUFFER_SIZE','MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS']]) {
      s.indexed[target]=[];for(let i=0;i<q(g[max]);i++)s.indexed[target].push([g.getIndexedParameter(g[binding],i),g.getIndexedParameter(g[start],i),g.getIndexedParameter(g[size],i)]);
    }
    s.drawBuffers=Array.from({length:s.DRAW_FRAMEBUFFER_BINDING?q(g.MAX_DRAW_BUFFERS):1},(_,i)=>q(g.DRAW_BUFFER0+i));return s;
  }
  restore(s) {
    const g=this.gl;
    // Context loss can happen between enter() and leave(). Do not spread null
    // vectors or issue additional WebGL commands while the host transitions to
    // its faulted/restart-required state.
    if(!s||g.isContextLost())return false;
    // Native engine teardown can delete objects still referenced by a saved
    // state (including a currently bound, deletion-pending shader program).
    // A later scope must restore null instead of rebinding invalid GL objects.
    const live=(object,kind)=>object && g['is'+kind](object)?object:null;
    s.CURRENT_PROGRAM=live(s.CURRENT_PROGRAM,'Program');
    if(s.CURRENT_PROGRAM && g.getProgramParameter(s.CURRENT_PROGRAM,g.DELETE_STATUS))s.CURRENT_PROGRAM=null;
    const shadow=s.emscripten.currentProgram;
    if(shadow?.value && (!g.isProgram(shadow.value) || g.getProgramParameter(shadow.value,g.DELETE_STATUS)))shadow.value=null;
    const previousDraw=s.DRAW_FRAMEBUFFER_BINDING,previousRead=s.READ_FRAMEBUFFER_BINDING;
    for(const [key,kind] of [['VERTEX_ARRAY_BINDING','VertexArray'],['TRANSFORM_FEEDBACK_BINDING','TransformFeedback'],['DRAW_FRAMEBUFFER_BINDING','Framebuffer'],['READ_FRAMEBUFFER_BINDING','Framebuffer'],['RENDERBUFFER_BINDING','Renderbuffer']])s[key]=live(s[key],kind);
    for(const key of Object.keys(s.buffers))s.buffers[key]=live(s.buffers[key],'Buffer');
    for(const bindings of Object.values(s.indexed))for(const binding of bindings)binding[0]=live(binding[0],'Buffer');
    for(const unit of s.textures)for(let i=0;i<5;i++)unit[i]=live(unit[i],i===4?'Sampler':'Texture');
    if(previousDraw && !s.DRAW_FRAMEBUFFER_BINDING)s.drawBuffers=[g.BACK];
    if(previousRead && !s.READ_FRAMEBUFFER_BINDING)s.READ_BUFFER=g.BACK;
    g.useProgram(s.CURRENT_PROGRAM);g.bindVertexArray(s.VERTEX_ARRAY_BINDING);g.bindTransformFeedback(g.TRANSFORM_FEEDBACK,s.TRANSFORM_FEEDBACK_BINDING);
    g.bindFramebuffer(g.DRAW_FRAMEBUFFER,s.DRAW_FRAMEBUFFER_BINDING);g.bindFramebuffer(g.READ_FRAMEBUFFER,s.READ_FRAMEBUFFER_BINDING);g.bindRenderbuffer(g.RENDERBUFFER,s.RENDERBUFFER_BINDING);
    g.drawBuffers(s.drawBuffers);g.readBuffer(s.READ_BUFFER);
    for(const [target,bindings] of Object.entries(s.indexed))bindings.forEach(([buffer,start,size],i)=>{if(buffer&&size)g.bindBufferRange(g[target],i,buffer,start,size);else g.bindBufferBase(g[target],i,buffer);});
    for(const [key,value] of Object.entries(s.buffers))g.bindBuffer(g[key],value);
    s.textures.forEach((t,i)=>{g.activeTexture(g.TEXTURE0+i);[g.TEXTURE_2D,g.TEXTURE_CUBE_MAP,g.TEXTURE_3D,g.TEXTURE_2D_ARRAY].forEach((target,j)=>g.bindTexture(target,t[j]));g.bindSampler(i,t[4]);});g.activeTexture(s.ACTIVE_TEXTURE);
    for(const [key,value] of Object.entries(s.enables))value?g.enable(g[key]):g.disable(g[key]);
    g.viewport(...s.VIEWPORT);g.scissor(...s.SCISSOR_BOX);g.colorMask(...s.COLOR_WRITEMASK);g.clearColor(...s.COLOR_CLEAR_VALUE);g.clearDepth(s.DEPTH_CLEAR_VALUE);g.clearStencil(s.STENCIL_CLEAR_VALUE);
    g.depthMask(s.DEPTH_WRITEMASK);g.depthFunc(s.DEPTH_FUNC);g.depthRange(...s.DEPTH_RANGE);g.cullFace(s.CULL_FACE_MODE);g.frontFace(s.FRONT_FACE);
    g.blendColor(...s.BLEND_COLOR);g.blendEquationSeparate(s.BLEND_EQUATION_RGB,s.BLEND_EQUATION_ALPHA);g.blendFuncSeparate(s.BLEND_SRC_RGB,s.BLEND_DST_RGB,s.BLEND_SRC_ALPHA,s.BLEND_DST_ALPHA);
    for(const [face,prefix] of [[g.FRONT,'STENCIL_'],[g.BACK,'STENCIL_BACK_']]) {g.stencilFuncSeparate(face,s[prefix+'FUNC'],s[prefix+'REF'],s[prefix+'VALUE_MASK']);g.stencilMaskSeparate(face,s[prefix+'WRITEMASK']);g.stencilOpSeparate(face,s[prefix+'FAIL'],s[prefix+'PASS_DEPTH_FAIL'],s[prefix+'PASS_DEPTH_PASS']);}
    g.lineWidth(s.LINE_WIDTH);g.polygonOffset(s.POLYGON_OFFSET_FACTOR,s.POLYGON_OFFSET_UNITS);g.sampleCoverage(s.SAMPLE_COVERAGE_VALUE,s.SAMPLE_COVERAGE_INVERT);
    for(const [key,value] of Object.entries(s.pixelStore))g.pixelStorei(g[key],value);
    for(const [key,{present,value}] of Object.entries(s.emscripten)) {
      if(present)g[key]=value;else delete g[key];
    }
    return true;
  }
  enter(owner) {
    const previous={owner:this.owner,state:this.capture()};
    if(!previous.state)return null;
    if(this.states.has(owner))this.restore(this.states.get(owner));
    if(this.gl.isContextLost())return null;
    this.activate(owner);return previous;
  }
  leave(previous) {
    if(!previous)return false;
    const current=this.capture();
    if(!current){this.owner=previous.owner;return false;}
    this.states.set(this.owner,current);this.restore(previous.state);this.activate(previous.owner);return true;
  }
  scope(owner,callback) {const previous=this.enter(owner);if(!previous)throw new Error('Shared WebGL context is lost');try{return callback();}finally{this.leave(previous);}}
}
export function sameGLState(a,b,path='state') {
  if(Object.is(a,b))return;
  if(a&&b&&(Array.isArray(a)||ArrayBuffer.isView(a))) {if(a.length!==b.length)throw new Error(path+' length');a.forEach((value,i)=>sameGLState(value,b[i],path+'['+i+']'));return;}
  if(a&&b&&Object.getPrototypeOf(a)===Object.prototype&&Object.getPrototypeOf(b)===Object.prototype) {for(const key of Object.keys(a))sameGLState(a[key],b[key],path+'.'+key);return;}
  throw new Error(path+' changed');
}
