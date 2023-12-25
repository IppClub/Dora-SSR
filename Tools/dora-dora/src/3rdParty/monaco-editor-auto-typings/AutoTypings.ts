import { AutoTypingsCore } from './AutoTypingsCore';
import { Options } from './Options';
import type * as monaco from 'monaco-editor';

type Editor = monaco.editor.ICodeEditor | monaco.editor.IStandaloneCodeEditor;

export class AutoTypings extends AutoTypingsCore {
  private constructor(editor: Editor, options: Options) {
    super(editor, options);
  }

  public static async create(editor: Editor, options?: Partial<Options>): Promise<AutoTypingsCore> {
    return await AutoTypingsCore.create(editor, {
      ...options,
      monaco: options?.monaco ?? (await import('monaco-editor')),
    });
  }
}
