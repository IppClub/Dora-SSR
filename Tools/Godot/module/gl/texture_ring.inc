// Common GPU copy/synchronization algorithm, included by EGL and WGL transports.
// Requires a platform-local Transport, get(), check() and GL entry points.
uint32_t dora_gl_texture(void *p,uint32_t slot) {
    auto *t=get(p); return t && slot<t->buffers?t->slots[slot].texture:0;
}
int dora_gl_can_produce(void *p,uint32_t slot,uint64_t last_read) {
    auto *t=get(p); if (!t || slot>=t->buffers) return 0;
    auto &s=t->slots[slot]; if (!last_read) return 1;
    if (s.read<last_read || !s.consumed) { ++t->deferred; return 0; }
    GLenum result=glClientWaitSync(s.consumed,0,0);
    if (result==GL_WAIT_FAILED) { ++t->errors; error="consumer fence query failed"; return 0; }
    if (result==GL_TIMEOUT_EXPIRED) { ++t->deferred; return 0; }
    return 1;
}
int dora_gl_can_advance(void *p,uint32_t slot,uint64_t last_read) {
    auto *t=get(p); if (!t || slot>=t->buffers) return 0;
    const auto &target=t->slots[slot];
    if (last_read && (target.read<last_read || !target.consumed)) { ++t->deferred; return 0; }
#if !defined(__EMSCRIPTEN__)
    // Completion of the previous copy also covers all preceding Godot draws.
    // Do not enter another Godot iteration while that queue may be waiting on
    // a host consumer. The target read itself will be waited on by the GPU.
    for (const auto &previous:t->slots) if (t->sequence && previous.sequence==t->sequence) {
        const auto result=glClientWaitSync(previous.ready,0,0);
        if (result==GL_WAIT_FAILED) { ++t->errors; error="producer fence query failed"; return 0; }
        if (result==GL_TIMEOUT_EXPIRED) { ++t->deferred; return 0; }
    }
#endif
    // Web uses one verified WebGL2 context/command queue. Every host read was
    // submitted before the next producer call, so queue order already prevents
    // overwrite. There is no cross-context GPU wait cycle to break with a CPU
    // completion poll; keep the submitted-reader ledger check above.
    return 1;
}
static uint64_t copy_slot(void *p,uint32_t source,uint32_t slot,uint64_t last_read,bool queued) {
    auto *t=get(p); if (!t || slot>=t->buffers || !source
        || !(queued?dora_gl_can_advance(t,slot,last_read):dora_gl_can_produce(t,slot,last_read))) return 0;
    auto &s=t->slots[slot];
    if (s.consumed) glWaitSync(s.consumed,0,GL_TIMEOUT_IGNORED);
    GLint old_read=0,old_draw=0;
    glGetIntegerv(GL_READ_FRAMEBUFFER_BINDING,&old_read);
    glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING,&old_draw);
    GLboolean scissor=glIsEnabled(GL_SCISSOR_TEST);
    glBindFramebuffer(GL_READ_FRAMEBUFFER,t->source_fbo);
    glFramebufferTexture2D(GL_READ_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,source,0);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,t->target_fbo);
    glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,s.texture,0);
    if (glCheckFramebufferStatus(GL_READ_FRAMEBUFFER)!=GL_FRAMEBUFFER_COMPLETE
        || glCheckFramebufferStatus(GL_DRAW_FRAMEBUFFER)!=GL_FRAMEBUFFER_COMPLETE) {
        glBindFramebuffer(GL_READ_FRAMEBUFFER,old_read);
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER,old_draw);
        ++t->errors; error="incomplete shared texture framebuffer"; return 0;
    }
    glDisable(GL_SCISSOR_TEST);
    glBlitFramebuffer(0,0,t->width,t->height,0,0,t->width,t->height,GL_COLOR_BUFFER_BIT,GL_NEAREST);
    glBindFramebuffer(GL_READ_FRAMEBUFFER,old_read);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,old_draw);
    if (scissor) glEnable(GL_SCISSOR_TEST);
    if (s.ready) glDeleteSync(s.ready);
    s.ready=glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE,0); glFlush();
    if (!s.ready || !check(t)) return 0;
    s.sequence=++t->sequence; return s.sequence;
}
uint64_t dora_gl_copy(void *p,uint32_t source,uint32_t slot,uint64_t last_read) {
    return copy_slot(p,source,slot,last_read,false);
}
uint64_t dora_gl_copy_async(void *p,uint32_t source,uint32_t slot,uint64_t last_read) {
    return copy_slot(p,source,slot,last_read,true);
}
int dora_gl_consumer_begin(void *p,uint32_t slot,uint64_t sequence) {
    auto *t=get(p); if (!t || slot>=t->buffers) return 0;
    auto &s=t->slots[slot];
    if (!s.ready || s.sequence!=sequence) { ++t->errors; error="stale GL producer publication"; return 0; }
    glWaitSync(s.ready,0,GL_TIMEOUT_IGNORED); return check(t);
}
int dora_gl_consumer_end(void *p,uint32_t slot,uint64_t read) {
    auto *t=get(p); if (!t || slot>=t->buffers) return 0;
    auto &s=t->slots[slot]; if (read<=s.read) { ++t->errors; return 0; }
    if (s.consumed) glDeleteSync(s.consumed);
    s.consumed=glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE,0); s.read=read; glFlush();
    return s.consumed && check(t);
}
void dora_gl_drain([[maybe_unused]] void *p) {
    glFinish();
#if defined(__EMSCRIPTEN__)
    // WebGL2 intentionally hides same-task fence completion, even after a
    // synchronous finish. Record the successful queue drain rather than
    // treating a cached TIMEOUT_EXPIRED as an unfinished GPU command.
    // https://registry.khronos.org/webgl/specs/latest/2.0/#3.7.14
    auto *t=get(p);
    if (t && check(t)) t->completed=t->sequence;
#endif
}
uint64_t dora_gl_completed(void *p) {
    auto *t=get(p); if (!t) return 0;
#if defined(__EMSCRIPTEN__)
    if (t->completed==t->sequence) return t->completed;
#endif
    // Queried on the producer context after drain, or for diagnostic snapshots.
    for (uint32_t i=0;i<t->buffers;++i) {
        auto &s=t->slots[i]; if (!s.ready) continue;
        GLenum r=glClientWaitSync(s.ready,0,0);
        if (r==GL_ALREADY_SIGNALED || r==GL_CONDITION_SATISFIED)
            if (s.sequence>t->completed) t->completed=s.sequence;
    }
    return t->completed;
}
uint64_t dora_gl_deferred(void *p) { return get(p)->deferred; }
uint64_t dora_gl_errors(void *p) { return get(p)->errors; }

void dora_gl_clear_targets(void *p) {
    auto *t=get(p); if (!t) return;
    glFinish(); t->completed=t->sequence;
    GLint read=0,draw=0;
    glGetIntegerv(GL_READ_FRAMEBUFFER_BINDING,&read); glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING,&draw);
    glBindFramebuffer(GL_READ_FRAMEBUFFER,t->source_fbo);
    glFramebufferTexture2D(GL_READ_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,0,0);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,t->target_fbo);
    glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,0,0);
    glBindFramebuffer(GL_READ_FRAMEBUFFER,read); glBindFramebuffer(GL_DRAW_FRAMEBUFFER,draw);
    for (auto &s:t->slots) {
        if (s.ready) glDeleteSync(s.ready);
        if (s.consumed) glDeleteSync(s.consumed);
        if (s.texture && s.owned) glDeleteTextures(1,&s.texture);
        s=Slot{};
    }
}
int dora_gl_bind_targets(void *p,uint32_t width,uint32_t height,const uint32_t *textures,uint32_t count) {
    auto *t=get(p);
    if (!t || !textures || !width || !height || width>8192 || height>8192 || count!=t->buffers) return 0;
    if (!check(t)) { error="pre-existing error before target validation: "+error; return 0; }
    GLint binding=0,draw=0; glGetIntegerv(GL_TEXTURE_BINDING_2D,&binding);
    glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING,&draw);
    GLuint validation=0; glGenFramebuffers(1,&validation);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,validation);
    bool valid=validation!=0;
    for (uint32_t i=0;i<count;++i) {
        if (!textures[i] || !glIsTexture(textures[i])) { valid=false; break; }
        for (uint32_t j=0;j<i;++j) if (textures[j]==textures[i]) valid=false;
        // Rebinding a currently owned slot would delete it during replacement.
        for (const auto &s:t->slots) if (s.owned && s.texture==textures[i]) valid=false;
        glBindTexture(GL_TEXTURE_2D,textures[i]);
        // GLES3.0 has no texture-level size query. Dimensions are a host
        // contract; validate a renderable normalized RGBA8 attachment instead.
        glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_TEXTURE_2D,textures[i],0);
        if (glCheckFramebufferStatus(GL_DRAW_FRAMEBUFFER)!=GL_FRAMEBUFFER_COMPLETE) valid=false;
        for (GLenum component:{GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE,GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE,
                              GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE,GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE}) {
            GLint bits=0; glGetFramebufferAttachmentParameteriv(GL_DRAW_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,component,&bits);
            if (bits!=8) valid=false;
        }
        GLint type=0; glGetFramebufferAttachmentParameteriv(GL_DRAW_FRAMEBUFFER,GL_COLOR_ATTACHMENT0,GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE,&type);
        if (type!=GL_UNSIGNED_NORMALIZED) valid=false;
    }
    glBindTexture(GL_TEXTURE_2D,binding);
    glBindFramebuffer(GL_DRAW_FRAMEBUFFER,draw);
    if (validation) glDeleteFramebuffers(1,&validation);
    if (!valid || !check(t)) { error="incompatible host-owned GL target textures"; return 0; }
    dora_gl_clear_targets(t);
    for (uint32_t i=0;i<count;++i) { t->slots[i].texture=textures[i]; t->slots[i].owned=false; }
    t->width=width; t->height=height;
    glFlush(); return check(t);
}
