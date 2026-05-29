let myCodeMirror = CodeMirror(document.getElementById("live-code"), {
	value: '',
	mode: "lua",
	lineNumbers: true,
	readOnly: true,
	theme: 'material-darker',
	viewportMargin: 10,
	indentUnit: 4,
});
myCodeMirror.setSize("100%", "100%");
export function refresh(script) {
	// myCodeMirror.cm.height = 600;
	// console.log(myCodeMirror);
	myCodeMirror.setValue(script);
	requestAnimationFrame(() => {})
	myCodeMirror.setCursor({ line: 0, ch: 0 });
	// console.log(script);
}
