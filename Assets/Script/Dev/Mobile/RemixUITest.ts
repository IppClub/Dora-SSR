import { App, Content, Node, Size, sleep, thread } from "Dora";
import type { AgentQuestionnaireAnswers } from "Agent/Questionnaire";
import type { AgentSessionDetailResult, AgentSessionItem, AgentSessionStatus } from "Agent/Session";
import type { LLMConfig } from "Agent/Utils";
import { startMobileRemix, type MobileRemixServices } from "Dev/Mobile/Remix";

const resultPath = "/tmp/dora-mobile-remix-ui.result";

function expect(condition: boolean, message: string) {
	if (!condition) throw new Error(message);
}

function findTagged(root: Node.Type, tag: string): Node.Type | undefined {
	if (root.tag === tag) return root;
	let result: Node.Type | undefined;
	root.eachChild(child => {
		const found = findTagged(child, tag);
		if (!found) return false;
		result = found;
		return true;
	});
	return result;
}

const llmConfig: LLMConfig = {
	url: "https://example.invalid",
	model: "ui-test-model",
	apiKey: "test",
	contextWindow: 64000,
	temperature: 0.1,
	maxTokens: 1024,
	supportsFunctionCalling: true,
};

let status: AgentSessionStatus = "WAITING_USER";
let questionnairePending = true;
let respondedAnswers: AgentQuestionnaireAnswers | undefined;
let stopCount = 0;
let playCount = 0;

const session = (): AgentSessionItem => ({
	id: 91001,
	projectRoot: Content.assetPath,
	title: "Mobile Remix UI Test",
	kind: "main",
	rootSessionId: 91001,
	memoryScope: "main",
	workMode: "code",
	status,
	currentTaskId: 92001,
	currentTaskStatus: status,
	createdAt: 1,
	updatedAt: 1,
});

const detail = (): AgentSessionDetailResult => ({
	success: true,
	session: session(),
	relatedSessions: [],
	messages: [],
	steps: [],
	checkpoints: [],
	pendingQuestionnaire: questionnairePending ? {
		id: 93001,
		sessionId: 91001,
		taskId: 92001,
		step: 1,
		status: "PENDING",
		schema: {
			title: "选择 Remix 方向",
			questions: [{
				id: "style",
				prompt: "希望调整成哪种节奏？",
				type: "single_choice",
				required: true,
				allowOther: true,
				options: [
					{ id: "relaxed", label: "轻松", recommended: true },
					{ id: "fast", label: "紧张", recommended: false },
				],
			}],
		},
		createdAt: 1,
	} : undefined,
	hasActivePlan: false,
});

const services: MobileRemixServices = {
	createSession: () => ({ success: true, session: session() }),
	getSession: () => detail(),
	setWorkMode: () => ({ success: true }),
	sendPrompt: () => ({ success: true, sessionId: 91001, taskId: 92001 }),
	respondQuestionnaire: (_sessionId, _questionnaireId, answers) => {
		respondedAnswers = answers;
		questionnairePending = false;
		status = "RUNNING";
		return { success: true, sessionId: 91001, taskId: 92001 };
	},
	stopSessionTask: () => {
		stopCount++;
		status = "STOPPED";
		return { success: true };
	},
	getActiveLLMConfig: () => ({ success: true, id: 94001, config: llmConfig }),
	getLLMConfig: () => ({ success: true, id: 94001, config: llmConfig }),
	getLLMConfigSummaries: () => [{ id: 94001, name: "UI Test", model: "ui-test-model", active: true }],
};

App.winSize = Size(390, 844);
thread(() => {
	sleep(0.4);
	const host = startMobileRemix({
		entry: { id: "remix-ui-test", title: "轨道花园", workDir: Content.assetPath },
		onBack: () => undefined,
		onPlay: () => { playCount++; },
		services,
	});
	sleep(0.5);

	expect(findTagged(host, "remix-questionnaire") !== undefined, "questionnaire UI was not rendered");
	expect(findTagged(host, "remix-stop") !== undefined && findTagged(host, "remix-send") === undefined, "Questionnaire must retain only the shared Stop control");
	expect(App.saveScreenshot("/tmp/dora-mobile-remix-questionnaire-ui") !== "", "questionnaire screenshot failed");
	sleep(0.25);

	findTagged(host, "remix-question-submit")?.emit("Tapped");
	expect(respondedAnswers === undefined, "required questionnaire submitted without an answer");

	const option = findTagged(host, "remix-question-style-option-relaxed");
	expect(option !== undefined, "questionnaire choice was not rendered");
	option?.emit("Tapped");
	findTagged(host, "remix-question-submit")?.emit("Tapped");
	expect(respondedAnswers !== undefined, "questionnaire answer was not submitted");
	expect(respondedAnswers?.[0]?.selectedOptionIds?.[0] === "relaxed", "questionnaire selected option mismatch");

	const stop = findTagged(host, "remix-stop");
	expect(stop !== undefined, "Stop action was not rendered after questionnaire resume");
	expect(findTagged(host, "remix-send") === undefined && stop?.width === 82, "Stop must replace Send in its compact slot");
	stop?.emit("Tapped");
	expect(stopCount === 1 && status === "STOPPED", "Stop action did not stop the Agent");

	status = "DONE";
	sleep(0.35);
	const play = findTagged(host, "remix-play");
	expect(play !== undefined, "Play now action was not rendered for DONE state");
	expect(App.saveScreenshot("/tmp/dora-mobile-remix-done-ui") !== "", "done screenshot failed");
	sleep(0.25);
	play?.emit("Tapped");
	expect(playCount === 1, "Play now did not invoke the game callback");
	expect(!host.visible, "Remix host must hide before game launch");

	Content.save(resultPath, "passed questionnaire=1 stop=1 play=1\n");
	host.removeFromParent(true);
});
