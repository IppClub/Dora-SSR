export const EditorTheme = "dora-dark";

const inferDefinitionCommands = new Map<string, string>();

export const setInferDefinitionCommand = (modelUri: string, command: string | null) => {
	if (command === null) {
		inferDefinitionCommands.delete(modelUri);
		return;
	}
	inferDefinitionCommands.set(modelUri, command);
};

export const getInferDefinitionCommand = (modelUri: string) =>
	inferDefinitionCommands.get(modelUri);
