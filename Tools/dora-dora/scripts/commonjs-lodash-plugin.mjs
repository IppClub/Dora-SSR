// Lodash prefers a global AMD loader over CommonJS. In a bundled module this
// leaves module.exports empty when Monaco's AMD loader is already present.
export function commonjsLodashPlugin() {
	return {
		name: 'commonjs-lodash',
		enforce: 'pre',
		transform(code, id) {
			if (!id.replace(/\\/g, '/').endsWith('/lodash/lodash.js')) return null;
			return { code: `var define;\n${code}`, map: null };
		},
	};
}
