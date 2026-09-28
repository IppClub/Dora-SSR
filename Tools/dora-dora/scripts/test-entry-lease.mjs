import assert from 'node:assert/strict';
import {fileURLToPath} from 'node:url';
import path from 'node:path';
import {loadAgentTsModule} from './load-agent-ts-module.mjs';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../..');
globalThis.error = message => { throw new Error(message); };
globalThis.tostring = value => value instanceof Error ? value.message : String(value);
const lease = await loadAgentTsModule(path.join(root, 'Assets/Script/Lib/Agent/Tool/EntryLease.ts'));

function createEntry({running = false, runId = 0, stopResult = true} = {}) {
	const state = {running, runId, stopCalls: 0};
	return {
		state,
		getCurrentEntryStatus() {
			return {success: true, running: state.running, runId: state.runId};
		},
		stop() {
			state.stopCalls++;
			if (stopResult) state.running = false;
			return stopResult;
		},
	};
}

const userGame = createEntry({running: true, runId: 7});
assert.equal(lease.acquireEntryLease('agent-1', userGame), true);
assert.equal(userGame.state.stopCalls, 1);
lease.recordEntryLeaseRun('agent-1', userGame);
userGame.state.running = true;
userGame.state.runId = 8;
assert.equal(lease.ownsEntryLease('agent-1', userGame), true);
assert.throws(() => lease.acquireEntryLease('agent-2', userGame), /another Agent tool/);
assert.equal(userGame.state.stopCalls, 1);
assert.equal(lease.releaseEntryLease('agent-1', userGame), undefined);
assert.equal(userGame.state.stopCalls, 2);

const idleEntry = createEntry();
assert.equal(lease.acquireEntryLease('agent-2', idleEntry), false);
assert.equal(idleEntry.state.stopCalls, 0);
assert.equal(lease.releaseEntryLease('agent-2', idleEntry), undefined);

const refusingGame = createEntry({running: true, runId: 3, stopResult: false});
assert.throws(
	() => lease.acquireEntryLease('agent-3', refusingGame),
	/could not interrupt the running user game/,
);
assert.equal(refusingGame.state.stopCalls, 1);

console.log('entry lease priority tests passed');
