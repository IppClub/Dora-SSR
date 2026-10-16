#!/usr/bin/env python3
"""Real native engine acceptance; --engine must be a freshly built Dora binary.

Requires a graphical desktop and unused ports 8866/8868. Assets are isolated.
"""
import argparse
import gzip
import hashlib
import hmac
import http.client
import json
import ipaddress
import plistlib
from pathlib import Path
import socket
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.parse
import uuid
import zipfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--engine', required=True, type=Path)
parser.add_argument('--web-assets', type=Path, help='Also verify the real gzip-only Web IDE distribution')
parser.add_argument('--lan-address', help='Explicit non-loopback IPv4 address of this machine')
parser.add_argument('--require-lan', action='store_true', help='Fail if no LAN interface can be exercised')
parser.add_argument('--hold', action='store_true', help='Keep fixture alive for browser acceptance until Enter')
args = parser.parse_args()
engine = args.engine.resolve()
local = 'http://127.0.0.1:8866'
foreign = 'http://localhost:18736'
checks = 0
lan_checks = 0

if args.lan_address:
    lan = str(ipaddress.IPv4Address(args.lan_address))
else:
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as route:
            route.connect(('192.0.2.1', 1))
            lan = route.getsockname()[0]
    except OSError:
        lan = None
if lan and (ipaddress.ip_address(lan).is_loopback or ipaddress.ip_address(lan).is_unspecified):
    lan = None
if lan:
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as probe:
        try:
            probe.bind((lan, 0))
        except OSError as error:
            parser.error(f'LAN address {lan} is not assigned to this machine: {error}')
if args.require_lan and not lan:
    parser.error('No non-loopback IPv4 interface; use --lan-address with an address assigned to this machine')

# Do not accidentally exercise or alter authentication on an unrelated server.
for port in [8866, 8868]:
    with socket.socket() as probe:
        if hasattr(socket, 'SO_EXCLUSIVEADDRUSE'):
            probe.setsockopt(socket.SOL_SOCKET, socket.SO_EXCLUSIVEADDRUSE, 1)
        else:
            probe.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            probe.bind(('0.0.0.0', port))
        except OSError as error:
            parser.error(f'Port {port} is already in use: {error}')

if sys.platform == 'darwin' and engine.parents[2].suffix == '.app':
    bundle = engine.parents[2]
    info = bundle / 'Contents/Info.plist'
    if not info.is_file():
        parser.error(f'Missing {info}; rebuild the application metadata before testing LAN access')
    metadata = plistlib.loads(info.read_bytes())
    signature = subprocess.check_output(['codesign', '-dv', str(bundle)], stderr=subprocess.STDOUT, text=True)
    if f"Identifier={metadata['CFBundleIdentifier']}\n" not in signature or 'Info.plist=not bound' in signature:
        parser.error('The application signature is not bound to its bundle identifier; rebuild Dora.app')
    subprocess.run(['codesign', '--verify', '--deep', '--strict', str(bundle)], check=True)


def call(path='/ping', body='{}', origin=local, method='POST', headers=None, want=200, address='127.0.0.1'):
    global checks, lan_checks
    hs = {'Content-Type': 'application/json', **({'Origin': origin} if origin is not None else {}), **(headers or {})}
    conn = http.client.HTTPConnection(address, 8866, timeout=15)
    stage = 'TCP connect'
    try:
        conn.connect()
        stage = 'send request'
        conn.request(method, path, body=body, headers=hs)
        stage = 'receive HTTP response'
        res = conn.getresponse()
        data, out = res.read(), dict(res.getheaders())
    except TimeoutError as error:
        hint = ' Check macOS Firewall authorization for this exact build; a connected socket can still wait for incoming-connection approval.' if sys.platform == 'darwin' else ''
        raise TimeoutError(f'{method} http://{address}:8866{path}, Origin={origin}, expected={want}, timed out at {stage}.{hint}') from error
    finally:
        conn.close()
    assert res.status == want, (path, origin, res.status, data)
    if origin and want != 403:
        assert out.get('Access-Control-Allow-Origin') == origin, out
        assert 'Origin' in out.get('Vary', ''), out
    checks += 1
    if address == lan:
        lan_checks += 1
    return data, out


def signed(path='/ping', body='{}', method='POST'):
    ts, nonce = str(int(time.time())), uuid.uuid4().hex
    payload = '\n'.join(['qa-session', method, path, ts, nonce, hashlib.sha256(body.encode()).hexdigest() if body else ''])
    return {'X-Dora-Session': 'qa-session', 'X-Dora-Timestamp': ts, 'X-Dora-Nonce': nonce,
            'X-Dora-Signature': hmac.new(b'qa-secret', payload.encode(), hashlib.sha256).hexdigest()}


def ws(origin, want=101, authenticated=False, resource=None, address='127.0.0.1', host=None):
    global checks, lan_checks
    target = resource or '/'
    if authenticated:
        ts, nonce = str(int(time.time())), uuid.uuid4().hex
        target += '?' + urllib.parse.urlencode(sorted({'session': 'qa-session', 'ts': ts, 'nonce': nonce}.items()))
        payload = '\n'.join(['qa-session', 'GET', target, ts, nonce, ''])
        target += '&sig=' + hmac.new(b'qa-secret', payload.encode(), hashlib.sha256).hexdigest()
    req = f'GET {target} HTTP/1.1\r\nHost: {host or f"{address}:8868"}\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\nSec-WebSocket-Version: 13\r\n'
    if origin is not None:
        req += f'Origin: {origin}\r\n'
    with socket.create_connection((address, 8868), timeout=15) as sock:
        sock.sendall((req + '\r\n').encode())
        reply = sock.recv(4096)
        assert reply.startswith(f'HTTP/1.1 {want} '.encode()), reply
    checks += 1
    if address == lan:
        lan_checks += 1
    return target


with tempfile.TemporaryDirectory(prefix='dora-native-access-') as temp:
    root = Path(temp)
    assets, www = root / 'Assets', root / 'www'
    (assets / 'Script').mkdir(parents=True)
    if args.web_assets:
        shutil.copytree(args.web_assets.resolve(), www)
    else:
        www.mkdir()
    (www / 'test.txt').write_text('native access fixture\n' * 100)
    packed_source = b'console.log("gzip-only native fixture");\n' * 200
    packed = gzip.compress(packed_source, mtime=0)
    (www / 'only.js.gz').write_bytes(packed)
    (www / 'only.data.gz').write_bytes(packed)
    assert not (www / 'only.js').exists()
    (www / 'browser.html').write_text((Path(__file__).parent / 'fixtures/http-access.html').read_text())
    mounted = root / 'gzip-assets.zip'
    with zipfile.ZipFile(mounted, 'w', compression=zipfile.ZIP_STORED) as archive:
        archive.writestr('zip-only.js.gz', packed)
    script = """local D = require('Dora')
D.Content:insertSearchPath(1, MOUNTED)
local H = D.HttpServer
H.wwwPath = WWW
H:post('/ping', function(req) return {success=true} end)
H:get('/read-sync', function(req) return {success=true} end)
H:postSchedule('/deferred', function(req) D.sleep(0.01); return {success=true} end)
H:post('/auth', function(req) H.authToken = req.body.token or ''; return {success=true} end)
H:post('/quit', function() D.thread(function() D.sleep(0.2); D.App:shutdown() end); return {success=true} end)
assert(H:start(8866)); assert(H:startWS(8868))
print('HTTP_ACCESS_NATIVE_READY')
""".replace('WWW', json.dumps(str(www))).replace('MOUNTED', json.dumps(str(mounted)))
    (assets / 'Script/init.lua').write_text(script)
    with (root / 'engine.log').open('w') as log:
        proc = subprocess.Popen([str(engine), '--asset', str(assets)], stdout=log, stderr=subprocess.STDOUT)
        try:
            for attempt in range(100):
                if proc.poll() is not None:
                    raise RuntimeError((root / 'engine.log').read_text()[-6000:])
                try:
                    call()
                    break
                except OSError:
                    time.sleep(0.1)
            else:
                raise RuntimeError('engine did not listen')
            call('/deferred')
            ws(local)
            for origin in [None, foreign, 'https://dev.example', 'http://evil.test']:
                call(origin=origin, want=401)
                ws(origin, want=401)
            call(origin=None, headers={'Sec-Fetch-Site': 'same-origin'})
            call(origin=local, headers={'Sec-Fetch-Site': 'cross-site'}, want=401)
            for bad in ['null', 'http://localhost:18736/', 'http://user@localhost:18736']:
                call(origin=bad, want=403)
                ws(bad, want=403)
            call(headers={'Host': 'evil.test:8866'}, want=403)
            _, preflight = call(origin=foreign, method='OPTIONS', headers={'Access-Control-Request-Method': 'POST', 'Access-Control-Request-Headers': 'x-dora-signature,content-type'})
            assert 'X-Dora-Signature' in preflight['Access-Control-Allow-Headers']
            call('/test.txt', body=None, origin=foreign, method='GET', want=401)
            call('/test.txt', body=None, origin=None, method='GET')
            if args.web_assets:
                manifest = json.loads((www / 'precompressed-assets.json').read_text())
                for name, expected in manifest['files'].items():
                    assert not (www / name).exists(), name
                    encoded, headers = call('/' + urllib.parse.quote(name, safe='/'), body=None, origin=None, method='GET', headers={'Accept-Encoding':'gzip'})
                    assert headers['Content-Encoding'] == 'gzip', name
                    assert len(encoded) == expected['gzipSize'] and hashlib.sha256(encoded).hexdigest() == expected['gzipSha256'], name
                    decoded = gzip.decompress(encoded)
                    assert len(decoded) == expected['size'] and hashlib.sha256(decoded).hexdigest() == expected['sha256'], name
                index, _ = call('/', body=None, origin=None, method='GET', headers={'Accept-Encoding':'identity'})
                assert hashlib.sha256(index).hexdigest() == manifest['files']['index.html']['sha256']
                print(f"Actual Web IDE: {len(manifest['files'])} gzip-only assets served at their original URLs", flush=True)
            data, headers = call('/zip-only.js', body=None, origin=None, method='GET', headers={'Accept-Encoding':'gzip'})
            assert data == packed and headers['Content-Encoding'] == 'gzip'
            data, headers = call('/zip-only.js', body=None, origin=None, method='GET', headers={'Accept-Encoding':'identity'})
            assert data == packed_source and 'Content-Encoding' not in headers
            # Distribution contains only gzip; logical URLs keep MIME and validators.
            encoded, headers = call('/only.js', body=None, origin=None, method='GET', headers={'Accept-Encoding':'gzip'})
            assert encoded == packed and gzip.decompress(encoded) == packed_source
            assert headers['Content-Encoding'] == 'gzip' and 'javascript' in headers['Content-Type']
            gzip_etag = headers['ETag']
            identity, headers = call('/only.js', body=None, origin=None, method='GET', headers={'Accept-Encoding':'gzip;q=0'})
            assert identity == packed_source and 'Content-Encoding' not in headers and headers['ETag'] != gzip_etag
            part, headers = call('/only.js', body=None, origin=None, method='GET', headers={'Accept-Encoding':'gzip','Range':'bytes=2-9'}, want=206)
            assert part == packed_source[2:10] and 'Content-Encoding' not in headers
            assert headers['Content-Range'] == f'bytes 2-9/{len(packed_source)}'
            empty, headers = call('/only.js', body=None, origin=None, method='HEAD', headers={'Accept-Encoding':'gzip'})
            assert not empty and headers['Content-Length'] == str(len(packed)) and headers['Content-Encoding'] == 'gzip'
            empty, headers = call('/only.js', body=None, origin=None, method='GET', headers={'Accept-Encoding':'gzip','If-None-Match':gzip_etag}, want=304)
            assert not empty
            data, headers = call('/only.data', body=None, origin=None, method='GET', headers={'Accept-Encoding':'gzip'})
            assert data == packed and headers['Content-Type'] == 'application/octet-stream' and headers['Content-Encoding'] == 'gzip'
            data, headers = call('/only.js', body=None, origin=None, method='GET')
            assert data == packed_source and 'Content-Encoding' not in headers
            call('/read-sync', body=None, origin=None, method='GET', want=401)
            call('/read-sync', body=None, origin=None, method='GET', headers={'Sec-Fetch-Site':'same-origin'})
            for site in ['cross-site', 'same-site']:
                call('/test.txt', body=None, origin=None, method='GET', headers={'Sec-Fetch-Site':site}, want=401)
                navigation = {'Sec-Fetch-Site':site, 'Sec-Fetch-Mode':'navigate', 'Sec-Fetch-Dest':'document'}
                _, response_headers = call('/browser.html', body=None, origin=None, method='GET', headers=navigation)
                assert {'Sec-Fetch-Mode', 'Sec-Fetch-Dest'}.issubset(set(response_headers.get('Vary', '').split(', '))), response_headers
                call('/read-sync', body=None, origin=None, method='GET', headers=navigation, want=401)
                call('/browser.html', body=None, origin=foreign, method='GET', headers=navigation, want=401)
                for dest in ['iframe', 'script', 'empty']:
                    call('/browser.html', body=None, origin=None, method='GET', headers={**navigation, 'Sec-Fetch-Dest':dest}, want=401)
            if lan:
                lan_origin = f'http://{lan}:8866'
                for origin in [None, lan_origin, foreign, local]:
                    call(origin=origin, address=lan, want=401)
                    ws(origin, address=lan, want=401)
                call('/read-sync', body=None, origin=None, method='GET', address=lan, want=401)
                call('/read-sync', body=None, origin=None, method='GET', headers={'Sec-Fetch-Site':'same-origin'}, address=lan, want=401)
                forged = {'Host':'127.0.0.1:8866', 'Sec-Fetch-Site':'same-origin', 'X-Forwarded-For':'127.0.0.1', 'X-Forwarded-Host':'127.0.0.1:8866'}
                call(origin=local, headers=forged, address=lan, want=401)
                ws(local, host='127.0.0.1:8868', address=lan, want=401)
                # The public static navigation is needed to open the login UI.
                call('/only.js', body=None, origin=None, method='GET', address=lan)
                call('/only.js', body=None, origin=lan_origin, method='GET', address=lan)
                call('/only.js', body=None, origin=foreign, method='GET', address=lan, want=401)
                module = {'Sec-Fetch-Site':'same-origin', 'Sec-Fetch-Mode':'cors', 'Sec-Fetch-Dest':'script'}
                call('/only.js', body=None, origin=lan_origin, method='GET', headers=module, address=lan)
                call('/only.js', body=None, origin=foreign, method='GET', headers=module, address=lan, want=401)
                call('/read-sync', body=None, origin=lan_origin, method='GET', headers=module, address=lan, want=401)
                for site in ['cross-site', 'same-site']:
                    call('/only.js', body=None, origin=None, method='GET', headers={'Sec-Fetch-Site':site}, address=lan, want=401)
                    navigation = {'Sec-Fetch-Site':site, 'Sec-Fetch-Mode':'navigate', 'Sec-Fetch-Dest':'document'}
                    call('/browser.html', body=None, origin=None, method='GET', headers=navigation, address=lan)
                    call('/read-sync', body=None, origin=None, method='GET', headers=navigation, address=lan, want=401)
                    call('/browser.html', body=None, origin=foreign, method='GET', headers=navigation, address=lan, want=401)
                    call('/browser.html', body=None, origin=None, method='GET', headers={**navigation, 'Sec-Fetch-Dest':'iframe'}, address=lan, want=401)
                _, out = call(origin=foreign, method='OPTIONS', address=lan, headers={'Access-Control-Request-Method':'POST', 'Access-Control-Request-Headers':'x-dora-signature,content-type'})
                assert out['Access-Control-Allow-Origin'] == foreign and 'X-Dora-Signature' in out['Access-Control-Allow-Headers']
                call(origin='null', address=lan, want=403)
                ws('null', address=lan, want=403)
            call('/auth', body='{"token":"legacy-token"}', origin=foreign)
            call(origin=foreign, headers={'Authorization': 'Bearer legacy-token'})
            call(origin=foreign, headers={'X-Dora-Auth': 'legacy-token'})
            call(origin=foreign, headers={'X-Dora-Auth': 'wrong'}, want=401)
            ws(foreign, resource='/?auth=legacy-token')
            if lan:
                for origin in [None, lan_origin, foreign]:
                    call(origin=origin, address=lan, headers={'Authorization':'Bearer legacy-token'})
                    call(origin=origin, address=lan, headers={'X-Dora-Auth':'legacy-token'})
                    ws(origin, address=lan, resource='/?auth=legacy-token')
                call(origin=lan_origin, address=lan, headers={'X-Dora-Auth':'wrong'}, want=401)
                ws(lan_origin, address=lan, resource='/?auth=wrong', want=401)

            call('/auth', body='{"token":"qa-session:qa-secret"}', origin=foreign)
            for origin in [None, foreign, 'https://dev.example']:
                hs = signed()
                _, out = call(origin=origin, headers=hs)
                if origin:
                    assert out['Cache-Control'] == 'no-store'
                call(origin=origin, headers=hs, want=401)
                ws(origin, authenticated=True)
            if lan:
                for origin in [None, lan_origin, foreign]:
                    hs = signed()
                    _, out = call(origin=origin, address=lan, headers=hs)
                    assert out['Cache-Control'] == 'no-store'
                    call(origin=origin, address=lan, headers=hs, want=401)
                    target = ws(origin, address=lan, authenticated=True)
                    ws(origin, address=lan, resource=target, want=401)
                call('/deferred', origin=lan_origin, address=lan, headers=signed('/deferred'))
                call('/read-sync', body=None, origin=None, method='GET', address=lan, headers=signed('/read-sync','',method='GET'))
                encoded, out = call('/only.js', body=None, origin=foreign, method='GET', address=lan,
                                    headers={**signed('/only.js','',method='GET'),'Accept-Encoding':'gzip'})
                assert gzip.decompress(encoded) == packed_source and out['Cache-Control'] == 'no-store'
                part, _ = call('/only.js', body=None, origin=lan_origin, method='GET', address=lan,
                               headers={**signed('/only.js','',method='GET'),'Range':'bytes=2-9'}, want=206)
                assert part == packed_source[2:10]
                broken = signed(); broken['X-Dora-Signature'] = '0' * 64
                call(origin=lan_origin, address=lan, headers=broken, want=401)
                stale = signed(); stale['X-Dora-Timestamp'] = '1'
                call(origin=lan_origin, address=lan, headers=stale, want=401)
                call(origin=lan_origin, address=lan, headers=signed('/wrong'), want=401)
                call(origin=lan_origin, address=lan, body='{"changed":true}', headers=signed(), want=401)
                call(origin=lan_origin, address=lan, headers={**signed(),'Host':'evil.test:8866'}, want=403)
            call('/deferred', origin=foreign, headers=signed('/deferred'))
            call('/read-sync', body=None, origin=None, method='GET', headers=signed('/read-sync','',method='GET'))
            call(origin=foreign, headers=signed('/wrong'), want=401)
            stale = signed()
            stale['X-Dora-Timestamp'] = '1'
            call(origin=foreign, headers=stale, want=401)
            target = ws(foreign, authenticated=True)
            ws(foreign, resource=target, want=401)
            _, out = call('/test.txt', body=None, method='GET', origin=foreign, headers=signed('/test.txt', '', method='GET'))
            assert out['Cache-Control'] == 'no-store'
            call('/auth', body='{"token":""}')
            call()
            ws(local)
            call(origin=foreign, want=401)
            ws(foreign, want=401)
            if lan:
                call(origin=lan_origin, address=lan, want=401)
                ws(lan_origin, address=lan, want=401)
                print(f'LAN {lan}: {lan_checks} HTTP/WS auth, replay, origin, forwarding, CORS and gzip checks passed', flush=True)
            else:
                print('LAN checks NOT RUN: no non-loopback IPv4 interface', flush=True)
            if args.hold:
                call('/auth', body='{"token":"qa-session:qa-secret"}')
                print(f'BROWSER_READY ({checks} checks passed)', flush=True)
                input()
            call('/quit')
            proc.wait(timeout=10)
            assert proc.returncode == 0, proc.returncode
            print(f'Real native engine: {checks} local/cross-origin/CORS/HTTP/WS/session/deferred checks passed')
        finally:
            if proc.poll() is None:
                proc.terminate()
                try:
                    proc.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    proc.kill()
                    proc.wait()
