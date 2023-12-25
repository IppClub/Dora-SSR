/// <reference path="lib.es6-subset.d.ts" />
/// <reference path="lib.lua.d.ts" />

declare module "dora" {
	interface ObjectConstructor {
		count: number;
	}
	export var Object: ObjectConstructor;
}
