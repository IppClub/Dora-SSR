import path from "path";
import { EmitHost } from "./transpilation";
import * as lua from "./LuaAST";
import { LuaTarget } from "./CompilerOptions";
import { getOrUpdate } from "./utils";
import lualib_module_info from "./lualib_module_info.json";

export enum LuaLibFeature {
    ArrayAt = "ArrayAt",
    ArrayConcat = "ArrayConcat",
    ArrayEntries = "ArrayEntries",
    ArrayEvery = "ArrayEvery",
    ArrayFill = "ArrayFill",
    ArrayFilter = "ArrayFilter",
    ArrayForEach = "ArrayForEach",
    ArrayFind = "ArrayFind",
    ArrayFindIndex = "ArrayFindIndex",
    ArrayFrom = "ArrayFrom",
    ArrayIncludes = "ArrayIncludes",
    ArrayIndexOf = "ArrayIndexOf",
    ArrayIsArray = "ArrayIsArray",
    ArrayJoin = "ArrayJoin",
    ArrayMap = "ArrayMap",
    ArrayPush = "ArrayPush",
    ArrayPushArray = "ArrayPushArray",
    ArrayReduce = "ArrayReduce",
    ArrayReduceRight = "ArrayReduceRight",
    ArrayReverse = "ArrayReverse",
    ArrayUnshift = "ArrayUnshift",
    ArraySort = "ArraySort",
    ArraySlice = "ArraySlice",
    ArraySome = "ArraySome",
    ArraySplice = "ArraySplice",
    ArrayToObject = "ArrayToObject",
    ArrayFlat = "ArrayFlat",
    ArrayFlatMap = "ArrayFlatMap",
    ArraySetLength = "ArraySetLength",
    ArrayToReversed = "ArrayToReversed",
    ArrayToSorted = "ArrayToSorted",
    ArrayToSpliced = "ArrayToSpliced",
    ArrayWith = "ArrayWith",
    Await = "Await",
    Class = "Class",
    ClassExtends = "ClassExtends",
    CloneDescriptor = "CloneDescriptor",
    CountVarargs = "CountVarargs",
    Decorate = "Decorate",
    DecorateLegacy = "DecorateLegacy",
    DecorateParam = "DecorateParam",
    Delete = "Delete",
    DelegatedYield = "DelegatedYield",
    DescriptorGet = "DescriptorGet",
    DescriptorSet = "DescriptorSet",
    Error = "Error",
    FunctionBind = "FunctionBind",
    Generator = "Generator",
    InstanceOf = "InstanceOf",
    InstanceOfObject = "InstanceOfObject",
    Iterator = "Iterator",
    LuaIteratorSpread = "LuaIteratorSpread",
    Map = "Map",
    MapGroupBy = "MapGroupBy",
    Match = "Match",
    MathAtan2 = "MathAtan2",
    MathModf = "MathModf",
    MathSign = "MathSign",
    MathTrunc = "MathTrunc",
    New = "New",
    Number = "Number",
    NumberIsFinite = "NumberIsFinite",
    NumberIsInteger = "NumberIsInteger",
    NumberIsNaN = "NumberIsNaN",
    NumberParseInt = "ParseInt",
    NumberParseFloat = "ParseFloat",
    NumberToString = "NumberToString",
    NumberToFixed = "NumberToFixed",
    ObjectAssign = "ObjectAssign",
    ObjectDefineProperty = "ObjectDefineProperty",
    ObjectEntries = "ObjectEntries",
    ObjectFromEntries = "ObjectFromEntries",
    ObjectGetOwnPropertyDescriptor = "ObjectGetOwnPropertyDescriptor",
    ObjectGetOwnPropertyDescriptors = "ObjectGetOwnPropertyDescriptors",
    ObjectGroupBy = "ObjectGroupBy",
    ObjectKeys = "ObjectKeys",
    ObjectRest = "ObjectRest",
    ObjectValues = "ObjectValues",
    ParseFloat = "ParseFloat",
    ParseInt = "ParseInt",
    Promise = "Promise",
    PromiseAll = "PromiseAll",
    PromiseAllSettled = "PromiseAllSettled",
    PromiseAny = "PromiseAny",
    PromiseRace = "PromiseRace",
    Set = "Set",
    SetDescriptor = "SetDescriptor",
    SparseArrayNew = "SparseArrayNew",
    SparseArrayPush = "SparseArrayPush",
    SparseArraySpread = "SparseArraySpread",
    WeakMap = "WeakMap",
    WeakSet = "WeakSet",
    SourceMapTraceBack = "SourceMapTraceBack",
    Spread = "Spread",
    StringAccess = "StringAccess",
    StringCharAt = "StringCharAt",
    StringCharCodeAt = "StringCharCodeAt",
    StringEndsWith = "StringEndsWith",
    StringIncludes = "StringIncludes",
    StringPadEnd = "StringPadEnd",
    StringPadStart = "StringPadStart",
    StringReplace = "StringReplace",
    StringReplaceAll = "StringReplaceAll",
    StringSlice = "StringSlice",
    StringSplit = "StringSplit",
    StringStartsWith = "StringStartsWith",
    StringSubstr = "StringSubstr",
    StringSubstring = "StringSubstring",
    StringTrim = "StringTrim",
    StringTrimEnd = "StringTrimEnd",
    StringTrimStart = "StringTrimStart",
    Symbol = "Symbol",
    SymbolRegistry = "SymbolRegistry",
    TypeOf = "TypeOf",
    Unpack = "Unpack",
    Using = "Using",
    UsingAsync = "UsingAsync",
}

export interface LuaLibFeatureInfo {
    dependencies?: LuaLibFeature[];
    exports: string[];
}

export type LuaLibModulesInfo = Record<LuaLibFeature, LuaLibFeatureInfo>;

const luaLibModulesInfo = new Map<LuaTarget, LuaLibModulesInfo>();

export function getLuaLibModulesInfo(luaTarget: LuaTarget): LuaLibModulesInfo {
    if (!luaLibModulesInfo.has(luaTarget)) {
        luaLibModulesInfo.set(luaTarget, lualib_module_info as LuaLibModulesInfo);
    }
    return luaLibModulesInfo.get(luaTarget)!;
}

// This caches the names of lualib exports to their LuaLibFeature, avoiding a linear search for every lookup
const lualibExportToFeature = new Map<LuaTarget, ReadonlyMap<string, LuaLibFeature>>();

export function getLuaLibExportToFeatureMap(
    luaTarget: LuaTarget,
): ReadonlyMap<string, LuaLibFeature> {
    if (!lualibExportToFeature.has(luaTarget)) {
        const luaLibModulesInfo = getLuaLibModulesInfo(luaTarget);
        const map = new Map<string, LuaLibFeature>();
        for (const [feature, info] of Object.entries(luaLibModulesInfo)) {
            for (const exportName of info.exports) {
                map.set(exportName, feature as LuaLibFeature);
            }
        }
        lualibExportToFeature.set(luaTarget, map);
    }

    return lualibExportToFeature.get(luaTarget)!;
}

const lualibFeatureCache = new Map<LuaTarget, Map<LuaLibFeature, string>>();

export function readLuaLibFeature(feature: LuaLibFeature, luaTarget: LuaTarget, emitHost: EmitHost): string {
    const featureMap = getOrUpdate(lualibFeatureCache, luaTarget, () => new Map());
    if (!featureMap.has(feature)) {
        const featurePath = path.join("lualib", `${feature}.lua`);
        const luaLibFeature = emitHost.readFile(featurePath);
        if (luaLibFeature === undefined) {
            throw new Error(`Could not load lualib feature from '${featurePath}'`);
        }
        featureMap.set(feature, luaLibFeature);
    }
    return featureMap.get(feature)!;
}

export function resolveRecursiveLualibFeatures(
    features: Iterable<LuaLibFeature>,
    luaTarget: LuaTarget,
    emitHost: EmitHost,
    luaLibModulesInfo: LuaLibModulesInfo = getLuaLibModulesInfo(luaTarget)
): LuaLibFeature[] {
    const loadedFeatures = new Set<LuaLibFeature>();
    const result: LuaLibFeature[] = [];

    function load(feature: LuaLibFeature): void {
        if (loadedFeatures.has(feature)) return;
        loadedFeatures.add(feature);

        const dependencies = luaLibModulesInfo[feature]?.dependencies;
        if (dependencies) {
            dependencies.forEach(load);
        }

        result.push(feature);
    }

    for (const feature of features) {
        load(feature);
    }

    return result;
}

export function loadInlineLualibFeatures(
    features: Iterable<LuaLibFeature>,
    luaTarget: LuaTarget,
    emitHost: EmitHost
): string {
    return resolveRecursiveLualibFeatures(features, luaTarget, emitHost)
        .map(feature => readLuaLibFeature(feature, luaTarget, emitHost))
        .join("\n");
}

export function loadImportedLualibFeatures(
    features: Iterable<LuaLibFeature>,
    luaTarget: LuaTarget,
    emitHost: EmitHost
): lua.Statement[] {
    const luaLibModuleInfo = getLuaLibModulesInfo(luaTarget);

    const imports = Array.from(features).flatMap(feature => luaLibModuleInfo[feature].exports);
    if (imports.length === 0) {
        return [];
    }

    const requireCall = lua.createCallExpression(lua.createIdentifier("require"), [
        lua.createStringLiteral("lualib_bundle"),
    ]);

    const luaLibId = lua.createIdentifier("____lualib");
    const importStatement = lua.createVariableDeclarationStatement(luaLibId, requireCall);
    const statements: lua.Statement[] = [importStatement];
    // local <export> = ____luaLib.<export>
    for (const item of imports) {
        statements.push(
            lua.createVariableDeclarationStatement(
                lua.createIdentifier(item),
                lua.createTableIndexExpression(luaLibId, lua.createStringLiteral(item))
            )
        );
    }
    return statements;
}

const luaLibBundleContent = new Map<string, string>();

export function getLuaLibBundle(luaTarget: LuaTarget, emitHost: EmitHost): string {
    const lualibPath = "lualib_bundle.lua";
    if (!luaLibBundleContent.has(lualibPath)) {
        const result = emitHost.readFile(lualibPath);
        if (result !== undefined) {
            luaLibBundleContent.set(lualibPath, result);
        } else {
            throw new Error(`Could not load lualib bundle from '${lualibPath}'`);
        }
    }

    return luaLibBundleContent.get(lualibPath) as string;
}

export function getLualibBundleReturn(exportedValues: string[]): string {
    return `\nreturn {\n${exportedValues.map(exportName => `  ${exportName} = ${exportName}`).join(",\n")}\n}\n`;
}

export function buildMinimalLualibBundle(
    features: Iterable<LuaLibFeature>,
    luaTarget: LuaTarget,
    emitHost: EmitHost
): string {
    const code = loadInlineLualibFeatures(features, luaTarget, emitHost);
    const moduleInfo = getLuaLibModulesInfo(luaTarget);
    const exports = Array.from(features).flatMap(feature => moduleInfo[feature].exports);

    return code + getLualibBundleReturn(exports);
}
