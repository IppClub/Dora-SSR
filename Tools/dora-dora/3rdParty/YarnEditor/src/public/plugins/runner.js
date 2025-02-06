import { yarnRender } from './bondage/renderer';
const { JSONEditor } = require('./jsoneditor/jsoneditor.min');

export var Runner = function({
		app,
		createButton,
		onYarnEditorOpen,
		onYarnInPreviewMode,
		onYarnSavedNode,
		onKeyDown,
		onLoad,
		getPluginStore,
		setPluginStore,
	}) {
	const self = this;
	this.name = 'Runner';

	onLoad(() => {
		// create a button in the file menu
		createButton(self.name, {
			name: 'Playtest variables',
			attachTo: 'fileMenuDropdown',
			onClick: 'onOpenDialog()',
			iconName: 'cog',
		});
	});

	// Variables editor dialog
	this.onOpenDialog = async () => {
		let editor = null;
		const { value: formValues } = await Swal.fire({
			title: 'Playtest starting variables',
			html: '<div class="json-editor-wrapper"><div id="jsoneditor"/></div>',
			focusConfirm: false,
			customClass: 'swal-wide',
			onOpen: () => {
				// create the editor
				require('./jsoneditor/size-overrides.css');
				editor = new JSONEditor(document.getElementById('jsoneditor'), {
					// theme: 'bootstrap2',
					schema: {
						type: 'array',
						format: 'table',
						title: 'Playtest values',
						uniqueItems: true,
						items: {
							type: 'object',
							title: 'Variable',
							format: 'grid',
							properties: {
								key: {
									type: 'string',
									default: 'myVar',
								},
								value: {
									type: 'string',
									default: 'true',
								},
							},
						},
					},
				});

				// set json
				const localVariables = getPluginStore(self.name);
				editor.setValue(
					typeof localVariables.variables !== 'object'
					? [{ key: 'var', value: '1' }]
					: localVariables.variables
				);
			},
			preConfirm: () => {
				return editor.getValue();
			},
		});

		if (formValues) {
			setPluginStore(self.name, 'variables', formValues);
		}
	};

	onKeyDown(e => {
		if (!app.editing() || !app.isEditorInPlayMode()) return;
		switch (e.keyCode) {
			case app.input.keys.Z:
				e.preventDefault();
				if (self.previewStory.finished) {
					self.togglePlayMode(false);
					self.gotoLastPlayNode();
					return;
				}
				if (self.previewStory.vnSelectedChoice != -1) {
					self.previewStory.vnSelectChoice();
				} else {
					self.previewStory.advance();
				}
				if (self.previewStory.paused) {
					self.previewStory.finished = true;
				}
				break;
			case app.input.keys.Up:
				e.preventDefault();
				if (self.previewStory.vnSelectedChoice != -1) {
					self.previewStory.vnUpdateChoice(-1);
				}
				break;
			case app.input.keys.Down:
				e.preventDefault();
				if (self.previewStory.vnSelectedChoice != -1) {
					self.previewStory.vnUpdateChoice(1);
				}
				break;
		}
	});

	const updateRunnerMode = () => {
		this.previewStory = new yarnRender(app);

		this.gotoLastPlayNode = function() {
			if (
				app.editing() &&
				app.editing().title() !== self.previewStory.node.title
			) {
				app.openNodeByTitle(self.previewStory.node.title);
			}
			app.editor.focus();
		};

		this.advanceStoryPlayMode = function() {
			if (!self.previewStory.finished && !self.previewStory.paused) {
				self.previewStory.advance();
			} else {
				self.togglePlayMode(false);
				self.gotoLastPlayNode();
			}
		};

		this.togglePlayMode = function(playModeOverwrite = false) {
			const editor = $('.editor')[0];
			const storyPreviewPlayButton = document.getElementById(
				'storyPlayButton'
			);
			const editorPlayPreviewer = document.getElementById('editor-play');
			$('#editor-play').addClass('inYarnMode');
			$('#commandDebugLabel').addClass('inYarnMode');
			app.isEditorInPlayMode(playModeOverwrite);
			if (playModeOverwrite) {
				//preview play mode
				editor.style.display = 'none';
				$('.bbcode-toolbar').addClass('hidden');
				editorPlayPreviewer.style.display = 'flex';
				$(storyPreviewPlayButton).addClass('disabled');
				self.previewStory.emiter.on('finished', function() {
					self.togglePlayMode(false);
					self.gotoLastPlayNode();
				});
				self.previewStory.emiter.on('startedNode', function(e) {
					if (app.isEditorSplit) {
						app.workspace.warpToNode(
							app.getFirstFoundNode(e.title.toLowerCase().trim())
						);
					}
				});
				const localVariables = getPluginStore(self.name);
				app.data.getSaveData('json').then(saveData => {
					let listener = (e) => {
						let syntaxError = e.syntaxError;
						window.document.removeEventListener("YarnChecked", listener);
						self.previewStory.initYarn(
							JSON.parse(saveData),
							app
								.editing()
								.title()
								.trim(),
							'NVrichTextLabel',
							false,
							'commandDebugLabel',
							localVariables.variables || [],
							syntaxError
						);
					};
					window.document.addEventListener("YarnChecked", listener);
					let event = new Event("YarnCheckSyntax");
					event.code = saveData;
					window.document.dispatchEvent(event);
				});
			} else {
				//edit mode
				app.editor.session.setScrollTop(editorPlayPreviewer.scrollTop);
				editorPlayPreviewer.style.display = 'none';
				editor.style.display = 'flex';
				$(storyPreviewPlayButton).removeClass('disabled');
				$('.bbcode-toolbar').removeClass('hidden');
				$('.toggle-toolbar').removeClass('hidden');
				$('.editor-counter').removeClass('hidden');
				self.previewStory.terminate();
			}
		};

		onYarnInPreviewMode(() => self.togglePlayMode(false));
		onYarnSavedNode(() => self.togglePlayMode(false));

		onYarnEditorOpen(() => {
			createButton(self.name, {
				iconName: 'play',
				title: 'Preview',
				attachTo: 'bbcodeToolbar',
				onClick: 'togglePlayMode(true)',
				className: 'bbcode-button bbcode-button-right',
				id: 'storyPlayButton',
			});

			const element = document.createElement('div');
			element.innerHTML = `
			<div class="editor-play" id="editor-play" onpointerdown="app.plugins.${self.name}.advanceStoryPlayMode()">
				<p class="story-playtest-answer" id="NVrichTextLabel"></p>
				<div id="commandDebugLabel"></div>
			</div>
			`;
			document.getElementById('editorContainer').appendChild(element);
		});
	};

	updateRunnerMode();

	//TODO remove this ugly hack
	app.togglePlayMode = this.togglePlayMode;
};
