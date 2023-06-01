/* eslint-disable jquery/no-ajax */
const path = require('path');
const saveAs = require('file-saver');
import { Node } from './node';
import { FILETYPE } from './utils';

export const data = {
	appInstanceStates: ko.observable([]),
	restoreFromLocalStorage: ko.observable(false),
	// All the bellow go into appInstanceStates, which controls r/w of app states to local storage (for file tabs feature)
	isDocumentDirty: ko.observable(false),
	editingPath: ko.observable(null),
	editingName: ko.observable('NewFile'),
	editingType: ko.observable('json'),
	editingFolder: ko.observable(null),
	documentHeader: ko.observable(null),
	lastStorageHost: ko.observable('LOCAL'), // GIST | LOCAL
	lastEditedUnix: ko.observable(new Date()),
	lastSavedUnix: ko.observable(null),
	editingFileFolder: function(addSubPath = '') {
		const filePath = data.editingPath() ? data.editingPath() : '';
		return addSubPath.length > 0
			? path.join(path.dirname(filePath), addSubPath)
			: path.dirname(filePath);
	},
	startNewFile: function(editingName = 'NewFile', content) {
		data.editingPath(null);
		data.editingName(editingName);
		data.editingType('json');
		data.editingFolder(null);
		data.documentHeader(null);
		app.workspace.selectedNodes = [];
		app.editing(null);
		if (content === undefined || content === "") {
			app.nodes([
				app
					.newNode(true)
					.title('Start')
					.body('Empty text'),
			]);
			app.tags([]);
			app.updateNodeLinks();
		} else {
			data.loadJSONData(content);
		}
		app.workspace.warpToNodeByIdx(0);
		data.lastStorageHost('LOCAL');
		data.isDocumentDirty(true);
		app.refreshWindowTitle();
		//data.saveAppStateToLocalStorage();
		app.ui.dispatchEvent('newYarnFileStarted');
	},
	askForFileName: function() {
		Swal.fire({
			title: 'Enter a New File Name',
			input: 'text',
			inputPlaceholder: 'NewFile',
			showCancelButton: true,
		}).then(result => {
			if (result.value || result.value === '') {
				data.startNewFile(result.value || 'NewFile');
			}
		});
	},
	setNewFile: function() {
		Swal.fire({
			title: 'Create a New File?',
			text: `Any unsaved progress to ${data.editingName()}.${data.editingType()} will be lost!
			Path: ${data.editingPath()}
			Storage: ${data.lastStorageHost()}
			`,
			icon: 'warning',
			showCancelButton: true,
			confirmButtonText: 'New file',
			cancelButtonText: 'No, cancel!',
		}).then(result => {
			if (result.value) {
				data.askForFileName();
			}
		});
	},
	loadDocumentStateTabFromIndex: function(index) {
		console.log('ATTEMPT TO LOAD STATE', index);
		app.settings.selectedFileTab(index);
		data.loadAppStateFromLocalStorage();
	},
	getCurrentAppState: function() {
		return {
			editingPath: data.editingPath(),
			editingName: data.editingName(),
			documentType: app.settings.documentType(),
			editingType: data.editingType(),
			editingFolder: data.editingFolder(),
			editingTitle: app.editing() ? app.editing().title() : null,
			nodes: data.getNodesAsObjects(),
			documentHeader: data.documentHeader(),
			tags: app.tags(),
			editorSelection: app.editor ? app.editor.selection.getRange() : null,
			transform: app.workspace.transform,
			scale: app.workspace.scale,
			lastStorageHost: data.lastStorageHost(),
			lastEditedUnix: data.lastEditedUnix() || '',
			lastSavedUnix: data.lastSavedUnix(),
			pluginStorage: app.plugins.pluginStorage,
		};
	},
	deleteDocumentStateTab: function(index) {
		Swal.fire({
			title: 'Are you sure?',
			text: `Are you sure you want to close this file? Any unsaved changes to ${data.editingName()}.${data.editingType()} will be lost!
			Path: ${data.editingPath() || ''}
			Storage: ${data.lastStorageHost()}
			`,
			icon: 'warning',
			showCancelButton: true,
			confirmButtonText: 'Yes close',
			cancelButtonText: 'Cancel',
			reverseButtons: true,
		}).then(result => {
			if (result.value) {
				console.log('DELETE TAB', data.appInstanceStates(), index);
				const mutatedState = data
					.appInstanceStates()
					.filter((_, i) => i !== index)
					.map(state => ({ ...state }));
				data.appInstanceStates([...mutatedState]);
				data.saveAppStateToLocalStorage();

				setTimeout(() => {
					const nextIndex =
						index > data.appInstanceStates().length - 1
							? data.appInstanceStates().length - 1
							: index;
					data.loadDocumentStateTabFromIndex(nextIndex);
				}, 500);
				console.log(
					data.appInstanceStates(),
					'resulting mutation',
					mutatedState
				); //ok
			}
		});
	},
	addDocumentState: function({ editingName, editingType, yarnData, checked }) {
		//Mutate states
		data.appInstanceStates([
			...data.appInstanceStates(),
			{ ...data.getCurrentAppState() }, //this is pretty slow
		]);
		console.log('DOCUMENT TAB ADDED', data.appInstanceStates());
		data.saveAppStateToLocalStorage();
		data.loadDocumentStateTabFromIndex(data.appInstanceStates().length - 1);
		if (checked) {
			data.editingName(editingName);
			data.editingType(editingType);
		} else {
			data.startNewFile(editingName, editingType);
		}

		console.log({ editingName, yarnData, editingType, checked });
	},
	addDocumentStateTab: function() {
		data.promptFileNameAndFormat(
			data.addDocumentState,
			null,
			'📜 Name of new file',
			` Copy of ${data.editingName()}`
		);
	},
	saveAppStateToLocalStorage: function(writeCurrent = true) {
		if (writeCurrent) app.ui.dispatchEvent('yarnSavedStateToLocalStorage');
		if (!data.restoreFromLocalStorage()) return;

		const storage = app.settings.storage;
		data.isDocumentDirty(true);
		data.lastEditedUnix(new Date());
		app.refreshWindowTitle();
		console.log('Update storage', data.appInstanceStates(), writeCurrent);
		const updatedStates = [...data.appInstanceStates()];
		if (writeCurrent)
			updatedStates[app.settings.selectedFileTab()] = data.getCurrentAppState();
		data.appInstanceStates(updatedStates);
		storage.setItem('appStates', JSON.stringify(data.appInstanceStates()));
	},
	loadAppStateFromLocalStorage: function() {
		if (!data.restoreFromLocalStorage()) return; // to ignore sometimes?

		const storage = app.settings.storage;
		// Just in case clear old state's cache
		if (storage.getItem('appState')) storage.clear(); //TODO remove later
		const appStates = JSON.parse(storage.getItem('appStates')); // appStateS <- new key
		const currentDocState = appStates[app.settings.selectedFileTab()];
		data.appInstanceStates(appStates);
		//console.log('APP state', appStates, currentDocState);
		if (currentDocState) {
			const {
				editingPath,
				lastStorageHost,
				editingName,
				editingType,
				documentType,
				editingFolder,
				editingTitle,
				editorSelection,
				nodes,
				documentHeader,
				tags,
				transform,
				scale,
				pluginStorage,
				lastEditedUnix,
				lastSavedUnix,
			} = currentDocState;
			data.editingPath(editingPath);
			data.editingName(editingName);
			data.editingType(editingType);
			app.settings.documentType(documentType);
			data.editingFolder(editingFolder);
			data.lastStorageHost(lastStorageHost);
			data.lastEditedUnix(lastEditedUnix);
			data.lastSavedUnix(lastSavedUnix);
			app.nodes([]);
			data.getNodesFromObjects(nodes).forEach(node => app.nodes.push(node));
			app.tags(tags);
			app.updateNodeLinks();
			app.workspace.setTranslation(transform.x, transform.y);
			app.workspace.setZoom(scale * 4);
			if (editingTitle) {
				app.editNode(app.nodes().find(node => node.title() === editingTitle));
				if (editorSelection) app.editor.selection.setRange(editorSelection);
			}
			app.plugins.pluginStorage = pluginStorage;

			console.log("local storage load header", content.header);
			data.documentHeader(documentHeader);
			data.isDocumentDirty(true);
			app.refreshWindowTitle();
			app.ui.dispatchEvent('yarnLoadedStateFromLocalStorage');
		}
	},
	readFile: function(file, filename, clearNodes) {
		data.getFileData(file, filename).then(result => {
			data.editingPath(file.path);
			data.editingType(result.type);
			data.loadData(result.data, result.type, clearNodes);
		});
	},

	setNewFileStats: function(fileName, filePath, lastStorageHost = 'LOCAL') {
		console.log('Updated save data', fileName, filePath);
		data.editingName(fileName.replace(/^.*[\\\/]/, ''));
		data.isDocumentDirty(false);
		data.editingPath(filePath);
		data.lastStorageHost(lastStorageHost);
		app.refreshWindowTitle();
	},
	openFile: function(file, filename) {
		const confirmText = data.editingPath()
			? 'Any unsaved progress to ' + data.editingName() + ' will be lost.'
			: 'Any unsaved progress will be lost.';

		Swal.fire({
			title: 'Are you sure you want to open another file?',
			text: confirmText,
			icon: 'warning',
			showConfirmButton: true,
			showCancelButton: true,
		}).then(result => {
			if (result.value === true) {
				data.readFile(file, filename, true);
				data.setNewFileStats(filename, file.path);
				app.refreshWindowTitle();
			}
		});
	},
	openFileFromFilePath: function(filePath) {
		const fileName = app.path.basename(filePath);
		$.ajax({
			url: filePath,
			async: false,
			success: result => {
				const type = data.getFileType(fileName);
				if (type === FILETYPE.UNKNOWN) {
					Swal.fire({
						title: 'Unknown filetype!',
						icon: 'error',
					});
				} else {
					data.loadData(result, type, true);
					data.setNewFileStats(fileName, filePath);
					data.editingType(type);
				}
			},
		});
	},
	getFileData: function(file, filename) {
		return new Promise((resolve, reject) => {
			const reader = new FileReader();
			reader.onload = function(e) {
				const type = data.getFileType(filename);
				if (type === FILETYPE.UNKNOWN) {
					Swal.fire({
						title: 'Unknown filetype!',
						icon: 'error',
					});
					reject();
				} else {
					resolve({
						file,
						type,
						data: reader.result,
						name: file.name,
					});
				}
			};
			reader.readAsText(file);
		});
	},
	openFiles: async function(file, filename) {
		const files = document.getElementById('open-file').files;

		for (const file of Object.values(files)) {
			const fileData = await data.getFileData(file, file.name);
			console.log('FILEDATA', fileData);
			const editingName = fileData.name;
			const editingType = fileData.type;
			data.addDocumentState({
				editingName,
				editingType,
				yarnData: fileData.data,
			});
			data.loadData(fileData.data, editingType, true);
		}
	},
	openFolder: function(e, foldername) {
		editingFolder = foldername;
		Swal.fire({
			text:
				'openFolder not yet implemented e: ' + e + ' foldername: ' + foldername,
			icon: 'error',
		});
	},

	appendFile: function(file, filename) {
		data.readFile(file, filename, false);
	},

	getFileType: function(filename) {
		const lowerFileName = filename.toLowerCase();

		if (lowerFileName.endsWith('.json')) return FILETYPE.JSON;

		return FILETYPE.UNKNOWN;
	},

	dispatchEventDataLoaded: function() {
		var event = new CustomEvent('yarnLoadedData');
		event.document = document;
		event.data = data;
		event.app = app;
		window.dispatchEvent(event);
		window.parent.dispatchEvent(event);
	},
	restoreSettingsFromDocumentHeader: function() {
		/*
		if (data.documentHeader() !== null) {
			const documentHeader = data.documentHeader();
			console.log('Apply settings from file header:', documentHeader);
			if ('markupLanguage' in documentHeader)
				app.settings.markupLanguage(documentHeader.markupLanguage);
			if ('language' in documentHeader)
				app.settings.language(documentHeader.language);
			if ('filetypeVersion' in documentHeader)
				app.settings.filetypeVersion(documentHeader.filetypeVersion);
			app.settings.apply();
		}*/
	},
	loadJSONData: function(content) {
		data.loadData(content, FILETYPE.JSON, true);
	},
	loadData: function(content, type, clearNodes) {
		const objects = [];
		const pushContent = extractedNodes => {
			for (let i = 0; i < extractedNodes.length; i++) {
				if ('title' in extractedNodes[i]) objects.push(extractedNodes[i]);
			}
		};

		// different depending on file
		if (type === FILETYPE.JSON) {
			content = JSON.parse(content);
			if (!content) {
				return;
			}
			if (Array.isArray(content)) {
				// Old json format
				pushContent(content);
			} else {
				// New Json format
				data.documentHeader(content.header);
				pushContent(content.nodes);
			}
			app.setDocumentType('yarn'); //TODO try to store yarn in json
		}

		app.limitNodesUpdate(() => {
			if (clearNodes) app.nodes.removeAll();

			data.getNodesFromObjects(objects).forEach(node => app.nodes.push(node));
		});

		data.editingType(type); // Set type when loading
		data.restoreSettingsFromDocumentHeader();
		app.updateNodeLinks();
		app.workspace.warpToNodeByIdx(0);
		data.isDocumentDirty(false);

		// Callback for embedding in other webapps
		data.dispatchEventDataLoaded();
	},
	getNodeFromObject: function(object) {
		return new Node({
			title: object.title,
			body: object.body,
			tags: object.tags,
			colorID: object.colorID,
			x: parseInt(object.position.x),
			y: parseInt(object.position.y),
		});
	},
	getNodeAsObject: function(node) {
		return {
			title: node.title(),
			tags: node.tags(),
			body: node.body(),
			position: { x: node.x(), y: node.y() },
			colorID: node.colorID(),
		};
	},
	getNodesFromObjects: function(objects) {
		const appNodes = [];
		if (!objects) return [];
		objects.forEach(object => {
			appNodes.push(data.getNodeFromObject(object));
		});
		return appNodes;
	},

	getNodesAsObjects: function() {
		const nodesObjects = [];
		const nodes = app.nodes();

		for (var i = 0; i < nodes.length; i++) {
			nodesObjects.push(data.getNodeAsObject(nodes[i]));
		}
		return nodesObjects;
	},

	getJSONData: function() {
		return data.getSaveData(FILETYPE.JSON);
	},

	getSaveData: async function(
		type,
		content = data.getNodesAsObjects()
	) {
		var output = '';

		if (type === FILETYPE.JSON) {
			// store useful values for later use if the file type supports it
			if (app.settings.filetypeVersion() === '2') {
				const date = new Date();
				data.documentHeader({
					...data.documentHeader(),
					lastSavedUnix: date,
					language: app.settings.language(),
					documentType: app.settings.documentType(),
					markupLanguage: app.settings.markupLanguage(),
					filetypeVersion: app.settings.filetypeVersion(),
					pluginStorage: app.plugins.pluginStorage,
				});
				output = JSON.stringify(
					{ header: data.documentHeader(), nodes: content },
					null,
					'\t'
				);
			} else {
				output = JSON.stringify(content, null, '\t');
			}
		}

		//console.log("Exporter Output", output);

		data.isDocumentDirty(false);
		app.refreshWindowTitle();
		return output;
	},

	saveTo: function(path, content, callback = null) {
		if (app.fs) {
			app.fs.writeFile(path, content, { encoding: 'utf-8' }, function(err) {
				data.editingPath(path);
				if (callback) callback();
				if (err) {
					Swal.fire({
						title: 'Error Saving Data to ' + path + ': ' + err,
						icon: 'error',
					});
				} else {
					app.ui.notification.fire({
						title: 'Saved!',
						icon: 'success',
					});
					app.ui.dispatchEvent('yarnSavedData');
					data.setNewFileStats(path, path, 'LOCAL');
				}
			});
		}
	},

	openFileDialog: function(dialog, callback) {
		dialog.bind('change', function(e) {
			// make callback
			callback(e.currentTarget.files[0], dialog.val());

			// replace input field with a new identical one, with the value cleared
			// (html can't edit file field values)
			var saveas = '';
			var accept = '';
			if (dialog.attr('nwsaveas') != undefined)
				saveas = 'nwsaveas="' + dialog.attr('nwsaveas') + '"';
			if (dialog.attr('accept') != undefined)
				saveas = 'accept="' + dialog.attr('accept') + '"';

			dialog
				.parent()
				.append(
					'<input type="file" id="' +
						dialog.attr('id') +
						'" ' +
						accept +
						' ' +
						saveas +
						'>'
				);
			dialog.unbind('change');
			dialog.remove();
		});

		dialog.trigger('click');
	},

	saveFileDialog: function(dialog, type, content) {
		const fileName =
			(data.editingName() || '').replace(/\.[^/.]+$/, '') + '.' + type;
		var blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
		saveAs(blob, fileName);
	},

	tryOpenFile: function() /// Refactor to send signal to the main process
	{
		data.openFileDialog($('#open-file'), data.openFiles);
	},

	promptFileNameAndFormat: function(
		cb,
		suggestions = null,
		title = '💾 Save file - enter file name',
		showCheckBox = ''
	) {
		const guessedFileName =
			data.editingName().replace(/\.[^/.]+$/, '') +
			'(new).' +
			data.editingType();
		Swal.fire({
			title,
			html: ` <input id="swal-input1" list="select-file-name" name="select" placeholder="${guessedFileName}">
			<datalist class="form-control" id="select-file-name">
				${suggestions &&
					suggestions
						.map(suggestion => `<option value="${suggestion}" />`)
						.join('')}
			</datalist>
			${
				showCheckBox
					? `<br/><br/><input type="checkbox" id="swal-checkbox-checked"> ${showCheckBox}</input>`
					: ''
			}
				`,
			onOpen: () => {
				if (data.editingName() !== 'NewFile') {
					document.getElementById('swal-input1').value = guessedFileName;
				}
			},
			showCancelButton: true,
			preConfirm: () => ({
				name: document.getElementById('swal-input1').value,
				checked: showCheckBox
					? document.getElementById('swal-checkbox-checked').checked
					: false,
			}),
		}).then(({ value }) => {
			if (value) {
				const { name, checked } = value;
				const guessedNewFormat = name.split('.').pop();
				const editingType = Object.values(FILETYPE).includes(guessedNewFormat)
					? guessedNewFormat
					: data.editingType();
				const editingName =
					(name || '').replace(/\.[^/.]+$/, '') + '.' + editingType;
				data.getSaveData(editingType).then(yarnData => {
					cb({
						editingName,
						editingType,
						yarnData,
						checked,
					});
				});
			}
		});
	},

	tryShareFilePwa: function(format) {
		data.promptFileNameAndFormat(({ editingName, yarnData }) => {
			const parts = [new Blob([yarnData], { type: 'text/plain' })];
			const file = new File(parts, editingName, {});

			if (
				navigator.canShare &&
				navigator.canShare({
					files: [file],
				})
			) {
				navigator
					.share({
						title: editingName,
						text: yarnData,
						file: [file],
					})
					.then(() => console.log('Successful share'))
					.catch(error => console.log('Error sharing', error));
			} else {
				Swal.fire({
					title:
						'Web Share API is not supported in your browser.\nTry using it on your smartphone or tablet...',
					icon: 'error',
				});
			}
		});
	},

	tryOpenFolder: function() {
		data.openFileDialog($('#open-folder'), data.openFolder);
	},

	tryAppend: function() {
		data.openFileDialog($('#open-file'), data.appendFile);
	},

	save: function() {
		if (app.editingVisualStudioCodeFile()) {
			// if we're editing a file in the VSCode extension, it handles
			// saving the file on its end so we do nothing here
			return;
		}

		if (data.editingPath()) data.trySaveCurrent();
		else data.trySave(FILETYPE.JSON);
	},

	trySave: function(type) {
		data
			.getSaveData(type)
			.then(saveData => data.saveFileDialog($('#save-file'), type, saveData));
	},

	trySaveCurrent: function() {
		if (!data.isDocumentDirty()) return;

		if (data.editingPath().length > 0 && data.editingType().length > 0) {
			data.getSaveData(data.editingType()).then(saveData => {
				data.saveTo(data.editingPath(), saveData);
			});
		}
	},

	doesFileExist: function(filePath) {
		//todo remove fs from everywhere, use cache to load images instead
		return false;
	},
	triggerPasteClipboard: function() {
		if (navigator.clipboard) {
			navigator.clipboard
				.readText()
				.then(text => {
					app.clipboard = text;
				})
				.catch(err => {
					app.clipboard = app.editor.getSelectedText();
					console.log('No clipboard access', err, 'using local instead');
				});
		}
		// execCommand("paste") will not work on web browsers, due to security
		setTimeout(() => app.insertTextAtCursor(app.clipboard), 100);
	},
	triggerCopyClipboard: function() {
		const selectedText = app.editor.getSelectedText();
		app.clipboard = selectedText;
		if (navigator.clipboard && selectedText.length > 0) {
			navigator.clipboard.writeText(selectedText).then(() => {
				/* clipboard successfully set */
				app.clipboard = selectedText;
			});
		}
	},
};
