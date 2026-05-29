import '../scss/jquery.contextMenu.css';
import '../scss/normalize.css';
import '../scss/spectrum.css';
import 'sweetalert2/dist/sweetalert2.min.css';
import '../scss/style.css';

import { Utils } from './classes/utils';
import { i18n } from './classes/i18n';

import ko from 'knockout';
window.ko = ko;

import jquery from 'jquery';
window.$ = window.jQuery = jquery;

import ace from 'ace-builds/src-noconflict/ace';
import { registerYarnMode } from './mode-yarn.js';
import { registerYarnTheme } from './theme-yarn.js';

// Keep these imports, they are used elsewhere in the app
import Swal from 'sweetalert2';

window.yarnI18n = i18n;

window.addEventListener('YarnEditorSetLanguage', event => {
	i18n.setLanguage(event.language || event.detail?.language);
});

async function runYarnEditor() {
	await import('jquery-contextmenu');
	const mousewheelModule = await import('jquery-mousewheel');
	(mousewheelModule.default || mousewheelModule)(jquery);
	await import('jquery-resizable-dom');

	window.ace = ace;
	ace.config.set('basePath', Utils.getPublicPath());
	window.define = ace.define;
	registerYarnMode(ace);
	registerYarnTheme(ace);
	window.applyYarnAceSyntax = editor => {
		if (!editor) return;
		const YarnMode = ace.require('ace/mode/yarn').Mode;
		ace.require('ace/theme/yarn');
		editor.setTheme('ace/theme/yarn');
		editor.getSession().setMode(new YarnMode());
		const app = window.app;
		if (!app) return;
		if (!window.isYarnAceContextMenuRegistered) {
			$.contextMenu(app.utils.getEditorContextMenu(/\|/g));
			window.isYarnAceContextMenuRegistered = true;
		}
		editor.setOptions({
			enableBasicAutocompletion: app.settings.autocompleteSuggestionsEnabled(),
			enableLiveAutocompletion: app.settings.autocompleteSuggestionsEnabled(),
			behavioursEnabled: app.settings.autoCloseBrackets(),
		});
	};

	await import('ace-builds/src-min-noconflict/ext-language_tools');
	await import('ace-builds/src-min-noconflict/ext-searchbox');
	await import('./libs/knockout.ace.js');
	await import('jquery.transit');

	await import('spectrum-colorpicker');

	window.Swal = Swal;

	const { App } = await import('./classes/app.js');
	const { version } = await import('../public/version.json');

	window.app = new App('Yarn', version);
	window.app.i18n = i18n;
	window.app.t = i18n.t;
	window.app.run();
	i18n.applyDomTranslations();

	// Register plugins from plugin folder
	const { Plugins } = await import('../public/plugins');
	const appPlugins = new Plugins(window.app);
	Object.assign(window.app.plugins, appPlugins);
	window.dispatchEvent(new Event('YarnEditorReady'));
}

runYarnEditor();
