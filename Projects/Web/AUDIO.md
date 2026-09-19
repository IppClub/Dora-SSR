# Independent Web audio

The standard `dora-web-player` now initializes a second, small SoLoud WASM
instance inside an AudioWorklet. It owns its memory, sources, decoders, voices,
and mixer. `Audio.play/playStream` send encoded resources and commands through
a MessagePort; no PCM production or scheduled buffer refill runs on the main
thread. There is no SharedArrayBuffer, pthread, COOP or COEP requirement.
HTTPS (or localhost) and AudioWorklet support are required. The packaged player
includes `audio-worklet.js` and `dora-audio-mixer.wasm`; the gallery hashes both
into the player revision and its deployment gate checks their presence.

## Scope and compatibility

- Migrated: `Audio.play`, `stop`, `playStream`, `stopStream`, `stopAll`, global
  volume, pause/resume of current voices, looping and timed fades/stops.
- Encoded WAV, OGG, MP3 and FLAC are decoded using the existing SoLoud decoders;
  browser-native codec support is not required. Streaming sources use WavStream, avoiding
  expansion of whole music tracks to PCM.
- Sound effects retain SoLoud's normal center pan; background music retains
  background routing and voice protection. The mixer uses the AudioContext's
  actual sample rate and adapts browser render quanta to 128-frame mix blocks.
- Pending asynchronous stream loads are invalidated by stream replacement,
  stopStream or stopAll. Pausing the page suspends both audio contexts; stopping
  the player closes the worklet context and releases the host resource cache.
- Initialization failure selects the original SDL backend before the engine
  starts. A host may explicitly select it using `Module.doraAudioWorklet=false`
  before loading the runtime. Runtime processor failure is reported and disables
  the worklet; already-playing voices cannot be seamlessly recovered. New calls
  use the legacy backend. There is never duplicate playback of the same voice.
- File-backed AudioSource and encoded WavFile/WavStream sources use the worklet for
  2D, background and 3D playback. Node/world position, listener position and
  orientation, velocity, native distance/Doppler models, cones, air absorption,
  listener-relative positioning and volume limits cross the command boundary.
  Only changed parameters are applied, so a visit/update cannot cancel a fade.
- AudioBus hierarchy, gains, pan, speed, fades and all eleven existing filter
  types are mirrored into the worklet. Filter instances and processing stay in
  that isolated mixer. Native buses remain available for fallback sources;
  there is no duplicate playback of migrated sources. Bus getters still query
  the native mirror, so fade progress queries can lag during main-thread stalls.
  If migrated and fallback sources share a filtered bus, its filters operate
  separately in each backend, not on one combined signal. Such mixed custom
  graphs are not yet equivalent to a single-mixer graph.
- Ordinary Love `static`, `stream`, SoundData and cloned sources now use this
  path, preserving each LoveNode's volume bus and per-source filters/effects.
  Static sources are decoded once per cached asset; streams decode during mixing.
  Source creation still performs native validation/metadata decoding for API
  compatibility and fallback, and Web WavFile retains its encoded bytes.
- Custom AudioFile decoders (including PCM queues and tracker music) still use
  SDL. They are
  **not** protected against main-thread stalls. AudioSource reports that fallback
  once per node; it never silently drops bus routing or custom source behavior.
  Buses created before worklet availability also retain their native route.
  Generic Audio voice handles remain opaque; worklet handles use
  an index field of zero, which cannot collide with SoLoud voice handles.
- AudioSource playing/paused/position state is returned approximately every
  1024 rendered samples and after commands. Command revisions prevent stale
  snapshots from undoing a local pause/seek. End notifications return to Dora's
  logic scheduler, retain AudioEnd/autoRemove behavior and are deduplicated by
  handle. A blocked main thread may delay events/getter refresh, not mixing.
- Play returns a submitted handle; asynchronous decoder/capacity errors are
  logged with that handle. New play/control messages can be delayed by a main
  thread stall, even though established playback continues independently.

Encoded assets are cached with a 64 MiB host LRU budget and a 64 MiB worklet
budget; worklet eviction only removes assets without active voices. Each play
carries an encoded copy, allowing safe worklet eviction without a synchronous
cross-thread cache handshake. There are at most 64 live voices, with SoLoud's
Dora's native 255-active-voice mixing budget (buses also consume mixer voices,
so SoLoud's upstream default of 16 is insufficient for larger Love projects). The worklet
budget charges decoded PCM for static assets and encoded bytes for streams;
static expansion is checked using stream metadata before allocation.
Large resource loading, decoder allocation and
CPU overload on the audio thread can still cause glitches: this change removes
the main-thread dependency, not every possible cause of audio artifacts.

## Validation

Build `dora-web-player` as usual; it depends on `dora-web-audio-mixer`.

```sh
# No browser/GPU; runs in Docs CI after packaging.
node Tools/build-scripts/test_web_audio_worklet.mjs build/web
# Optional codec fixtures follow the build-directory argument.
node Tools/build-scripts/test_web_audio_state.mjs

# Local Chrome only; never added to CI.
node Tools/build-scripts/check_web_audio_worklet.mjs build/web
node Tools/build-scripts/check_web_audio_worklet.mjs build/web --fallback
node Tools/build-scripts/check_web_audio_worklet.mjs build/web --spatial
node Tools/build-scripts/check_web_audio_worklet.mjs build/web-audio-gallery --gallery
node Tools/build-scripts/check_web_audio_worklet.mjs build/web-audio-gallery --gallery --fallback
# Real AudioSource Lua integration, including AudioEnd, autoRemove and stopAll:
node Tools/build-scripts/stage_web_audio_source_test.mjs build/web
# Pass its printed output directory:
node Tools/build-scripts/check_web_audio_worklet.mjs <output-directory> --gallery --game=audio-source-test
# Build with DORA_WEB_BUILD_LOVE_PROBE=ON; local browser only:
node Tools/build-scripts/check_web_audio_worklet.mjs build/web --love-probe
node Tools/build-scripts/check_web_audio_worklet.mjs build/web --love-probe --fallback
# Also set DORA_WEB_LOVE_COMPLEX_PACKAGE to the licensed local Balatro package:
# Balatro itself requires a pthread build for its save thread, independent of mixing.
node Tools/build-scripts/check_web_audio_worklet.mjs build/web-pthreads --love-complex --isolated
```

The browser harness records audio in a second worklet while deliberately
blocking the main thread for 600 ms. It checks frame progression, silent blocks,
waveform discontinuities, pause/resume, fade/stop, and context shutdown on a
server without isolation headers. Gallery mode loads the real Dodge the Creeps
player, starts the game using Enter, verifies an active worklet voice and stops
the player. These checks are not a substitute for playback on affected phones.

Diagnostics: `Module.doraAudio.state` reports backend, sample rate, rendered
frames, last-reported live voices/buses, cache sizes and context state. DSP statistics
are sampled once per second, so counts may lag a stop command.

## Next phase

Extend the command/resource protocol to custom AudioFile/PCM queues and tracker
decoders; do not transplant pointers into the separate WASM instance. Lua-generated
PCM still needs producer headroom: independent mixing cannot prevent starvation
if the main-thread producer stops longer than the buffered audio. The current
Lua surface only exposes a subset of the C++ AudioSource API;
the migration does not introduce new Lua methods just for testing.
Validate on affected iOS/Android browsers, including touch unlock, background /
lock-screen recovery, repeated game replacement, low-memory and many-voice loads.
