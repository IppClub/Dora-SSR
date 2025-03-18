const requires: Set<string> = new Set();

const Require = {
	add(name: string) {
		requires.add(name);
	},
	getCode() {
		return Array.from(requires).map((name) => `local ${name} <const> = require("${name}")`).join('\n');
	},
	clear() {
		requires.clear();
	},
};

export default Require;
