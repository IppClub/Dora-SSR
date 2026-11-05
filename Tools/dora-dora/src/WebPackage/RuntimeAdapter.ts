import {strFromU8, strToU8} from 'fflate';

export function prepareHtmlRuntime(bytes: Uint8Array): Uint8Array {
  let source = strFromU8(bytes);
  for (const name of ['dora-audio-mixer.wasm', 'audio-worklet.js']) {
    const expression = `new URL("${name}",base)`;
    if (source.split(expression).length !== 2) throw new Error('Invalid snapshot/audio v1 adapter');
    source = source.replace(expression, `Module.locateFile("${name}")`);
  }
  return strToU8(source);
}

// Existing installed IDEs may carry the pre-optional production runtime.
// Adapt only its known Godot bootstrap guard, leaving core engine code intact.
export function prepareOptionalGodotRuntime(bytes: Uint8Array): Uint8Array {
  const source = strFromU8(bytes);
  const guard = 'if(!globalThis.crossOriginIsolated)return;';
  const optional = 'if(Module.doraGodotEnabled===false||!globalThis.crossOriginIsolated)return;';
  if (source.includes(optional)) return bytes;
  if (source.split(guard).length !== 2) throw new Error('Invalid optional Godot runtime adapter');
  return strToU8(source.replace(guard, optional));
}
