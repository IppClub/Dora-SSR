#!/usr/bin/env python3
"""Opt-in real provider acceptance using existing configuration, never logging keys.

Requires an isolated Web IDE instance and explicit authorization for paid calls.
Only fixture projects and temporary copies of model configurations are modified.
"""
import argparse
import http.client
import json
from pathlib import Path
import sqlite3
import time
import urllib.parse
import uuid

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--config-db', type=Path, required=True)
p.add_argument('--app-root', type=Path, required=True)
p.add_argument('--report', type=Path, required=True)
p.add_argument('--allow-paid', action='store_true', required=True)
p.add_argument('--model-id', type=int, action='append')
a = p.parse_args()
secrets = []
results = []
a.report.parent.mkdir(parents=True, exist_ok=True)


def redact(value):
    text = str(value)
    for key in secrets:
        if key: text = text.replace(key, '[redacted]')
    return text


def call(path, body=None):
    conn = http.client.HTTPConnection('127.0.0.1', 8866, timeout=30)
    try:
        conn.request('POST', path, json.dumps(body or {}, ensure_ascii=False).encode(), {'Content-Type': 'application/json', 'Origin': 'http://127.0.0.1:8866'})
        r = conn.getresponse(); data = r.read()
        assert r.status == 200, (path, r.status)
        result = json.loads(data)
        assert result.get('success'), (path, result.get('message', 'request failed'))
        return result
    finally: conn.close()


status = call('/status')
app = Path(status['appPath'])
assert (a.app_root / '.dora-webide-acceptance').read_text().strip() == 'disposable'
assert app.resolve().is_relative_to(a.app_root.resolve()) and not app.resolve().is_relative_to(Path.home())
assert Path(status['writablePath']).resolve() == app.resolve()
db = sqlite3.connect('file:' + urllib.parse.quote(str(a.config_db.resolve())) + '?mode=ro', uri=True)
db.row_factory = sqlite3.Row
models = [dict(row) for row in db.execute('SELECT * FROM LLMConfig WHERE active = 1 ORDER BY updated_at DESC') if not a.model_id or row['id'] in a.model_id]
db.close()
assert models, 'No selected active model configuration'
secrets = [m['api_key'] for m in models]
for model_index, model in enumerate(models):
    cid = sid = None
    started = time.monotonic()
    result = {'name': model['name'], 'model': model['model'], 'provider': urllib.parse.urlsplit(model['url']).hostname}
    print('START', model['name'], flush=True)
    try:
        name = 'Paid acceptance ' + uuid.uuid4().hex[:8]
        config = {'name': name, 'url': model['url'], 'model': model['model'], 'key': model['api_key'], 'contextWindow': model['context_window'], 'temperature': model['temperature'], 'maxTokens': 4096, 'reasoningEffort': model['reasoning_effort'], 'customOptions': model['custom_options'], 'supportsFunctionCalling': bool(model['supports_function_calling'])}
        call('/llm/create', config)
        cid = next(x['id'] for x in call('/llm/list').get('items', []) if x['name'] == name)
        project = app / ('paid-qa-' + uuid.uuid4().hex[:8]); project.mkdir()
        (project / 'init.lua').write_text('print("Disposable API acceptance")\n')
        sid = call('/agent/session/create', {'projectRoot': str(project), 'title': name})['session']['id']
        call('/agent/session/send', {'sessionId': sid, 'prompt': '这是一次隔离验收。请调用 edit_file，仅创建项目根目录的 qa-paid-api.txt，内容恰好为 QA_PAID_API_OK。完成后只回复 QA_DONE。无需阅读其它文件、运行项目或执行其它任务。', 'llmConfigId': cid, 'workMode': 'code', 'disabledAgentTools': ['spawn_sub_agent', 'ask_user', 'preview_game', 'execute_command']})
        previous = None
        for _ in range(120):
            state = call('/agent/task/status', {'sessionId': sid})
            phase = state['session'].get('currentTaskStatus')
            if phase != previous: print('STATE', model['name'], phase, flush=True); previous = phase
            if phase not in ['RUNNING', 'PENDING']: break
            time.sleep(1)
        else:
            call('/agent/task/stop', {'sessionId': sid})
            raise AssertionError('Provider task exceeded the 120 second acceptance limit; stop requested')
        result['taskState'] = phase
        assert phase == 'DONE', ('task did not complete', phase)
        output = project / 'qa-paid-api.txt'
        assert output.is_file() and output.read_text().strip() == 'QA_PAID_API_OK', 'Expected tool-created file missing or incorrect'
        assert 'QA_DONE' in json.dumps(state.get('messages', [])), 'Final model response missing'
        task = state['session']['currentTaskId']
        diff = call('/agent/task/diff', {'sessionId': sid, 'taskId': task})
        assert 'qa-paid-api.txt' in json.dumps(diff), 'Tool edit missing from change set'
        checkpoints = call('/agent/checkpoint/list', {'sessionId': sid})
        items = checkpoints.get('checkpoints', [])
        assert items, 'Tool edit did not create a checkpoint'
        checkpoint = items[-1]['id']
        assert 'qa-paid-api.txt' in json.dumps(call('/agent/checkpoint/diff', {'sessionId': sid, 'checkpointId': checkpoint}))
        if model_index == 0:
            call('/agent/checkpoint/rollback', {'sessionId': sid, 'checkpointId': checkpoint})
        else:
            call('/agent/task/rollback', {'sessionId': sid, 'taskId': task})
        assert not output.exists(), 'Rollback did not remove the newly created fixture file'
        assert (project / 'init.lua').read_text() == 'print("Disposable API acceptance")\n', 'Rollback changed an unrelated file'
        result.update(ok=True, project=str(project), sessionId=sid, taskId=task, checkpointCount=len(items), rollbackVerified=True)
        print('PASS', model['name'], 'streaming, edit_file, persistence, change set and DONE', flush=True)
    except Exception as error:
        result.update(ok=False, error=redact(error))
        print('FAIL', model['name'], redact(error), flush=True)
    finally:
        if cid is not None:
            try: call('/llm/delete', {'id': cid})
            except Exception as error: result['cleanupError'] = redact(error)
        result['seconds'] = round(time.monotonic() - started, 2)
        results.append(result)
        a.report.write_text(json.dumps(results, ensure_ascii=False, indent=2))
raise SystemExit(any(not r.get('ok') or r.get('cleanupError') for r in results))
