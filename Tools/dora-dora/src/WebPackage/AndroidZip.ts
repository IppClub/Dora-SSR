import {deflateSync, inflateSync} from 'fflate';
import {view} from './AndroidManifest';

export interface ZipMember {
  name: string;
  method: number;
  crc: number;
  size: number;
  bytes: Uint8Array;
}

const decoder = new TextDecoder('utf-8', {fatal: true});
const encoder = new TextEncoder();
const crcTable = Uint32Array.from({length: 256}, (_, value) => {
  for (let i = 0; i < 8; i++) value = (value & 1 ? 0xedb88320 : 0) ^ (value >>> 1);
  return value >>> 0;
});

export function member(name: string, bytes: Uint8Array): ZipMember {
  let crc = 0xffffffff;
  for (const byte of bytes) crc = crcTable[(crc ^ byte) & 255] ^ (crc >>> 8);
  return {name, method: 8, crc: (crc ^ 0xffffffff) >>> 0, size: bytes.length, bytes: deflateSync(bytes)};
}

export function extractMember(entry: ZipMember, max: number) {
  if (entry.size > max) throw new Error('APK entry is too large');
  return entry.method === 0 ? entry.bytes : inflateSync(entry.bytes, {out: new Uint8Array(entry.size)});
}

interface ZipLocation extends Omit<ZipMember, 'bytes'> {
  offset: number;
  compressedSize: number;
}

export async function zipDirectory(input: Blob) {
  const trailer = await input.slice(-65557).arrayBuffer();
  const endData = new DataView(trailer);
  let end = trailer.byteLength - 22;
  while (end >= 0 && (endData.getUint32(end, true) !== 0x06054b50 || end + 22 + endData.getUint16(end + 20, true) !== trailer.byteLength)) end--;
  if (end < 0) throw new Error('Invalid APK template ZIP');
  const start = endData.getUint32(end + 16, true);
  const size = endData.getUint32(end + 12, true);
  const count = endData.getUint16(end + 10, true);
  if (endData.getUint32(end + 4, true) !== 0 || endData.getUint16(end + 8, true) !== count
    || start + size !== input.size - trailer.byteLength + end || size > 32 * 1024 * 1024) {
    throw new Error('Invalid APK ZIP directory');
  }

  const bytes = new Uint8Array(await input.slice(start, start + size).arrayBuffer());
  const data = view(bytes);
  const u16 = (offset: number) => data.getUint16(offset, true);
  const u32 = (offset: number) => data.getUint32(offset, true);
  let at = 0;
  const entries = new Map<string, ZipLocation>();
  for (let i = 0; i < count; i++) {
    if (at + 46 > size || u32(at) !== 0x02014b50) throw new Error('Invalid APK ZIP entry');
    const nameLength = u16(at + 28);
    const method = u16(at + 10);
    const offset = u32(at + 42);
    const compressedSize = u32(at + 20);
    const name = decoder.decode(bytes.subarray(at + 46, at + 46 + nameLength));
    if (offset + 30 > start || u16(at + 8) & 1 || (method !== 0 && method !== 8)) throw new Error('Unsupported APK ZIP entry');
    if (!name.endsWith('/')) {
      if (name.includes('\\') || name.split('/').some(part => !part || part === '.' || part === '..') || entries.has(name)) {
        throw new Error('Invalid APK ZIP path');
      }
      entries.set(name, {name, method, crc: u32(at + 16), size: u32(at + 24), offset, compressedSize});
    }
    at += 46 + nameLength + u16(at + 30) + u16(at + 32);
  }
  if (at !== size) throw new Error('Invalid APK ZIP directory size');
  const read = async ({offset, compressedSize, name, method, crc, size}: ZipLocation): Promise<ZipMember> => {
    const header = new DataView(await input.slice(offset, offset + 30).arrayBuffer());
    if (header.getUint32(0, true) !== 0x04034b50) throw new Error('Invalid APK local ZIP entry');
    const from = offset + 30 + header.getUint16(26, true) + header.getUint16(28, true);
    if (from + compressedSize > start) throw new Error('Invalid APK ZIP entry size');
    const bytes = new Uint8Array(await input.slice(from, from + compressedSize).arrayBuffer());
    return {name, method, crc, size, bytes};
  };
  return {entries, read};
}

export function alignedZip(entries: ZipMember[]) {
  const files: Uint8Array[] = [];
  const directory: Uint8Array[] = [];
  let offset = 0;
  let directorySize = 0;
  for (const entry of entries) {
    const name = encoder.encode(entry.name);
    const alignment = entry.method === 0 ? (entry.name.endsWith('.so') ? 16384 : 4) : 1;
    const base = offset + 30 + name.length;
    const extra = base % alignment === 0 ? 0 : 4 + ((alignment - (base + 4) % alignment) % alignment);
    const local = new Uint8Array(30 + name.length + extra);
    const localView = view(local);
    localView.setUint32(0, 0x04034b50, true);
    localView.setUint16(4, 20, true);
    localView.setUint16(6, 0x800, true);
    localView.setUint16(8, entry.method, true);
    localView.setUint16(12, 33, true);
    localView.setUint32(14, entry.crc, true);
    localView.setUint32(18, entry.bytes.length, true);
    localView.setUint32(22, entry.size, true);
    localView.setUint16(26, name.length, true);
    localView.setUint16(28, extra, true);
    local.set(name, 30);
    if (extra) {
      localView.setUint16(30 + name.length, 0xa11e, true);
      localView.setUint16(32 + name.length, extra - 4, true);
    }
    const central = new Uint8Array(46 + name.length);
    const centralView = view(central);
    centralView.setUint32(0, 0x02014b50, true);
    centralView.setUint16(4, 20, true);
    central.set(local.subarray(4, 28), 6);
    centralView.setUint32(42, offset, true);
    central.set(name, 46);
    files.push(local, entry.bytes);
    directory.push(central);
    directorySize += central.length;
    offset += local.length + entry.bytes.length;
  }
  if (entries.length > 65535 || offset + directorySize + 22 >= 0x7fffffff) throw new Error('APK is too large');
  const end = new Uint8Array(22);
  const data = view(end);
  data.setUint32(0, 0x06054b50, true);
  data.setUint16(8, entries.length, true);
  data.setUint16(10, entries.length, true);
  data.setUint32(12, directorySize, true);
  data.setUint32(16, offset, true);
  return {files, directory, end, offset};
}
