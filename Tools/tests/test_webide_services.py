#!/usr/bin/env python3
"""Exercise the real Web IDE service in a disposable application data directory.

Start Dora with a separate OS application-data home before invoking this test.
The status guard refuses a normal user profile. No public Git/LLM requests occur.
"""
import argparse
from collections import defaultdict
import http.client
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import threading
import json
from pathlib import Path
import re
import subprocess
import time
import urllib.parse
import uuid

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--app-root', type=Path, required=True, help='Disposable application data parent')
parser.add_argument('--report', type=Path, required=True)
args = parser.parse_args()
repo = Path(__file__).resolve().parents[2]
coverage = defaultdict(list)
failures = []
checks = 0


def request(path, body=None, method='POST', origin='http://127.0.0.1:8866', raw=None, headers=None):
    conn = http.client.HTTPConnection('127.0.0.1', 8866, timeout=30)
    data = raw if raw is not None else json.dumps(body or {}, ensure_ascii=False).encode() if method == 'POST' else None
    try:
        conn.request(method, path, body=data, headers={'Content-Type': 'application/json', **({'Origin': origin} if origin else {}), **(headers or {})})
        response = conn.getresponse()
        content = response.read()
        return response.status, content, dict(response.getheaders())
    finally:
        conn.close()


def call(path, body=None, success=None, method='POST', label='functional'):
    global checks
    status, content, _ = request(path, body, method)
    assert status == 200, (path, status, content[:300])
    try:
        result = json.loads(content)
    except Exception as error:
        raise AssertionError((path, 'non-JSON service response', content[:300])) from error
    if success is not None:
        assert result.get('success') is success, (path, body, result)
    coverage[path.split('?')[0]].append(label)
    checks += 1
    return result


status = call('/status', success=True)
app = Path(status['appPath'])
assert (args.app_root / '.dora-webide-acceptance').read_text().strip() == 'disposable', 'Create the disposable-profile marker before running this test'
assert not app.resolve().is_relative_to(Path.home().resolve()), 'Refusing application data inside the normal user home'
assert args.app_root.resolve() != Path.home().resolve()
assert app.resolve().is_relative_to(args.app_root.resolve()) and app.resolve() != args.app_root.resolve(), 'Refusing the normal application profile'
assert Path(status['writablePath']).resolve() == app.resolve(), 'Writable directory must also be isolated'
work = app / ('service-qa-' + uuid.uuid4().hex[:8])
work.mkdir()


def path(name):
    return str(work / name)


def scenario(name, fn):
    try:
        fn()
        print('PASS', name, flush=True)
    except Exception as error:
        failures.append({'scenario': name, 'error': str(error)})
        print('FAIL', name, str(error)[:500], flush=True)


source = (repo / 'Assets/Script/Dev/WebServer.yue').read_text()
routes = re.findall(r'HttpServer\\(postSchedule|post|get|upload)\s*\(?\s*"([^"]+)"', source)


def contracts():
    for kind, endpoint in routes:
        method = 'GET' if kind == 'get' else 'POST'
        if endpoint not in ['/auth', '/auth/confirm']:
            status, data, _ = request(endpoint, method=method, origin='http://localhost:18736')
            assert status == 401, (endpoint, status, data[:200])
            coverage[endpoint].append('unauthenticated cross-origin rejected')
        if endpoint == '/compiler/poll':
            # The live IDE owns its pending compiler jobs. A competing poll
            # would steal work; check only its authentication gate here.
            continue
        if endpoint == '/upload':
            status, _, _ = request(endpoint)
            assert status == 400, status
            coverage[endpoint].append('invalid multipart rejected')
        else:
            call(endpoint, method=method, label='empty request contract')


scenario('all route authentication and empty-input contracts', contracts)


def git_auth_invalid_types():
    global checks
    for body in [1, 'invalid', {'url': 13}, {'url': False}, {'repoPath': '/', 'command': 1}]:
        status, data, _ = request('/git/auth/match', raw=json.dumps(body).encode())
        assert status == 200, (status, data[:200])
        assert json.loads(data).get('success') is False, data[:200]
        coverage['/git/auth/match'].append('invalid input type rejected')
        checks += 1


scenario('Git auth rejects invalid input types without a Lua traceback', git_auth_invalid_types)


def filesystem():
    call('/new', {'path': path('中文 空格'), 'content': '', 'folder': True}, True)
    file = path('中文 空格/hello.txt')
    call('/new', {'path': file, 'content': '初始内容\n', 'folder': False}, True)
    call('/new', {'path': file, 'content': 'overwrite', 'folder': False}, False)
    assert call('/read', {'path': file}, True)['content'] == '初始内容\n'
    call('/write', {'path': file, 'content': '更新 🌟\n'}, True)
    assert call('/read', {'path': file}, True)['content'] == '更新 🌟\n'
    assert call('/stat', {'path': file}, True)['size'] == len('更新 🌟\n'.encode())
    call('/stat', {'path': path('中文 空格')}, False)
    call('/exist', {'file': file}, True)
    call('/exist', {'file': path('missing.txt')}, False)
    call('/read', {'path': path('missing.txt')}, False)
    assert '中文 空格/hello.txt' in call('/list', {'path': str(work)}, True)['files']
    assert call('/read-sync?'+urllib.parse.urlencode({'path': file}), method='GET', success=True)['content'] == '更新 🌟\n'
    renamed = path('中文 空格/renamed.txt')
    call('/rename', {'old': file, 'new': renamed}, True)
    for folder in ['copy', 'move']:
        call('/new', {'path': path(folder), 'folder': True, 'content': ''}, True)
    call('/assets/batch', {'operation': 'copy', 'sources': [renamed], 'target': path('copy')}, True)
    call('/assets/batch', {'operation': 'move', 'sources': [path('copy/renamed.txt')], 'target': path('move')}, True)
    call('/assets/batch', {'operation': 'delete', 'sources': [path('move/renamed.txt')]}, True)
    call('/assets/batch', {'operation': 'copy', 'sources': [path('中文 空格')], 'target': path('中文 空格')}, False)
    call('/assets/batch', {'operation': 'delete', 'sources': [str(app.parent)]}, False)
    call('/assets/children', {'path': str(work)})
    call('/assets/files', {'path': str(work)})
    archive = path('roundtrip.zip')
    call('/zip', {'path': path('中文 空格'), 'zipFile': archive, 'obfuscated': False}, True)
    call('/unzip', {'zipFile': archive, 'path': path('unpacked')}, True)
    assert Path(path('unpacked/renamed.txt')).read_text() == '更新 🌟\n'
    relative = str(work.relative_to(app) / '中文 空格')
    boundary = 'DoraQA' + uuid.uuid4().hex
    payload = (f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="upload.txt"\r\nContent-Type: text/plain\r\n\r\nuploaded from QA\r\n--{boundary}--\r\n').encode()
    status, data, _ = request('/upload?' + urllib.parse.urlencode({'path': relative}), raw=payload, headers={'Content-Type': 'multipart/form-data; boundary=' + boundary})
    assert status == 200 and Path(path('中文 空格/upload.txt')).read_text() == 'uploaded from QA', (status, data)
    coverage['/upload'].append('multipart upload to disposable directory')
    call('/delete', {'path': renamed}, True)
    call('/delete', {'path': renamed}, False)


scenario('file CRUD, unicode, batch operations, multipart upload and ZIP round trip', filesystem)


def downloads():
    payload = b'Web IDE download integrity\n' * 100
    class File(BaseHTTPRequestHandler):
        def log_message(self, *_): pass
        def do_GET(self):
            self.send_response(200); self.send_header('Content-Length', str(len(payload))); self.end_headers(); self.wfile.write(payload)
    server = ThreadingHTTPServer(('127.0.0.1', 0), File)
    worker = threading.Thread(target=server.serve_forever, daemon=True); worker.start()
    try:
        target = work / 'download.txt'
        call('/download', {'url': f'http://127.0.0.1:{server.server_port}/download.txt', 'target': str(target)}, True)
        for _ in range(100):
            if target.is_file() and target.read_bytes() == payload: break
            time.sleep(.1)
        assert target.read_bytes() == payload, 'Downloaded content differs from the source'
    finally:
        server.shutdown(); server.server_close(); worker.join(timeout=3)


scenario('real streamed download with byte-for-byte integrity', downloads)



def languages():
    for suffix, code in [('lua', 'print("QA_LUA_OK")'), ('yue', 'print "QA_YUE_OK"'), ('tl', 'print("QA_TEAL_OK")')]:
        file = path('sample_' + suffix + '.' + suffix)
        call('/new', {'path': file, 'content': code, 'folder': False}, True)
        call('/check', {'file': file, 'content': code}, True)
        call('/build', {'path': file}, suffix != 'lua')
        call('/run', {'file': file, 'asProj': False}, True)
        assert call('/run/status', success=True)['running'] is True
        call('/stop', success=True)
        assert call('/run/status', success=True)['running'] is False
    ts_file = path('sample_ts.ts')
    call('/new', {'path': ts_file, 'content': 'print("QA_TS_OK");', 'folder': False}, True)
    call('/ts/build', {'path': ts_file, 'projectRoot': str(work)}, True)
    call('/run', {'file': ts_file, 'asProj': False}, True)
    call('/stop', success=True)
    call('/check', {'file': path('bad.lua'), 'content': 'local = '}, False)
    call('/check', {'file': path('bad.yue'), 'content': 'a = ('}, False)
    call('/check', {'file': path('bad.tl'), 'content': 'local n: number = "text"'}, False)
    call('/infer', {'lang': 'lua', 'file': path('language.lua'), 'content': 'local n = 1\nprint(n)', 'line': 'print(n', 'row': 2}, True)
    assert call('/complete', {'lang': 'lua', 'file': path('language.lua'), 'content': 'string.', 'line': 'string.', 'row': 1}, True)['suggestions']
    assert call('/signature', {'lang': 'lua', 'file': path('language.lua'), 'content': 'string.sub(', 'line': 'string.sub', 'row': 1}, True)['signatures']
    call('/body/parse', {'file': path('shape.b.lua'), 'content': 'return {"Array"}'}, True)
    call('/body/parse', {'file': path('shape.b.lua'), 'content': 'return {}'}, False)
    call('/body/parse', {'file': path('shape.b.lua'), 'content': 'error("qa")'}, False)
    call('/yarn/check', {'code': json.dumps({'nodes': [{'title': 'Start', 'body': 'Hello world'}]})}, True)
    call('/yarn/check-file', {'code': 'title: Start\n---\nHello world\n===\n'}, True)
    wa = path('wa-project')
    call('/wa/create', {'path': wa}, True)
    call('/wa/create', {'path': wa}, False)
    wa_file = Path(wa) / 'src/main.wa'
    call('/wa/format', {'file': str(wa_file)}, False)  # Already formatted: no change.
    wa_file.write_text(wa_file.read_text().replace('\t', '    '))
    formatted = call('/wa/format', {'file': str(wa_file)}, True)
    call('/write', {'path': str(wa_file), 'content': formatted['code']}, True)
    call('/wa/build', {'path': wa}, True)
    call('/wa/update_dora', {'path': wa}, True)
    for language in ['en', 'zh-Hans']:
        found = call('/doc/search', {'docLanguage': language, 'docType': 'dora-api', 'programmingLanguage': 'lua', 'pattern': 'Node', 'limit': 3}, True)
        coverage['/doc/search'].append(language)
    call('/doc/read', {'docLanguage': 'en', 'file': 'not-a-real-doc.md'}, False)
    call('/agent/command', {'projectRoot': str(work), 'mode': 'lua', 'code': 'print("QA_COMMAND_BRIDGE_OK")', 'timeoutSeconds': 5}, True)
    call('/agent/preview', {'projectRoot': str(work), 'entry': 'sample_lua.lua', 'captureAtSeconds': [.1], 'queueTimeoutSeconds': 5}, True)
    call('/command', {'code': 'print "QA_COMMAND_OK"', 'log': True}, True)
    call('/log', {'count': 10}, True)
    call('/log', {'count': -1}, False)
    call('/log/save', success=True)


scenario('language check/build/run/stop, body/Yarn/Wa tools, documentation and logs', languages)


def git():
    gitdir = work / 'git-repo'; gitdir.mkdir()
    def run(*cmd):
        return subprocess.check_output(['git', '-C', str(gitdir), *cmd], text=True).strip()
    run('init', '-b', 'main'); run('config', 'user.name', 'Web IDE QA'); run('config', 'user.email', 'qa@example.invalid')
    (gitdir / 'hello.txt').write_text('initial\n'); run('add', '.'); run('commit', '-m', 'Disposable QA fixture')
    head = run('rev-parse', 'HEAD'); (gitdir / 'hello.txt').write_text('changed\n')
    (gitdir / 'untracked.txt').write_text('disposable\n')
    body = {'repoPath': str(gitdir)}
    for endpoint in ['/git/summary', '/git/status-files', '/git/history', '/git/remotes', '/git/branches', '/git/tags']:
        call(endpoint, body, True)
    call('/git/file-diff', {**body, 'path': 'hello.txt', 'staged': False}, True)
    call('/git/commit-file-diff', {**body, 'path': 'hello.txt', 'commit': head}, True)
    call('/git/commit-files', {**body, 'commit': head}, True)
    call('/git/discard-untracked', {**body, 'paths': ['../outside']}, False)
    call('/git/discard-untracked', {**body, 'paths': ['hello.txt']}, False)
    call('/git/discard-untracked', {**body, 'paths': ['untracked.txt']}, True)
    assert not (gitdir / 'untracked.txt').exists()
    job = call('/git/run', {**body, 'command': 'status'}, True)['jobId']
    for _ in range(100):
        result = call('/git/status', {'jobId': job}, True)
        if result['status']['state'] in ['done', 'failed', 'cancelled']: break
        time.sleep(.05)
    assert result['status']['state'] == 'done', result
    call('/git/status', {'jobId': 99999999}, False)
    call('/git/cancel', {'jobId': 99999999}, False)
    call('/git/profile/save', {'name': 'Web IDE QA', 'email': 'qa@example.invalid'})
    call('/git/profile/get')
    call('/git/auth/match', {'url': 'https://example.invalid/qa/repo.git'}, True)
    call('/git/auth/save', {'host': 'example.invalid', 'label': 'Disposable QA', 'username': 'qa', 'token': 'not-a-real-token'}, True)
    items = call('/git/auth/list', success=True)['items']; item = next(x for x in items if x['label'] == 'Disposable QA')
    call('/git/auth/match', {'url': 'https://example.invalid/qa/repo.git'}, True)
    call('/git/auth/delete', {'id': item['id']}, True)
    call('/git/auth/test', {'id': 99999999}, False)


scenario('isolated Git status/diff/history/jobs and credential CRUD without external remotes', git)


def agents():
    config = {'name': 'Disposable QA model', 'url': 'http://127.0.0.1:18889', 'model': 'qa-model', 'key': 'not-a-real-key', 'contextWindow': 8192, 'customOptions': '{}'}
    call('/llm/create', config, True)
    items = call('/llm/list', success=True)['items']; item = next(x for x in items if x['name'] == config['name'])
    call('/llm/update', {**config, 'id': item['id'], 'temperature': .2}, True)
    call('/llm/update', {**config, 'id': item['id'], 'customOptions': '[]'}, False)
    call('/llm/delete', {'id': item['id']}, True)
    session = call('/agent/session/create', {'projectRoot': str(work), 'title': 'Disposable QA session'}, True)['session']
    sid = session['id']
    call('/agent/session/get', {'sessionId': sid}, True)
    call('/agent/session/create-sub', {'parentSessionId': sid, 'title': 'Disposable QA child'}, True)
    call('/agent/session/mode', {'sessionId': sid, 'workMode': 'plan'}, True)
    call('/agent/session/mode', {'sessionId': sid, 'workMode': 'invalid'}, False)
    call('/agent/task/status', {'sessionId': sid}, True)
    call('/agent/task/running', success=True)
    call('/agent/project-root', {'file': path('sample.lua')})
    call('/agent/runtime/status', success=True)
    for endpoint, body in {
        '/agent/vision/asset': {'sessionId': sid, 'path': path('missing.png')},
        '/agent/session/send': {'sessionId': -1, 'prompt': 'do not send'},
        '/agent/session/send-local': {'sessionId': sid, 'prompt': 'do not send', 'localAgentConfigId': -1},
        '/agent/session/continue': {'sessionId': -1},
        '/agent/session/finish-handoff': {'sessionId': -1},
        '/agent/session/resend': {'sessionId': -1, 'messageId': -1, 'prompt': 'do not send'},
        '/agent/session/questionnaire/respond': {'sessionId': sid, 'questionnaireId': -1, 'answers': []},
        '/agent/session/questionnaire/cancel': {'sessionId': sid, 'questionnaireId': -1},
        '/agent/checkpoint/list': {'sessionId': sid},
        '/agent/checkpoint/diff': {'sessionId': sid, 'checkpointId': -1},
        '/agent/checkpoint/rollback': {'sessionId': sid, 'checkpointId': -1},
        '/agent/task/diff': {'sessionId': sid, 'taskId': -1},
        '/agent/task/rollback': {'sessionId': sid, 'taskId': -1},
    }.items(): call(endpoint, body, False)
    call('/agent/session/local/info', {'sessionId': sid}, True)
    call('/agent/session/local/new', {'sessionId': sid})
    call('/agent/task/stop', {'sessionId': sid})
    call('/local-agent/list', success=True)
    call('/local-agent/save', {'name': ''}, False)
    call('/local-agent/delete', {'id': -1})
    call('/local-agent/verify', {'id': -1, 'projectRoot': str(work)}, False)


scenario('LLM configuration, Agent sessions/subsessions/modes and invalid task boundaries', agents)


def model_roundtrip():
    received = []
    class Model(BaseHTTPRequestHandler):
        def log_message(self, *_):
            pass
        def do_POST(self):
            body = json.loads(self.rfile.read(int(self.headers.get('Content-Length', '0'))))
            received.append(self.path)
            if body.get('stream'):
                chunks = [
                    {'id': 'qa-completion', 'choices': [{'index': 0, 'delta': {'role': 'assistant', 'content': 'QA_MODEL_OK'}, 'finish_reason': None}]},
                    {'id': 'qa-completion', 'choices': [{'index': 0, 'delta': {}, 'finish_reason': 'stop'}], 'usage': {'prompt_tokens': 10, 'completion_tokens': 3, 'total_tokens': 13}},
                ]
                payload = (''.join('data: ' + json.dumps(x) + '\n\n' for x in chunks) + 'data: [DONE]\n\n').encode()
                mime = 'text/event-stream'
            else:
                payload = json.dumps({'id': 'qa-completion', 'choices': [{'index': 0, 'message': {'role': 'assistant', 'content': 'QA_MODEL_OK'}, 'finish_reason': 'stop'}], 'usage': {'prompt_tokens': 10, 'completion_tokens': 3, 'total_tokens': 13}}).encode()
                mime = 'application/json'
            self.send_response(200); self.send_header('Content-Type', mime); self.send_header('Content-Length', str(len(payload))); self.end_headers(); self.wfile.write(payload)
    server = ThreadingHTTPServer(('127.0.0.1', 0), Model)
    worker = threading.Thread(target=server.serve_forever, daemon=True); worker.start()
    cid = None
    try:
        config = {'name': 'Loopback QA model', 'url': f'http://127.0.0.1:{server.server_port}/v1/chat/completions', 'model': 'qa-model', 'key': 'not-a-real-key', 'contextWindow': 262144, 'maxTokens': 1024, 'customOptions': json.dumps({'auxiliaryOptions': {'model': 'qa-model', 'max_tokens': 1024}})}
        call('/llm/create', config, True)
        cid = next(x['id'] for x in call('/llm/list', success=True)['items'] if x['name'] == config['name'])
        project = work / 'model-project'; project.mkdir()
        (project / 'init.lua').write_text('print("QA model project")')
        sid = call('/agent/session/create', {'projectRoot': str(project), 'title': 'Loopback model QA'}, True)['session']['id']
        call('/agent/session/send', {'sessionId': sid, 'prompt': 'Reply with QA_MODEL_OK. Do not use tools.', 'llmConfigId': cid}, True)
        for _ in range(200):
            state = call('/agent/task/status', {'sessionId': sid}, True)
            if state['session'].get('currentTaskStatus') not in ['RUNNING', 'PENDING']:
                break
            time.sleep(.1)
        assert received, 'The configured loopback model was never called'
        assert 'QA_MODEL_OK' in json.dumps(state['messages']), state
        assert state['session']['currentTaskStatus'] == 'DONE', state['session']
        call('/agent/checkpoint/list', {'sessionId': sid}, True)
        call('/agent/task/diff', {'sessionId': sid, 'taskId': state['session']['currentTaskId']}, False)  # A text-only reply creates no change set.
    finally:
        if cid is not None: call('/llm/delete', {'id': cid}, True)
        server.shutdown(); server.server_close(); worker.join(timeout=3)


scenario('real Agent request, streamed loopback model response, persistence and task completion', model_roundtrip)


report = {'routes': len(routes), 'checks': checks, 'failures': failures, 'coverage': {endpoint: coverage[endpoint] for _, endpoint in routes}, 'workspace': str(work)}
args.report.parent.mkdir(parents=True, exist_ok=True)
args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2))
print(f'{checks} JSON assertions, {sum(bool(coverage[p]) for _,p in routes)}/{len(routes)} route coverage, {len(failures)} failed scenarios', flush=True)
raise SystemExit(bool(failures))
