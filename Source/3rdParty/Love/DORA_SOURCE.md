# LOVE Source

This vendored source is pinned to the official LOVE 11.5 release.

- Upstream: `https://github.com/love2d/love.git`
- Tag: `11.5`
- Annotated tag object: `f834ab72481e95fa90abf573643c8dd168ae0660`
- Peeled commit: `6eb8d546736d5915a8b5af30b2cf33456dfdcb1a`
- Imported: 2026-08-02
- Imported content: a reproducible curated subset of the pinned upstream tree

The canonical reproducible Dora delta is
`Source/Love/Patches/dora-love-11.5-consolidated.patch.gz`. The numbered
patches remain fine-grained review records and may overlap when a later module
slice refreshes a shared wrapper file. Run
`Tools/build-scripts/verify_love_upstream_replay.sh <love-11.5-checkout>` to
apply the canonical delta and compare the complete curated source set.

Dora-owned adapters live in `Source/Love/`. The retained subset consists of:

- LOVE's Object/Proxy common runtime, built as `liblove` by xmake;
- backend-independent Data, Stream, hash, LZ4, noise, keyboard-table, thread,
  filesystem and Theora stream sources actually reused by Dora;
- the exact Love 11.5 Lua wrapper `.cpp` files read by the API parity audit;
- the unchanged `MathModule`, `RandomGenerator`, `Transform`, and `BezierCurve`
  implementations, common math types, wrapper headers/Lua helpers and compiled
  wrappers, which form the first complete upstream-wrapper module closure;
- the unchanged Data base, `DataModule`, ByteData, DataView, CompressedData,
  compressor, hash, Base64 and LZ4 implementations plus object wrappers. Only
  the module wrapper is patched for state-local lookup and Lua 5.5 pack calls.
- the unchanged upstream File/FileData interfaces, implementations and Lua
  wrappers. Dora implements the abstract File contract over its injected
  Content backend; the PhysFS backend remains intentionally omitted.
- the upstream Sound module, Decoder base/wrapper, SoundData object/wrapper and
  their headers. `DoraLoveSound` is the concrete state-local module and the
  existing Content/SoLoud decoder supplies PCM bytes; public construction,
  object lifetime and Lua methods come from Love 11.5. Small patches cover the
  state-local factory, Lua 5.5 numeric behavior and allocation/seek guards.
- the unchanged upstream pixel-format table, utf8cpp headers, GlyphData object
  and wrapper. Dora rasterizers fill the upstream GlyphData allocation while
  font generation remains on the existing Content/stb/BMFont backend.
- the unchanged upstream Rasterizer base and wrapper. Dora's Image, stb
  TrueType, and BMFont implementation is a concrete Rasterizer subclass, so
  the original wrapper dispatches directly through upstream virtual methods.
- the upstream ImageData object, pixel conversion/paste implementation, Data
  inheritance, wrapper and Lua `mapPixel` helper. `DoraImageData` only overrides
  PNG/TGA encoding so decode/encode and writes remain on the owning state's
  injected image and Content backends; all public object methods come from
  Love 11.5.
- the upstream CompressedImageData object, mip/slice storage, Data inheritance
  and wrapper. `DoraCompressedImageData` only converts the state-local Dora
  compressed parser result into upstream `CompressedMemory`/`CompressedSlice`
  storage; clone, queries and Data methods use Love 11.5.
- the upstream Image module and wrapper. `DoraLoveImage` is the state-local
  concrete factory and delegates decode, encode and compressed-image parsing to
  the owning LoveRuntime's Content/image backend. The generic upstream cube-face
  and volume-layer algorithms remain available, while native magpie format
  handlers and process-global module lookup remain omitted.
- the upstream Font interface and wrapper plus the unchanged stb-backed
  `TrueTypeRasterizer`. `DoraLoveFont` is the state-local factory: it preserves
  Dora Content, default-font, ImageData and BMFont page loading while the Love
  11.5 wrapper owns overload parsing, object registration and Lua-visible
  behavior.
- the unchanged upstream graphics Quad object and wrapper. Dora's current
  Graphics factory supplies texture dimensions from its own Image/Canvas
  handles, while viewport, layer, vertex data, lifetime and Lua methods use
  Love 11.5 directly.
- the unchanged upstream Drawable base and Type. Every Dora Image, Canvas,
  Mesh, SpriteBatch, ParticleSystem, Text and Video object now derives from the
  real C++ Drawable base instead of only advertising a parallel Lua Type; draw
  submission still enters the owning state-local Dora graphics adapter.
- the upstream Graphics Resource, depth/stencil constants, Texture/Image
  objects and original Texture/Image wrappers. Dora's Image handle wrapper is
  a concrete upstream `graphics::Image`; public Texture/Image overload parsing
  and methods come from Love 11.5, while allocation, pixel replacement and
  lifetime remain delegated to the owning LoveRuntime graphics backend.
- the upstream Graphics Canvas object and wrapper header. Dora's Canvas handle
  wrapper is a concrete upstream `graphics::Canvas`, preserving the original
  `Canvas -> Texture -> Drawable` object and Type chain. RenderTarget creation,
  capability checks, active-target safety, readback and mipmap generation stay
  in the owning state-local Dora graphics backend; the original Canvas wrapper
  implementation is retained for the next wrapper-dispatch slice.
- the original Graphics `draw` and `drawLayer` wrapper bodies, split into a
  dependency-light compilation unit. Their Drawable/Texture/Quad overload and
  standard Transform parsing remains Love 11.5 code; only final submission is
  routed through the current Lua state's Graphics command adapter.
- the upstream Graphics Mesh, SpriteBatch and ParticleSystem Types, public
  object contracts and original Lua wrappers. Dora supplies concrete per-state CPU storage, strong
  resource references, render-buffer construction and draw submission; the
  wrappers retain overload parsing, color quantization, object registration and
  Lua-visible errors. Particle simulation also remains instance-local rather
  than using Love's process-global renderer/random path. Their constructors and draw commands resolve only the
  owning Lua state's Graphics adapter.
- the upstream Graphics Font and Text Types, public object contracts and
  original Lua wrappers. Dora's Font handle implements metrics, filtering and
  fallback references; Dora's Text object keeps the existing layout/run cache.
  Construction and draw commands resolve the owning state-local Graphics
  adapter, and the original wrappers own colored-text, alignment, Transform
  and object method parsing.
- the upstream Graphics Video and VideoStream Types and original Lua wrappers.
  Dora's concrete objects retain Content-backed Theora state, RGBA texture and
  SoLoud Source references; the original wrappers own playback, synchronization,
  filter, `audio` and `dpiscale` semantics. Final Video construction resolves
  only the owning Lua state's Graphics adapter.

LOVE's main loop, platform projects, SDL backends, renderer, audio mixer,
filesystem backend, bundled Lua, Box2D, and every unused bundled library are
intentionally omitted. The companion
`Dora-Example/Test/Love/UpstreamSourceSubsetAudit.mjs` locks the retained file
set and prevents an accidental full-tree import.

Upstream files should remain unchanged whenever possible. Required upstream
changes must be recorded as small, auditable patches in `Source/Love/Patches/`
and documented here. To refresh the subset, check out the peeled commit in a
temporary directory, copy it into this directory, then run
`DORA_SSR_ROOT=/path/to/Dora-SSR node /path/to/Dora-Example/Test/Love/UpstreamSourceSubsetAudit.mjs --prune`.
The command refuses an incomplete or unexpected import and
removes only files outside the manifest. Rerun it without `--prune`, followed
by the API parity, runtime, sanitizer, and platform build audits.

The complete upstream licensing notice is retained in `license.txt`.

## Dora patches

- `Source/Love/Patches/0001-state-local-module-context.patch` adds lookup by
  module type or name to each Lua state's existing `love._modules` registry and
  stops `luax_register_module` from registering process-global module
  singletons. This is required for multiple isolated LoveNode Lua states.
- `Source/Love/Patches/0002-state-local-math-wrapper.patch` makes the upstream
  math wrapper use that state-local lookup. Its deprecated `compress` and
  `decompress` aliases use the compiled upstream data implementation.
- `Source/Love/Patches/0003-initialize-transform-matrix-layout.patch` fixes an
  uninitialized enum read in Love 11.5's invalid-layout error path, as detected
  by Dora's UBSan test.
- `Source/Love/Patches/0004-state-local-data-lua55-pack.patch` makes the data
  wrapper state-local and uses Lua 5.5's standard string pack functions. This
  preserves the public Love API without importing a second Lua implementation;
  diagnostic-only enum variables are initialized for UBSan-safe invalid input.
- `Source/Love/Patches/0005-empty-lz4-ubsan.patch` validates empty LZ4 data and
  uses the size-bounded decoder instead of Love 11.5's legacy fast path, which
  performs invalid prefix-pointer arithmetic detected by Dora's UBSan tests.
- `Source/Love/Patches/0006-state-local-content-filesystem-wrapper.patch`
  creates the wrapper module from the owning state's Dora Content adapter and
  removes PhysFS, DroppedFile, SDL dynamic-library loading, and global module
  lookup from the embedded path.
- `Source/Love/Patches/0007-disable-native-filesystem-fallback.patch` disables
  host filesystem and executable-path fallbacks in the upstream base class;
  `DoraLoveFilesystem` supplies the supported behavior through Content.
- `Source/Love/Patches/0008-sounddata-size-overflow.patch` performs the
  SoundData allocation-size overflow check with exact integer arithmetic before
  multiplication instead of Love 11.5's imprecise post-multiplication double,
  and retains Dora's 256 MiB decoded-data ceiling.
- `Source/Love/Patches/0009-state-local-sound-lua55.patch` creates the Sound
  module from the owning state's Dora/SoLoud adapter, makes Decoder resolve that
  state-local module, preserves Love 11.5/LuaJIT numeric truncation on Lua 5.5,
  and rejects non-finite seek offsets.
- `Source/Love/Patches/0010-dora-imagedata-backend.patch` makes ImageData
  encoding virtual and disables native process-global codec lookup so the Dora
  subclass can use its state-local decoder/encoder and Content policy. It also
  adds Lua 5.5 integer-range guards, makes integer pixel conversion NaN-safe,
  makes overlapping self-paste defined, initializes the invalid-format
  diagnostic enum, and fixes the upstream table-color stack index.
- `Source/Love/Patches/0011-state-local-font-wrapper.patch` makes the Font
  factory an explicit backend interface, creates the module from the owning
  state's `DoraLoveFont`, and removes FreeType, embedded Vera and native image
  factories from the embedded path. It also preserves Love/LuaJIT numeric
  truncation under Lua 5.5, validates narrowing and Unicode ranges, and fixes
  the upstream BMFont page-table conversion to inspect the requested element.
- `Source/Love/Patches/0012-dora-compressed-image-data-backend.patch` adds a
  protected empty construction path so an embedded parser adapter can populate
  upstream compressed memory and mip slices without importing Love's native
  DDS/KTX/PVR format-handler factories.
- `Source/Love/Patches/0013-state-local-image-wrapper.patch` turns the Image
  module's decode and compressed-data factories into the Dora backend boundary,
  removes native magpie handler construction, and creates one `DoraLoveImage`
  per Lua state instead of consulting the process-global module singleton.
- `Source/Love/Patches/0014-dora-graphics-texture-image-backend.patch` removes
  Graphics-singleton and native stream-renderer dependencies from Texture and
  Image, exposes the backend-dependent operations as virtual boundaries, and
  stores DPI scale explicitly. The original object model and Lua wrappers stay
  in use; Dora supplies handle validation, upload and draw submission.
- `Source/Love/Patches/0015-lua55-proxy-uservalues.patch` makes the common
  Object proxy allocation honor Dora's configured Lua 5.5 uservalue count;
  upstream-compatible builds still default to one slot.
- `Source/Love/Patches/0016-shared-standard-transform-parser.patch` copies Love
  11.5's unchanged standard draw-transform parser into a dependency-light
  header. The embedded Graphics dispatch reuses its `Transform` and numeric
  overload semantics without linking Love's native renderer or window path.
- `Source/Love/Patches/0017-state-local-canvas-object.patch` removes Canvas'
  process-global native Graphics queries and defers capability, active-target
  and backend dimension checks to Dora's per-state graphics adapter. The
  original Canvas settings validation and Texture inheritance remain intact.
- `Source/Love/Patches/0018-state-local-graphics-draw-wrapper.patch` extracts
  the original `w_draw/w_drawLayer` bodies from the native Graphics wrapper so
  they can compile without the renderer/window closure. The bodies resolve a
  state-local Graphics command interface instead of `Graphics::instance()`;
  overload selection and Transform parsing are unchanged.
- `Source/Love/Patches/0019-state-local-canvas-wrapper.patch` removes the
  native Graphics singleton from `Canvas:renderTo`, resolves the owning
  state's Canvas command adapter, and preserves the original Canvas/Texture
  wrapper method tables. Dora's Canvas subclass remains responsible for
  RenderTarget switching, readback and mipmap backend work.
- `Source/Love/Patches/0020-state-local-graphics-transform-state-wrapper.patch`
  splits the original transform-stack wrappers away from native Graphics and
  resolves a state-local command interface. Dora stores the actual stack and
  affine transform while the wrapper owns Lua overloads, defaults and errors.
- `Source/Love/Patches/0021-state-local-graphics-display-state-wrapper.patch`
  splits color/background-color, line and point state parsing away from native
  Graphics. The original Lua overload and enum behavior is retained while the
  state-local Dora adapter owns the stored values.
- `Source/Love/Patches/0022-state-local-graphics-mask-wireframe-wrapper.patch`
  migrates the original ColorMask and wireframe wrappers to the same
  state-local adapter and leaves backend application in Dora.
- `Source/Love/Patches/0023-state-local-graphics-scissor-wrapper.patch`
  migrates scissor parsing and intersection to the state-local display adapter.
- `Source/Love/Patches/0024-state-local-graphics-default-filter-wrapper.patch`
  migrates default texture and mipmap filter parsing while keeping Dora's
  backend-specific filter representation in the state-local adapter.
- `Source/Love/Patches/0025-state-local-graphics-blend-wrapper.patch`
  migrates blend parsing to the state-local adapter without importing native
  Love renderer state.
- `Source/Love/Patches/0026-state-local-graphics-depth-cull-wrapper.patch`
  migrates depth, cull and front-face winding wrappers to the state-local
  display adapter.
- `Source/Love/Patches/0027-state-local-graphics-stencil-test-wrapper.patch`
  migrates stencil-test state and query parsing to the same adapter.
- `Source/Love/Patches/0028-state-local-graphics-stencil-wrapper.patch`
  migrates stencil callback/action/clear parsing to the state-local adapter and
  guarantees backend stencil-write cleanup when the callback raises an error.
- `Source/Love/Patches/0029-state-local-graphics-canvas-target-wrapper.patch`
  migrates the original Canvas target switching/query wrappers to the
  state-local adapter while Dora retains render-target validation and backend
  ownership.
- `Source/Love/Patches/0030-state-local-graphics-clear-discard-wrapper.patch`
  migrates original clear/discard overload parsing to the state-local Canvas
  command adapter while Dora retains clear submission and pass ownership.
- `Source/Love/Patches/0031-state-local-graphics-reset-pass-wrappers.patch`
  migrates the original reset, present and flushBatch entry points to the
  state-local Graphics command adapter. Dora remains the sole frame, pass,
  swapchain and window owner.
- `Source/Love/Patches/0032-dora-mesh-object-backend.patch` keeps Love's Mesh
  Type and public object contract but makes storage and drawing backend-owned;
  Dora supplies per-state CPU data, references, render buffers and submission.
- `Source/Love/Patches/0033-mesh-wrapper-enum-ubsan.patch` initializes two
  diagnostic-only Mesh enums so invalid input remains defined under UBSan.
- `Source/Love/Patches/0034-state-local-mesh-constructor-wrapper.patch`
  preserves Love 11.5's `newMesh` overload and vertex parsing while routing
  standard, custom and Data-backed construction to the owning Lua state's Dora
  Graphics adapter.
- `Source/Love/Patches/0035-dora-spritebatch-object-wrapper.patch` keeps the
  upstream SpriteBatch Type, Drawable inheritance, public methods and Lua
  wrapper while exposing backend-owned storage and draw operations implemented
  by Dora's per-state SpriteBatch object.
- `Source/Love/Patches/0036-state-local-spritebatch-constructor-wrapper.patch`
  preserves Love 11.5's `newSpriteBatch` overload parsing while routing object
  creation to the owning Lua state's Dora Graphics adapter.
- `Source/Love/Patches/0037-dora-particlesystem-object-wrapper.patch` keeps
  the ParticleSystem Type, Drawable/public method contract and original Lua
  wrapper while making simulation storage, construction and drawing explicit
  per-state Dora backend boundaries. The wrapper retains the previously
  supported `isEmpty` and `isFull` compatibility queries.
- `Source/Love/Patches/0038-dora-font-object-wrapper.patch` keeps the Graphics
  Font Type, alignment constants and original object wrapper while making font
  metrics, fallback lists and filtering a per-state Dora backend contract.
- `Source/Love/Patches/0039-dora-text-object-wrapper.patch` keeps the Text
  Type, Drawable/public method contract and original Lua wrapper while making
  layout storage, construction and draw submission explicit state-local Dora
  backend boundaries.
- `Source/Love/Patches/0040-dora-shader-object-wrapper.patch` keeps the Shader
  Type, uniform metadata contract and original object wrapper while making
  compilation, reflection, sampler ownership and uniform submission explicit
  per-state Dora backend boundaries. The embedded path does not import Love's
  OpenGL ShaderStage or process-global current/default Shader state.
- `Source/Love/Patches/0041-dora-audio-source-object-wrapper.patch` keeps the
  Source Type, object contract and original method wrapper while routing
  playback, queueing, spatial state, filters and effects through the owning
  Dora AudioBackend. It adds a proxy-index hook for clone identity and retains
  finite/range checks required by the Lua 5.5 embedded path.
- `Source/Love/Patches/0042-dora-video-object-wrapper.patch` keeps the Video and
  VideoStream Types and original object wrappers while replacing native GL
  resource ownership with a state-local Dora Graphics Video factory. The
  original `newVideo` Lua constructor still controls `audio` and `dpiscale`
  semantics; Dora continues to own Content input, Theora frame upload and
  SoLoud-backed Source synchronization.
- the upstream Variant, Threadable, Channel, LuaThread and ThreadModule public
  object contracts and original Channel/Thread/module wrappers. Dora concrete
  objects retain the existing Lua 5.5 worker, Content request pump,
  runtime-scoped queues, cancellation and join implementation; Video alone
  continues to use Love's native platform thread primitive.
- Love's `captureScreenshot(function|string|Channel)` overload and encoded
  format parser in a renderer-independent wrapper. Dora owns the deferred
  framebuffer readback and creates the final upstream ImageData before callback,
  Channel transfer, or PNG/TGA encoding through Content.
- the upstream System and Timer Lua wrappers over state-local abstract module
  contracts. Dora supplies clipboard, URL, vibration, power/background-music
  and steady-clock/frame timing operations without importing SDL platform
  modules or Love's process-global module singletons.
- the upstream Event Message object, wrapper and Lua poll iterator. Dora maps
  them onto each LoveRuntime's private FIFO and host event pump; no SDL event
  queue or process-global Event singleton is imported.
- the upstream Window constants, settings and complete module wrapper over a
  state-local virtual-window implementation. No native SDL window, GL context,
  swapchain or process-global Window singleton is imported.
- the upstream Keyboard key/scancode tables and complete module wrapper over
  LoveRuntime's pressed-state and Dora's IME/layout backend; no SDL Keyboard
  singleton is imported.
- the upstream Mouse/Cursor object model and complete module wrapper over
  LoveRuntime's pointer state and Dora's host cursor backend; no SDL Mouse
  singleton is imported.
- the upstream Touch interface and complete module wrapper over LoveRuntime's
  active touch set; no SDL Touch singleton or global touch list is imported.
- the upstream Joystick object/constants and complete module wrapper over each
  LoveRuntime's Dora controller state; no SDL Joystick singleton is imported.
- the backend-neutral upstream Physics Body/Shape/Joint Type and enum sources;
  no Box2D backend source or header is imported.
- `Source/Love/Patches/0043-state-local-graphics-info-wrapper.patch` preserves
  the original surface/status query entry points in a dependency-light unit
  and replaces the native Graphics singleton with the owning Lua state's Dora
  Graphics info command.
- `Source/Love/Patches/0044-state-local-graphics-capabilities-wrapper.patch`
  preserves Love's optional output-table semantics for capability, format,
  renderer, limit and statistics queries while sourcing values from the owning
  Lua state's Dora Graphics capabilities command.
- `Source/Love/Patches/0045-state-local-graphics-primitives-wrapper.patch`
  preserves the original primitive overloads and table forms in a dependency-
  light wrapper while routing parsed geometry to the owning Lua state's Dora
  Graphics primitives command.
- `Source/Love/Patches/0046-state-local-draw-instanced-wrapper.patch` adds the
  original Mesh/count/standard-transform `drawInstanced` entry to the split
  draw wrapper and removes the last Dora-side public draw parser.
- `Source/Love/Patches/0047-state-local-graphics-quad-constructor.patch`
  preserves Love's Texture/layer/numeric-dimension `newQuad` overloads in a
  state-local, renderer-independent constructor wrapper.
- `Source/Love/Patches/0048-state-local-canvas-formats-wrapper.patch` keeps
  `getCanvasFormats` readable/output-table parsing in the state-local
  capabilities wrapper and leaves only format support queries in Dora.
- `Source/Love/Patches/0049-state-local-canvas-constructor-wrapper.patch`
  preserves Love's Canvas dimensions/layers/settings parser and leaves
  RenderTarget validation and creation in the state-local Dora backend.
- `Source/Love/Patches/0050-state-local-shader-state-wrapper.patch` preserves
  Love's nil/Shader selection wrappers and routes them through the current
  state's Dora Shader backend without parallel Lua registry ownership.
- `Source/Love/Patches/0051-state-local-font-state-wrapper.patch` preserves
  Love's Font selection/default lookup wrappers over the current state's Dora
  font handles and upstream StrongRef ownership.
- `Source/Love/Patches/0052-state-local-graphics-print-wrapper.patch`
  preserves Love's `print/printf` overload parsing and colored-text contract;
  the state-local Dora adapter performs resolved layout and backend submission.
- `Source/Love/Patches/0053-state-local-shader-constructor-wrapper.patch`
  preserves Shader source/FileData/path overload parsing and validation return
  semantics while resolving Filesystem and Graphics through the owning state.
- `Source/Love/Patches/0054-state-local-font-constructor-wrapper.patch`
  preserves Rasterizer conversion for TrueType, ImageFont and BMFont creation;
  Dora owns in-memory font upload, cache-backed defaults and final handles.
- `Source/Love/Patches/0055-state-local-image-constructor-wrapper.patch`
  preserves ImageData/CompressedImageData/Content conversion, settings, DPI,
  mipmap, array, cube and volume parsing; Dora owns the final texture upload
  and handle lifetime for the current Lua State.
- `Source/Love/Patches/0056-state-local-thread-wrapper.patch` preserves the
  public Thread/Channel object model and original wrappers but makes their
  factories abstract and state-local. Dora supplies Lua 5.5 worker states,
  cross-state value snapshots, Content pumping, cancellation and join.
- `Source/Love/Patches/0057-state-local-screenshot-wrapper.patch` preserves
  Love's function/string/Channel overload and PNG/TGA format parsing while
  routing the parsed request to the current state's Dora Graphics adapter.
- `Source/Love/Patches/0058-state-local-system-timer-wrappers.patch` restores
  the System/Timer wrapper surface over state-local Dora service and clock
  contracts, without importing their native SDL implementations.
- `Source/Love/Patches/0059-state-local-event-wrapper.patch` restores Message,
  the Event wrapper and Lua poll iterator over LoveRuntime's private FIFO and
  host pump instead of the native SDL event queue.
- `Source/Love/Patches/0060-state-local-window-wrapper.patch` restores the
  complete Window parser/module surface over Dora's virtual embedded window;
  only state-local lookup, factory creation and catchable backend errors differ.
- `Source/Love/Patches/0061-state-local-keyboard-wrapper.patch` makes the
  Keyboard wrapper factory state-local and routes text-input validation errors
  through the normal Lua exception boundary.
- `Source/Love/Patches/0062-state-local-mouse-cursor-wrapper.patch` makes the
  Mouse factory state-local and keeps cursor construction/selection exceptions
  inside the normal Lua boundary while preserving the original method tables.
- `Source/Love/Patches/0063-state-local-touch-wrapper.patch` makes the Touch
  wrapper factory and lookup state-local while retaining Love's touch-id parser
  and public module table unchanged.
- `Source/Love/Patches/0064-state-local-joystick-wrapper.patch` makes the
  JoystickModule and Filesystem lookup state-local and replaces only the SDL
  factory with Dora's controller adapter.
- `Source/Love/Patches/0065-upstream-physics-base-types.patch` adds the exact
  backend-neutral Physics base Type/enum sources to the curated subset before
  the object wrappers are adapted to PlayRho-backed Dora handles.
- `Source/Love/Patches/0066-upstream-physics-body-wrapper.patch` restores the
  original Body Lua wrapper over a backend-neutral Body/World contract. Dora's
  concrete object delegates to the owning LoveRuntime and PlayRho backend;
  World/Body identity, fixtures, joints, contacts and arbitrary user data use
  Love's Object/Proxy ownership model.
- `Source/Love/Patches/0067-upstream-physics-world-wrapper.patch` restores the
  original World method table and overload flow over Dora's PlayRho world.
  World enumeration, callbacks and origin translation are state-local; the
  incompatible Box2D contact-filter callback stays excluded by design.
- `Source/Love/Patches/0068-upstream-physics-fixture-contact-wrappers.patch`
  restores backend-neutral Fixture and Contact bases and their original Love
  method tables over Dora's PlayRho backend.
- `Source/Love/Patches/0069-upstream-physics-shape-wrapper.patch` restores the
  Shape method table and Circle/Polygon/Edge/Chain operations over a
  backend-neutral contract; Dora implements geometry queries and mutations in
  the owning Runtime's PlayRho backend.
- `Source/Love/Patches/0070-upstream-physics-joint-wrapper.patch` restores the
  common Joint and all eleven subtype method tables over a backend-neutral
  contract; Dora implements constraints, relationships and lifetime in the
  owning Runtime's PlayRho backend.
- `Source/Love/Patches/0071-android-imagedata-cmath.patch` explicitly includes
  `<cmath>` for the existing NaN clamp on Android NDK 21.
