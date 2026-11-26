import exportPolicy from '../../../../Assets/Script/Dev/ExportPolicy.json';
import forge from 'node-forge';
import {sha256} from '@noble/hashes/sha2.js';
import {joinBytes, rewriteAndroidManifest, view, word, type AndroidGameInfo} from './AndroidManifest';
import {alignedZip, extractMember, member, zipDirectory, type ZipMember} from './AndroidZip';
import {projectNeedsGodot} from './GodotDependency';

type SigningKey = {key: forge.pki.rsa.PrivateKey; certificate: forge.pki.Certificate};
const bytes = (value: string) => Uint8Array.from(value, character => character.charCodeAt(0));
const binary = (value: Uint8Array) => forge.util.binary.raw.encode(value);
const der = (value: forge.asn1.Asn1) => bytes(forge.asn1.toDer(value).getBytes());
const field = (...parts: Uint8Array[]) => joinBytes(word(parts.reduce((length, part) => length + part.length, 0)), ...parts);
const rsaSigningAlgorithm = word(0x0103);

function importKey(file: Uint8Array, password: string): SigningKey {
  try {
    const asn1 = forge.asn1.fromDer(binary(file));
    const store = forge.pkcs12.pkcs12FromAsn1(asn1, true, password);
    const bags = (type: string) => store.getBags({bagType: type})[type] ?? [];
    const keys = [...bags(forge.pki.oids.pkcs8ShroudedKeyBag), ...bags(forge.pki.oids.keyBag)];
    const key = keys[0]?.key;
    if (keys.length !== 1 || !key || !('n' in key)) throw new Error();
    const certificate = bags(forge.pki.oids.certBag).find(({cert}) => {
      const publicKey = cert?.publicKey;
      return publicKey && 'n' in publicKey && key.n.equals(publicKey.n) && key.e.equals(publicKey.e);
    })?.cert;
    if (!certificate) throw new Error();
    return {key, certificate};
  } catch {
    throw new Error('export.androidKeyInvalid');
  }
}

function createKey(password: string) {
  // The packager itself runs in a worker. Keep Forge from spawning a second
  // worker that would need a separate URL in the distributed Web IDE.
  const pair = forge.pki.rsa.generateKeyPair({bits: 3072});
  const certificate = forge.pki.createCertificate();
  certificate.publicKey = pair.publicKey;
  certificate.serialNumber = '01' + forge.util.bytesToHex(forge.random.getBytesSync(15));
  certificate.validity.notBefore = new Date(Date.now() - 86400000);
  certificate.validity.notAfter = new Date(certificate.validity.notBefore);
  certificate.validity.notAfter.setUTCFullYear(certificate.validity.notAfter.getUTCFullYear() + 50);
  const subject = [{name: 'commonName', value: 'Dora Game'}];
  certificate.setSubject(subject);
  certificate.setIssuer(subject);
  certificate.sign(pair.privateKey, forge.md.sha256.create());
  const store = der(forge.pkcs12.toPkcs12Asn1(pair.privateKey, certificate, password, {algorithm: 'aes256', friendlyName: 'game'}));
  return {key: pair.privateKey, certificate, store};
}

// APK v2 digests hash each 1 MiB chunk independently. Chunk boundaries reset
// between file data, the central directory and the end-of-directory record.
function sectionDigest(sections: Uint8Array[][]) {
  const chunks: Uint8Array[] = [];
  const chunkLimit = 1024 * 1024;
  for (const section of sections) {
    let remaining = section.reduce((size, item) => size + item.length, 0);
    let limit = Math.min(chunkLimit, remaining);
    let used = 0;
    let hash = sha256.create().update(Uint8Array.of(0xa5)).update(word(limit));
    for (const item of section) {
      for (let offset = 0; offset < item.length;) {
        const count = Math.min(limit - used, item.length - offset);
        hash.update(item.subarray(offset, offset + count));
        offset += count;
        used += count;
        remaining -= count;
        if (used === limit) {
          chunks.push(hash.digest());
          limit = Math.min(chunkLimit, remaining);
          used = 0;
          hash = sha256.create().update(Uint8Array.of(0xa5)).update(word(limit));
        }
      }
    }
  }
  const hash = sha256.create().update(Uint8Array.of(0x5a)).update(word(chunks.length));
  for (const chunk of chunks) hash.update(chunk);
  return hash.digest();
}

const long = (value: number) => joinBytes(word(value), word(0));

function signArchive(zip: ReturnType<typeof alignedZip>, identity: SigningKey) {
  const digest = sectionDigest([zip.files, zip.directory, [zip.end]]);
  const certBytes = der(forge.pki.certificateToAsn1(identity.certificate));
  const signed = joinBytes(field(field(rsaSigningAlgorithm, field(digest))), field(field(certBytes)), field());
  const md = forge.md.sha256.create().update(binary(signed));
  const signature = bytes(identity.key.sign(md));
  const key = identity.certificate.publicKey as forge.pki.rsa.PublicKey;
  const publicKey = der(forge.pki.publicKeyToAsn1(key));
  const v2 = field(field(field(signed), field(field(rsaSigningAlgorithm, field(signature))), field(publicKey)));
  const pair = joinBytes(long(v2.length + 4), word(0x7109871a), v2);
  const size = long(pair.length + 24);
  const block = joinBytes(size, pair, size, new TextEncoder().encode('APK Sig Block 42'));
  view(zip.end).setUint32(16, zip.offset + block.length, true);
  return new Blob([...zip.files, block, ...zip.directory, zip.end] as BlobPart[], {type: 'application/vnd.android.package-archive'});
}

const policy = exportPolicy.androidTemplate;
function excluded(name: string) {
  if (policy.excludedPaths.includes(name) || policy.excludedDirectories.some(prefix => name.startsWith(prefix))) return true;
  if (name.startsWith('lib/') && policy.excludedLibraries.some(library => name.endsWith('/' + library))) return true;
  if (!name.startsWith('META-INF/')) return false;
  const filename = name.slice('META-INF/'.length).toLowerCase();
  return !filename.includes('/') && (policy.signatureNames.includes(filename)
    || policy.signaturePrefixes.some(prefix => filename.startsWith(prefix))
    || policy.signatureSuffixes.some(suffix => filename.endsWith(suffix)));
}

async function inferProjectGodot(assets: Awaited<ReturnType<typeof zipDirectory>>) {
  const relevant: Record<string, Uint8Array> = Object.create(null);
  let scanned = 0;
  for (const [name, entry] of assets.entries) {
    if (!name.startsWith('Game/')) continue;
    if (/(?:^|\/)project\.godot$|\.(?:pck|gd|gdc|tscn|scn|tres|gdshader|gdshaderinc|gdextension)$/i.test(name)) {
      relevant[name.slice(5)] = new Uint8Array();
    } else if (/\.(?:lua|tl|tsx?|yue|xml|wasm|wa|rs|vs|bl|json|res)$/i.test(name)) {
      scanned += entry.size;
      if (scanned > 64 * 1024 * 1024) throw new Error('Android project scripts are too large to inspect');
      relevant[name.slice(5)] = extractMember(await assets.read(entry), 64 * 1024 * 1024);
    }
  }
  return projectNeedsGodot(relevant);
}

export async function createAndroidArchive(template: Blob, project: Blob, game: AndroidGameInfo, password: string, keyFile?: Uint8Array, needsGodot?: boolean) {
  if (game.packageName.length > 200 || !/^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$/.test(game.packageName)
    || !Number.isInteger(game.versionCode) || game.versionCode < 1 || game.versionCode > 2147483647
    || !game.title.trim() || !game.versionName.trim()) throw new Error('Invalid Android game metadata');
  if (keyFile && keyFile.length > 1024 * 1024) throw new Error('export.androidKeyInvalid');
  const [apk, assets] = await Promise.all([zipDirectory(template), zipDirectory(project)]);
  const manifest = apk.entries.get('AndroidManifest.xml');
  const abis = [...apk.entries.keys()].flatMap(name => /^lib\/([^/]+)\/libmain\.so$/.exec(name)?.[1] ?? []);
  if (!manifest || !apk.entries.has('classes.dex') || !apk.entries.has('resources.arsc') || !abis.length) throw new Error('Invalid Dora APK template');
  if (!assets.entries.has('Script/init.lua')) throw new Error('Missing Android game startup script');

  const godot = needsGodot ?? await inferProjectGodot(assets);
  if (godot && abis.some(abi => !apk.entries.has(`lib/${abi}/libgodot_android.so`))) throw new Error('The Dora APK template is missing Godot');

  const updatedManifest = rewriteAndroidManifest(extractMember(await apk.read(manifest), 2 * 1024 * 1024), game);
  const members: ZipMember[] = [];
  for (const entry of apk.entries.values()) {
    const {name} = entry;
    if (excluded(name) || (!godot && name.endsWith('/libgodot_android.so'))) continue;
    members.push(name === 'AndroidManifest.xml' ? member(name, updatedManifest) : await apk.read(entry));
  }
  const names = new Set(members.map(({name}) => name));
  for (const entry of assets.entries.values()) {
    const name = 'assets/' + entry.name;
    if (names.has(name)) throw new Error('Game assets conflict with the Android template');
    members.push({...await assets.read(entry), name});
  }
  const identity = keyFile ? importKey(keyFile, password) : createKey(password);
  return {apk: signArchive(alignedZip(members), identity), store: 'store' in identity ? identity.store as Uint8Array<ArrayBuffer> : undefined};
}
