const dictionaries = {
	en: {
		search: {
			placeholder: 'Search',
			title: 'Title',
			body: 'Body',
			tags: 'Tags',
			linkPlaceholder: 'search',
			addLink: 'Add Link',
		},
		toolbar: {
			createNode: 'Create Node',
			undo: 'Undo',
			redo: 'Redo',
			alignHorizontally: 'Align Horizontally',
			alignVertically: 'Align Vertically',
			alignSpiral: 'Align Spiral',
			sortAlphabetically: 'Sort Alphabetically',
			zoom1: 'Zoom 1:1',
			zoom2: 'Zoom 2:1',
			zoom3: 'Zoom 3:1',
			zoom4: 'Zoom 4:1',
			goBack: 'Go Back To Last Edited Node',
			bold: 'Bold',
			italic: 'Italic',
			underlined: 'Underlined',
			command: 'Command',
			choiceLink: 'Choice/Link',
			image: 'Image',
			colorPicker: 'Color Picker',
			autocomplete: 'Autocompletion Suggestions',
			autoCloseTags: 'Auto Close Tags',
			closeEditor: 'Close Editor',
			snapToOtherSide: 'Snap to Other Side',
			fullSizeEditor: 'Full Size Editor',
			searchEditor: 'Search (Ctrl+f)',
			splitView: 'Split View',
			showLineCounter: 'Show Line Counter',
			autoCloseBrackets: 'Auto Close Brackets',
		},
		editor: {
			titlePlaceholder: 'Title',
			tagsPlaceholder: 'Tags(use spaces)',
			characters: 'Characters:',
			lines: 'Lines:',
			rowIndex: 'Row Index:',
			columnIndex: 'Column Index:',
			syntaxLabel: '{{documentType}} syntax',
			selectHint: 'Alt + Drag to Select',
		},
		errors: {
			duplicateTitle: 'Another node has the same title',
			invalidTitle: 'Node titles cannot be empty and cannot contain whitespace or angle brackets.',
			failedSyntaxCheck: 'Failed to check syntax',
		},
		runner: {
			variables: 'Variables',
			playtestVariables: 'Playtest variables',
			playtestStartingVariables: 'Playtest starting variables',
			name: 'Name',
			variableNamePlaceholder: 'variable_name',
			type: 'Type',
			value: 'Value',
			delete: 'Delete',
			noVariables: 'No variables yet.',
			addVariable: 'Add Variable',
			invalidVariableName: 'Variable names must start with a letter or underscore and contain only letters, numbers, or underscores.',
			invalidNumber: 'Number variables require a valid numeric value.',
			preview: 'Preview',
			pressToAdvance: 'Press Z or Click to advance',
			title: 'Title',
			tags: 'Tags',
			commandCall: 'Command call',
			syntaxError: 'Syntax error',
			typeString: 'string',
			typeNumber: 'number',
			typeBoolean: 'boolean',
		},
		windowTitle: 'Yarn - {{title}} {{dirty}}',
	},
	zh: {
		search: {
			placeholder: '搜索',
			title: '标题',
			body: '正文',
			tags: '标签',
			linkPlaceholder: '搜索',
			addLink: '添加链接',
		},
		toolbar: {
			createNode: '创建节点',
			undo: '撤销',
			redo: '重做',
			alignHorizontally: '水平对齐',
			alignVertically: '垂直对齐',
			alignSpiral: '螺旋排列',
			sortAlphabetically: '按字母排序',
			zoom1: '缩放 1:1',
			zoom2: '缩放 2:1',
			zoom3: '缩放 3:1',
			zoom4: '缩放 4:1',
			goBack: '回到上次编辑节点',
			bold: '加粗',
			italic: '斜体',
			underlined: '下划线',
			command: '命令',
			choiceLink: '选项/链接',
			image: '图片',
			colorPicker: '颜色选择',
			autocomplete: '自动补全建议',
			autoCloseTags: '自动闭合标签',
			closeEditor: '关闭编辑器',
			snapToOtherSide: '吸附到另一侧',
			fullSizeEditor: '全尺寸编辑器',
			searchEditor: '搜索 (Ctrl+f)',
			splitView: '分屏视图',
			showLineCounter: '显示行计数',
			autoCloseBrackets: '自动闭合括号',
		},
		editor: {
			titlePlaceholder: '标题',
			tagsPlaceholder: '标签（用空格分隔）',
			characters: '字符数：',
			lines: '行数：',
			rowIndex: '行：',
			columnIndex: '列：',
			syntaxLabel: '{{documentType}} 语法',
			selectHint: 'Alt + 拖拽选择',
		},
		errors: {
			duplicateTitle: '已有另一个节点使用相同标题',
			invalidTitle: '节点标题不能为空，且不能包含空白字符或尖括号。',
			failedSyntaxCheck: '语法检查失败',
		},
		runner: {
			variables: '变量',
			playtestVariables: '测试运行变量',
			playtestStartingVariables: '测试运行初始变量',
			name: '名称',
			variableNamePlaceholder: '变量名',
			type: '类型',
			value: '值',
			delete: '删除',
			noVariables: '暂无变量。',
			addVariable: '添加变量',
			invalidVariableName: '变量名必须以字母或下划线开头，并且只能包含字母、数字或下划线。',
			invalidNumber: '数值变量需要有效的数字。',
			preview: '预览',
			pressToAdvance: '按 Z 或点击继续',
			title: '标题',
			tags: '标签',
			commandCall: '命令调用',
			syntaxError: '语法错误',
			typeString: '字符串',
			typeNumber: '数值',
			typeBoolean: '布尔值',
		},
		windowTitle: 'Yarn - {{title}} {{dirty}}',
	},
};

const normalizeLanguage = language => String(language || '').match(/^zh/i) ? 'zh' : 'en';

let currentLanguage = normalizeLanguage(new URL(window.location.href).searchParams.get('lang') || navigator.language);
const listeners = new Set();

const getValue = (dictionary, key) => key.split('.').reduce((value, part) => value?.[part], dictionary);

const interpolate = (text, params = {}) => Object.entries(params).reduce(
	(result, [key, value]) => result.replaceAll(`{{${key}}}`, String(value)),
	text
);

const translate = (key, params) => {
	const value = getValue(dictionaries[currentLanguage], key) ?? getValue(dictionaries.en, key) ?? key;
	return typeof value === 'string' ? interpolate(value, params) : key;
};

const translateElement = element => {
	const textKey = element.dataset.i18n;
	if (textKey) {
		element.textContent = translate(textKey);
	}
	const titleKey = element.dataset.i18nTitle;
	if (titleKey) {
		element.setAttribute('title', translate(titleKey));
	}
	const placeholderKey = element.dataset.i18nPlaceholder;
	if (placeholderKey) {
		element.setAttribute('placeholder', translate(placeholderKey));
	}
};

const applyDomTranslations = () => {
	document.documentElement.lang = currentLanguage === 'zh' ? 'zh-Hans' : 'en';
	document.querySelectorAll('[data-i18n], [data-i18n-title], [data-i18n-placeholder]').forEach(translateElement);
	window.app?.refreshSyntaxLabel?.();
	window.app?.validateTitle?.();
};

export const i18n = {
	t: translate,
	language: () => currentLanguage,
	setLanguage(language) {
		const nextLanguage = normalizeLanguage(language);
		if (nextLanguage === currentLanguage) {
			applyDomTranslations();
			return;
		}
		currentLanguage = nextLanguage;
		applyDomTranslations();
		listeners.forEach(listener => listener(currentLanguage));
	},
	onChange(listener) {
		listeners.add(listener);
		return () => listeners.delete(listener);
	},
	applyDomTranslations,
};
