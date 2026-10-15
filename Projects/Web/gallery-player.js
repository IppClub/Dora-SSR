// Resolve only catalogued games before starting the shared runtime.
(async () => {
	try {
		window.doraSetProgress(0, 'Loading game catalog…');
		const gameId = new URLSearchParams(location.search).get('game');
		const catalogUrl = new URL('../../catalog.json', document.baseURI);
		const response = await fetch(catalogUrl, {cache: 'no-cache'});
		if (!response.ok) throw new Error('Game catalog is unavailable');
		const catalog = await response.json();
		const game = catalog.games.find(item => item.id === gameId);
		if (!game) throw new Error('Select a game from the gallery');
		const manifest = new URL(game.manifest, catalogUrl);
		if (manifest.origin !== location.origin) throw new Error('Invalid game origin');
		Module.doraManifestUrl = manifest.href;
		Module.doraStorageId = game.id;
		const script = document.createElement('script');
		script.src = new URL('dora-player-runtime.js', document.baseURI).href;
		document.body.appendChild(script);
	} catch (error) { window.doraSetState('faulted', error.message); }
})();
