const encodeRfc3986Component = (value: string) => encodeURIComponent(value).replace(/[!'()*]/g, (character) =>
	`%${character.charCodeAt(0).toString(16).toUpperCase()}`,
);

export const canonicalizeAuthPath = (url: URL) => {
	if (!url.searchParams || Array.from(url.searchParams).length === 0) {
		return url.pathname;
	}
	const params = Array.from(url.searchParams.entries());
	params.sort(([keyA, valueA], [keyB, valueB]) => {
		const keySort = keyA < keyB ? -1 : keyA > keyB ? 1 : 0;
		if (keySort !== 0) return keySort;
		return valueA < valueB ? -1 : valueA > valueB ? 1 : 0;
	});
	const query = params
		.map(([key, value]) => `${encodeRfc3986Component(key)}=${encodeRfc3986Component(value)}`)
		.join('&');
	return query ? `${url.pathname}?${query}` : url.pathname;
};
