import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const [app, tour, workspace, fileTree, i18n] = await Promise.all([
	readFile(new URL("../src/App.tsx", import.meta.url), "utf8"),
	readFile(new URL("../src/FirstProjectTour.tsx", import.meta.url), "utf8"),
	readFile(new URL("../src/ProjectWorkspacePanel.tsx", import.meta.url), "utf8"),
	readFile(new URL("../src/FileTree.tsx", import.meta.url), "utf8"),
	readFile(new URL("../src/i18n.ts", import.meta.url), "utf8"),
]);

assert.match(
	app,
	/if \(initFile !== null && await openAgentSessionTab\(newFile, true\)\)/,
	"new projects should follow the normal Agent-first route",
);
assert.doesNotMatch(app, /openInEditor/, "the tour must not bypass the Agent-first route");
assert.match(
	app,
	/setFirstProjectTourCurrent\(FirstProjectTourStep\.AgentIntro\)/,
	"project creation should advance the tour to the Agent introduction",
);
assert.match(app, /onOpenEntryFile=\{openFirstProjectEntryFile\}/);
assert.match(app, /onReturnToAgent=\{finishFirstProjectTourAtAgent\}/);

assert.match(tour, /data-first-project-agent-tab="true"/);
assert.match(tour, /placement: compact \? "center" : "bottomRight"/);
assert.match(tour, /onboarding\.useAgent/);
assert.match(tour, /onboarding\.editEntry/);
assert.match(tour, /onboarding\.returnToAgent/);
assert.match(workspace, /data-first-project-agent-panel=/);
assert.match(workspace, /data-first-project-agent-tab=/);

assert.doesNotMatch(fileTree, /firstProjectTourTargetKey/);
assert.doesNotMatch(fileTree, /onFirstProjectTourTargetSelect/);

for (const key of [
	"agentIntroTitle",
	"agentIntroDescription",
	"useAgent",
	"editEntry",
	"returnToAgent",
]) {
	assert.equal(
		i18n.match(new RegExp(`\\b${key}:`, "g"))?.length,
		2,
		`${key} should exist in both locales`,
	);
}

console.log("First project tour Agent-first contract checks passed");
