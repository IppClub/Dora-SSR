// Only embedded IDE hosts expose these message channels. Ordinary browsers
// continue using the same run request and response without view switching.
type NativeRunWindow = Window & {
	webkit?: { messageHandlers?: { doraIDERun?: { postMessage(message: string): void } } };
	chrome?: { webview?: { postMessage(message: string): void } };
	DoraIDERun?: { postMessage(message: string): void };
};

export async function runWithNativeIDE<T extends { success: boolean; err?: string }>(run: () => Promise<T>): Promise<T> {
	const host = window as NativeRunWindow;
	const send = (message: string) => {
		try {
			if (host.top !== host) return;
			if (host.webkit?.messageHandlers?.doraIDERun) host.webkit.messageHandlers.doraIDERun.postMessage(message);
			else if (host.DoraIDERun) host.DoraIDERun.postMessage(message);
			else host.chrome?.webview?.postMessage(message);
		} catch { /* A disappearing native view must not alter the run result. */ }
	};
	const id = crypto.randomUUID?.() ?? `${Date.now()}-${Math.random().toString(36).slice(2)}`;
	send(`dora-ide-run:start:${id}`);
	try {
		const result = await run();
		send(`dora-ide-run:${result.success && !result.err ? 'success' : 'cancel'}:${id}`);
		return result;
	} catch (error) {
		send(`dora-ide-run:cancel:${id}`);
		throw error;
	}
}
