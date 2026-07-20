// @preview-file off clear
import { sanitizeUTF8 } from "Agent/Utils";

export type AgentQuestionType = "single_choice" | "multiple_choice" | "text";

export interface AgentQuestionOption {
	id: string;
	label: string;
	description?: string;
	recommended?: boolean;
}

export interface AgentQuestion {
	id: string;
	prompt: string;
	description?: string;
	type: AgentQuestionType;
	required: boolean;
	options?: AgentQuestionOption[];
	allowOther?: boolean;
	placeholder?: string;
	minSelections?: number;
	maxSelections?: number;
}

export interface AgentQuestionnaireSchema {
	title: string;
	description?: string;
	questions: AgentQuestion[];
}

export interface AgentQuestionnaireAnswer {
	questionId: string;
	status: "answered" | "skipped";
	selectedOptionIds?: string[];
	otherText?: string;
	text?: string;
}

export type AgentQuestionnaireAnswers = AgentQuestionnaireAnswer[];

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== undefined && !Array.isArray(value);
}

function trimText(value: string): string {
	const [trimmed] = string.match(value, "^%s*(.-)%s*$");
	return trimmed ?? "";
}

function cleanString(value: unknown, maxLength: number): string {
	if (typeof value !== "string") return "";
	const text = trimText(sanitizeUTF8(value));
	const nextPos = utf8.offset(text, maxLength + 1);
	return nextPos === undefined ? text : string.sub(text, 1, nextPos - 1);
}

function cleanBoolean(value: unknown, fallback = false): boolean {
	return typeof value === "boolean" ? value : fallback;
}

function cleanInteger(value: unknown, fallback: number, minValue: number, maxValue: number): number {
	let result = typeof value === "number" && Number.isFinite(value) ? math.floor(value) : fallback;
	if (result < minValue) result = minValue;
	if (result > maxValue) result = maxValue;
	return result;
}

function isSafeIdentifier(value: string): boolean {
	if (value === "") return false;
	for (let i = 0; i < value.length; i++) {
		const code = value.charCodeAt(i);
		const allowed = (code >= 48 && code <= 57)
			|| (code >= 65 && code <= 90)
			|| (code >= 97 && code <= 122)
			|| code === 45
			|| code === 95;
		if (!allowed) return false;
	}
	return true;
}

export function normalizeQuestionnaire(value: unknown):
	| { success: true; schema: AgentQuestionnaireSchema }
	| { success: false; message: string } {
	if (!isRecord(value)) return { success: false, message: "ask_user requires an object" };
	const title = cleanString(value.title, 120);
	if (title === "") return { success: false, message: "ask_user requires title" };
	if (!Array.isArray(value.questions) || value.questions.length < 1 || value.questions.length > 8) {
		return { success: false, message: "ask_user requires 1 to 8 questions" };
	}
	const ids: Record<string, boolean> = {};
	const questions: AgentQuestion[] = [];
	for (let i = 0; i < value.questions.length; i++) {
		const raw = value.questions[i];
		if (!isRecord(raw)) return { success: false, message: `question ${i + 1} must be an object` };
		const id = cleanString(raw.id, 64);
		const prompt = cleanString(raw.prompt, 500);
		const type = cleanString(raw.type, 32) as AgentQuestionType;
		if (!isSafeIdentifier(id)) return { success: false, message: `question ${i + 1} has invalid id` };
		if (ids[id]) return { success: false, message: `duplicate question id: ${id}` };
		if (prompt === "") return { success: false, message: `question ${id} requires prompt` };
		if (type !== "single_choice" && type !== "multiple_choice" && type !== "text") {
			return { success: false, message: `question ${id} has invalid type` };
		}
		ids[id] = true;
		const question: AgentQuestion = {
			id,
			prompt,
			type,
			required: cleanBoolean(raw.required, true),
		};
		const description = cleanString(raw.description, 1000);
		if (description !== "") question.description = description;
		const placeholder = cleanString(raw.placeholder, 200);
		if (placeholder !== "") question.placeholder = placeholder;
		question.allowOther = cleanBoolean(raw.allowOther, false);
		if (type === "text" && (raw.options !== undefined || raw.minSelections !== undefined || raw.maxSelections !== undefined)) {
			return { success: false, message: `text question ${id} cannot define options or selection bounds` };
		}
		if (type !== "text") {
			if (!Array.isArray(raw.options) || raw.options.length < 2 || raw.options.length > 8) {
				return { success: false, message: `question ${id} requires 2 to 8 options` };
			}
			const optionIds: Record<string, boolean> = {};
			let recommendedCount = 0;
			question.options = [];
			for (let j = 0; j < raw.options.length; j++) {
				const rawOption = raw.options[j];
				if (!isRecord(rawOption)) return { success: false, message: `question ${id} option ${j + 1} must be an object` };
				const optionId = cleanString(rawOption.id, 64);
				const label = cleanString(rawOption.label, 160);
				if (!isSafeIdentifier(optionId) || optionIds[optionId]) return { success: false, message: `question ${id} has an invalid or duplicate option id` };
				if (label === "") return { success: false, message: `question ${id} option ${optionId} requires label` };
				optionIds[optionId] = true;
				const recommended = cleanBoolean(rawOption.recommended, false);
				if (recommended) recommendedCount++;
				const option: AgentQuestionOption = { id: optionId, label, recommended };
				const optionDescription = cleanString(rawOption.description, 600);
				if (optionDescription !== "") option.description = optionDescription;
				question.options.push(option);
			}
			if (type === "single_choice" && recommendedCount > 1) {
				return { success: false, message: `single-choice question ${id} may have at most one recommended option` };
			}
			if (type === "multiple_choice") {
				const choiceCount = question.options.length + (question.allowOther ? 1 : 0);
				question.minSelections = cleanInteger(raw.minSelections, question.required ? 1 : 0, 0, choiceCount);
				question.maxSelections = cleanInteger(raw.maxSelections, choiceCount, 1, choiceCount);
				if (question.minSelections > question.maxSelections) return { success: false, message: `question ${id} has invalid selection bounds` };
				if (recommendedCount > question.maxSelections) {
					return { success: false, message: `multiple-choice question ${id} recommends ${recommendedCount} options but maxSelections is ${question.maxSelections}` };
				}
			}
		}
		questions.push(question);
	}
	const schema: AgentQuestionnaireSchema = { title, questions };
	const description = cleanString(value.description, 2000);
	if (description !== "") schema.description = description;
	return { success: true, schema };
}

export function validateQuestionnaireAnswers(schema: AgentQuestionnaireSchema, value: unknown):
	| { success: true; answers: AgentQuestionnaireAnswers }
	| { success: false; message: string } {
	if (!Array.isArray(value)) return { success: false, message: "answers must be an array" };
	const byQuestionId: Record<string, Record<string, unknown>> = {};
	for (let i = 0; i < value.length; i++) {
		const item = value[i];
		if (!isRecord(item)) return { success: false, message: `answer ${i + 1} must be an object` };
		const questionId = cleanString(item.questionId, 64);
		if (!isSafeIdentifier(questionId) || byQuestionId[questionId]) return { success: false, message: "answers contain an invalid or duplicate questionId" };
		byQuestionId[questionId] = item;
	}
	if (value.length !== schema.questions.length) return { success: false, message: "answers must include every question exactly once" };
	const answers: AgentQuestionnaireAnswers = [];
	for (let i = 0; i < schema.questions.length; i++) {
		const question = schema.questions[i];
		const raw = byQuestionId[question.id];
		if (!raw) return { success: false, message: `question ${question.id} is missing` };
		const status = raw.status === "skipped" ? "skipped" : (raw.status === "answered" ? "answered" : "");
		if (status === "") return { success: false, message: `question ${question.id} has invalid status` };
		if (status === "skipped") {
			if (question.required) return { success: false, message: `question ${question.id} is required and cannot be skipped` };
			answers.push({ questionId: question.id, status: "skipped" });
			continue;
		}
		if (question.type === "text") {
			const answer = cleanString(raw.text, 8000);
			if (question.required && answer === "") return { success: false, message: `question ${question.id} is required` };
			answers.push({ questionId: question.id, status: "answered", text: answer });
			continue;
		}
		const optionIds: Record<string, boolean> = {};
		for (let j = 0; j < (question.options ?? []).length; j++) optionIds[(question.options ?? [])[j].id] = true;
		const selected = Array.isArray(raw.selectedOptionIds)
			? raw.selectedOptionIds.filter(item => typeof item === "string") as string[]
			: [];
		const unique: string[] = [];
		for (let j = 0; j < selected.length; j++) {
			const id = cleanString(selected[j], 64);
			if (!optionIds[id]) return { success: false, message: `question ${question.id} has an invalid option` };
			if (unique.indexOf(id) < 0) unique.push(id);
		}
		const otherText = cleanString(raw.otherText, 8000);
		if (otherText !== "" && question.allowOther !== true) return { success: false, message: `question ${question.id} does not allow a custom answer` };
		const selectionCount = unique.length + (otherText !== "" ? 1 : 0);
		if (question.required && selectionCount === 0) return { success: false, message: `question ${question.id} is required` };
		if (question.type === "single_choice" && selectionCount > 1) return { success: false, message: `question ${question.id} allows one answer` };
		if (question.type === "multiple_choice") {
			if (selectionCount < (question.minSelections ?? 0) || selectionCount > (question.maxSelections ?? selectionCount)) {
				return { success: false, message: `question ${question.id} does not meet the selection bounds` };
			}
		}
		const answer: AgentQuestionnaireAnswer = { questionId: question.id, status: "answered", selectedOptionIds: unique };
		if (otherText !== "") answer.otherText = otherText;
		answers.push(answer);
	}
	return { success: true, answers };
}
