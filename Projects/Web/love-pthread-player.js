(function installLovePthreadPlayer(global) {
	"use strict";

	Module.doraSkipManifestMount = true;
	const STORAGE_KEY = "dora-love-pthread-player-projects-v1";
	const state = {ready: false, running: false, busy: false, projects: []};

	function elements() {
		return {
			canvas: document.getElementById("canvas"), panel: document.getElementById("player-panel"),
			status: document.getElementById("player-status"), picker: document.getElementById("package-picker"),
			projects: document.getElementById("recent-projects"), stop: document.getElementById("stop-project")
		};
	}

	function setStatus(message, faulted = false) {
		const ui = elements();
		ui.status.textContent = message;
		ui.status.dataset.faulted = faulted ? "true" : "false";
	}

	function loadProjects() {
		try {
			const value = JSON.parse(localStorage.getItem(STORAGE_KEY) || "[]");
			state.projects = Array.isArray(value) ? value.filter((item) =>
				item && typeof item.id === "string" && typeof item.name === "string").slice(0, 12) : [];
		} catch (_) { state.projects = []; }
	}

	function saveProjects() {
		localStorage.setItem(STORAGE_KEY, JSON.stringify(state.projects));
	}

	function renderProjects() {
		const ui = elements();
		ui.projects.replaceChildren();
		for (const project of state.projects) {
			const button = document.createElement("button");
			button.type = "button";
			button.className = "recent-project";
			button.textContent = project.name;
			button.addEventListener("click", () => startProject(project));
			ui.projects.append(button);
		}
		ui.projects.hidden = state.projects.length === 0;
	}

	async function projectId(file) {
		const digest = await crypto.subtle.digest("SHA-256", await file.arrayBuffer());
		const hash = [...new Uint8Array(digest).subarray(0, 8)]
			.map((value) => value.toString(16).padStart(2, "0")).join("");
		const stem = file.name.replace(/\.dora$/i, "").normalize("NFKD")
			.replace(/[^A-Za-z0-9._-]+/g, "-").replace(/^-+|-+$/g, "").slice(0, 40) || "love-project";
		return `${stem}-${hash}`;
	}

	function call(name, returnType = "number", argumentTypes = [], args = []) {
		return Module.ccall(name, returnType, argumentTypes, args);
	}

	function runtimeError() {
		const pointer = call("dora_web_love_player_error", "number");
		return pointer ? Module.UTF8ToString(pointer) : "Love project failed";
	}

	async function unlockAudio() {
		const context = Module.SDL2?.audioContext;
		if (context && context.state !== "running") await context.resume();
	}

	function showLauncher(message = "Choose a .dora Love project to play.") {
		const ui = elements();
		state.running = false;
		ui.panel.hidden = false;
		ui.stop.hidden = true;
		setStatus(message);
		renderProjects();
	}

	function pollProject(project) {
		const status = call("dora_web_love_player_status");
		if (status < 0) {
			const message = runtimeError();
			const stopping = call("dora_web_love_player_stop") === 1;
			void (async () => {
				while (stopping && call("dora_web_love_player_status") === 2)
					await new Promise((resolve) => setTimeout(resolve, 16));
				state.busy = false;
				showLauncher(message);
				setStatus(message, true);
			})();
			return;
		}
		if (status === 1) {
			const ui = elements();
			state.busy = false;
			state.running = true;
			ui.panel.hidden = true;
			ui.stop.hidden = false;
			ui.canvas.focus();
			global.dispatchEvent(new CustomEvent("dora-love-player-started", {detail: project}));
			return;
		}
		setTimeout(() => pollProject(project), 16);
	}

	async function startProject(project) {
		if (!state.ready || state.busy || state.running) return false;
		state.busy = true;
		setStatus(`Starting ${project.name}…`);
		void unlockAudio().catch(() => {});
		const entry = `/user/projects/${project.id}/main.lua`;
		if (call("dora_web_love_player_start", "number", ["string"], [entry]) !== 1) {
			state.busy = false;
			setStatus(runtimeError(), true);
			return false;
		}
		pollProject(project);
		return true;
	}

	async function importPackage(file) {
		if (!file || state.busy || state.running) return false;
		if (!/\.dora$/i.test(file.name)) throw new Error("Choose a .dora package");
		state.busy = true;
		setStatus(`Validating ${file.name}…`);
		try {
			const inspected = await global.DoraWebPackage.inspectLovePackage(file);
			const id = await projectId(file);
			const project = {id, name: file.name.replace(/\.dora$/i, "") || file.name};
			const target = `/user/projects/${id}`;
			if (!Module.FS.analyzePath(target).exists) {
				setStatus(`Installing ${file.name}…`);
				await global.DoraWebPackage.installPackage(Module, inspected, id);
			}
			state.projects = [project, ...state.projects.filter((item) => item.id !== id)].slice(0, 12);
			saveProjects();
			state.busy = false;
			return startProject(project);
		} catch (error) {
			state.busy = false;
			setStatus(String(error?.message || error), true);
			return false;
		}
	}

	async function stopProject() {
		if (!state.running || state.busy) return false;
		state.busy = true;
		if (call("dora_web_love_player_stop") !== 1) {
			state.busy = false;
			return false;
		}
		while (call("dora_web_love_player_status") === 2)
			await new Promise((resolve) => setTimeout(resolve, 16));
		try {
			await Module.doraSyncUserStorage();
			state.busy = false;
			showLauncher("Project stopped. Saves were synchronized.");
			return true;
		} catch (error) {
			state.busy = false;
			showLauncher("Project stopped, but save synchronization failed.");
			setStatus(String(error?.message || error), true);
			return false;
		}
	}

	function initialize() {
		if (state.ready) return;
		if (!global.crossOriginIsolated || typeof global.SharedArrayBuffer !== "function") {
			setStatus("This player requires COOP/COEP headers and cross-origin isolation.", true);
			return;
		}
		state.ready = true;
		loadProjects();
		showLauncher();
		const ui = elements();
		ui.picker.addEventListener("change", () => {
			const file = ui.picker.files?.[0];
			ui.picker.value = "";
			if (file) importPackage(file);
		});
		ui.stop.addEventListener("click", stopProject);
		for (const eventName of ["dragenter", "dragover"]) document.addEventListener(eventName, (event) => {
			event.preventDefault();
			document.documentElement.dataset.dragging = "true";
		});
		document.addEventListener("dragleave", () => { delete document.documentElement.dataset.dragging; });
		document.addEventListener("drop", (event) => {
			event.preventDefault();
			delete document.documentElement.dataset.dragging;
			const file = event.dataTransfer?.files?.[0];
			if (file) importPackage(file);
		});
		const requested = new URLSearchParams(location.search).get("project");
		const project = state.projects.find((item) => item.id === requested);
		if (project) startProject(project);
	}

	global.DoraLovePthreadPlayer = Object.freeze({state, importPackage, startProject, stopProject});
	global.addEventListener("dora-statechange", (event) => {
		if (event.detail?.state === "running") setTimeout(initialize, 0);
	});
})(globalThis);
