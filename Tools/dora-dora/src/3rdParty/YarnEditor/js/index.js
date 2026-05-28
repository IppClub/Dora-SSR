import '../scss/jquery.contextMenu.css';
import '../scss/normalize.css';
import '../scss/spectrum.css';
import 'sweetalert2/dist/sweetalert2.min.css';
import '../scss/style.css';

import { Utils } from './classes/utils';

import ko from 'knockout';
window.ko = ko;

import jquery from 'jquery';
window.$ = window.jQuery = jquery;

import ace from 'ace-builds/src-noconflict/ace';

// Keep these imports, they are used elsewhere in the app
import Swal from 'sweetalert2';

async function runYarnEditor() {
	await import('jquery-contextmenu');
	const mousewheelModule = await import('jquery-mousewheel');
	(mousewheelModule.default || mousewheelModule)(jquery);
	await import('jquery-resizable-dom');

	window.ace = ace;
	ace.config.set('basePath', Utils.getPublicPath()); //needed to import yarn mode
	window.define = ace.define;
	await import('./mode-yarn.js');
	await import('./theme-yarn.js');

	await import('ace-builds/src-min-noconflict/ext-language_tools');
	await import('ace-builds/src-min-noconflict/ext-searchbox');
	await import('./libs/knockout.ace.js');
	await import('jquery.transit');

	await import('spectrum-colorpicker');

	window.Swal = Swal;

	const { App } = await import('./classes/app.js');
	const { version } = await import('../public/version.json');

	window.app = new App('Yarn', version);
	window.app.run();

	// Register plugins from plugin folder
	const { Plugins } = await import('../public/plugins');
	const appPlugins = new Plugins(window.app);
	Object.assign(window.app.plugins, appPlugins);
	window.dispatchEvent(new Event('YarnEditorReady'));
}

runYarnEditor();
