// @preview-file off
import { App, Dictionary, Director, HttpServer, Node, emit, json } from "Dora";

function send(message: Record<string, unknown>) {
	const [encoded] = json.encode(message);
	if (encoded === undefined) return;
	const event = Dictionary(); event.type = "Send"; event.msg = encoded; emit("AppWS", event);
}

export interface IDETarget {id: string; embedded: boolean; activeAt: number; seenAt: number;}
const targets: Record<string, IDETarget> = {};
let nativeState = "stopped";
let serial = 0;
const pending: Record<string, (success: boolean) => void> = {};
const listener = Node();
listener.addTo(Director.systemUI);
listener.gslot("AppIDEState", (state: string) => { nativeState = state; });
listener.gslot("AppWS", (event: {type?: string; msg: string}) => {
	if (typeof event === "string" || event.type !== "Receive") return;
	const [message] = json.decode(event.msg);
	if (!message || typeof message !== "object") return;
	const data = message as {name: string; id: string; embedded?: boolean; active?: boolean; requestId?: string; success?: boolean};
	if (typeof data.id !== "string" || data.id.length > 100) return;
	if (data.name === "ImportIDEClient") {
		const previous = targets[data.id];
		targets[data.id] = {id: data.id, embedded: data.embedded === true, seenAt: App.runningTime,
			activeAt: data.active === true ? App.runningTime : previous?.activeAt ?? 0};
	} else if (data.name === "ImportIDEClosed") {
		delete targets[data.id];
	} else if (data.name === "ImportIDEOpened" && typeof data.requestId === "string") {
		pending[`${data.id}:${data.requestId}`]?.(data.success === true);
	}
});
export function getNativeState() {return nativeState;}
let lastProbe = -math.huge;
export function getTargets(): IDETarget[] {
	if (HttpServer.wsConnectionCount === 0) return [];
	if (App.runningTime - lastProbe > 5) {lastProbe = App.runningTime; send({name: "ImportIDEProbe"});}
	const result: IDETarget[] = [];
	for (const [id, target] of pairs(targets)) {
		if (App.runningTime - target.seenAt > 45) { delete targets[id]; continue; }
		if (target.embedded && (!App.webIDEEnabled || nativeState === "stopped" || nativeState === "failed")) continue;
		result.push(target);
	}
	result.sort((a, b) => b.activeAt - a.activeAt);
	return result;
}
export function openProject(target: IDETarget, root: string): Promise<boolean> {
	return new Promise(resolve => {
		serial++;
		const requestId = tostring(serial);
		const key = `${target.id}:${requestId}`;
		let settled = false;
		const finish = (success: boolean) => { if (settled) return; settled = true; delete pending[key]; resolve(success); };
		pending[key] = finish;
		const started = App.runningTime;
		send({name: "ImportIDEOpen", target: target.id, requestId, root});
		Director.systemScheduler.schedule(() => {
			if (settled) return true;
			if (HttpServer.wsConnectionCount === 0 || App.runningTime - started > 8) { finish(false); return true; }
			return false;
		});
	});
}
