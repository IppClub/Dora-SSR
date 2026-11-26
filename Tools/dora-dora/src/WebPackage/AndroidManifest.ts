// Binary Android XML, following the same rewrite rules as GameManifest.java.
const utf8 = new TextDecoder();
const utf16 = new TextDecoder('utf-16le');
const encoder = new TextEncoder();

export const view = (bytes: Uint8Array) => new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
export function joinBytes(...parts: Uint8Array[]): Uint8Array<ArrayBuffer> {
  const result = new Uint8Array(parts.reduce((size, part) => size + part.length, 0));
  let offset = 0;
  for (const part of parts) {
    result.set(part, offset);
    offset += part.length;
  }
  return result;
}
export function word(value: number) {
  const bytes = new Uint8Array(4);
  view(bytes).setUint32(0, value, true);
  return bytes;
}

export interface AndroidGameInfo {
  packageName: string;
  title: string;
  versionName: string;
  versionCode: number;
}

export function rewriteAndroidManifest(input: Uint8Array, game: AndroidGameInfo) {
  const manifest = input.slice();
  const data = view(manifest);
  const u16 = (offset: number) => data.getUint16(offset, true);
  const u32 = (offset: number) => data.getUint32(offset, true);
  if (u16(0) !== 3 || u16(2) !== 8 || u32(4) !== manifest.length) throw new Error('Invalid Android manifest');
  const pool = 8;
  const header = u16(pool + 2);
  const size = u32(pool + 4);
  const count = u32(pool + 8);
  const flags = u32(pool + 16);
  const strings = u32(pool + 20);
  const isUtf8 = (flags & 0x100) !== 0;
  if (u16(pool) !== 1 || header < 28 || u32(pool + 12) !== 0
    || strings < header + count * 4 || size < strings || pool + size > manifest.length) throw new Error('Invalid Android string pool');

  const getString = (index: number) => {
    if (index >= count) throw new Error('Invalid Android string index');
    let at = pool + strings + u32(pool + header + index * 4);
    let sizeInBytes;
    if (isUtf8) {
      at += manifest[at] & 128 ? 2 : 1;
      const first = manifest[at++];
      sizeInBytes = first & 128 ? ((first & 127) << 8) | manifest[at++] : first;
    } else {
      const first = u16(at);
      at += 2;
      const length = first & 0x8000 ? ((first & 0x7fff) << 16) | u16(at) : first;
      if (first & 0x8000) at += 2;
      sizeInBytes = length * 2;
    }
    if (at + sizeInBytes > pool + size) throw new Error('Invalid Android string');
    return (isUtf8 ? utf8 : utf16).decode(manifest.subarray(at, at + sizeInBytes));
  };
  const extra = new Map<string, number>();
  const setText = (at: number, text: string) => {
    if (!extra.has(text)) extra.set(text, count + extra.size);
    const index = extra.get(text)!;
    data.setUint32(at + 8, index, true);
    data.setUint8(at + 15, 3);
    data.setUint32(at + 16, index, true);
  };
  const setValue = (at: number, type: number, value: number) => {
    data.setUint32(at + 8, 0xffffffff, true);
    data.setUint8(at + 15, type);
    data.setUint32(at + 16, value, true);
  };
  let templateId = '';
  let filterStart = -1;
  let launcher = false;
  let omitPermission = -1;
  let bodyStart = pool + size;
  const body: Uint8Array[] = [];
  const found = new Set<string>();
  for (let chunk = bodyStart; chunk < manifest.length;) {
    const kind = u16(chunk);
    const chunkHeader = u16(chunk + 2);
    const length = u32(chunk + 4);
    if (length < 8 || chunk + length > manifest.length) throw new Error('Invalid Android XML chunk');
    if (kind === 0x102 || kind === 0x103) {
      const element = chunk + chunkHeader;
      const tag = getString(u32(element + 4));
      if (kind === 0x102 && tag === 'intent-filter') {
        filterStart = chunk;
        launcher = false;
      }
      if (kind === 0x103 && tag === 'intent-filter' && filterStart >= 0) {
        if (!launcher) {
          body.push(manifest.subarray(bodyStart, filterStart));
          bodyStart = chunk + length;
        }
        filterStart = -1;
      } else if (kind === 0x103 && omitPermission >= 0) {
        body.push(manifest.subarray(bodyStart, omitPermission));
        bodyStart = chunk + length;
        omitPermission = -1;
      }
      if (kind === 0x102) {
        const start = element + u16(element + 8);
        const stride = u16(element + 10);
        const attributes = u16(element + 12);
        if (stride < 20 || start + stride * attributes > chunk + length) throw new Error('Invalid Android XML attributes');
        for (let i = 0; i < attributes; i++) {
          const at = start + i * stride;
          const name = getString(u32(at + 4));
          const text = manifest[at + 15] === 3 ? getString(u32(at + 16)) : '';
          if (tag === 'manifest' && name === 'package') {
            templateId = text;
            if (!templateId || templateId === game.packageName) throw new Error('Choose a package name different from Dora');
            setText(at, game.packageName);
            found.add(name);
          } else if (tag === 'manifest' && name === 'versionCode') {
            setValue(at, 0x10, game.versionCode);
            found.add(name);
          } else if (tag === 'manifest' && name === 'versionName') {
            setText(at, game.versionName);
            found.add(name);
          } else if (tag === 'application' && name === 'label') {
            setText(at, game.title);
            found.add(name);
          } else if (tag === 'application' && (name === 'icon' || name === 'roundIcon')) {
            setValue(at, 1, 0x0108002c);
            if (name === 'icon') found.add(name);
          } else if (filterStart >= 0 && tag === 'action' && name === 'name' && text === 'android.intent.action.MAIN') {
            launcher = true;
          } else if (tag === 'uses-permission' && name === 'name' && text === 'android.permission.REQUEST_INSTALL_PACKAGES') {
            omitPermission = chunk;
          } else if (templateId && text.startsWith(templateId + '.')
            && (name === 'authorities' || name === 'permission' || (name === 'name' && ['permission', 'uses-permission'].includes(tag)))) {
            setText(at, game.packageName + text.slice(templateId.length));
          } else if (tag === 'activity' && name === 'name' && text.startsWith('.')) {
            setText(at, 'org.ippclub.dorassr' + text);
          }
        }
      }
    }
    chunk += length;
  }
  if (found.size !== 5) throw new Error('The Dora APK is missing game export metadata');
  body.push(manifest.subarray(bodyStart));

  const offsets: Uint8Array[] = [];
  const encoded: Uint8Array[] = [];
  const oldStrings = manifest.subarray(pool + strings, pool + size);
  let next = oldStrings.length;
  const utf8Length = (length: number) => length < 128 ? Uint8Array.of(length) : Uint8Array.of(128 | (length >> 8), length & 255);
  for (const text of extra.keys()) {
    const bytes = isUtf8
      ? encoder.encode(text)
      : new Uint8Array(Uint16Array.from({length: text.length}, (_, i) => text.charCodeAt(i)).buffer);
    if (text.length > 0x7fff || bytes.length > 0x7fff) throw new Error('Game metadata is too long');
    const entry = isUtf8
      ? joinBytes(utf8Length(text.length), utf8Length(bytes.length), bytes, Uint8Array.of(0))
      : joinBytes(Uint8Array.of(text.length & 255, text.length >> 8), bytes, Uint8Array.of(0, 0));
    offsets.push(word(next));
    encoded.push(entry);
    next += entry.length;
  }
  const poolHeader = manifest.slice(pool, pool + header + count * 4);
  const poolData = view(poolHeader);
  const padding = (4 - next % 4) % 4;
  poolData.setUint32(4, size + extra.size * 4 + next - oldStrings.length + padding, true);
  poolData.setUint32(8, count + extra.size, true);
  poolData.setUint32(16, flags & ~1, true);
  poolData.setUint32(20, strings + extra.size * 4, true);
  const result = joinBytes(manifest.subarray(0, pool), poolHeader, ...offsets, new Uint8Array(strings - header - count * 4), oldStrings, ...encoded, new Uint8Array(padding), ...body);
  view(result).setUint32(4, result.length, true);
  return result;
}
