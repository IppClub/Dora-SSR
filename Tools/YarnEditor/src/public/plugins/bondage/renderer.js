import YarnBound from 'yarn-bound';
const EventEmitter = require('events').EventEmitter;

export var yarnRender = function(app) {
	let visitedNodes = [];
	this.visitedNodes = visitedNodes; // collects titles of ALL visited nodes
	let node = { title: '' };
	this.node = node; // gets raw data from yarn text nodes
	let emiter = new EventEmitter();
	this.emiter = emiter;
	let commandsPassedLog = [];
	this.commandsPassedLog = commandsPassedLog;
	let commandPassed = '';
	this.commandPassed = commandPassed;
	this.finished = true;

	this.visitedChapters = []; // to keep track of all visited start chapters
	this.vnChoiceSelectionCursor = '>';
	this.startTimeWait;
	this.vnSelectedChoice = -1;
	this.storyChapter = ''; // current chapter choices
	this.choices = {}; // all choices from all start chapters
	this.jsonData = null;
	this.runner = null;
	this.paused = false;

	let vnChoices,
		vnResult,
		htmIDtoAttachYarnTo,
		debugLabelIdToAttachTo = null;

	this.advanceRunner = (choice) => {
		try {
			this.runner.advance(choice);
		} catch (err) {
			vnResult = null;
			this.paused = true;
			let errorMessage = 'string' === typeof err ? err : err.message;
			if (errorMessage.includes("Parse error")) {
				errorMessage = "Syntax error";
			}
			emiter.emit('errorResult', errorMessage);
		}
	};

	this.vnSelectChoice = () => {
		let endTimeWait = new Date().getTime();
		if (endTimeWait - this.startTimeWait < 100) {
			return;
		} // we need to wait for user to see the questions
		const optionText = vnResult.options[this.vnSelectedChoice].text;
		this.choices[this.storyChapter].push(optionText);
		this.emiter.emit('choiceMade', optionText);
		this.advanceRunner(this.vnSelectedChoice);
		this.goToNext();
		this.changeText();
		if (vnResult && vnResult.isDialogueEnd && !this.paused) {
			this.finished = true;
		}
		vnChoices = undefined;
		this.vnSelectedChoice = -1;
	};

	this.vnUpdateChoice = (direction = 0) => {
		// direction: -1 or 1
		if (this.vnSelectedChoice < 0) {
			return;
		}
		if (!vnResult.options) {
			return;
		}
		let attemptChoice = this.vnSelectedChoice + direction;
		if (attemptChoice > vnResult.options.length - 1) {
			attemptChoice = 0;
		} else if (attemptChoice < 0) {
			attemptChoice = vnResult.options.length - 1;
		}
		this.vnSelectedChoice = attemptChoice;
		vnChoices = document.createElement('DIV');
		vnResult.options.forEach((choice, i) => {
			if (!choice.isAvailable) return;
			const btn = document.createElement('DIV');
			if (i == this.vnSelectedChoice) {
				btn.innerHTML = `${this.vnChoiceSelectionCursor} [${choice.text}]`;
			} else {
				btn.innerHTML = `${this.vnChoiceSelectionCursor.replace(
					/.*/gm,
					'&nbsp;'
				)} [${choice.text}]`;
			}
			btn.onclick = e => {
				e.stopPropagation();
				this.vnSelectedChoice = i;
				this.vnUpdateChoice();
				this.vnSelectChoice();
			};
			btn.className = 'storyPreviewChoiceButton';
			vnChoices.appendChild(btn);
		});
		emiter.emit('choiceUpdated', this.vnSelectedChoice);
		this.updateVNHud();
	};

	this.advance = () => {
		if (vnResult && vnResult.constructor.name !== 'OptionsResult') {
			this.advanceRunner();
			this.goToNext();
		}
		this.changeText();
		if (vnResult && vnResult.isDialogueEnd && !this.paused) {
			this.finished = true;
		}
		if (this.paused) {
			this.finished = true;
		}
	};

	// this function is triggered on key press/release
	this.changeText = () => {
		if (this.paused) {
			return;
		}
		if (vnResult.constructor.name === 'TextResult') {
			emiter.emit('textResult', vnResult.text);
		} else if (vnResult.constructor.name === 'OptionsResult') {
			// Add choices to text
			if (this.vnSelectedChoice === -1) {
				this.vnSelectedChoice = 0;
				this.vnUpdateChoice();
				this.startTimeWait = new Date().getTime();
			}
		} else if (vnResult.constructor.name === 'CommandResult') {
			this.runCommand();
		}
	};

	this.goToNext = () => {
		if (!this.runner) return;
		vnResult = this.runner.currentResult;
		if (!vnResult) return;
		if (vnResult && vnResult.markup) {
			let text = vnResult.text;
			if (text === "" && vnResult.markup.length > 0 && vnResult.markup[0].name === "separator_") {
				this.advanceRunner();
				this.goToNext();
				return;
			}
			for (let i = vnResult.markup.length - 1; i >= 0; i--) {
				const item = vnResult.markup[i];
				const {position = 0, length = 0} = item;
				const before = text.substring(0, position);
				const mid = text.substring(position, position + length);
				const after = text.substring(position + length);
				switch (item.name) {
					case "character":
					case "char": {
						const {properties: {name}} = item;
						if (name) {
							text = `[color=fbc400]${name}:[/color] ${text}`;
						}
						break;
					}
					case "b":
						text = `${before}[b]${mid}[/b]${after}`;
						break;
					case "u":
						text = `${before}[u]${mid}[/u]${after}`;
						break;
					case "i":
						text = `${before}[i]${mid}[/i]${after}`;
						break;
					case "color": {
						const {properties: {color}} = item;
						text = `${before}[color=${color}]${mid}[/color]${after}`;
						break;
					}
					case "img":
						text = `${before}[img]${mid}[/img]${after}`;
						break;
				}
			}
			vnResult.text = text;
		}
		if (vnResult.constructor.name === 'TextResult') {
			if (vnResult.metadata && this.node.title !== vnResult.metadata.title) {
				this.node = this.jsonCopy(vnResult.metadata);
				this.visitedNodes.push(vnResult.metadata.title);
				this.emiter.emit('startedNode', this.node);
			}
		}
	};

	this.runCommand = () => {
		emiter.emit('commandCall', vnResult.command);
		commandsPassedLog.push(vnResult.command);
	};

	// trigger this only on text update
	this.updateVNHud = () => {
		if (vnChoices !== undefined) {
			document.getElementById(htmIDtoAttachYarnTo).innerHTML = '';
			document.getElementById(htmIDtoAttachYarnTo).appendChild(vnChoices);
		}
	};

	this.terminate = () => {
		try {
			let element = document.getElementById(htmIDtoAttachYarnTo);
			element && (element.innerHTML = '');

			element = document.getElementById(debugLabelIdToAttachTo);
			element && (element.innerHTML = '');

			vnChoices = undefined;

			emiter.removeAllListeners();
			this.finished = true;
		} catch (e) {
			console.warn(e);
		}
	};

	this.initYarn = (
		yarnDataObject,
		startChapter,
		htmlIdToAttachTo,
		resourcesPath,
		debugLabelId,
		playtestVariables,
		syntaxError
	) => {
		debugLabelIdToAttachTo = debugLabelId;
		htmIDtoAttachYarnTo = htmlIdToAttachTo;
		this.yarnDataObject = yarnDataObject;
		this.startChapter = startChapter;
		this.resourcesPath = resourcesPath;
		this.finished = false;
		document.getElementById(debugLabelIdToAttachTo).innerHTML =
			"<br/><font color='#fbc400'>Press Z or Click to advance</font><br/>";
		if (syntaxError && syntaxError.length > 0) {
			const div = document.createElement("div");
			div.textContent = syntaxError;
			document.getElementById(
				debugLabelIdToAttachTo
			).innerHTML += `<pre class="story-playtest-bubble" style="color: #f05050;">${div.innerHTML}</pre>`;
		}
		emiter.on('startedNode', function(nodeData) {
			document.getElementById(debugLabelIdToAttachTo).innerHTML +=
				"<br/><font color='CADETBLUE'>Title: " +
				nodeData.title +
				'</font>';
			if (nodeData.tags.length > 0 && nodeData.tags[0].length > 0)
				document.getElementById(debugLabelIdToAttachTo).innerHTML +=
					"<br/><font color='deeppink'>Tags: " +
					nodeData.tags +
					'</font>';
		});
		emiter.on('choiceMade', function(choice) {
			document.getElementById(
				debugLabelIdToAttachTo
			).innerHTML += `<p class="story-playtest-bubble story-playtest-answer answer-post">${app.richTextFormatter.richTextToHtml(choice)}</p>`;
		});
		emiter.on('commandCall', function(call) {
			document.getElementById(
				debugLabelIdToAttachTo
			).innerHTML += `<br/><font color='green'>Command call:</font> <font color='#fbc400'>&lt;&lt;${call}&gt;&gt;</font>`;
		});
		emiter.on('errorResult', function(text) {
			document.getElementById(
				debugLabelIdToAttachTo
			).innerHTML += `<p class="story-playtest-bubble" style="color: #f05050;">${text}</p>`;
			document.getElementById(htmIDtoAttachYarnTo).innerHTML =
				'<span class="story-animated-dots"><p>.</p><p>.</p><p>.</p></span>';
			//story-playtest-bubble
			document.getElementById(htmIDtoAttachYarnTo).className =
				'story-playtest-bubble';
			document.getElementById(debugLabelIdToAttachTo).scrollTo({
				top: document.getElementById(debugLabelIdToAttachTo).scrollHeight,
				left: 0,
				behavior: 'smooth',
			});
		});
		emiter.on('textResult', function(text) {
			document.getElementById(
				debugLabelIdToAttachTo
			).innerHTML += `<p class="story-playtest-bubble">${app.richTextFormatter.richTextToHtml(
				text
			)}</p>`;
			document.getElementById(htmIDtoAttachYarnTo).innerHTML =
				'<span class="story-animated-dots"><p>.</p><p>.</p><p>.</p></span>';
			//story-playtest-bubble
			document.getElementById(htmIDtoAttachYarnTo).className =
				'story-playtest-bubble';
			document.getElementById(debugLabelIdToAttachTo).scrollTo({
				top: document.getElementById(debugLabelIdToAttachTo).scrollHeight,
				left: 0,
				behavior: 'smooth',
			});
		});
		emiter.on('choiceUpdated', function(choiceIndex) {
			document.getElementById(htmIDtoAttachYarnTo).className =
				'story-playtest-answer';
		});

		emiter.on('finished', function() {
			emiter.removeAllListeners();
		});

		if (Array.isArray(yarnDataObject)) {
			this.jsonData = yarnDataObject;
		} else if ('nodes' in yarnDataObject) {
			this.jsonData = yarnDataObject.nodes;
		} else return;

		for (let node of this.jsonData) {
			node.body = node.body.trim().replace(/\n\s*\n/g, "\n//\n").replace(/(^\s*)(<<.*?>>)/gm, (match, indent, content) => {
				return `${indent}${content}\n${indent}[separator_/]`;
			});
			const operatorMap = {
				'+=': '+',
				'-=': '-',
				'*=': '*',
				'/=': '/',
				'%=': '%'
			};
			// Replace shorthand operators (+=, -=, *=, /=, %=) with their full form
			node.body = node.body.replace(/<<set\s+(\$[\w_]+)\s*(\+=|\-=|\*=|\/=|%=)\s*(.+?)>>/g, (match, variable, operator, value) => {
				return `<<set ${variable} = ${variable} ${operatorMap[operator]} ${value}>>`;
			});
		}
		const variables = new Map();
		playtestVariables.forEach(function(variable) {
			const numVar = Number.parseFloat(variable.value);
			if (!Number.isNaN(numVar)) {
				variables.set(variable.key, numVar);
			} else {
				let booleanVar = undefined;
				switch (variable.value.trim()) {
					case "true":
						booleanVar = true;
						break;
					case "false":
						booleanVar = false;
						break;
				}
				if (booleanVar !== undefined) {
					variables.set(variable.key, booleanVar);
				} else {
					variables.set(variable.key, variable.value);
				}
			}
		});
		this.loadYarnChapter(startChapter, variables);
	};

	this.loadYarnChapter = (storyChapter, variables) => {
		this.finished = false;
		this.vnSelectedChoice = -1;
		this.storyChapter = storyChapter;
		this.choices[this.storyChapter] = [];
		this.visitedChapters.push(storyChapter);
		this.paused = false;
		this.runner = null;
		vnResult = null;
		try {
			this.runner = new YarnBound({
				dialogue: this.jsonData,
				startAt: storyChapter,
				variableStorage: variables,
				handleCommand: (result) => {
					emiter.emit('commandCall', result.command);
				},
			});
		} catch (err) {
			vnResult = null;
			this.paused = true;
			let errorMessage = 'string' === typeof err ? err : err.message;
			if (errorMessage.includes("Parse error")) {
				errorMessage = "Syntax error";
			}
			emiter.emit('errorResult', errorMessage);
		}
		this.goToNext();
		this.changeText();
		if (vnResult && vnResult.isDialogueEnd && !this.paused) {
			this.finished = true;
		}
	};

	// external function to check if a choice was made
	this.wasChoiceMade = (
		choiceName,
		chapterInWhichItWasMade = this.storyChapter
	) => {
		if (this.choices[chapterInWhichItWasMade].includes(choiceName)) {
			return true;
		} else {
			return false;
		}
	};

	// external function to check how many times a node has been visited
	this.timesNodeWasVisited = nodeName => {
		let counted = 0;
		this.visitedNodes.forEach((visitedNode, i) => {
			if (visitedNode === nodeName) {
				counted += 1;
			}
		});
		return counted;
	};

	// we need this to make copies instead of references
	this.jsonCopy = src => {
		return JSON.parse(JSON.stringify(src));
	};
};
