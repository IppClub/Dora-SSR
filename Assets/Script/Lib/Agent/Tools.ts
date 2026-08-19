// @preview-file off clear
export { planTruncatedEditRecovery } from 'Agent/Tool/TruncatedEditRecovery';
export type { TruncatedEditRecoveryNotice, TruncatedEditRecoveryPlan } from 'Agent/Tool/TruncatedEditRecovery';
export { sendWebIDEFileUpdate, sendWebIDERefreshTree } from 'Agent/Tool/WebIDESync';
export {
	getLogs,
	listFiles,
	readFile,
	readFileRaw,
	inspectWorkspaceTextTarget,
	searchFiles,
} from 'Agent/Tool/Workspace';
export type {
	ListFilesResult,
	GetLogsResult,
	ReadFileResult,
	WorkspaceTextTargetResult,
	SearchFilesToolResult,
} from 'Agent/Tool/Workspace';

export { searchDoraDoc, searchDoraDocHttp, readDoraDoc } from 'Agent/Tool/DoraDocSearch';
export type {
	DoraDocLanguage,
	DoraDocSearchType,
	DoraDocProgrammingLanguage,
	DoraDocSearchHit,
	DoraDocSearchResult,
	DoraDocReadResult,
} from 'Agent/Tool/DoraDocSearch';


export {
	createTask,
	setTaskStatus,
	listCheckpointsForTasks,
	listCheckpoints,
	getCheckpoint,
	summarizeTaskChangeSet,
	getTaskChangeSetDiff,
	applyFileChanges,
	deleteFile,
	rollbackCheckpoint,
	rollbackTaskChangeSet,
	getCheckpointEntriesForDebug,
	getCheckpointDiff,
} from 'Agent/Tool/Checkpoint';
export type {
	AgentTaskStatus,
	AgentTaskWorkMode,
	CheckpointStatus,
	FileOp,
	FileChange,
	ApplyChangesOptions,
	CreateTaskResult,
	ApplyChangesResult,
	DeleteFileResult,
	RollbackResult,
	TaskRollbackResult,
	CheckpointDiffFile,
	CheckpointDiffResult,
	CheckpointItem,
	TaskChangeSetFile,
	TaskChangeSetSummary,
} from 'Agent/Tool/Checkpoint';

export { build, runSingleTsTranspile } from 'Agent/Tool/Build';
export type { BuildMessage, BuildResult } from 'Agent/Tool/Build';

export { fetchUrl } from 'Agent/Tool/Fetch';
export type { FetchUrlMode, FetchUrlProgress, FetchUrlResult } from 'Agent/Tool/Fetch';

export { executeCommand } from 'Agent/Tool/Command';
export type {
	ExecuteCommandMode,
	ExecuteCommandProgress,
	ExecuteCommandResult,
} from 'Agent/Tool/Command';
