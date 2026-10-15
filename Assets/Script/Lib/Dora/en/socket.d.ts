/// <reference path="lua.d.ts" />

/** Shared types for the bundled LuaSocket 3.1.0 modules. */
declare namespace LuaSocket {
	type Family = "inet" | "inet6";
	type ShutdownMode = "both" | "send" | "receive";
	type ReceivePattern = "*a" | "*l" | number;
	type Source = (this: void) => LuaMultiReturn<[string | undefined, string | undefined]>;
	type Sink = (this: void, chunk?: string, error?: string) => LuaMultiReturn<[1 | undefined, string | undefined]>;
	type Filter = (this: void, chunk?: string) => string | undefined;

	interface Selectable {
		getfd(): number;
		dirty(): boolean;
	}

	interface TCP extends Selectable {
		/** Accepts a pending client connection. */
		accept(): LuaMultiReturn<[TCP | undefined, string | undefined]>;
		bind(address: string, port: number): LuaMultiReturn<[1 | undefined, string | undefined]>;
		close(): 1;
		connect(address: string, port: number): LuaMultiReturn<[1 | undefined, string | undefined]>;
		getfamily(): Family;
		getoption(name: string): any;
		getpeername(): LuaMultiReturn<[string | undefined, number | string | undefined, Family | undefined]>;
		getsockname(): LuaMultiReturn<[string | undefined, number | string | undefined, Family | undefined]>;
		getstats(): LuaMultiReturn<[number, number, number]>;
		gettimeout(): LuaMultiReturn<[number, number]>;
		listen(backlog?: number): LuaMultiReturn<[1 | undefined, string | undefined]>;
		receive(pattern?: ReceivePattern, prefix?: string): LuaMultiReturn<[string | undefined, string | undefined, string | undefined]>;
		send(data: string, start?: number, end?: number): LuaMultiReturn<[number | undefined, string | undefined, number | undefined]>;
		setoption(name: string, value: any): LuaMultiReturn<[1 | undefined, string | undefined]>;
		setstats(received?: number, sent?: number, age?: number): 1;
		settimeout(value: number, mode?: "b" | "t"): 1;
		shutdown(mode?: ShutdownMode): 1;
	}

	interface UDP extends Selectable {
		close(): 1;
		getfamily(): Family;
		getoption(name: string): any;
		getpeername(): LuaMultiReturn<[string | undefined, number | undefined]>;
		getsockname(): LuaMultiReturn<[string | undefined, number | undefined, Family | undefined]>;
		gettimeout(): LuaMultiReturn<[number, number]>;
		receive(size?: number): LuaMultiReturn<[string | undefined, string | undefined]>;
		receivefrom(size?: number): LuaMultiReturn<[string | undefined, string | undefined, number | undefined]>;
		send(data: string): LuaMultiReturn<[number | undefined, string | undefined]>;
		sendto(data: string, address: string, port: number): LuaMultiReturn<[number | undefined, string | undefined]>;
		setoption(name: string, value: any): LuaMultiReturn<[1 | undefined, string | undefined]>;
		setpeername(address?: string, port?: number): LuaMultiReturn<[1 | undefined, string | undefined]>;
		setsockname(address: string, port: number): LuaMultiReturn<[1 | undefined, string | undefined]>;
		settimeout(value: number, mode?: "b" | "t"): 1;
	}

	interface HTTPRequest {
		url: string;
		method?: string;
		headers?: Record<string, string | number>;
		source?: Source;
		sink?: Sink;
		step?: (this: void, source: Source, sink: Sink) => LuaMultiReturn<[1 | undefined, string | undefined]>;
		proxy?: string;
		redirect?: boolean;
		maxredirects?: number;
		create?: (this: void) => TCP;
		/** HTTPS timeout in seconds. */
		timeout?: number;
		/** HTTPS peer verification mode. LuaSec-compatible requests default to no verification; use `"peer"` or `true` to enable it. */
		verify?: "peer" | "none" | boolean;
	}

	/** Components returned by `socket.url.parse` and accepted by `socket.url.build`. */
	interface URLParts {
		scheme?: string;
		authority?: string;
		userinfo?: string;
		user?: string;
		password?: string;
		host?: string;
		port?: string | number;
		path?: string;
		params?: string;
		query?: string;
		fragment?: string;
	}

	interface URLPath extends Array<string> {
		is_absolute?: 1;
		is_directory?: 1;
	}

	interface FTPRequest {
		url?: string;
		host?: string;
		port?: number;
		user?: string;
		password?: string;
		path?: string;
		type?: "a" | "i";
		command?: string | string[];
		argument?: string | string[];
		check?: string | number | Array<string | number>;
		source?: Source;
		sink?: Sink;
		step?: (this: void, source: Source, sink: Sink) => LuaMultiReturn<[1 | undefined, string | undefined]>;
		create?: (this: void) => TCP;
	}

	interface SMTPMessage {
		headers?: Record<string, string>;
		body: string | Source | Array<SMTPMessage>;
		preamble?: string;
		epilogue?: string;
		zone?: string;
	}

	interface SMTPMail {
		from: string;
		rcpt: string | string[];
		source: Source;
		server?: string;
		port?: number;
		domain?: string;
		user?: string;
		password?: string;
		step?: (this: void, source: Source, sink: Sink) => LuaMultiReturn<[1 | undefined, string | undefined]>;
		create?: (this: void) => TCP;
	}
}

/** TCP, UDP, DNS, timeout, source and sink helpers from LuaSocket 3.1.0. */
declare module "socket" {
	export const _VERSION: string;
	export const BLOCKSIZE: number;
	export function bind(this: void, host: string, port: number, backlog?: number): LuaMultiReturn<[LuaSocket.TCP | undefined, string | undefined]>;
	export function connect(this: void, address: string, port: number, localAddress?: string, localPort?: number, family?: LuaSocket.Family): LuaMultiReturn<[LuaSocket.TCP | undefined, string | undefined]>;
	export function connect4(this: void, address: string, port: number, localAddress?: string, localPort?: number): LuaMultiReturn<[LuaSocket.TCP | undefined, string | undefined]>;
	export function connect6(this: void, address: string, port: number, localAddress?: string, localPort?: number): LuaMultiReturn<[LuaSocket.TCP | undefined, string | undefined]>;
	export function gettime(this: void): number;
	export function newtry(this: void, finalizer?: (this: void) => void): (this: void, ...values: any[]) => any;
	export function protect<T extends (...args: any[]) => any>(this: void, fn: T): T;
	export function select(this: void, readable: LuaSocket.Selectable[], writable?: LuaSocket.Selectable[], timeout?: number): LuaMultiReturn<[LuaSocket.Selectable[], LuaSocket.Selectable[], string | undefined]>;
	export function sink(this: void, mode: "close-when-done" | "keep-open", socket: LuaSocket.TCP): LuaSocket.Sink;
	export function skip(this: void, count: number, ...values: any[]): any;
	export function sleep(this: void, seconds: number): void;
	export function source(this: void, mode: "by-length" | "until-closed", socket: LuaSocket.TCP, length?: number): LuaSocket.Source;
	export function tcp(this: void): LuaMultiReturn<[LuaSocket.TCP | undefined, string | undefined]>;
	export function tcp4(this: void): LuaMultiReturn<[LuaSocket.TCP | undefined, string | undefined]>;
	export function tcp6(this: void): LuaMultiReturn<[LuaSocket.TCP | undefined, string | undefined]>;
	export function tryFn(this: void, ...values: any[]): any;
	export {tryFn as try};
	export function udp(this: void): LuaMultiReturn<[LuaSocket.UDP | undefined, string | undefined]>;
	export function udp4(this: void): LuaMultiReturn<[LuaSocket.UDP | undefined, string | undefined]>;
	export function udp6(this: void): LuaMultiReturn<[LuaSocket.UDP | undefined, string | undefined]>;

	export namespace dns {
		function getaddrinfo(this: void, host: string): LuaMultiReturn<[Array<{family: LuaSocket.Family; addr: string}> | undefined, string | undefined]>;
		function gethostname(this: void): string;
		function getnameinfo(this: void, address: string): LuaMultiReturn<[string | undefined, string | undefined]>;
		function tohostname(this: void, address: string): LuaMultiReturn<[string | undefined, string | undefined]>;
		function toip(this: void, address: string): LuaMultiReturn<[string | undefined, string | undefined]>;
	}
}

/** Blocking HTTP/1.1 client implemented by LuaSocket. HTTPS is backed by Dora's XRT client. */
declare module "socket.http" {
	export let TIMEOUT: number;
	export let USERAGENT: string;
	export let PROXY: string | undefined;
	export function request(this: void, url: string, body?: string): LuaMultiReturn<[string | undefined, number | string, Record<string, string> | undefined, string | undefined]>;
	export function request(this: void, request: LuaSocket.HTTPRequest): LuaMultiReturn<[1 | undefined, number | string, Record<string, string> | undefined, string | undefined]>;
}

/** Blocking HTTPS request compatibility implemented by Dora's XRT client. Peer verification is opt-in for LuaSec compatibility. */
declare module "ssl.https" {
	export let TIMEOUT: number;
	export const PORT: 443;
	export function request(this: void, url: string, body?: string): LuaMultiReturn<[string | undefined, number | string, Record<string, string> | undefined, string | undefined]>;
	export function request(this: void, request: LuaSocket.HTTPRequest): LuaMultiReturn<[1 | undefined, number | string, Record<string, string> | undefined, string | undefined]>;
}

/** URL parsing, composition, escaping and relative resolution helpers. */
declare module "socket.url" {
	export const _VERSION: string;
	/** Percent-encodes every byte outside LuaSocket's unreserved set. */
	export function escape(this: void, value: string): string;
	/** Decodes `%xx` byte escapes without applying form-style `+` conversion. */
	export function unescape(this: void, value: string): string;
	/** Splits a URL into RFC-style named components, optionally seeded with defaults. */
	export function parse(this: void, value: string, defaults?: LuaSocket.URLParts): LuaMultiReturn<[LuaSocket.URLParts | undefined, string | undefined]>;
	/** Rebuilds a URL from parsed components. */
	export function build(this: void, parts: LuaSocket.URLParts): string;
	/** Resolves a relative URL against a base URL. */
	export function absolute(this: void, base: string | LuaSocket.URLParts, relative: string): string;
	/** Splits and percent-decodes a path into segments. */
	export function parse_path(this: void, path: string): LuaSocket.URLPath;
	/** Joins path segments, percent-encoding them unless `unsafe` is true. */
	export function build_path(this: void, path: LuaSocket.URLPath, unsafe?: boolean): string;
}

/** Blocking FTP client built on LuaSocket. */
declare module "socket.ftp" {
	export let TIMEOUT: number;
	export let USER: string;
	export let PASSWORD: string;
	/** Downloads a URL to a string, or streams a table-form request into its sink. */
	export function get(this: void, request: string): LuaMultiReturn<[string | undefined, string | undefined]>;
	export function get(this: void, request: LuaSocket.FTPRequest): LuaMultiReturn<[1 | undefined, string | undefined]>;
	/** Uploads a string to a URL, or streams a table-form request from its source. */
	export function put(this: void, request: string, body: string): LuaMultiReturn<[number | undefined, string | undefined]>;
	export function put(this: void, request: LuaSocket.FTPRequest): LuaMultiReturn<[number | undefined, string | undefined]>;
	/** Executes one or more FTP control commands described by a request table. */
	export function command(this: void, request: LuaSocket.FTPRequest): LuaMultiReturn<[1 | undefined, string | undefined]>;
}

/** Blocking SMTP client and RFC 2045 message-source builder. */
declare module "socket.smtp" {
	export let TIMEOUT: number;
	export let SERVER: string;
	export let PORT: number;
	export let DOMAIN: string;
	export let ZONE: string;
	/** Converts a message description, including multipart bodies, into an LTN12 source. */
	export function message(this: void, message: LuaSocket.SMTPMessage): LuaSocket.Source;
	/** Sends one message through the configured SMTP server. */
	export function send(this: void, mail: LuaSocket.SMTPMail): LuaMultiReturn<[1 | undefined, string | undefined]>;
}

/** LTN12 streaming filters, sources, sinks and transfer pumps. */
declare module "ltn12" {
	export const BLOCKSIZE: number;
	export const _VERSION: string;
	interface FilterModule {
		chain(this: void, ...filters: LuaSocket.Filter[]): LuaSocket.Filter;
		cycle(this: void, lowLevel: (this: void, context: any, chunk?: string, extra?: any) => LuaMultiReturn<[string | undefined, any]>, context: any, extra?: any): LuaSocket.Filter;
	}
	interface SourceModule {
		cat(this: void, ...sources: LuaSocket.Source[]): LuaSocket.Source;
		chain(this: void, source: LuaSocket.Source, ...filters: LuaSocket.Filter[]): LuaSocket.Source;
		empty(this: void): LuaSocket.Source;
		error(this: void, message: string): LuaSocket.Source;
		rewind(this: void, source: LuaSocket.Source): LuaSocket.Source;
		simplify(this: void, source: LuaSocket.Source): LuaSocket.Source;
		string(this: void, value?: string): LuaSocket.Source;
		table(this: void, values: string[]): LuaSocket.Source;
	}
	interface SinkModule {
		chain(this: void, ...filtersAndSink: Array<LuaSocket.Filter | LuaSocket.Sink>): LuaSocket.Sink;
		error(this: void, message: string): LuaSocket.Sink;
		"null"(this: void): LuaSocket.Sink;
		simplify(this: void, sink: LuaSocket.Sink): LuaSocket.Sink;
		table(this: void, target?: string[]): LuaMultiReturn<[LuaSocket.Sink, string[]]>;
	}
	interface PumpModule {
		all(this: void, source: LuaSocket.Source, sink: LuaSocket.Sink, step?: PumpModule["step"]): LuaMultiReturn<[1 | undefined, string | undefined]>;
		step(this: void, source: LuaSocket.Source, sink: LuaSocket.Sink): LuaMultiReturn<[1 | undefined, string | undefined]>;
	}
	export const filter: FilterModule;
	export const source: SourceModule;
	export const sink: SinkModule;
	export const pump: PumpModule;
}

/** MIME Base64, quoted-printable, line normalization and wrapping filters. */
declare module "mime" {
	export const _VERSION: string;
	export function encode(this: void, name?: "base64" | "quoted-printable", mode?: string): LuaSocket.Filter;
	export function decode(this: void, name?: "base64" | "quoted-printable"): LuaSocket.Filter;
	export function wrap(this: void, name?: "text" | "base64" | "quoted-printable" | "default", length?: number): LuaSocket.Filter;
	export function normalize(this: void, marker?: string): LuaSocket.Filter;
	export function stuff(this: void): LuaSocket.Filter;
	/** Low-level Base64 encoder; returns encoded output and the pending context for the next call. */
	export function b64(this: void, context?: string, chunk?: string): LuaMultiReturn<[string | undefined, string | undefined]>;
	/** Low-level Base64 decoder; returns decoded output and pending context. */
	export function unb64(this: void, context?: string, chunk?: string): LuaMultiReturn<[string | undefined, string | undefined]>;
	/** Low-level quoted-printable encoder. */
	export function qp(this: void, context?: string, chunk?: string, marker?: string): LuaMultiReturn<[string | undefined, string | undefined]>;
	/** Low-level quoted-printable decoder. */
	export function unqp(this: void, context?: string, chunk?: string): LuaMultiReturn<[string | undefined, string | undefined]>;
	/** Low-level line wrapper; returns output and remaining columns. */
	export function wrp(this: void, remaining: number, chunk?: string, length?: number): LuaMultiReturn<[string | undefined, number]>;
	/** Low-level quoted-printable line wrapper. */
	export function qpwrp(this: void, remaining: number, chunk?: string, length?: number): LuaMultiReturn<[string | undefined, number]>;
	/** Low-level end-of-line normalizer. */
	export function eol(this: void, context: number, chunk?: string, marker?: string): LuaMultiReturn<[string | undefined, number]>;
	/** Low-level SMTP dot-stuffing transform. */
	export function dot(this: void, context: number, chunk?: string): LuaMultiReturn<[string | undefined, number]>;
}
