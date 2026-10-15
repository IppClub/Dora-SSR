/// <reference path="lua.d.ts" />

/** Dora 内置 LuaSocket 3.1.0 模块共享的类型。 */
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
		/** 接受一个等待中的客户端连接。 */
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
		/** HTTPS 超时时间，单位为秒。 */
		timeout?: number;
		/** HTTPS 对端证书验证模式。为兼容 LuaSec，默认不验证；设为 `"peer"` 或 `true` 时启用。 */
		verify?: "peer" | "none" | boolean;
	}

	/** `socket.url.parse` 返回、`socket.url.build` 接收的 URL 组成部分。 */
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

/** LuaSocket 3.1.0 提供的 TCP、UDP、DNS、超时、数据源和数据接收器接口。 */
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

/** LuaSocket 实现的阻塞式 HTTP/1.1 客户端；HTTPS 由 Dora 的 XRT 客户端提供。 */
declare module "socket.http" {
	export let TIMEOUT: number;
	export let USERAGENT: string;
	export let PROXY: string | undefined;
	export function request(this: void, url: string, body?: string): LuaMultiReturn<[string | undefined, number | string, Record<string, string> | undefined, string | undefined]>;
	export function request(this: void, request: LuaSocket.HTTPRequest): LuaMultiReturn<[1 | undefined, number | string, Record<string, string> | undefined, string | undefined]>;
}

/** 由 Dora XRT 客户端实现的阻塞式 HTTPS 请求兼容模块；为兼容 LuaSec，对端验证默认不启用。 */
declare module "ssl.https" {
	export let TIMEOUT: number;
	export const PORT: 443;
	export function request(this: void, url: string, body?: string): LuaMultiReturn<[string | undefined, number | string, Record<string, string> | undefined, string | undefined]>;
	export function request(this: void, request: LuaSocket.HTTPRequest): LuaMultiReturn<[1 | undefined, number | string, Record<string, string> | undefined, string | undefined]>;
}

/** URL 解析、拼装、转义和相对地址解析工具。 */
declare module "socket.url" {
	export const _VERSION: string;
	/** 对 LuaSocket 非保留字符集合之外的字节执行百分号编码。 */
	export function escape(this: void, value: string): string;
	/** 解码 `%xx` 字节转义，不进行表单风格的加号转换。 */
	export function unescape(this: void, value: string): string;
	/** 将 URL 拆分为命名字段，并可用默认值表预填。 */
	export function parse(this: void, value: string, defaults?: LuaSocket.URLParts): LuaMultiReturn<[LuaSocket.URLParts | undefined, string | undefined]>;
	/** 从 URL 字段表重新生成 URL。 */
	export function build(this: void, parts: LuaSocket.URLParts): string;
	/** 以基础 URL 为基准解析相对 URL。 */
	export function absolute(this: void, base: string | LuaSocket.URLParts, relative: string): string;
	/** 将路径拆成若干段并进行百分号解码。 */
	export function parse_path(this: void, path: string): LuaSocket.URLPath;
	/** 拼接路径段；除非 `unsafe` 为真，否则会自动转义。 */
	export function build_path(this: void, path: LuaSocket.URLPath, unsafe?: boolean): string;
}

/** 基于 LuaSocket 的阻塞式 FTP 客户端。 */
declare module "socket.ftp" {
	export let TIMEOUT: number;
	export let USER: string;
	export let PASSWORD: string;
	/** 将 URL 下载为字符串，或把表形式请求流式写入 sink。 */
	export function get(this: void, request: string): LuaMultiReturn<[string | undefined, string | undefined]>;
	export function get(this: void, request: LuaSocket.FTPRequest): LuaMultiReturn<[1 | undefined, string | undefined]>;
	/** 向 URL 上传字符串，或从表形式请求的 source 流式上传。 */
	export function put(this: void, request: string, body: string): LuaMultiReturn<[number | undefined, string | undefined]>;
	export function put(this: void, request: LuaSocket.FTPRequest): LuaMultiReturn<[number | undefined, string | undefined]>;
	/** 执行请求表描述的一条或多条 FTP 控制命令。 */
	export function command(this: void, request: LuaSocket.FTPRequest): LuaMultiReturn<[1 | undefined, string | undefined]>;
}

/** 阻塞式 SMTP 客户端和 RFC 2045 邮件数据源生成器。 */
declare module "socket.smtp" {
	export let TIMEOUT: number;
	export let SERVER: string;
	export let PORT: number;
	export let DOMAIN: string;
	export let ZONE: string;
	/** 将邮件描述（包括多段正文）转换为 LTN12 source。 */
	export function message(this: void, message: LuaSocket.SMTPMessage): LuaSocket.Source;
	/** 通过配置的 SMTP 服务器发送一封邮件。 */
	export function send(this: void, mail: LuaSocket.SMTPMail): LuaMultiReturn<[1 | undefined, string | undefined]>;
}

/** LTN12 流式过滤器、数据源、数据接收器和传输泵。 */
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

/** MIME Base64、Quoted-Printable、换行规范化和自动换行过滤器。 */
declare module "mime" {
	export const _VERSION: string;
	export function encode(this: void, name?: "base64" | "quoted-printable", mode?: string): LuaSocket.Filter;
	export function decode(this: void, name?: "base64" | "quoted-printable"): LuaSocket.Filter;
	export function wrap(this: void, name?: "text" | "base64" | "quoted-printable" | "default", length?: number): LuaSocket.Filter;
	export function normalize(this: void, marker?: string): LuaSocket.Filter;
	export function stuff(this: void): LuaSocket.Filter;
	/** 底层 Base64 编码函数；返回编码结果和供下一次调用使用的待处理上下文。 */
	export function b64(this: void, context?: string, chunk?: string): LuaMultiReturn<[string | undefined, string | undefined]>;
	/** 底层 Base64 解码函数；返回解码结果和待处理上下文。 */
	export function unb64(this: void, context?: string, chunk?: string): LuaMultiReturn<[string | undefined, string | undefined]>;
	/** 底层 quoted-printable 编码函数。 */
	export function qp(this: void, context?: string, chunk?: string, marker?: string): LuaMultiReturn<[string | undefined, string | undefined]>;
	/** 底层 quoted-printable 解码函数。 */
	export function unqp(this: void, context?: string, chunk?: string): LuaMultiReturn<[string | undefined, string | undefined]>;
	/** 底层换行包装函数；返回输出和当前行剩余列数。 */
	export function wrp(this: void, remaining: number, chunk?: string, length?: number): LuaMultiReturn<[string | undefined, number]>;
	/** 底层 quoted-printable 换行包装函数。 */
	export function qpwrp(this: void, remaining: number, chunk?: string, length?: number): LuaMultiReturn<[string | undefined, number]>;
	/** 底层行结束符规范化函数。 */
	export function eol(this: void, context: number, chunk?: string, marker?: string): LuaMultiReturn<[string | undefined, number]>;
	/** 底层 SMTP 点转义函数。 */
	export function dot(this: void, context: number, chunk?: string): LuaMultiReturn<[string | undefined, number]>;
}
