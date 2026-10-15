import type * as Service from './Service';

export interface AgentSessionSnapshot {
	session: Service.AgentSession | null;
	relatedSessions: Service.AgentSession[];
	spawnInfo: Service.AgentSessionSpawnInfo | null;
	messages: Service.AgentSessionMessage[];
	steps: Service.AgentSessionStep[];
	checkpoints: Service.AgentCheckpointItem[];
	pendingQuestionnaire: Service.AgentQuestionnaire | null;
	workMode: "code" | "plan";
	hasActivePlan: boolean;
}

const MAX_SNAPSHOTS = 24;
const snapshots = new Map<number, AgentSessionSnapshot>();

const copySnapshot = (snapshot: AgentSessionSnapshot): AgentSessionSnapshot => ({
	...snapshot,
	relatedSessions: [...snapshot.relatedSessions],
	messages: [...snapshot.messages],
	steps: [...snapshot.steps],
	checkpoints: [...snapshot.checkpoints],
});

export const getAgentSessionSnapshot = (sessionId: number) => {
	const snapshot = snapshots.get(sessionId);
	if (!snapshot) return null;
	snapshots.delete(sessionId);
	snapshots.set(sessionId, snapshot);
	return copySnapshot(snapshot);
};

export const setAgentSessionSnapshot = (
	sessionId: number,
	snapshot: AgentSessionSnapshot,
) => {
	snapshots.delete(sessionId);
	snapshots.set(sessionId, copySnapshot(snapshot));
	while (snapshots.size > MAX_SNAPSHOTS) {
		const oldestSessionId = snapshots.keys().next().value;
		if (oldestSessionId === undefined) break;
		snapshots.delete(oldestSessionId);
	}
};

export const deleteAgentSessionSnapshot = (sessionId: number) => {
	snapshots.delete(sessionId);
};

export const clearAgentSessionSnapshotsForTest = () => {
	snapshots.clear();
};
