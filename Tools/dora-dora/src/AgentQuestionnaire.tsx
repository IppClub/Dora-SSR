import React from "react";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Checkbox from "@mui/material/Checkbox";
import Radio from "@mui/material/Radio";
import Stack from "@mui/material/Stack";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { useTranslation } from "react-i18next";
import * as Service from "./Service";
import { Color } from "./Theme";

interface AgentQuestionnaireProps {
	questionnaire: Service.AgentQuestionnaire;
	submitting: boolean;
	onSubmit: (answers: Service.AgentQuestionnaireAnswer[]) => void;
	onCancel: () => void;
}

export default function AgentQuestionnaire(props: AgentQuestionnaireProps) {
	const { t } = useTranslation();
	const [index, setIndex] = React.useState(0);
	const [answers, setAnswers] = React.useState<Record<string, string | string[]>>({});
	const [otherText, setOtherText] = React.useState<Record<string, string>>({});
	const [skipped, setSkipped] = React.useState<Record<string, boolean>>({});
	const [draftReady, setDraftReady] = React.useState(false);
	const questions = props.questionnaire.schema.questions;
	const question = questions[index];
	const draftKey = `agent-questionnaire:${props.questionnaire.id}`;

	React.useEffect(() => {
		setDraftReady(false);
		try {
			const text = window.sessionStorage.getItem(draftKey);
			const draft = text ? JSON.parse(text) as { index?: number; answers?: Record<string, string | string[]>; otherText?: Record<string, string>; skipped?: Record<string, boolean> } : undefined;
			setIndex(Math.min(Math.max(0, draft?.index ?? 0), Math.max(0, questions.length - 1)));
			setAnswers(draft?.answers ?? {});
			setOtherText(draft?.otherText ?? {});
			setSkipped(draft?.skipped ?? {});
		} catch {
			setIndex(0);
			setAnswers({});
			setOtherText({});
			setSkipped({});
		}
		setDraftReady(true);
	}, [draftKey, questions.length]);

	React.useEffect(() => {
		if (!draftReady) return;
		window.sessionStorage.setItem(draftKey, JSON.stringify({ index, answers, otherText, skipped }));
	}, [answers, draftKey, draftReady, index, otherText, skipped]);

	if (!question) return null;
	const current = answers[question.id];
	const selected = Array.isArray(current) ? current : (typeof current === "string" && current !== "" ? [current] : []);
	const otherValue = otherText[question.id] ?? "";
	const isSkipped = skipped[question.id] === true;
	const minimum = question.type === "multiple_choice" ? (question.minSelections ?? (question.required ? 1 : 0)) : (question.required ? 1 : 0);
	const maximum = question.type === "multiple_choice" ? (question.maxSelections ?? Number.MAX_SAFE_INTEGER) : 1;
	const selectionCount = selected.length + (otherValue.trim() !== "" ? 1 : 0);
	const valid = isSkipped ? !question.required : (question.type === "text"
		? (!question.required || (typeof current === "string" && current.trim() !== ""))
		: selectionCount >= minimum && selectionCount <= maximum);
	const isLast = index === questions.length - 1;

	const clearSkipped = () => setSkipped(prev => ({ ...prev, [question.id]: false }));

	const choose = (optionId: string) => {
		clearSkipped();
		if (question.type === "single_choice") {
			setAnswers(prev => ({ ...prev, [question.id]: optionId }));
			setOtherText(prev => ({ ...prev, [question.id]: "" }));
			return;
		}
		const next = selected.indexOf(optionId) >= 0
			? selected.filter(item => item !== optionId)
			: [...selected, optionId];
		const nextCount = next.length + (otherValue.trim() !== "" ? 1 : 0);
		if (nextCount <= (question.maxSelections ?? Number.MAX_SAFE_INTEGER)) {
			setAnswers(prev => ({ ...prev, [question.id]: next }));
		}
	};

	const updateOther = (value: string) => {
		const nextCount = (question.type === "single_choice" ? 0 : selected.length) + (value.trim() === "" ? 0 : 1);
		if (question.type === "multiple_choice" && nextCount > maximum) return;
		clearSkipped();
		setOtherText(prev => ({ ...prev, [question.id]: value }));
		if (question.type === "single_choice" && value.trim() !== "") {
			setAnswers(prev => ({ ...prev, [question.id]: "" }));
		}
	};

	const buildSubmission = (): Service.AgentQuestionnaireAnswer[] => questions.map(item => {
		if (skipped[item.id] === true) return { questionId: item.id, status: "skipped" };
		const value = answers[item.id];
		if (item.type === "text") {
			return { questionId: item.id, status: "answered", text: typeof value === "string" ? value.trim() : "" };
		}
		const selectedOptionIds = Array.isArray(value) ? value : (typeof value === "string" && value !== "" ? [value] : []);
		const answer: Service.AgentQuestionnaireAnswer = { questionId: item.id, status: "answered", selectedOptionIds };
		const custom = otherText[item.id]?.trim();
		if (custom) answer.otherText = custom;
		return answer;
	});

	const skipCurrent = () => {
		if (question.required) return;
		setSkipped(prev => ({ ...prev, [question.id]: true }));
		setAnswers(prev => ({ ...prev, [question.id]: question.type === "multiple_choice" ? [] : "" }));
		setOtherText(prev => ({ ...prev, [question.id]: "" }));
		if (isLast) {
			const submission = buildSubmission().map(item => item.questionId === question.id ? { questionId: question.id, status: "skipped" as const } : item);
			props.onSubmit(submission);
		} else {
			setIndex(value => value + 1);
		}
	};

	return (
		<Box sx={{ px: 2, pb: 2, flexShrink: 0, backgroundColor: Color.Background }}>
			<Box sx={{ border: `1px solid ${Color.Line}`, borderRadius: 3, backgroundColor: Color.BackgroundDark, overflow: "hidden", maxHeight: "min(58vh, 560px)", display: "flex", flexDirection: "column" }}>
				<Box sx={{ px: 2, pt: 2, pb: 1.5, overflowY: "auto", minHeight: 0 }}>
					<Stack direction="row" justifyContent="space-between" alignItems="center" sx={{ mb: 2 }}>
						<Typography variant="subtitle2" sx={{ color: Color.TextPrimary }}>
							{index + 1}/{questions.length} {t("agent.questionnaire.questions")}
						</Typography>
						<Stack direction="row" spacing={0.75}>
							{questions.map((_, questionIndex) => (
								<Box key={questionIndex} sx={{ width: 24, height: 3, borderRadius: 2, backgroundColor: questionIndex === index ? Color.Theme : Color.Line }} />
							))}
						</Stack>
					</Stack>
					<Typography variant="subtitle1" sx={{ color: Color.TextPrimary, fontWeight: 650 }}>
						{question.prompt}
					</Typography>
					{question.description ? <Typography variant="body2" sx={{ color: Color.TextSecondary, mt: 0.5 }}>{question.description}</Typography> : null}
					<Typography variant="caption" sx={{ color: Color.TextSecondary, display: "block", mt: 0.75, mb: 1.5 }}>
						{question.type === "multiple_choice" ? t("agent.questionnaire.multiple") : (question.type === "text" ? t("agent.questionnaire.text") : t("agent.questionnaire.single"))}
					</Typography>

					{question.type === "text" ? (
						<TextField
							fullWidth multiline minRows={3} maxRows={8}
							value={typeof current === "string" ? current : ""}
							placeholder={question.placeholder}
							disabled={props.submitting}
							onChange={event => { clearSkipped(); setAnswers(prev => ({ ...prev, [question.id]: event.target.value })); }}
						/>
					) : (
						<Stack spacing={1}>
							{(question.options ?? []).map(option => {
								const checked = selected.indexOf(option.id) >= 0;
								return (
									<Box key={option.id} onClick={() => !props.submitting && choose(option.id)} sx={{ p: 1.25, borderRadius: 2, border: `1px solid ${checked ? `${Color.Theme}88` : Color.Line}`, backgroundColor: checked ? `${Color.Theme}25` : "rgba(255,255,255,0.025)", cursor: "pointer" }}>
										<Stack direction="row" spacing={1} alignItems="flex-start">
											{question.type === "single_choice" ? <Radio checked={checked} size="small" sx={{ p: 0.25 }} /> : <Checkbox checked={checked} size="small" sx={{ p: 0.25 }} />}
											<Box>
												<Typography variant="body2" sx={{ color: Color.TextPrimary, fontWeight: 650 }}>{option.label}{option.recommended ? ` (${t("agent.questionnaire.recommended")})` : ""}</Typography>
												{option.description ? <Typography variant="body2" sx={{ color: Color.TextSecondary, mt: 0.25 }}>{option.description}</Typography> : null}
											</Box>
										</Stack>
									</Box>
								);
							})}
							{question.allowOther ? (
								<TextField fullWidth size="small" value={otherValue} disabled={props.submitting} placeholder={t("agent.questionnaire.other")} onChange={event => updateOther(event.target.value)} />
							) : null}
						</Stack>
					)}
				</Box>
				<Stack direction="row" justifyContent="space-between" alignItems="center" sx={{ borderTop: `1px solid ${Color.Line}`, p: 1.25, flexShrink: 0 }}>
					<Button
						variant="outlined"
						size="small"
						disabled={props.submitting}
						onClick={props.onCancel}
						sx={{
							color: Color.TextSecondary,
							borderColor: Color.Line,
							borderRadius: 2,
							px: 1.5,
							"&:hover": {
								color: Color.TextPrimary,
								borderColor: Color.TextSecondary,
								backgroundColor: "rgba(255,255,255,0.04)",
							},
						}}
					>
						{t("agent.questionnaire.cancel")}
					</Button>
					<Stack direction="row" spacing={1}>
						<Button disabled={index === 0 || props.submitting} onClick={() => setIndex(value => Math.max(0, value - 1))}>{t("agent.questionnaire.previous")}</Button>
						{!question.required ? <Button disabled={props.submitting} onClick={skipCurrent}>{t("agent.questionnaire.skip")}</Button> : null}
						<Button variant="contained" disabled={!valid || props.submitting} onClick={() => isLast ? props.onSubmit(buildSubmission()) : setIndex(value => value + 1)}>
							{isLast ? t("agent.questionnaire.submit") : t("agent.questionnaire.next")}
						</Button>
					</Stack>
				</Stack>
			</Box>
		</Box>
	);
}
