import { SourceCache } from './SourceCache';
import { ProgressUpdate } from './ProgressUpdate';
import type * as monaco from 'monaco-editor';

export interface Options {
  /**
   * Share source cache between multiple editor instances by storing
   * the cache in a static property.
   *
   * Defaults to false.
   */
  shareCache: boolean;

  /**
   * Only use packages specified in the `versions` property.
   *
   * Defaults to false.
   */
  onlySpecifiedPackages: boolean;

  /**
   * Load typings from prespecified versions when initializing. Versions
   * need to be specified in the ``versions`` option.
   *
   * Defaults to false.
   */
  preloadPackages: boolean;

  /**
   * After typings were resolved and injected into monaco, auto-typings
   * updates the value of the current model to trigger a refresh in
   * monaco's typing logic, so that it uses the injected typings.
   */
  dontRefreshModelValueAfterResolvement: boolean;

  /**
   * Prespecified package versions. If a package is loaded whose
   * name is specified in this object, it will load with the exact
   * version specified in the object.
   *
   * Example:
   *
   * ```json
   * {
   *   "@types/react": "17.0.0",
   *   "csstype": "3.0.5"
   * }
   * ```
   *
   * Setting the option ``onlySpecifiedPackages`` to true makes this
   * property act as a whitelist for packages.
   *
   * Setting the option ``preloadPackages`` makes the packages specified
   * in this property load directly after initializing the auto-loader.
   */
  versions?: { [packageName: string]: string };

  /**
   * If a new package was loaded, its name and version is added to the
   * version object, and this method is called with the updated object.
   * @param versions updated versions object.
   */
  onUpdateVersions?: (versions: { [packageName: string]: string }) => void;

  /**
   * Supply a cache where declaration files and package.json files are
   * cached to.
   */
  sourceCache: SourceCache;

  /**
   * Debounces code reanalyzing after user has changed the editor contents
   * by the specified amount. Set to zero to disable. Value provided in
   * milliseconds.
   *
   * Defaults to 4000, i.e. 4 seconds.
   */
  debounceDuration: number;

  /**
   * Maximum recursion depth for recursing packages. Determines how many
   * nested package declarations are loaded. For example, if ``packageRecursionDepth``
   * has the value 2, the code in the monaco editor references packages ``A1``, ``A2``
   * and ``A3``, package ``A1`` references package ``B1`` and ``B1`` references ``C1``,
   * then packages ``A1``, ``A2``, ``A3`` and ``B1`` are loaded. Set to zero to
   * disable.
   *
   * Defaults to 3.
   */
  packageRecursionDepth: number;

  /**
   * Maximum recursion depth for recursing files. Determines how many
   * nested file declarations are loaded. The same as ``packageRecursionDepth``,
   * but for individual files. Set to zero to disable.
   *
   * Defaults to 10.
   */
  fileRecursionDepth: number;

  /**
   * Called after progress updates like loaded declarations or events.
   * @param update detailed event object containing update infos.
   * @param textual a textual representation of the update for debugging.
   */
  onUpdate?: (update: ProgressUpdate, textual: string) => void;

  /**
   * Called if errors occur.
   * @param error a textual representation of the error.
   */
  onError?: (error: string) => void;
  /**
   * instance of monaco editor
   */
  monaco: typeof monaco;
}
