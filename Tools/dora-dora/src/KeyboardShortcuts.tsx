/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import FolderOpenOutlinedIcon from '@mui/icons-material/FolderOpenOutlined';
import NoteAddOutlinedIcon from '@mui/icons-material/NoteAddOutlined';
import SearchIcon from '@mui/icons-material/Search';
import { useTranslation } from 'react-i18next';
import doraWelcome from './dora-body.png';
import './KeyboardShortcuts.css';

interface KeyboardShortcutsProps {
	left: number;
	top: number;
	bottom: number;
	onGoToFile: () => void;
	onNewFile: () => void;
	onOpenProjects: () => void;
}

const apple = navigator.platform.indexOf("Mac") === 0
	|| navigator.platform === "iPhone"
	|| navigator.platform === "iPad";

function ShortcutKeys({ keys }: { keys: string[] }) {
	return (
		<span className="welcome-shortcut-keys">
			{keys.map(key => <kbd key={key} className="welcome-shortcut-key">{key}</kbd>)}
		</span>
	);
}

const KeyboardShortcuts = (props: KeyboardShortcutsProps) => {
	const { t } = useTranslation();
	const shiftKey = apple ? "⇧" : "Shift";
	const modHint = t(apple ? "menu.modKeyHintMac" : "menu.modKeyHintOther");
	const actions = [
		{
			label: t("menu.goToFile"),
			keys: ["Mod", "P"],
			icon: <SearchIcon fontSize="small" />,
			onClick: props.onGoToFile,
		},
		{
			label: t("menu.new"),
			keys: ["Mod", shiftKey, "N"],
			icon: <NoteAddOutlinedIcon fontSize="small" />,
			onClick: props.onNewFile,
		},
		{
			label: t("menu.browseProjects"),
			keys: [],
			icon: <FolderOpenOutlinedIcon fontSize="small" />,
			onClick: props.onOpenProjects,
		},
	];
	const secondaryShortcuts = [
		{ label: t("menu.save"), keys: ["Mod", "S"] },
		{ label: t("menu.run"), keys: ["Mod", "R"] },
		{ label: t("menu.viewLog"), keys: ["Mod", "."] },
	];
	return (
		<section
			className="welcome-empty-state"
			style={{ left: props.left, top: props.top, bottom: props.bottom }}
			aria-labelledby="welcome-empty-title"
		>
			<div className="welcome-empty-content">
				<img className="welcome-empty-mascot" src={doraWelcome} alt="" aria-hidden="true" />
				<h1 id="welcome-empty-title" className="welcome-empty-title">
					{t("menu.emptyEditorTitle")}
				</h1>
				<p className="welcome-empty-description">
					{t("menu.emptyEditorDescription")}
				</p>
				<div className="welcome-actions">
					{actions.map(action => (
						<button key={action.label} type="button" className="welcome-action" onClick={action.onClick}>
							<span className="welcome-action-icon">{action.icon}</span>
							<span>{action.label}</span>
							{action.keys.length > 0 ? <ShortcutKeys keys={action.keys} /> : null}
						</button>
					))}
				</div>
				<div className="welcome-secondary-shortcuts">
					{secondaryShortcuts.map(shortcut => (
						<span key={shortcut.label} className="welcome-secondary-shortcut">
							<span>{shortcut.label}</span>
							<ShortcutKeys keys={shortcut.keys} />
						</span>
					))}
				</div>
				<p className="welcome-mod-hint">{modHint}</p>
			</div>
		</section>
	);
};

export default KeyboardShortcuts;
