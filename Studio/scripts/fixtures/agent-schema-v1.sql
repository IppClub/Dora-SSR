-- Historical schema v1, with no message inbox.
CREATE TABLE agent.AgentSession(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		project_root TEXT NOT NULL,
		title TEXT NOT NULL DEFAULT '',
		kind TEXT NOT NULL DEFAULT 'main',
		root_session_id INTEGER NOT NULL DEFAULT 0,
		parent_session_id INTEGER,
		memory_scope TEXT NOT NULL DEFAULT 'main',
		status TEXT NOT NULL DEFAULT 'IDLE',
		current_task_id INTEGER,
		current_task_status TEXT NOT NULL DEFAULT 'IDLE',
		created_at INTEGER NOT NULL,
		updated_at INTEGER NOT NULL,
		metrics_json TEXT NOT NULL DEFAULT '',
		work_mode TEXT NOT NULL DEFAULT 'code'
	);
CREATE INDEX agent.idx_agent_session_project_root
		ON AgentSession(project_root, updated_at DESC);
CREATE TABLE agent.AgentSessionMessage(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		session_id INTEGER NOT NULL,
		task_id INTEGER,
		role TEXT NOT NULL,
		content TEXT NOT NULL DEFAULT '',
		display_content TEXT NOT NULL DEFAULT '',
		created_at INTEGER NOT NULL,
		updated_at INTEGER NOT NULL
	);
CREATE INDEX agent.idx_agent_session_message_sid_id
		ON AgentSessionMessage(session_id, id);
CREATE TABLE agent.AgentSessionStep(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		session_id INTEGER NOT NULL,
		task_id INTEGER NOT NULL,
		step INTEGER NOT NULL,
		tool TEXT NOT NULL DEFAULT '',
		status TEXT NOT NULL DEFAULT 'PENDING',
		reason TEXT NOT NULL DEFAULT '',
		reasoning_content TEXT NOT NULL DEFAULT '',
		params_json TEXT NOT NULL DEFAULT '',
		result_json TEXT NOT NULL DEFAULT '',
		checkpoint_id INTEGER,
		checkpoint_seq INTEGER,
		files_json TEXT NOT NULL DEFAULT '',
		created_at INTEGER NOT NULL,
		updated_at INTEGER NOT NULL
	);
CREATE UNIQUE INDEX agent.idx_agent_session_step_unique
		ON AgentSessionStep(session_id, task_id, step);
CREATE INDEX agent.idx_agent_session_step_sid_task_step
		ON AgentSessionStep(session_id, task_id, step);
CREATE TABLE agent.AgentTask(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		status TEXT NOT NULL,
		prompt TEXT NOT NULL DEFAULT '',
		head_seq INTEGER NOT NULL DEFAULT 0,
		work_mode TEXT NOT NULL DEFAULT 'code',
		created_at INTEGER NOT NULL,
		updated_at INTEGER NOT NULL
	);
CREATE TABLE agent.AgentCheckpoint(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		task_id INTEGER NOT NULL,
		seq INTEGER NOT NULL,
		status TEXT NOT NULL,
		summary TEXT NOT NULL DEFAULT '',
		tool_name TEXT NOT NULL DEFAULT '',
		created_at INTEGER NOT NULL,
		applied_at INTEGER,
		reverted_at INTEGER
	);
CREATE INDEX agent.idx_agent_cp_task_seq
		ON AgentCheckpoint(task_id, seq);
CREATE TABLE agent.AgentCheckpointEntry(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		checkpoint_id INTEGER NOT NULL,
		ord INTEGER NOT NULL,
		path TEXT NOT NULL,
		op TEXT NOT NULL,
		before_exists INTEGER NOT NULL,
		before_data BLOB,
		after_exists INTEGER NOT NULL,
		after_data BLOB,
		bytes_before INTEGER NOT NULL DEFAULT 0,
		bytes_after INTEGER NOT NULL DEFAULT 0
	);
CREATE INDEX agent.idx_agent_entry_cp_ord
		ON AgentCheckpointEntry(checkpoint_id, ord);
CREATE TABLE agent.AgentTaskReference(
		owner_task_id INTEGER NOT NULL,
		target_task_id INTEGER NOT NULL,
		kind TEXT NOT NULL,
		created_at INTEGER NOT NULL,
		PRIMARY KEY(owner_task_id, target_task_id, kind)
	);
CREATE INDEX agent.idx_agent_task_ref_target
		ON AgentTaskReference(target_task_id);
PRAGMA agent.user_version = 1;
