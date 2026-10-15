export function registerYarnMode(ace) {
	ace.define('ace/mode/yarn', [
		'require',
		'exports',
		'module',
		'ace/lib/oop',
		'ace/mode/text',
		'ace/mode/text_highlight_rules',
		'ace/mode/behaviour/cstyle',
	], function(require, exports) {
		'use strict';

		var oop = require('../lib/oop');
		var TextMode = require('./text').Mode;
		var TextHighlightRules = require('./text_highlight_rules').TextHighlightRules;
		var CstyleBehaviour = require('./behaviour/cstyle').CstyleBehaviour;

		var YarnHighlightRules = function() {
			this.$rules = {
				start: [
					{
						token: 'comment',
						regex: '^\\/\\/.*$',
					},
					{
						token: 'paren.lcomm',
						regex: '<<',
						next: 'comm',
					},
				],
				link: [
					{
						token: 'string.llink',
						regex: '[^\\s<>]+',
					},
				],
				comm: [
					{
						token: 'string.comm',
						regex: '[^>]+',
					},
					{
						token: 'paren.rcomm',
						regex: '>>',
						next: 'start',
					},
				],
			};
		};

		var Mode = function() {
			this.HighlightRules = YarnHighlightRules;
			this.$behaviour = new CstyleBehaviour();
		};

		oop.inherits(YarnHighlightRules, TextHighlightRules);
		oop.inherits(Mode, TextMode);

		(function() {
			this.type = 'text';
			this.getNextLineIndent = function(state, line) {
				return this.$getIndent(line);
			};
			this.$id = 'ace/mode/yarn';
		}.call(Mode.prototype));

		exports.Mode = Mode;
	});
}
