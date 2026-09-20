import {strFromU8, strToU8} from 'fflate';
import {sha256} from '@noble/hashes/sha2.js';
import {bytesToHex} from '@noble/hashes/utils.js';

// Compatibility boundary for the gallery player built from 9c593934. That
// player supports snapshots but predates an audio resource resolver hook.
// Match the complete JS artifact, not source snippets that imply capabilities.
// A new player revision needs a verified adapter and real-runtime tests here;
// HTTP export does not require this legacy HTML compatibility adapter.
const snapshotAudioV1 = 'd564f6de220b15ea62c6ce4985e4fc64280fb03d9d51880513c31e1688404d40';

export function prepareHtmlRuntime(bytes: Uint8Array): Uint8Array {
  const fingerprint = bytesToHex(sha256(bytes));
  if (fingerprint !== snapshotAudioV1) {
    throw new Error(`Unverified HTML runtime (${fingerprint}). Use the verified export runtime or add a tested snapshot/audio adapter for this engine build. HTTP export remains available.`);
  }
  let source = strFromU8(bytes);
  for (const name of ['dora-audio-mixer.wasm', 'audio-worklet.js']) {
    const expression = `new URL("${name}",base)`;
    if (source.split(expression).length !== 2) throw new Error('Invalid snapshot/audio v1 adapter');
    source = source.replace(expression, `Module.locateFile("${name}")`);
  }
  return strToU8(source);
}
