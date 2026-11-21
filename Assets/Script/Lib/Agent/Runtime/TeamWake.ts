// Team agent wake-context assembly. Lives in its own module to keep Session.lua's
// main-chunk local count under the 200-local limit.
import { Content, Path } from 'Dora';

export const TEAM_AGENT_TYPES = ['audio', 'visual', 'level', 'test'];

export function buildTeamWakeContext(projectRoot: string, agentType: string): string {
	if (TEAM_AGENT_TYPES.indexOf(agentType) < 0) return '';
	const readIfExists = (path: string): string => {
		if (!Content.exist(path)) return '';
		const text = Content.load(path) as string | undefined;
		return typeof text === 'string' ? text : '';
	};
	const truncateHead = (text: string, maxLines: number, maxChars: number): string => {
		if (text === '') return '';
		const lines = text.split('\n');
		const out: string[] = [];
		let total = 0;
		for (const line of lines) {
			total += line.length + 1;
			if (out.length >= maxLines || total > maxChars) {
				out.push('... (truncated)');
				break;
			}
			out.push(line);
		}
		return out.join('\n');
	};
	const sections: string[] = [];
	const profile = readIfExists(Path(projectRoot, '.agent', 'teams', agentType, 'PROFILE.md'));
	if (profile.trim() !== '') {
		sections.push(`# Team profile (.agent/teams/${agentType}/PROFILE.md)\n${truncateHead(profile.trim(), 60, 6000)}`);
	}
	const assets = readIfExists(Path(projectRoot, '.agent', 'main', 'ASSETS.md'));
	if (assets.trim() !== '') {
		sections.push(`# Shared asset state (.agent/main/ASSETS.md)\n${truncateHead(assets.trim(), 60, 6000)}`);
	}
	const memoryIndex = readIfExists(Path(projectRoot, '.agent', 'teams', agentType, 'memory', 'MEMORY.md'));
	if (memoryIndex.trim() !== '') {
		sections.push(`# Team memory index (.agent/teams/${agentType}/memory/MEMORY.md; topic files live next to it, read on demand)\n${truncateHead(memoryIndex.trim(), 40, 4000)}`);
	}
	sections.push(`# Team memory protocol
You are a persistent team agent. This trigger is one engagement; the team memory in .agent/teams/${agentType}/memory/ survives across triggers.
MEMORY.md is an index with one line per entry; details belong in topic files next to it.
Write a memory only when one of these triggers fires; most runs should write nothing:
- feedback: the user (often via the parent agent's task) corrected or confirmed a taste, style, or approach decision
- project: a decision, constraint, or rationale not derivable from project files, ASSETS.md, or PROFILE.md
- reference: where to find external resources (API keys, libraries, endpoints)
Never store anything derivable from project files. When writing: append exactly one line to MEMORY.md, put details in a topic file, and if the index exceeds 40 lines, merge or drop stale entries first.`);
	return sections.join('\n\n---\n\n');
}
