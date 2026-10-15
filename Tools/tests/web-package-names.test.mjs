import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {test} from 'node:test';
import vm from 'node:vm';
import {deflateRawSync, inflateRawSync} from 'node:zlib';

const source = await readFile(new URL('../../Projects/Web/web-package.js', import.meta.url), 'utf8');
function api(Decoder = TextDecoder) {
  const scope = {TextDecoder: Decoder, TextEncoder, Uint8Array};
  vm.runInNewContext(source, scope);
  return scope.DoraWebPackage;
}
const packageApi = api();
// Byte fixtures were encoded independently with Python's gb18030 codec.
const legacyNames = [
  ['素材/图片/logo.png', 'cbd8b2c42fcdbcc6ac2f6c6f676f2e706e67'],
  ['脚本/main.lua', 'bdc5b1be2f6d61696e2e6c7561'],
  ['配置.json', 'c5e4d6c32e6a736f6e'],
  ['😀.txt', '9439fc362e747874'],
];
function zip(entries) {
  const localParts = [], centralParts = [];
  let offset = 0;
  for (const {name, flags = 0, localFlags = flags, deflate = false} of entries) {
    const bytes = Buffer.isBuffer(name) ? name : Buffer.from(name);
    const data = Buffer.from([0, 255, 128, 42]);
    const compressed = deflate ? deflateRawSync(data) : data;
    const crc = packageApi.crc32(data), method = deflate ? 8 : 0;
    const local = Buffer.alloc(30), central = Buffer.alloc(46);
    local.writeUInt32LE(0x04034b50, 0); local.writeUInt16LE(20, 4);
    local.writeUInt16LE(localFlags, 6); local.writeUInt16LE(method, 8);
    local.writeUInt32LE(crc, 14); local.writeUInt32LE(compressed.length, 18);
    local.writeUInt32LE(data.length, 22); local.writeUInt16LE(bytes.length, 26);
    central.writeUInt32LE(0x02014b50, 0); central.writeUInt16LE(20, 4);
    central.writeUInt16LE(20, 6); central.writeUInt16LE(flags, 8);
    central.writeUInt16LE(method, 10); central.writeUInt32LE(crc, 16);
    central.writeUInt32LE(compressed.length, 20); central.writeUInt32LE(data.length, 24);
    central.writeUInt16LE(bytes.length, 28); central.writeUInt32LE(offset, 42);
    localParts.push(local, bytes, compressed); centralParts.push(central, bytes);
    offset += local.length + bytes.length + compressed.length;
  }
  const directory = Buffer.concat(centralParts), end = Buffer.alloc(22);
  end.writeUInt32LE(0x06054b50, 0); end.writeUInt16LE(entries.length, 8);
  end.writeUInt16LE(entries.length, 10); end.writeUInt32LE(directory.length, 12);
  end.writeUInt32LE(offset, 16);
  return Buffer.concat([...localParts, directory, end]);
}
async function paths(entries, implementation = packageApi) {
  const archive = await implementation.inspectArchive(zip(entries), {inflateRaw: inflateRawSync});
  for (const file of archive.files) assert.deepEqual([...file.data], [0, 255, 128, 42]);
  return Array.from(archive.files, file => file.path);
}

test('ASCII and UTF-8 names work with or without bit 11', async () => {
  for (const flags of [0, 0x800]) {
    const names = ['init.lua', '素材/图片/logo.png', '😀.txt'];
    assert.deepEqual(await paths(names.map(name => ({name, flags}))), names);
  }
});
test('unflagged GB18030 names preserve two/four-byte names and binary content', async () => {
  for (const deflate of [false, true]) {
    assert.deepEqual(await paths(legacyNames.map(([, hex]) => ({name: Buffer.from(hex, 'hex'), deflate}))),
      legacyNames.map(([name]) => name));
  }
});
test('UTF-8 flag forbids legacy fallback', async () => {
  await assert.rejects(paths([{name: Buffer.from(legacyNames[0][1], 'hex'), flags: 0x800}]),
    /ZIP entry name is not valid UTF-8/);
});
test('invalid and truncated legacy bytes are rejected without replacement names', async () => {
  for (const raw of [[0xff], [0x81], [0x81, 0x30], [0x81, 0x30, 0x81]]) {
    await assert.rejects(paths([{name: Buffer.from(raw)}]), /ZIP entry name is not valid UTF-8/);
  }
});
test('decoded legacy paths still reject traversal and mixed-encoding collisions', async () => {
  await assert.rejects(paths([{name: Buffer.from('2e2e2fcde2b2bf2e747874', 'hex')}]), /unsafe ZIP entry path/);
  await assert.rejects(paths([
    {name: Buffer.from(legacyNames[2][1], 'hex')}, {name: legacyNames[2][0], flags: 0x800},
  ]), /duplicate normalized ZIP entry/);
  await assert.rejects(paths([
    {name: Buffer.from('c4bfc2bc2f412e747874', 'hex')},
    {name: Buffer.from('c4bfc2bc2f612e747874', 'hex')},
  ]), /duplicate normalized ZIP entry/);
});
test('local/central UTF-8 flag disagreement remains rejected', async () => {
  await assert.rejects(paths([{name: 'init.lua', flags: 0, localFlags: 0x800}]), /ZIP headers disagree/);
});
test('UTF-8 happy path does not require a legacy decoder', async () => {
  const implementation = api(class extends TextDecoder {
    constructor(label, options) {
      if (label === 'gb18030') throw new RangeError('unsupported encoding');
      super(label, options);
    }
  });
  assert.deepEqual(await paths([{name: '素材/图片/logo.png'}], implementation), ['素材/图片/logo.png']);
  await assert.rejects(paths([{name: Buffer.from(legacyNames[0][1], 'hex')}], implementation),
    /ZIP entry name is not valid UTF-8/);
});
