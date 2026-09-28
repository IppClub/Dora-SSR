import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';
import path from 'node:path';
import {loadAgentTsModule} from './load-agent-ts-module.mjs';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../..');
const {createEntryRunQueue} = await loadAgentTsModule(path.join(root, 'Assets/Script/Lib/Agent/Tool/EntryRunQueue.ts'));

const queue = createEntryRunQueue(3);
assert.deepEqual(queue.enqueue('first'), {success: true, position: 1});
assert.deepEqual(queue.enqueue('second'), {success: true, position: 2});
assert.deepEqual(queue.enqueue('third'), {success: true, position: 3});
assert.deepEqual(queue.enqueue('fourth'), {success: false, message: 'entry run queue is full'});
assert.deepEqual(queue.get('first'), {id: 'first', state: 'queued', position: 1});
assert.equal(queue.tryAcquire('second'), false);
assert.equal(queue.tryAcquire('first'), true);
assert.deepEqual(queue.get('first'), {id: 'first', state: 'running'});
assert.equal(queue.cancel('third'), true);
assert.deepEqual(queue.get('third'), {id: 'third', state: 'missing'});
assert.equal(queue.release('second'), false);
assert.equal(queue.release('first'), true);
assert.equal(queue.tryAcquire('second'), true);
assert.deepEqual(queue.get('second'), {id: 'second', state: 'running'});
assert.equal(queue.release('second'), true);
assert.equal(queue.size(), 0);

const duplicate = createEntryRunQueue();
assert.equal(duplicate.enqueue('').success, false);
assert.equal(duplicate.enqueue('same').success, true);
assert.deepEqual(duplicate.enqueue('same'), {success: false, message: 'entry run is already queued'});
assert.equal(duplicate.tryAcquire('same'), true);
assert.deepEqual(duplicate.enqueue('same'), {success: false, message: 'entry run is already queued'});

console.log('entry run queue tests passed');
