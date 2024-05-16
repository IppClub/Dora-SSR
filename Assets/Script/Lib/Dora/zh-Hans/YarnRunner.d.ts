import {} from "Dora";

declare module 'YarnRunner' {
/**
 * 用于定义标记属性的接口。
 */
interface Markup {
	/**
	 * 标记的名称。
	 */
	name: string;

	/**
	 * 标记的起始位置。
	 */
	start: number;

	/**
	 * 标记的结束位置。
	 */
	stop: number;

	/**
	 * 与标记相关联的属性。
	 */
	attrs: Record<string, boolean | number | string> | undefined;
}

/**
 * 用于定义带有可选标记的文本结果的接口。
 */
interface TextResult {
	/**
	 * 文本内容。
	 */
	text: string;

	/**
	 * 文本的可选标记。
	 */
	marks: Markup[] | null;

	/**
	 * 标志，指示前进将产生 OptionResult 作为下个结果。
	 */
	optionsFollowed: boolean | null;
}

/**
 * 用于定义叙述中的选项的类型。
 * 当选项可用时，获取元素作为 TextResult，当选项不可用时，获取布尔值 false。
 */
type OptionResult = [option: TextResult | boolean];

class YarnRunner {
	private constructor();

	/** 用于访问 Yarn 脚本运行时变量的字段。 */
	readonly state: Record<string, string | number | boolean>;

	/**
	 * 用于推进叙述的方法。
	 * @param choice 如果提供了选项，则为选项的索引。 (可选)
	 * @return 如果叙述结束，则返回 nil。当 YarnRunner 仍在运行时，返回枚举字符串结果。
	 * @return 根据叙述，它可以返回结果的类型和相关内容：
	 * "Text" 和 TextResult。
	 * "Option" 和 OptionResult。
	 * "Error" 和字符串错误消息。
	 * nil 和表示叙述结束的字符串。
	 */
	advance(choice?: number):
		LuaMultiReturn<[null, string]> |
		LuaMultiReturn<["Text", TextResult]> |
		LuaMultiReturn<["Option", OptionResult]> |
		LuaMultiReturn<["Error", string]> |
		LuaMultiReturn<["Command", any]>;
}

export namespace YarnRunner {
	type Type = YarnRunner;
}

interface YarnRunnerClass {
	/**
	 * 创建 Yarn 脚本运行器。
	 * @param filename 要加载和执行的 Yarn 文件的名称。
	 * @param startTitle Yarn 脚本中的起始节点/标题。
	 * @param state 用于提供预定义变量的表格。（可选）
	 * @param command 执行的命令表格。（可选）
	 * @param testing 用于测试模式的布尔标志。处于测试模式时，将加载来自 Web IDE 的测试变量。默认为 `false`。（可选）
	 * @returns 返回 YarnRunner 对象。
	 */
	(
		this: void,
		filename: string,
		startTitle: string,
		state?: Record<string, string | number | boolean>,
		command?: Record<string, Function>,
		testing?: boolean
	): YarnRunner;
}

const yarnRunnerClass: YarnRunnerClass;
export = yarnRunnerClass;

} // module 'YarnRunner'
