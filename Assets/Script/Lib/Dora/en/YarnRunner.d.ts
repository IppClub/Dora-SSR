import {} from 'Dora';

declare module 'YarnRunner' {
/**
 * Interface to define markup attributes.
 */
interface Markup {
	/**
	 * Name of the markup.
	 */
	name: string;

	/**
	 * Starting position of the markup.
	 */
	start: number;

	/**
	 * Ending position of the markup.
	 */
	stop: number;

	/**
	 * Attributes associated with the markup.
	 */
	attrs: Record<string, boolean | number | string> | undefined;
}

/**
 * Interface to define textual results with optional markup.
 */
interface TextResult {
	/**
	 * Textual content.
	 */
	text: string;

	/**
	 * Optional markup for the text.
	 */
	marks: Markup[] | null;

	/**
	 * A flag indicating that advancing will yield an OptionResult as the next result.
	 */
	optionsFollowed: boolean | null;
}

/**
 * Type to define options in the narrative.
 * Gets element as TextResult when the option is available, gets boolean false when the option is unavailable.
 */
type OptionResult = [option: TextResult | boolean];

class YarnRunner {
	private constructor();

	/** Field for accessing Yarn script runtime variables. */
	readonly state: Record<string, string | number | boolean>;

	/**
	 * Method to advance the narrative.
	 * @param choice Index of the choice if presented with options. (optional)
	 * @return Returns nil if the narrative ended. Returns enum string result when YarnRunner is still running.
	 * @return Depending on the narrative, it can return a type of result and the associated content:
	 * "Text" and a TextResult.
	 * "Option" and an OptionResult.
	 * "Error" and a string error message.
	 * nil and a string indicating the narrative ends.
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
	 * Create a Yarn script runner.
	 * @param filename The name of the Yarn file to load and execute.
	 * @param startTitle The starting node/title in the Yarn script.
	 * @param state Table for providing predefined variables. (optional)
	 * @param command Table of commands to execute. (optional)
	 * @param testing Boolean flag for testing mode. When in testing mode, the testing variables from Web IDE will be loaded. Defaults to `false`. (optional)
	 * @returns Returns the YarnRunner object.
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