# LOVE Upstream Patches

Keep this directory empty except for upstream patches that cannot be expressed
as Dora-owned adapters. Each patch must document the LOVE 11.5 source file,
reason, compatibility effect, and the command used to apply or regenerate it.

The numbered files are fine-grained review snapshots. Some later slices refresh
files also present in earlier slices, so they are not the canonical sequential
release series. `dora-love-11.5-consolidated.patch.gz` is the reproducible patch
from upstream tag `11.5` (commit `6eb8d546736d5915a8b5af30b2cf33456dfdcb1a`)
to the current vendored source. Run
`Tools/build-scripts/verify_love_upstream_replay.sh <love-11.5-checkout>` to
apply it to a clean checkout and compare every curated source/build file.

Current patches:

- `0001-state-local-module-context.patch`: makes wrapper module lookup local to
  the active Lua state so multiple LoveNode instances cannot overwrite one
  process-global module singleton.
- `0002-state-local-math-wrapper.patch`: switches `love.math` to the state-local
  module lookup. Its deprecated compression aliases now call the compiled
  upstream `love.data` implementation unchanged.
- `0003-initialize-transform-matrix-layout.patch`: initializes the enum used to
  report an invalid `Transform:setMatrix` layout, preventing an upstream 11.5
  undefined read detected by UBSan while preserving the same Lua error.
- `0004-state-local-data-lua55-pack.patch`: switches `love.data` to state-local
  module lookup and delegates pack/unpack/packsize to the standard Lua 5.5
  string library instead of compiling Love's bundled Lua 5.3 compatibility
  implementation. It also initializes enum values used only to build invalid
  input diagnostics, avoiding the same upstream UBSan issue as Transform.
- `0005-empty-lz4-ubsan.patch`: handles valid empty LZ4 payloads explicitly and
  replaces the legacy unbounded fast decode with the size-bounded decoder,
  avoiding invalid prefix-pointer arithmetic while rejecting size mismatches.
- `0006-state-local-content-filesystem-wrapper.patch`: replaces the PhysFS/SDL
  singleton factory with the state-local Dora filesystem adapter, removes the
  native C loader and DroppedFile dependency, and keeps wrapper error paths
  compatible with the Content-only embedded runtime.
- `0007-disable-native-filesystem-fallback.patch`: removes host `stat`, executable
  path, and platform UTF helpers from the upstream Filesystem base. The Dora
  subclass supplies those queries through its injected Content backend.
- `0008-sounddata-size-overflow.patch`: replaces Love 11.5's imprecise
  post-multiplication floating-point size check with an exact integer check
  before allocation-size multiplication and keeps Dora's 256 MiB decoded-data
  ceiling.
- `0009-state-local-sound-lua55.patch`: creates `love.sound` through the owning
  Lua state's Dora/SoLoud adapter, uses state-local module lookup from the
  Decoder wrapper, preserves LuaJIT numeric truncation on Lua 5.5, and rejects
  non-finite Decoder seek offsets.
- `0010-dora-imagedata-backend.patch`: makes ImageData encoding overridable,
  disables Love's process-global native codec lookup in the embedded path,
  guards Lua 5.5 integer narrowing and NaN-to-integer pixel conversion, and
  fixes overlapping self-paste, diagnostic enum initialization and the
  upstream table-color stack index so the original wrapper can call the
  state-local Dora image/Content adapter safely.
- `0011-state-local-font-wrapper.patch`: turns the upstream Font construction
  methods into the Dora backend boundary and creates one `DoraLoveFont` per
  Lua state instead of using the process-global FreeType module. It removes
  embedded Vera/native Image/BMFont factories, adds Lua 5.5 narrowing and
  codepoint guards, and fixes `newBMFontRasterizer` table page conversion to
  use the current argument index rather than always reading argument one.
- `0012-dora-compressed-image-data-backend.patch`: adds a protected empty
  constructor to the upstream CompressedImageData object. Dora's state-local
  parser adapter uses it to populate upstream CompressedMemory and mip slices;
  native format-handler factories and filesystem access remain omitted.
- `0013-state-local-image-wrapper.patch`: makes the upstream Image factory a
  state-local Dora backend interface, removes native magpie handler creation,
  and lets the original wrapper register `love.image` without consulting the
  process-global module singleton.
- `0014-dora-graphics-texture-image-backend.patch`: keeps Love's original
  Graphics Texture/Image object model and Lua wrappers while replacing the
  process-global Graphics singleton, native stream drawing, format-capability
  lookup and flush hooks with virtual Dora backend boundaries. It also stores
  DPI scale explicitly so odd-sized `@2x` assets do not lose their scale when
  logical dimensions are rounded.
- `0015-lua55-proxy-uservalues.patch`: creates Love Object proxies with the
  configured number of Lua 5.5 uservalue slots. Dora uses those slots for
  native ownership edges such as Physics parents, Mesh textures and Text
  fonts; the default remains one slot for standalone upstream use.
- `0016-shared-standard-transform-parser.patch`: copies the unchanged Love 11.5
  standard draw-transform overload parser into a dependency-light header.
  Dora's state-local Graphics dispatch can therefore reuse the original
  `Transform`/numeric overload semantics without linking Love's native window,
  present or stream renderer implementation.
- `0017-state-local-canvas-object.patch`: keeps Love's original Canvas object,
  validation and Texture inheritance while removing its process-global native
  Graphics capability/active-target queries. Dora's state-local adapter owns
  those checks, RenderTarget handles, readback and mipmap generation.
- `0018-state-local-graphics-draw-wrapper.patch`: moves Love 11.5's unchanged
  `draw`/`drawLayer` overload parsing into a dependency-light wrapper unit and
  replaces only the final process-global native Graphics call with a
  state-local command interface implemented by Dora's Graphics module.
- `0019-state-local-canvas-wrapper.patch`: compiles the original Canvas and
  inherited Texture method tables, routes only `renderTo` through the current
  state's Graphics Canvas command adapter, and lets the Dora Canvas subclass
  provide backend readback through the original `newImageData` wrapper.
- `0020-state-local-graphics-transform-state-wrapper.patch`: extracts Love
  11.5's transform-stack wrapper bodies into a renderer-independent unit and
  replaces native Graphics singleton calls with the current state's command
  adapter. Parsing for stack types, optional push Transform, numeric defaults,
  Transform objects and point results remains in the upstream wrapper layer.
- `0021-state-local-graphics-display-state-wrapper.patch`: extracts Love
  11.5's color, background color, line and point state wrappers into a
  renderer-independent unit. Table/numeric color overloads and line enums stay
  in the wrapper while the current state's Dora adapter stores display state.
- `0022-state-local-graphics-mask-wireframe-wrapper.patch`: moves ColorMask
  default/boolean parsing and wireframe boolean parsing into the same
  state-local display-state wrapper; Dora applies the resulting values to its
  renderer backend and stores them for stack/reset semantics.
- `0023-state-local-graphics-scissor-wrapper.patch`: preserves Love 11.5's
  integer rectangle parsing, four-nil disable overload, negative-size errors
  and intersection behavior while applying the resulting state through Dora.
- `0024-state-local-graphics-default-filter-wrapper.patch`: preserves default
  filter and mipmap-filter enum/default/return parsing. Dora's adapter reports
  its matching min/mag restriction and validates backend numeric constraints.
- `0025-state-local-graphics-blend-wrapper.patch`: preserves all nine Love
  11.5 blend modes, both alpha modes, defaults and enum diagnostics. Dora's
  adapter owns capability checks and renderer blend-state conversion.
- `0026-state-local-graphics-depth-cull-wrapper.patch`: preserves depth compare,
  boolean write, no-argument reset, cull and winding enum parsing while Dora's
  adapter owns the combined renderer state updates.
- `0027-state-local-graphics-stencil-test-wrapper.patch`: preserves compare/value
  parsing and Love 11.5's `"always", 0` disabled query result while Dora's
  adapter applies the stencil test to its render-command state.
- `0028-state-local-graphics-stencil-wrapper.patch`: preserves Love 11.5's six
  stencil actions, callback and clear-value overloads while routing stencil
  writes through the current state's Dora adapter. The callback uses protected
  Lua invocation so Dora always ends stencil writing before rethrowing errors.
- `0029-state-local-graphics-canvas-target-wrapper.patch`: preserves Love
  11.5's `setCanvas/getCanvas` overloads for MRT, layered/mip targets,
  depth-stencil targets and temporary buffers. Dora validates native handles
  and submits the parsed render-target set through its state-local backend.
- `0030-state-local-graphics-clear-discard-wrapper.patch`: preserves Love
  11.5's broadcast/per-attachment clear overloads, optional stencil/depth
  values and discard parsing. Dora translates clear requests to its renderer;
  discard remains a valid framebuffer-invalidation no-op.
- `0031-state-local-graphics-reset-pass-wrappers.patch`: preserves the original
  reset, present and flushBatch Lua entry points while resolving the current
  state's Dora Graphics command adapter. Dora retains frame/pass and window
  ownership; present is an in-frame compatibility barrier and flushBatch is a
  valid no-op for already ordered Dora render commands.
- `0032-dora-mesh-object-backend.patch`: retains Love's Mesh Type and public
  object contract while replacing native Graphics/Buffer/Shader storage and
  drawing with virtual operations implemented by Dora's per-state Mesh object.
  The unchanged original Mesh Lua wrapper targets this contract.
- `0033-mesh-wrapper-enum-ubsan.patch`: initializes the temporary index and
  primitive enums used by invalid-value diagnostics, avoiding undefined reads
  under UBSan without changing valid Mesh wrapper behavior.
- `0034-state-local-mesh-constructor-wrapper.patch`: extracts Love 11.5's
  original `newMesh` overload, vertex-format, Data, table and enum parsing into
  the compiled Mesh wrapper, routing only construction through the current Lua
  state's Dora Graphics Mesh command adapter.
- `0035-dora-spritebatch-object-wrapper.patch`: retains Love's SpriteBatch
  Type, Drawable inheritance and public object contract while replacing native
  Graphics/Buffer storage and drawing with virtual operations implemented by
  Dora's per-state SpriteBatch object. The original method wrapper targets this
  contract and shares the standard transform parser with Graphics draw.
- `0036-state-local-spritebatch-constructor-wrapper.patch`: preserves Love
  11.5's `newSpriteBatch` Texture, size and usage parsing while routing only
  construction through the current Lua state's Dora Graphics SpriteBatch
  command adapter.
- `0037-dora-particlesystem-object-wrapper.patch`: retains Love's
  ParticleSystem Type, Drawable/public object contract and original method
  wrapper while replacing native Graphics/Buffer storage, process-global
  construction and draw submission with Dora's per-state simulation and
  renderer adapter. It also keeps Dora's existing `isEmpty`/`isFull`
  compatibility methods in the compiled wrapper.
- `0038-dora-font-object-wrapper.patch`: retains Love's Graphics Font Type,
  alignment constants and original 14-method Lua wrapper while replacing the
  native glyph-atlas/renderer object with a public backend contract implemented
  by Dora's per-state font handle. The wrapper catches Dora's line-height
  validation exception so invalid values remain ordinary Lua errors.
- `0039-dora-text-object-wrapper.patch`: retains Love's Text Type, Drawable
  contract and original method wrapper, and moves `newText` construction to the
  current Lua state's Graphics Text command. Dora keeps its existing layout
  cache and draw backend but no longer re-parses Text method or draw transforms.
- `0040-dora-shader-object-wrapper.patch`: retains Love's Shader Type, uniform
  metadata contract and original method wrapper while replacing native OpenGL
  shader stages with Dora's per-state compilation, reflection and submission
  backend. Small wrapper changes preserve Lua 5.5 integer range checks,
  non-gamma-correct color sends and exception-safe Dora backend errors.
- `0041-dora-audio-source-object-wrapper.patch`: retains Love's Source Type,
  public object contract and original method wrapper while delegating playback,
  queue, spatial audio, filters and effects to Dora's state-local AudioBackend.
  A clone proxy hook preserves module-level pause identity; finite/range and
  Lua 5.5 queue-region checks retain the existing embedded compatibility.
- `0042-dora-video-object-wrapper.patch`: retains Love's Video and VideoStream
  Types, original method wrappers and the public `newVideo` Lua constructor.
  Native GL video textures are replaced by a state-local Dora Graphics command
  factory; Content-backed Theora decoding, SoLoud Source synchronization and
  Dora texture upload remain owned by the corresponding LoveRuntime.
- `0043-state-local-graphics-info-wrapper.patch`: extracts Love 11.5's
  width/height, pixel size, DPI, active, created and gamma-correct query entry
  points into a renderer-independent wrapper unit. The wrappers resolve the
  current Lua state's Dora Graphics adapter instead of a native singleton.
- `0044-state-local-graphics-capabilities-wrapper.patch`: extracts the original
  supported-feature, texture/image format, renderer, system-limit and runtime
  statistics table construction into a state-local wrapper unit. Dora supplies
  only capability data through the current Lua state's Graphics adapter.
- `0045-state-local-graphics-primitives-wrapper.patch`: extracts Love's
  points/line/rectangle/circle/ellipse/arc/polygon overload parsing into a
  renderer-independent wrapper. Parsed geometry is submitted through the
  current Lua state's Dora Graphics primitives command.
- `0046-state-local-draw-instanced-wrapper.patch`: restores the original
  `drawInstanced` Mesh/count/standard-transform parser in the split draw
  wrapper so the Dora backend consumes the parsed matrix directly.
- `0047-state-local-graphics-quad-constructor.patch`: extracts the original
  Texture/layer/numeric-dimension `newQuad` overloads and constructs the
  renderer-independent upstream Quad after resolving the current state.
- `0048-state-local-canvas-formats-wrapper.patch`: extends the state-local
  capabilities wrapper with Love's readable flag and optional output-table
  semantics for `getCanvasFormats`.
- `0049-state-local-canvas-constructor-wrapper.patch`: extracts Love's complete
  Canvas settings parser and routes the resulting upstream Settings object to
  the current state's Dora Canvas factory.
- `0050-state-local-shader-state-wrapper.patch`: extracts `setShader/getShader`
  and resolves the selected Shader through the current state's Graphics
  adapter, using Love StrongRef ownership instead of a parallel Lua ref.
- `0051-state-local-font-state-wrapper.patch`: extracts `setFont/getFont` and
  resolves the selected/default Font through the current state's Graphics
  adapter while retaining it through Love's object model.
- `0052-state-local-graphics-print-wrapper.patch`: extracts `print/printf` and
  preserves Love's colored-text, optional Font, Transform/numeric transform,
  wrapping and alignment parsing over the current state's Dora text backend.
- `0053-state-local-shader-constructor-wrapper.patch`: extracts `newShader` and
  `validateShader`, resolves FileData and shader files through state-local Love
  modules, and leaves compilation and Shader object creation in Dora.
- `0054-state-local-font-constructor-wrapper.patch`: extracts `newFont`,
  `newImageFont` and `setNewFont`, retaining Love Rasterizer conversion over a
  state-local Dora Font factory with a cached default-font shortcut.
- `0055-state-local-image-constructor-wrapper.patch`: extracts `newImage`,
  `newArrayImage`, `newCubeImage` and `newVolumeImage`, preserving Love's
  Content/Data conversion, settings, DPI, mipmap and layered-image parsers over
  the current state's Dora Image factory.
- `0056-state-local-thread-wrapper.patch`: retains Love's Threadable, Thread,
  Channel and ThreadModule Types plus all original Lua method wrappers while
  replacing queue, worker-state and module factories with state-local Dora
  adapters. Love's native thread primitive remains available to Video only.
- `0057-state-local-screenshot-wrapper.patch`: extracts Love's original
  function, filename/format and Channel overload parser into a state-local
  Graphics command wrapper. Dora still owns asynchronous frame readback,
  generation cancellation, Content saving and final ImageData construction.
- `0058-state-local-system-timer-wrappers.patch`: restores the original System
  and Timer module wrappers over small state-local backend contracts. Dora
  remains the owner of clipboard, URL, vibration, application power state and
  frame timing; Lua overloads, enums and return-value semantics stay upstream.
- `0059-state-local-event-wrapper.patch`: restores Love's Message/Event object
  layer, module wrapper and Lua `poll` iterator while adapting queue pumping,
  waiting and dispatch to the owning LoveRuntime instead of SDL's global queue.
- `0060-state-local-window-wrapper.patch`: restores Love's complete Window
  settings/parser/module wrapper over a state-local virtual-window backend.
  Dora remains the sole host window, RenderTarget and display owner.
- `0061-state-local-keyboard-wrapper.patch`: switches the original Keyboard
  wrapper and key/scancode tables to a state-local Dora input/IME backend.
- `0062-state-local-mouse-cursor-wrapper.patch`: restores Love's Mouse/Cursor
  object and module wrappers over a state-local Dora pointer/cursor backend.
  Cursor identity and lifetime use the upstream Object/Proxy model while Dora
  remains responsible for node-local coordinates and the host cursor handle.
- `0063-state-local-touch-wrapper.patch`: restores Love's original Touch
  wrapper over each LoveRuntime's active touch set, preserving lightuserdata
  identifiers while Dora remains responsible for touch routing and coordinates.
- `0064-state-local-joystick-wrapper.patch`: restores Love's Joystick object,
  constants and module wrappers over a state-local Dora controller backend.
  Connected-object identity, mappings and vibration state remain per Runtime.
- `0065-upstream-physics-base-types.patch`: restores Love's backend-neutral
  Body, Shape and Joint Type/enum implementations. Dora handle objects inherit
  these bases while PlayRho remains the only compiled physics backend.
- `0066-upstream-physics-body-wrapper.patch`: restores Love's original Body
  object wrapper and extends the backend-neutral Body/World contracts used by
  Dora's PlayRho adapter. Only destroyed-state checks, damping validation and
  backend dispatch differ from the Box2D implementation.
- `0067-upstream-physics-world-wrapper.patch`: restores Love's original World
  wrapper over the state-local PlayRho world adapter. The Box2D-specific
  contact-filter callback is intentionally omitted; Dora's fixture filter and
  contact callback rules remain authoritative.
- `0068-upstream-physics-fixture-contact-wrappers.patch`: restores Love's
  original Fixture and Contact method tables over backend-neutral bases. Dora
  keeps its PlayRho filter implementation and signed 16-bit group index rule.
- `0069-upstream-physics-shape-wrapper.patch`: restores the Shape wrapper
  method table and subtype operations over a backend-neutral Shape contract.
  Dora supplies the state-local PlayRho geometry, ray, AABB, mass and ghost
  vertex operations without importing Love's Box2D backend.
- `0070-upstream-physics-joint-wrapper.patch`: restores the common Joint and
  all eleven subtype method tables over a backend-neutral Joint contract.
  Dora keeps state-local PlayRho constraints, handle ownership, relationships
  and Lua user data while removing the duplicate LoveRuntime parsers.
- `0071-android-imagedata-cmath.patch`: includes `<cmath>` directly for the
  existing NaN clamp because Android NDK 21 does not expose `std::isnan`
  through ImageData's transitive headers.
