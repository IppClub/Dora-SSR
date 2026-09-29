import assert from 'node:assert/strict';
import {mkdtemp} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import {join, resolve} from 'node:path';
import {spawn} from 'node:child_process';
import {readFile} from 'node:fs/promises';

const repo = resolve(import.meta.dirname, '../../..');
const source = await readFile(join(repo, 'Assets/Script/Lib/Agent/LocalAgent.ts'), 'utf8');
const generatedSource = await readFile(join(repo, 'Assets/Script/Lib/Agent/LocalAgent.lua'), 'utf8');
const session = await readFile(join(repo, 'Assets/Script/Lib/Agent/Session.ts'), 'utf8');
const webServer = await readFile(join(repo, 'Assets/Script/Dev/WebServer.yue'), 'utf8');
const agentPanel = await readFile(join(repo, 'Tools/dora-dora/src/AgentPanel.tsx'), 'utf8');
const agentComposer = await readFile(join(repo, 'Tools/dora-dora/src/AgentComposer.tsx'), 'utf8');
const agentStepList = await readFile(join(repo, 'Tools/dora-dora/src/AgentStepList.tsx'), 'utf8');
const llmConfigDialog = await readFile(join(repo, 'Tools/dora-dora/src/LLMConfigDialog.tsx'), 'utf8');
const i18n = await readFile(join(repo, 'Tools/dora-dora/src/i18n.ts'), 'utf8');
const bindingHeader = await readFile(join(repo, 'Tools/tolua++/Dora.h'), 'utf8');
const doraTypes = await readFile(join(repo, 'Assets/Script/Lib/Dora/en/Dora.d.ts'), 'utf8');
const processBridge = await readFile(join(repo, 'Source/Lua/LuaManual.cpp'), 'utf8');
const xrtBridge = await readFile(join(repo, 'Source/Http/XrtNetwork.c'), 'utf8');
const commandSkill = await readFile(join(repo, 'Assets/Doc/local-agent-skills/dora-agent-command/SKILL.md'), 'utf8');
const musicSkill = await readFile(join(repo, 'Assets/Doc/local-agent-skills/music-generation/SKILL.md'), 'utf8');

assert.match(source, /"opencode" \| "codex" \| "zcode" \| "claude-code"/);
assert.match(source, /\["run", "--format", "json", "--auto"/);
assert.match(source, /\["exec", "--json", "--dangerously-bypass-approvals-and-sandbox"/);
assert.match(source, /\["--prompt", prompt, "--json", "--mode", "yolo"/);
assert.match(source, /\["-p", "--output-format", "stream-json", "--verbose", "--dangerously-skip-permissions"/);
assert.match(source, /provider === "claude-code" && message/);
assert.match(source, /blockType === "tool_use"/);
assert.match(source, /blockType === "tool_result"/);
assert.match(source, /eventType === "result"/);
assert.match(source, /event\.raw\.is_error === true/);
assert.match(source, /Path\(projectRoot, "\.agents", "skills", skill\.name\)/);
assert.match(source, /Path\(projectRoot, "\.claude", "skills", skill\.name\)/);
assert.match(source, /const SKILL_VERSION = 5/);
assert.match(source, /function buildSkillContent\(\)/);
assert.match(source, /function ensureSkills\(/);
assert.match(source, /"dora-agent-command"/);
assert.match(source, /"music-generation"/);
assert.match(source, /GeneralUserGS-Presets\.md/);
assert.match(source, /Dora project skills available: dora-engine-coding, dora-agent-command, music-generation/);
assert.match(source, /App\.executablePath/);
assert.match(source, /Content\.assetPath/);
assert.match(source, /--asset \$\{quoteCommandArg\(assetPath\)\} cli/);
assert.match(source, /dora cli agent preview/);
assert.match(source, /existing\.includes\("<!-- dora-managed-skill:v"\)/);
assert.match(source, /For this turn, invoke Dora CLI only with this exact prefix/);
assert.match(source, /local-agent-bin/);
assert.match(source, /program: "\/bin\/chmod", args: \["700", shimPath\]/);
assert.match(source, /PATH: inheritedPath === "" \? shimDir/);
assert.match(source, /This project-scoped Dora command only supports: dora cli/);
assert.match(source, /if \[ "\$1" != "cli" \]/);
assert.match(source, /spec\.env = doraCommand\.env/);
assert.match(generatedSource, /local SKILL_VERSION = 5/);
assert.match(generatedSource, /local executablePath = App\.executablePath/);
assert.match(generatedSource, /For this turn, invoke Dora CLI only with this exact prefix/);
assert.match(bindingHeader, /string executablePath/);
assert.match(doraTypes, /readonly executablePath: string/);
assert.match(doraTypes, /env\?: Record<string, string>/);
assert.match(processBridge, /lua_getfield\(L, 2, "env"\)/);
assert.match(xrtBridge, /config\.arrEnv = \(str\*\)env/);
assert.match(source, /Stored local Agent session is unavailable; retrying once with a new session/);
assert.match(source, /provider === "zcode" && typeof record\.response === "string"/);
assert.match(source, /Started \$\{config\.name\} \(\$\{config\.provider\}\)/);
assert.match(source, /its CLI returns the structured message when the task completes/);
assert.match(source, /ZCode is still running \(\$\{elapsed\}s\); waiting for its buffered response/);
assert.match(source, /config\.provider === "zcode" \? 1800 : 900/);
assert.match(source, /monitorHost\.addTo\(Director\.systemUI\)/);
assert.match(source, /monitorHost\.once\(\(\) =>/);
assert.match(source, /provider === "opencode" && eventType === "tool_use"/);
assert.match(source, /provider === "codex" && itemType === "mcp_tool_call"/);
assert.match(source, /details\.push\(`arguments: \$\{encodeJson\(itemRecord\.arguments\)\}`\)/);
assert.match(source, /details\.push\(`input: \$\{encodeJson\(state\.input\)\}`\)/);
assert.match(source, /\.dora-local-agent-verify-/);
assert.match(source, /Content\.remove\(cwd\)/);
assert.match(session, /sendLocalPrompt/);
assert.match(session, /local_agent_message/);
assert.match(session, /activeLocalAgentControls\[session\.currentTaskId\]/);
assert.match(session, /if \(!completedSynchronously\) activeLocalAgentControls\[taskId\] = control/);
assert.match(session, /previous\.kind === event\.kind && previous\.text === text/);
assert.match(session, /if \(event\.kind === "assistant"\) assistant = text/);
assert.doesNotMatch(session, /tool content truncated/);
assert.match(webServer, /"\/agent\/session\/send-local"/);
assert.doesNotMatch(agentPanel, /Local Agent · full permissions/);
assert.doesNotMatch(agentPanel, /agentSessionLocalInfo\(/);
assert.match(agentPanel, /newSessionLabel=\{localBackendSelected \? t\("agent\.newSession"\)/);
assert.match(agentPanel, /hideContextUsage=\{localBackendSelected\}/);
assert.match(agentPanel, /currentTaskUsesLocalAgent/);
assert.match(agentPanel, /localAgentCompletionSummary/);
assert.match(agentPanel, /data-local-agent-completion-summary="true"/);
assert.match(agentPanel, /messageGroups\.currentSummaryMessages/);
assert.match(agentComposer, /data-agent-new-session="true"/);
assert.match(agentComposer, /hideContextUsage\?:boolean/);
assert.match(agentComposer, /dora-hidden-context-usage/);
assert.match(agentComposer, /justifyContent:'flex-start'/);
assert.doesNotMatch(agentComposer, /pr:compact\?20:23/);
assert.match(agentComposer, /AddCommentOutlinedIcon/);
assert.match(agentComposer, /color:Color\.TextSecondary/);
assert.match(agentComposer, /newSessionHint/);
assert.match(i18n, /newSession: "新会话"/);
assert.match(i18n, /localAgentCompleted: "Agent 任务已完成"/);
assert.match(llmConfigDialog, /const LOCAL_AGENT_TEMPLATES/);
assert.match(llmConfigDialog, /extraArgs: \['--skip-git-repo-check'\]/);
assert.match(llmConfigDialog, /'claude-code': \{/);
assert.match(llmConfigDialog, /executable: 'claude'/);
assert.match(llmConfigDialog, /data-local-agent-card=\{provider\}/);
assert.match(llmConfigDialog, /verifyAndActivateLocal/);
assert.doesNotMatch(llmConfigDialog, /const localColumns/);
assert.match(llmConfigDialog, /applyLocalAgentTemplate/);
assert.match(llmConfigDialog, /localCommandPreview/);
assert.doesNotMatch(llmConfigDialog, />Agent Configuration</);
assert.doesNotMatch(llmConfigDialog, /label="Provider"/);
assert.match(i18n, /localTemplate: "Agent 模板"/);
assert.match(i18n, /localCommandPreviewHint: "Dora 会自动添加这些必需参数/);
assert.match(i18n, /localVerifyActivate: "验证并激活"/);
assert.match(agentPanel, /localId !== undefined\s*\? await stopProjectRunBeforeAgent\(\)/);
assert.match(agentStepList, /data-local-agent-events="true"/);
assert.match(agentStepList, /function LocalAgentEventRows/);
assert.match(agentStepList, /data-local-agent-event-kind=\{event\.kind\}/);
assert.match(agentStepList, /getLocalAgentDisplayEvents\(step\)/);
assert.doesNotMatch(agentStepList, /events\.splice\(i, 1\)/);
assert.match(agentStepList, /data-local-agent-tool-toggle="true"/);
assert.match(agentStepList, /collapsedPreview/);
assert.match(agentStepList, /<Collapse in=\{toolCallOpen\}/);
assert.match(agentStepList, /event\.kind === "activity" && event\.text\.includes\('\"mcp_tool_call\"'\)/);
assert.doesNotMatch(agentStepList, /tool content truncated/);
assert.match(agentStepList, /\{index \+ 1\}/);
assert.doesNotMatch(agentStepList, /\{step\.step\}\.\{index \+ 1\}/);
assert.match(agentStepList, /data-local-agent-transcript="true"/);
assert.match(webServer, /postSchedule "\/agent\/command"/);
assert.match(webServer, /import "Agent\.Tool\.Command" as AgentCommand/);
assert.match(webServer, /import "Agent\.Tool\.Validation" as AgentValidation/);
assert.match(commandSkill, /dora cli agent command -p <project> --input \.agent\/command\.json/);
assert.match(commandSkill, /mode.*lua/);
assert.match(commandSkill, /mode.*git/);
assert.match(musicSkill, /requireProjectModule\('Agent\.Gen\.Music'\)/);
assert.match(musicSkill, /references\/Music\.d\.ts/);

function run(program, args, cwd, timeoutMs = 180_000) {
	return new Promise((resolveRun, reject) => {
		const child = spawn(program, args, {cwd, stdio: ['ignore', 'pipe', 'pipe'], env: process.env});
		let stdout = '';
		let stderr = '';
		const timer = setTimeout(() => {
			child.kill('SIGTERM');
			setTimeout(() => child.kill('SIGKILL'), 1500).unref();
		}, timeoutMs);
		child.stdout.on('data', chunk => { stdout = (stdout + chunk).slice(-4 * 1024 * 1024); });
		child.stderr.on('data', chunk => { stderr = (stderr + chunk).slice(-4 * 1024 * 1024); });
		child.on('error', reject);
		child.on('close', code => { clearTimeout(timer); resolveRun({code, stdout, stderr}); });
	});
}

function jsonValues(text) {
	const result = [];
	for (const line of text.split(/\r?\n/)) {
		if (!line.trim()) continue;
		try { result.push(JSON.parse(line)); } catch { /* diagnostics can be plain text */ }
	}
	if (result.length === 0) {
		try { result.push(JSON.parse(text)); } catch { /* no structured result */ }
	}
	return result;
}

function findSessionId(value) {
	if (!value || typeof value !== 'object') return undefined;
	for (const key of ['thread_id', 'threadId', 'session_id', 'sessionId', 'sessionID']) {
		if (typeof value[key] === 'string' && value[key]) return value[key];
	}
	for (const nested of Object.values(value)) {
		const found = findSessionId(nested);
		if (found) return found;
	}
	return undefined;
}

if (process.argv.includes('--real')) {
	const cwd = await mkdtemp(join(tmpdir(), 'dora-local-agent-'));
	const prompt = 'Reply with exactly DORA_LOCAL_AGENT_OK. Do not use tools and do not edit files.';
	const resumePrompt = 'Reply with exactly DORA_LOCAL_AGENT_RESUME_OK. Do not use tools and do not edit files.';
	const agents = [
		{
			name: 'codex',
			fresh: ['exec', '--json', '--dangerously-bypass-approvals-and-sandbox', '--skip-git-repo-check', '-C', cwd, prompt],
			resume: id => ['exec', 'resume', '--json', '--dangerously-bypass-approvals-and-sandbox', '--skip-git-repo-check', id, resumePrompt],
		},
		{
			name: 'opencode',
			fresh: ['run', '--format', 'json', '--auto', '--dir', cwd, prompt],
			resume: id => ['run', '--format', 'json', '--auto', '--dir', cwd, '--session', id, resumePrompt],
		},
		{
			name: 'zcode',
			fresh: ['--prompt', prompt, '--json', '--mode', 'yolo', '--cwd', cwd],
			resume: id => ['--prompt', resumePrompt, '--json', '--mode', 'yolo', '--cwd', cwd, '--resume', id],
		},
		{
			name: 'claude',
			fresh: ['-p', '--output-format', 'stream-json', '--verbose', '--dangerously-skip-permissions', prompt],
			resume: id => ['-p', '--output-format', 'stream-json', '--verbose', '--dangerously-skip-permissions', '--resume', id, resumePrompt],
		},
	];
	for (const agent of agents) {
		const fresh = await run(agent.name, agent.fresh, cwd);
		assert.equal(fresh.code, 0, `${agent.name} fresh failed: ${fresh.stderr || fresh.stdout}`);
		assert.match(fresh.stdout + fresh.stderr, /DORA_LOCAL_AGENT_OK/, `${agent.name} did not return acceptance marker`);
		const values = jsonValues(fresh.stdout);
		assert.ok(values.length > 0, `${agent.name} did not emit structured output`);
		const sessionId = values.map(findSessionId).find(Boolean);
		assert.ok(sessionId, `${agent.name} did not expose a session id`);
		const resumed = await run(agent.name, agent.resume(sessionId), cwd);
		assert.equal(resumed.code, 0, `${agent.name} resume failed: ${resumed.stderr || resumed.stdout}`);
		assert.match(resumed.stdout + resumed.stderr, /DORA_LOCAL_AGENT_RESUME_OK/, `${agent.name} did not resume the session`);
		console.log(`${agent.name}: fresh+resume passed (${sessionId.slice(0, 12)}…)`);
	}
}

console.log('local Agent backend contracts passed');
