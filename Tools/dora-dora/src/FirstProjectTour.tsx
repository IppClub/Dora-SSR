/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE. */

import { Button, ConfigProvider, Space, Tour, theme as antdTheme } from 'antd';
import type { TourProps } from 'antd';
import { useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import { Color } from './Theme';

export interface FirstProjectTourProps {
	open: boolean;
	current: number;
	creating: boolean;
	projectNameReady: boolean;
	exampleCodeReady: boolean;
	canInsertExample: boolean;
	onStart: () => void;
	onProjectNameReady: () => void;
	onInsertExample: () => void;
	onExampleCodeReady: () => void;
	onSkip: () => void;
	onFinish: () => void;
	onExploreAgent: () => void;
	onClose: () => void;
}

export const firstProjectExampleCode = 'print("Hello Dora!");';

const target = (selector: string) => () =>
	document.querySelector<HTMLElement>(selector);

const playControlTarget = (mode: string) => () =>
	Array.from(document.querySelectorAll<HTMLElement>(
		`[data-play-control-mode="${mode}"]`
	)).find((element) => {
		const rect = element.getBoundingClientRect();
		return rect.width > 0
			&& rect.height > 0
			&& element.closest('[data-play-control-strip="true"]') !== null;
	}) ?? null;

export default function FirstProjectTour(props: FirstProjectTourProps) {
	const { t } = useTranslation();
	const compact = typeof window !== "undefined"
		&& (window.innerWidth <= 600 || window.innerHeight <= 520);
	const allSteps = useMemo<NonNullable<TourProps['steps']>>(() => [
		{
			target: null,
			title: t("onboarding.firstProjectWelcomeTitle"),
			description: t("onboarding.firstProjectWelcomeDescription"),
			placement: "center",
		},
		{
			target: target('[data-first-project-workspace-root="true"]'),
			title: t("onboarding.workspaceTitle"),
			description: t("onboarding.workspaceDescription"),
			placement: compact ? "bottomLeft" : "right",
		},
		{
			target: target('[data-first-project-new="true"]'),
			title: t("onboarding.newMenuTitle"),
			description: t("onboarding.newMenuDescription"),
			placement: "right",
		},
		{
			target: target('[data-first-project-folder="true"]'),
			title: t("onboarding.folderTypeTitle"),
			description: t("onboarding.folderTypeDescription"),
			placement: "right",
		},
		{
			target: target('[data-first-project-name="true"]'),
			title: t("onboarding.firstProjectFormTitle"),
			description: t("onboarding.firstProjectFormDescription"),
			placement: "bottomRight",
		},
		{
			target: target('[data-first-project-checkbox="true"]'),
			title: t("onboarding.projectOptionTitle"),
			description: t("onboarding.projectOptionDescription"),
			placement: compact ? "top" : "right",
		},
		{
			target: target('[data-first-project-create="true"]'),
			title: t("onboarding.confirmProjectTitle"),
			description: t("onboarding.confirmProjectDescription"),
			placement: "topRight",
		},
		{
			target: compact ? null : target('[data-first-project-editor="true"]'),
			title: t("onboarding.exampleCodeTitle"),
			description: (
				<div>
					<div>{t("onboarding.exampleCodeDescription")}</div>
					<code style={{
						display: "block",
						marginTop: 10,
						padding: "8px 10px",
						borderRadius: 6,
						background: Color.Background,
						color: Color.Theme,
						whiteSpace: "pre-wrap",
					}}>
						{firstProjectExampleCode}
					</code>
				</div>
			),
			placement: compact ? "center" : "leftTop",
		},
		{
			target: playControlTarget("Run"),
			title: t("onboarding.runTitle"),
			description: t("onboarding.runDescription"),
			placement: "topRight",
		},
		{
			target: null,
			title: t("onboarding.completedTitle"),
			description: t("onboarding.completedDescription"),
			placement: "center",
		},
		{
			target: target('[data-first-project-log-close="true"]'),
			title: t("onboarding.closeLogTitle"),
			description: t("onboarding.closeLogDescription"),
			placement: compact ? "top" : "topRight",
		},
		{
			target: target('[data-first-project-agent-target="true"]'),
			title: t("onboarding.agentTitle"),
			description: t("onboarding.agentDescription"),
			placement: compact ? "topRight" : "right",
		},
	], [compact, t]);
	const agentPhase = props.current >= 10;
	const steps = agentPhase ? allSteps.slice(10) : allSteps.slice(0, 10);
	const current = agentPhase ? props.current - 10 : props.current;
	const hasActions = !agentPhase && [0, 4, 7, 9].includes(current);

	return (
		<ConfigProvider
			theme={{
				algorithm: antdTheme.darkAlgorithm,
				token: {
					colorPrimary: Color.Theme,
					colorPrimaryHover: "#ffd15f",
					colorTextLightSolid: Color.BackgroundDark,
					colorBgElevated: Color.BackgroundDark,
					colorBorder: Color.Line,
					borderRadius: 8,
				},
			}}
		>
			<Tour
				key={agentPhase ? "agent" : "project"}
				open={props.open}
				current={current}
				steps={steps}
				keyboard
				disabledInteraction={false}
				gap={{ offset: 8, radius: 8 }}
				mask={{ color: "rgba(0, 0, 0, 0.58)" }}
				scrollIntoViewOptions={{ block: "nearest", behavior: "smooth" }}
				zIndex={1500}
				width={compact ? Math.min(280, window.innerWidth - 24) : 320}
				onChange={() => undefined}
				onClose={props.onClose}
				actionsRender={(_, info) => {
					if (!hasActions) return null;
					return (
						<Space size={8}>
						{!agentPhase && info.current === 0 ? (
							<Button
								size="small"
								type="text"
								onClick={props.onSkip}
								disabled={props.creating}
							>
								{t("onboarding.skip")}
							</Button>
						) : null}
						{!agentPhase && info.current === 9 ? (
							<Button
								size="small"
								type="text"
								onClick={props.onFinish}
							>
								{t("onboarding.finish")}
							</Button>
						) : null}
						{!agentPhase && info.current === 9 ? (
							<Button
								size="small"
								type="primary"
								onClick={props.onExploreAgent}
							>
								{t("onboarding.exploreAgent")}
							</Button>
						) : null}
						{!agentPhase && info.current === 0 ? (
							<Button size="small" type="primary" onClick={props.onStart}>
								{t("onboarding.startCreating")}
							</Button>
						) : null}
						{!agentPhase && info.current === 4 ? (
							<Button
								size="small"
								type="primary"
								disabled={!props.projectNameReady}
								onClick={props.onProjectNameReady}
							>
								{t("onboarding.next")}
							</Button>
						) : null}
						{!agentPhase && info.current === 7 ? (
							<Button
								size="small"
								disabled={!props.canInsertExample || props.exampleCodeReady}
								onClick={props.onInsertExample}
							>
								{t("onboarding.insertExample")}
							</Button>
						) : null}
						{!agentPhase && info.current === 7 ? (
							<Button
								size="small"
								type="primary"
								disabled={!props.exampleCodeReady}
								onClick={props.onExampleCodeReady}
							>
								{t("onboarding.next")}
							</Button>
						) : null}
						</Space>
					);
				}}
				styles={{
					section: {
						maxWidth: 320,
						background: Color.BackgroundDark,
						border: `1px solid ${Color.Line}`,
						boxShadow: "0 18px 48px rgba(0, 0, 0, 0.46)",
					},
					footer: {
						alignItems: "stretch",
						flexDirection: "column",
						gap: hasActions ? 12 : 0,
					},
					indicators: {
						alignSelf: "flex-start",
						flexWrap: "nowrap",
						width: "100%",
					},
					actions: {
						alignSelf: "flex-end",
						display: hasActions ? undefined : "none",
					},
				}}
			/>
		</ConfigProvider>
	);
}
