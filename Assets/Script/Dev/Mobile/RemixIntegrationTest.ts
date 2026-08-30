import { Content, Path, sleep, thread } from "Dora";
import * as AgentSession from "Agent/Session";
import { getActiveLLMConfig } from "Agent/Utils";

const resultPath = "/tmp/dora-mobile-remix-integration.result";
const projectRoot = "/tmp/dora-mobile-remix-integration-project";

thread(() => {
	Content.save(resultPath, "running");
	Content.mkdir(projectRoot);
	Content.save(Path(projectRoot, "init.lua"), "return function() end\n");
	AgentSession.deleteSessionsByProjectRoot(projectRoot);
	const created = AgentSession.createSession(projectRoot, "Mobile Remix Integration Test");
	if (!created.success) {
		Content.save(resultPath, `failed: ${created.message}`);
		return;
	}
	const config = getActiveLLMConfig();
	if (!config.success) {
		Content.save(resultPath, "skipped: no active LLM config");
		AgentSession.deleteSessionsByProjectRoot(projectRoot);
		return;
	}
	AgentSession.setWorkMode(created.session.id, "plan");
	const sent = AgentSession.sendPrompt(
		created.session.id,
		"请只分析这个最小 Dora 项目，制定并提交一个不修改文件的简短测试计划。不要进入 Code 模式。",
		undefined,
		"plan",
		config.id,
		config.config,
	);
	if (!sent.success) {
		Content.save(resultPath, `failed: ${sent.message}`);
		AgentSession.deleteSessionsByProjectRoot(projectRoot);
		return;
	}
	let planReady = false;
	for (let i = 0; i < 120; i++) {
		sleep(0.5);
		const detail = AgentSession.getSession(created.session.id);
		if (!detail.success) continue;
		const assistantMessages = detail.messages.filter(message => message.role === "assistant").length;
		if (detail.session.status === "DONE" && detail.hasActivePlan && assistantMessages > 0) {
			planReady = true;
			break;
		}
		if (detail.session.status === "FAILED" || detail.session.status === "STOPPED") {
			Content.save(resultPath, `failed: status=${detail.session.status}`);
			return;
		}
	}
	if (!planReady) {
		AgentSession.stopSessionTask(created.session.id);
		Content.save(resultPath, "failed: timed out waiting for an active plan");
		return;
	}
	const codeSent = AgentSession.sendPrompt(
		created.session.id,
		"开始 Code 模式执行已确认计划：只把 init.lua 改成返回一个函数，该函数打印 mobile-remix-integration-ok；然后读取文件确认修改。",
		undefined,
		"code",
		config.id,
		config.config,
	);
	if (!codeSent.success) {
		Content.save(resultPath, `failed: code start: ${codeSent.message}`);
		return;
	}
	for (let i = 0; i < 180; i++) {
		sleep(0.5);
		const detail = AgentSession.getSession(created.session.id);
		if (!detail.success) continue;
		if (detail.session.status === "DONE") {
			const source = Content.load(Path(projectRoot, "init.lua"));
			const assistantMessages = detail.messages.filter(message => message.role === "assistant").length;
			if (source !== undefined && string.match(source, "mobile%-remix%-integration%-ok")[0] !== undefined && assistantMessages >= 2) {
				Content.save(resultPath, `passed: plan-to-code status=${detail.session.status} messages=${detail.messages.length} steps=${detail.steps.length}`);
				return;
			}
			Content.save(resultPath, "failed: code completed without the expected file change");
			return;
		}
		if (detail.session.status === "FAILED" || detail.session.status === "STOPPED") {
			Content.save(resultPath, `failed: code status=${detail.session.status}`);
			return;
		}
	}
	AgentSession.stopSessionTask(created.session.id);
	Content.save(resultPath, "failed: timed out waiting for Code completion");
});
