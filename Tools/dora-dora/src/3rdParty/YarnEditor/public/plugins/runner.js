import { yarnRender } from './bondage/renderer';

const variableTypes = ['string', 'number', 'boolean'];

const inferVariableType = value => {
	if (typeof value === 'boolean') return 'boolean';
	if (typeof value === 'number') return 'number';
	const text = String(value ?? '').trim();
	if (text === 'true' || text === 'false') return 'boolean';
	if (text !== '' && !Number.isNaN(Number.parseFloat(text)) && Number.isFinite(Number(text))) {
		return 'number';
	}
	return 'string';
};

const normalizeVariable = variable => {
	const type = variableTypes.includes(variable.type)
		? variable.type
		: inferVariableType(variable.value);
	return {
		key: variable.key || '',
		type,
		value: String(variable.value ?? (type === 'boolean' ? 'false' : '')),
	};
};

const createElement = (tagName, className, text) => {
	const element = document.createElement(tagName);
	if (className) element.className = className;
	if (text !== undefined) element.textContent = text;
	return element;
};

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
	const t = (key, params) => app.t(`runner.${key}`, params);
	const typeLabels = {
		string: () => t('typeString'),
		number: () => t('typeNumber'),
		boolean: () => t('typeBoolean'),
	};

	onLoad(() => {
		// create a button in the file menu
		createButton(self.name, {
			name: t('variables'),
			title: t('playtestVariables'),
			attachTo: 'fileMenuDropdown',
			onClick: 'onOpenDialog()',
			iconName: 'cog',
			id: 'runnerVariablesButton',
		});
	});

	// Variables editor dialog
	this.onOpenDialog = async () => {
		const localVariables = getPluginStore(self.name);
		const startingVariables = (
			Array.isArray(localVariables.variables)
			? localVariables.variables
			: []
		).map(normalizeVariable);
		let variableRows = startingVariables;

		const renderVariableRows = () => {
			const list = document.getElementById('variablesEditorRows');
			if (!list) return;
			list.innerHTML = '';
			variableRows.forEach((variable, index) => {
				const row = createElement('div', 'variables-editor-row');
				row.dataset.index = String(index);

				const nameField = createElement('label', 'variables-editor-field variables-editor-name');
				nameField.appendChild(createElement('span', null, t('name')));
				const nameInput = createElement('input');
				nameInput.type = 'text';
				nameInput.value = variable.key;
				nameInput.placeholder = t('variableNamePlaceholder');
				nameInput.pattern = '[A-Za-z_][A-Za-z0-9_]*';
				nameInput.autocomplete = 'off';
				nameInput.addEventListener('input', event => {
					event.target.value = event.target.value.replace(/[^A-Za-z0-9_]/g, '');
					variableRows[index].key = event.target.value;
				});
				nameField.appendChild(nameInput);

				const typeField = createElement('label', 'variables-editor-field variables-editor-type');
				typeField.appendChild(createElement('span', null, t('type')));
				const typeSelect = createElement('select');
				variableTypes.forEach(type => {
					const option = createElement('option', null, typeLabels[type]());
					option.value = type;
					option.selected = variable.type === type;
					typeSelect.appendChild(option);
				});
				typeSelect.addEventListener('change', event => {
					const nextType = event.target.value;
					const oldValue = variableRows[index].value;
					variableRows[index].type = nextType;
					if (nextType === 'boolean') {
						variableRows[index].value = oldValue === 'true' ? 'true' : 'false';
					} else if (nextType === 'number') {
						const numberValue = Number.parseFloat(oldValue);
						variableRows[index].value = Number.isNaN(numberValue) ? '0' : String(numberValue);
					}
					renderVariableRows();
				});
				typeField.appendChild(typeSelect);

				const valueField = createElement('label', 'variables-editor-field variables-editor-value');
				valueField.appendChild(createElement('span', null, t('value')));
				let valueControl;
				if (variable.type === 'boolean') {
					valueControl = createElement('select');
					['true', 'false'].forEach(value => {
						const option = createElement('option', null, value);
						option.value = value;
						option.selected = variable.value === value;
						valueControl.appendChild(option);
					});
				} else {
					valueControl = createElement('input');
					valueControl.type = variable.type === 'number' ? 'number' : 'text';
					valueControl.value = variable.value;
					if (variable.type === 'number') valueControl.step = 'any';
					valueControl.autocomplete = 'off';
				}
				valueControl.addEventListener('input', event => {
					variableRows[index].value = event.target.value;
				});
				valueControl.addEventListener('change', event => {
					variableRows[index].value = event.target.value;
				});
				valueField.appendChild(valueControl);

				const deleteButton = createElement('button', 'variables-editor-delete', t('delete'));
				deleteButton.type = 'button';
				deleteButton.addEventListener('click', () => {
					variableRows.splice(index, 1);
					renderVariableRows();
				});

				row.appendChild(nameField);
				row.appendChild(typeField);
				row.appendChild(valueField);
				row.appendChild(deleteButton);
				list.appendChild(row);
			});

			if (variableRows.length === 0) {
				list.appendChild(createElement('div', 'variables-editor-empty', t('noVariables')));
			}
		};

		const { value: formValues } = await Swal.fire({
			title: t('playtestStartingVariables'),
			html: `
				<div class="variables-editor">
					<div class="variables-editor-header">
						<span>${t('name')}</span>
						<span>${t('type')}</span>
						<span>${t('value')}</span>
						<span></span>
					</div>
					<div class="variables-editor-rows" id="variablesEditorRows"></div>
					<button class="variables-editor-add" id="variablesEditorAdd" type="button">${t('addVariable')}</button>
				</div>
			`,
			focusConfirm: false,
			customClass: {
				container: 'variables-dialog-container',
				popup: 'swal-wide variables-dialog',
			},
			onOpen: () => {
				document.getElementById('variablesEditorAdd').addEventListener('click', () => {
					variableRows.push({ key: '', type: 'string', value: '' });
					renderVariableRows();
					const rows = document.querySelectorAll('.variables-editor-row');
					const latestName = rows[rows.length - 1]?.querySelector('.variables-editor-name input');
					if (latestName) latestName.focus();
				});
				renderVariableRows();
			},
			preConfirm: () => {
				const sanitizedRows = variableRows
					.map(normalizeVariable)
					.filter(variable => variable.key.trim() !== '');
				const invalidName = sanitizedRows.find(variable => !/^[A-Za-z_][A-Za-z0-9_]*$/.test(variable.key));
				if (invalidName) {
					Swal.showValidationMessage(t('invalidVariableName'));
					return false;
				}
				const invalidNumber = sanitizedRows.find(variable => (
					variable.type === 'number' &&
					(variable.value.trim() === '' || !Number.isFinite(Number(variable.value)))
				));
				if (invalidNumber) {
					Swal.showValidationMessage(t('invalidNumber'));
					return false;
				}
				return sanitizedRows.map(variable => ({
					key: variable.key.trim(),
					type: variable.type,
					value: variable.type === 'boolean' ? variable.value === 'true' : variable.value.trim(),
				}));
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
				title: t('preview'),
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
