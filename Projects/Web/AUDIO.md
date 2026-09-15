# Independent Web audio — phase 1

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
  browser-native codec support is not required. Sources use WavStream, avoiding
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
- AudioSource, AudioBus, filters, positional/3D audio and PCM queues still use
  the original SDL backend. They are **not** protected against main-thread stalls
  in this phase. Generic Audio voice handles remain opaque; worklet handles use
  an index field of zero, which cannot collide with SoLoud voice handles.
- Play returns a submitted handle; asynchronous decoder/capacity errors are
  logged with that handle. New play/control messages can be delayed by a main
  thread stall, even though established playback continues independently.

Encoded assets are cached with a 64 MiB host LRU budget and a 64 MiB worklet
budget; worklet eviction only removes assets without active voices. Each play
carries an encoded copy, allowing safe worklet eviction without a synchronous
cross-thread cache handshake. There are at most 64 live voices, with SoLoud's
default active mixing budget. Large resource loading, decoder allocation and
CPU overload on the audio thread can still cause glitches: this change removes
the main-thread dependency, not every possible cause of audio artifacts.

## Validation

Build `dora-web-player` as usual; it depends on `dora-web-audio-mixer`.

```sh
# No browser/GPU; runs in Docs CI after packaging.
node Tools/build-scripts/test_web_audio_worklet.mjs build/web
# Optional codec fixtures follow the build-directory argument.

# Local Chrome only; never added to CI.
node Tools/build-scripts/check_web_audio_worklet.mjs build/web
node Tools/build-scripts/check_web_audio_worklet.mjs build/web --fallback
node Tools/build-scripts/check_web_audio_worklet.mjs build/web-audio-gallery --gallery
node Tools/build-scripts/check_web_audio_worklet.mjs build/web-audio-gallery --gallery --fallback
```

The browser harness records audio in a second worklet while deliberately
blocking the main thread for 600 ms. It checks frame progression, silent blocks,
waveform discontinuities, pause/resume, fade/stop, and context shutdown on a
server without isolation headers. Gallery mode loads the real Dodge the Creeps
player, starts the game using Enter, verifies an active worklet voice and stops
the player. These checks are not a substitute for playback on affected phones.

Diagnostics: `Module.doraAudio.state` reports backend, sample rate, rendered
frames, last-reported live voices, cache sizes and context state. DSP statistics
are sampled once per second, so counts may lag a stop command.

## Next phase

Extend the command/resource protocol to AudioSource, buses, filters, 3D state,
and PCM queues; do not transplant pointers into the separate WASM instance.
Preserve opaque-handle lifetime, getters, source-end notifications, hierarchy,
seeking and sample-accurate automation before moving those interfaces off SDL.
Validate on affected iOS/Android browsers, including touch unlock, background /
lock-screen recovery, repeated game replacement, low-memory and many-voice loads.
