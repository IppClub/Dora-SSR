const enabled = new URLSearchParams(window.location.search).get("doraPerf") === "1";

if (enabled) {
	type Listener = EventListenerOrEventListenerObject;
	type ListenerRecord = {
		wrapped: EventListener;
		abort?: () => void;
		cleanup: () => void;
	};
	type ListenerHolding = {
		active: number;
		types: Map<string, number>;
	};
	type TargetRecords = {
		buckets: Map<string, Map<Listener, ListenerRecord>>;
		holding: ListenerHolding;
	};

	const originalAdd = EventTarget.prototype.addEventListener;
	const originalRemove = EventTarget.prototype.removeEventListener;
	const targets = new WeakMap<EventTarget, TargetRecords>();
	let activeListenerCount = 0;
	const activeListenerTypes = new Map<string, number>();
	const finalizer = new FinalizationRegistry<ListenerHolding>((holding) => {
		activeListenerCount -= holding.active;
		for (const [type, count] of holding.types) {
			activeListenerTypes.set(type, (activeListenerTypes.get(type) ?? 0) - count);
		}
	});

	const captureOf = (options?: boolean | AddEventListenerOptions): boolean => (
		typeof options === "boolean" ? options : options?.capture === true
	);
	const keyOf = (type: string, capture: boolean) => `${type}:${capture ? 1 : 0}`;

	EventTarget.prototype.addEventListener = function (
		type: string,
		listener: Listener | null,
		options?: boolean | AddEventListenerOptions
	): void {
		if (listener === null) {
			originalAdd.call(this, type, listener, options);
			return;
		}
		const optionBag = typeof options === "object" ? options : undefined;
		if (optionBag?.signal?.aborted) return;
		const capture = captureOf(options);
		const key = keyOf(type, capture);
		let targetInfo = targets.get(this);
		if (!targetInfo) {
			targetInfo = {
				buckets: new Map(),
				holding: { active: 0, types: new Map() },
			};
			targets.set(this, targetInfo);
			finalizer.register(this, targetInfo.holding);
		}
		let listenerRecords = targetInfo.buckets.get(key);
		if (!listenerRecords) {
			listenerRecords = new Map();
			targetInfo.buckets.set(key, listenerRecords);
		}
		if (listenerRecords.has(listener)) return;

		const cleanup = () => {
			const current = listenerRecords?.get(listener);
			if (!current) return;
			listenerRecords?.delete(listener);
			activeListenerCount -= 1;
			targetInfo.holding.active -= 1;
			targetInfo.holding.types.set(type, (targetInfo.holding.types.get(type) ?? 0) - 1);
			activeListenerTypes.set(type, (activeListenerTypes.get(type) ?? 0) - 1);
			if (current.abort && optionBag?.signal) {
				originalRemove.call(optionBag.signal, "abort", current.abort);
			}
		};
		const wrapped: EventListener = function (event) {
			if (optionBag?.once) cleanup();
			if (typeof listener === "function") {
				listener.call(this, event);
			} else {
				listener.handleEvent(event);
			}
		};
		const record: ListenerRecord = { wrapped, cleanup };
		if (optionBag?.signal) {
			record.abort = () => {
				originalRemove.call(this, type, wrapped, capture);
				cleanup();
			};
			originalAdd.call(optionBag.signal, "abort", record.abort, { once: true });
		}
		listenerRecords.set(listener, record);
		activeListenerCount += 1;
		targetInfo.holding.active += 1;
		targetInfo.holding.types.set(type, (targetInfo.holding.types.get(type) ?? 0) + 1);
		activeListenerTypes.set(type, (activeListenerTypes.get(type) ?? 0) + 1);
		originalAdd.call(this, type, wrapped, options);
	};

	EventTarget.prototype.removeEventListener = function (
		type: string,
		listener: Listener | null,
		options?: boolean | EventListenerOptions
	): void {
		if (listener === null) {
			originalRemove.call(this, type, listener, options);
			return;
		}
		const key = keyOf(type, captureOf(options));
		const listenerRecords = targets.get(this)?.buckets.get(key);
		const record = listenerRecords?.get(listener);
		if (!record) {
			originalRemove.call(this, type, listener, options);
			return;
		}
		originalRemove.call(this, type, record.wrapped, options);
		record.cleanup();
	};

	const node = document.createElement("span");
	node.hidden = true;
	node.dataset.doraPerfDiagnostics = "true";
	node.dataset.doraPerfMonacoLoaded = "false";
	node.dataset.doraPerfTypeScriptWorkerLoaded = "false";
	node.dataset.doraPerfSearchInputCount = "0";
	node.dataset.doraPerfSearchInputP50 = "0.00";
	node.dataset.doraPerfSearchInputP95 = "0.00";
	node.dataset.doraPerfSearchInputMax = "0.00";
	document.documentElement.appendChild(node);
	const update = () => {
		node.dataset.doraPerfListeners = String(activeListenerCount);
		node.dataset.doraPerfListenerTypes = JSON.stringify(
			Object.fromEntries([...activeListenerTypes].filter(([, count]) => count > 0))
		);
		const memory = performance as Performance & {
			memory?: { usedJSHeapSize?: number };
		};
		const heap = memory.memory?.usedJSHeapSize;
		node.dataset.doraPerfHeap = typeof heap === "number" ? String(heap) : "";
		node.dataset.doraPerfTypeScriptWorkerLoaded = String(
			performance.getEntriesByType("resource").some((entry) => entry.name.includes("ts.worker"))
		);
	};
	update();
	window.setInterval(update, 500);
}
