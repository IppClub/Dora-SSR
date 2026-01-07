/* Copyright (c) 2017-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

import './KeyboardShortcuts.css';
import { useTranslation } from 'react-i18next';

const apple = navigator.platform.indexOf("Mac") === 0 || navigator.platform === "iPhone" || navigator.platform === "iPad";

const KeyboardShortcuts = () => {
	const {t} = useTranslation();
	const aShortcuts = [
		{ description: t("menu.modKey"), keys: apple ? ['⌃', '⌥', '⌘'] : ['Ctrl', 'Alt', 'Win'] },
		{ description: t("menu.goToFile"), keys: ['Mod', 'P'] },
		{ description: t("menu.switchTab"), keys: ['Mod', 'Number'] },
		{ description: t("menu.new"), keys: ['Mod', (apple ? '⇧' : 'Shift'), 'N'] },
		{ description: t("menu.delete"), keys: ['Mod', (apple ? '⇧' : 'Shift'), 'D'] },
		{ description: t("menu.save"), keys: ['Mod', 'S']},
	];
	const bShortcuts = [
		{ description: t("menu.saveAll"), keys: ['Mod', (apple ? '⇧' : 'Shift'), 'S']},
		{ description: t("menu.viewLog"), keys: ['Mod', '.'] },
		{ description: t("menu.stop"), keys: ['Mod', 'Q'] },
		{ description: t("menu.runThis"), keys: ['Mod', (apple ? '⇧' : 'Shift'), 'R'] },
		{ description: t("menu.run"), keys: ['Mod', 'R'] },
	];
	return (
		<div style={{width: '100vw', height: '100vh', display: 'flex', justifyContent: 'center', alignItems: 'center'}}>
			<div className="container">
				<ul className="list">
					{aShortcuts.map((shortcut, index) => (
						<li key={index} className="list-item">
							<span className="description">{shortcut.description}</span>
							<div className="keys">
								{shortcut.keys.map((key, keyIndex) => (
									<kbd key={keyIndex} className="key">{key}</kbd>
								))}
							</div>
						</li>
					))}
				</ul>
				<ul className="list">
					{bShortcuts.map((shortcut, index) => (
						<li key={index} className="list-item">
							<span className="description">{shortcut.description}</span>
							<div className="keys">
								{shortcut.keys.map((key, keyIndex) => (
									<kbd key={keyIndex} className="key">{key}</kbd>
								))}
							</div>
						</li>
					))}
				</ul>
			</div>
		</div>
	);
};

export default KeyboardShortcuts;
