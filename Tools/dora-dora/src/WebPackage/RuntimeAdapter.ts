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
