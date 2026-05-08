export type ActionXmlElement = {
	name: string;
	attrs: Record<string, string>;
	children: ActionXmlElement[];
};

const decodeXml = (value: string) => value
	.replace(/&quot;/g, '"')
	.replace(/&apos;/g, "'")
	.replace(/&lt;/g, "<")
	.replace(/&gt;/g, ">")
	.replace(/&amp;/g, "&");

export const escapeXml = (value: string) => value
	.replace(/&/g, "&amp;")
	.replace(/"/g, "&quot;")
	.replace(/</g, "&lt;")
	.replace(/>/g, "&gt;");

const parseTag = (rawTag: string) => {
	const trimmed = rawTag.trim();
	if (!trimmed || trimmed.startsWith("?") || trimmed.startsWith("!")) {
		return null;
	}
	const closing = trimmed.startsWith("/");
	const selfClosing = trimmed.endsWith("/");
	const body = closing ? trimmed.slice(1).trim() : (selfClosing ? trimmed.slice(0, -1).trim() : trimmed);
	const nameEnd = body.search(/\s/);
	const name = nameEnd < 0 ? body : body.slice(0, nameEnd);
	const attrText = nameEnd < 0 ? "" : body.slice(nameEnd + 1);
	const attrs: Record<string, string> = {};
	const attrPattern = /([^\s=]+)\s*=\s*"([^"]*)"/g;
	let match: RegExpExecArray | null;
	while ((match = attrPattern.exec(attrText)) !== null) {
		attrs[match[1]] = decodeXml(match[2]);
	}
	return {name, attrs, closing, selfClosing};
};

export const parseActionXml = (xml: string): ActionXmlElement => {
	const stack: ActionXmlElement[] = [];
	let root: ActionXmlElement | undefined;
	const tagPattern = /<([^>]+)>/g;
	let match: RegExpExecArray | null;
	while ((match = tagPattern.exec(xml)) !== null) {
		const tag = parseTag(match[1]);
		if (!tag) continue;
		if (tag.closing) {
			const current = stack.pop();
			if (!current || current.name !== tag.name) {
				throw new Error(`Unexpected closing tag </${tag.name}>`);
			}
			continue;
		}
		const element: ActionXmlElement = {name: tag.name, attrs: tag.attrs, children: []};
		const parent = stack[stack.length - 1];
		if (parent) {
			parent.children.push(element);
		} else {
			if (root) throw new Error("XML contains multiple root elements");
			root = element;
		}
		if (!tag.selfClosing) {
			stack.push(element);
		}
	}
	if (!root) throw new Error("XML root element is missing");
	if (stack.length !== 0) throw new Error(`Unclosed tag <${stack[stack.length - 1].name}>`);
	return root;
};
