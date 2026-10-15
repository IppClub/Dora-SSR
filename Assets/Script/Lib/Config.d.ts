import { Struct } from 'Utils';

declare module 'Config' {
	interface DoraConfig {
		loadAsync: () => void;
		load: () => void;
	}
	type ConfigType<T> = DoraConfig & Struct<T>;
	function Config<T>(this: void, schema: string, ...field: string[]): ConfigType<T>;
	export = Config;
} // module 'Config'