import * as ts from "typescript";
import { TransformationContext } from "../context";
import {
    doraHookDependencyArrayRequired,
    doraHookExtraDependency,
    doraHookMissingDependency,
} from "./diagnostics";

const checkedHookNames = new Set(["useMemo", "useCallback"]);

function getPropertyAccessText(node: ts.Identifier): string | undefined {
    let expression: ts.Expression = node;
    let current: ts.Node = node;

    while (
        current.parent &&
        ts.isPropertyAccessExpression(current.parent) &&
        current.parent.expression === expression
    ) {
        expression = current.parent;
        current = current.parent;
    }

    if (expression !== node) {
        return expression.getText();
    }
}

function isPropertyNameUse(node: ts.Identifier): boolean {
    const parent = node.parent;
    return (
        (ts.isPropertyAccessExpression(parent) && parent.name === node) ||
        (ts.isPropertyAssignment(parent) && parent.name === node) ||
        (ts.isMethodDeclaration(parent) && parent.name === node) ||
        (ts.isPropertyDeclaration(parent) && parent.name === node) ||
        (ts.isPropertySignature(parent) && parent.name === node) ||
        (ts.isMethodSignature(parent) && parent.name === node)
    );
}

function isDeclarationName(node: ts.Identifier): boolean {
    const parent = node.parent;
    return (
        (ts.isVariableDeclaration(parent) && parent.name === node) ||
        (ts.isBindingElement(parent) && parent.name === node) ||
        (ts.isParameter(parent) && parent.name === node) ||
        (ts.isFunctionDeclaration(parent) && parent.name === node) ||
        (ts.isFunctionExpression(parent) && parent.name === node) ||
        (ts.isClassDeclaration(parent) && parent.name === node) ||
        (ts.isInterfaceDeclaration(parent) && parent.name === node) ||
        (ts.isTypeAliasDeclaration(parent) && parent.name === node) ||
        (ts.isImportSpecifier(parent) && parent.name === node) ||
        (ts.isImportClause(parent) && parent.name === node) ||
        (ts.isNamespaceImport(parent) && parent.name === node)
    );
}

function getNodeSourceFileName(context: TransformationContext, node: ts.Node): string | undefined {
    const sourceFiles = [
        ts.getOriginalNode(node).getSourceFile(),
        node.getSourceFile(),
        context.sourceFile,
    ];
    for (const sourceFile of sourceFiles) {
        if (sourceFile?.fileName) {
            return sourceFile.fileName.replace(/\\/g, "/");
        }
    }
}

function containsNode(parent: ts.Node, child: ts.Node): boolean {
    return child.pos >= parent.pos && child.end <= parent.end && child.getSourceFile() === parent.getSourceFile();
}

function findEnclosingFunction(node: ts.Node): ts.Node | undefined {
    let current: ts.Node | undefined = node;
    while (current) {
        if (
            ts.isFunctionDeclaration(current) ||
            ts.isFunctionExpression(current) ||
            ts.isArrowFunction(current) ||
            ts.isMethodDeclaration(current) ||
            ts.isConstructorDeclaration(current) ||
            ts.isGetAccessorDeclaration(current) ||
            ts.isSetAccessorDeclaration(current)
        ) {
            return current;
        }
        current = current.parent;
    }
}

function getHookName(node: ts.CallExpression): string | undefined {
    const expression = ts.skipOuterExpressions(node.expression);
    if (ts.isIdentifier(expression)) {
        return checkedHookNames.has(expression.text) ? expression.text : undefined;
    }
    if (ts.isPropertyAccessExpression(expression) && checkedHookNames.has(expression.name.text)) {
        return expression.name.text;
    }
}

function getCalledSymbol(context: TransformationContext, node: ts.CallExpression): ts.Symbol | undefined {
    const expression = ts.skipOuterExpressions(node.expression);
    const name = ts.isPropertyAccessExpression(expression) ? expression.name : expression;
    if (!ts.isIdentifier(name)) {
        return;
    }

    const symbol = context.checker.getSymbolAtLocation(name);
    if (!symbol) {
        return;
    }

    return (symbol.flags & ts.SymbolFlags.Alias) !== 0 ? context.checker.getAliasedSymbol(symbol) : symbol;
}

function isDoraXHookCall(context: TransformationContext, node: ts.CallExpression): boolean {
    const hookName = getHookName(node);
    if (!hookName) {
        return false;
    }

    const symbol = getCalledSymbol(context, node);
    return (
        symbol?.getDeclarations()?.some(declaration => {
            if (!ts.isFunctionDeclaration(declaration) || declaration.name?.text !== hookName) {
                return false;
            }
            const fileName = declaration.getSourceFile().fileName.replace(/\\/g, "/");
            return (
                fileName === "DoraX.d.ts" ||
                fileName.endsWith("/DoraX.d.ts") ||
                (declaration.getSourceFile() !== context.sourceFile &&
                    (fileName === "DoraX.ts" || fileName.endsWith("/DoraX.ts")))
            );
        }) ?? false
    );
}

interface DependencyArrayInfo {
    argument?: ts.Expression;
    array?: ts.ArrayLiteralExpression;
}

function getDependencyArray(node: ts.CallExpression): DependencyArrayInfo {
    const deps = node.arguments[1];
    if (!deps) {
        return {};
    }
    const expression = ts.skipOuterExpressions(deps);
    return {
        argument: deps,
        array: ts.isArrayLiteralExpression(expression) ? expression : undefined,
    };
}

function collectDeclaredSymbols(context: TransformationContext, node: ts.Node): Set<ts.Symbol> {
    const declarations = new Set<ts.Symbol>();

    const visit = (current: ts.Node) => {
        if (ts.isIdentifier(current) && isDeclarationName(current)) {
            const symbol = context.checker.getSymbolAtLocation(current);
            if (symbol) {
                declarations.add(symbol);
            }
        }
        ts.forEachChild(current, visit);
    };

    visit(node);
    return declarations;
}

function getIdentifierSymbol(context: TransformationContext, node: ts.Identifier): ts.Symbol | undefined {
    const parent = node.parent;
    if (ts.isShorthandPropertyAssignment(parent) && parent.name === node) {
        const checker = context.checker as ts.TypeChecker & {
            getShorthandAssignmentValueSymbol?: (location: ts.Node) => ts.Symbol | undefined;
        };
        const symbol = checker.getShorthandAssignmentValueSymbol?.(parent);
        if (symbol) {
            return symbol;
        }
    }
    return context.checker.getSymbolAtLocation(node);
}

function isSignalValueDependency(context: TransformationContext, identifier: ts.Identifier, dependency: string): boolean {
    return (
        dependency.endsWith(".value") && context.checker.getTypeAtLocation(identifier).getProperty("value") !== undefined
    );
}

function shouldTrackSymbol(
    context: TransformationContext,
    callback: ts.Node,
    identifier: ts.Identifier,
    dependency: string,
    symbol: ts.Symbol
): boolean {
    const declarations = symbol.getDeclarations();
    if (!declarations || declarations.length === 0) {
        return false;
    }

    return declarations.some(declaration => {
        if (declaration.getSourceFile() !== callback.getSourceFile()) {
            return false;
        }
        if (containsNode(callback, declaration)) {
            return false;
        }
        const declarationFunction = findEnclosingFunction(declaration);
        if (!declarationFunction) {
            return isSignalValueDependency(context, identifier, dependency);
        }
        return containsNode(declarationFunction, callback);
    });
}

function collectUsedDependencies(context: TransformationContext, callback: ts.Node): string[] {
    const localSymbols = collectDeclaredSymbols(context, callback);
    const dependencies = new Map<string, ts.Node>();

    const visit = (current: ts.Node) => {
        if (ts.isFunctionLike(current) && current !== callback) {
            return;
        }

        if (ts.isIdentifier(current) && !isPropertyNameUse(current) && !isDeclarationName(current)) {
            const symbol = getIdentifierSymbol(context, current);
            const dependency = getPropertyAccessText(current) ?? current.getText();
            if (
                symbol &&
                !localSymbols.has(symbol) &&
                shouldTrackSymbol(context, callback, current, dependency, symbol)
            ) {
                if (!dependency.includes(".current")) {
                    dependencies.set(dependency, current);
                }
            }
        }

        ts.forEachChild(current, visit);
    };

    visit(callback);
    return [...dependencies.keys()].sort();
}

function collectDeclaredDependencies(deps: ts.ArrayLiteralExpression): Map<string, ts.Expression> {
    const dependencies = new Map<string, ts.Expression>();
    for (const element of deps.elements) {
        if (!ts.isSpreadElement(element)) {
            const dependency = ts.skipOuterExpressions(element);
            dependencies.set(dependency.getText(), dependency);
        }
    }
    return dependencies;
}

export function validateDoraHookDependencies(context: TransformationContext, node: ts.CallExpression): void {
    const sourceFileName = getNodeSourceFileName(context, node);
    if (sourceFileName === "DoraX.ts" || sourceFileName.endsWith("/DoraX.ts")) {
        return;
    }

    const hookName = getHookName(node);
    if (!hookName || !isDoraXHookCall(context, node)) {
        return;
    }

    const callback = node.arguments[0];
    if (!callback || (!ts.isArrowFunction(callback) && !ts.isFunctionExpression(callback))) {
        return;
    }

    const deps = getDependencyArray(node);
    if (!deps.array) {
        context.diagnostics.push(doraHookDependencyArrayRequired(deps.argument ?? node, hookName));
        return;
    }

    const declaredDependencies = collectDeclaredDependencies(deps.array);
    const usedDependencies = new Set(collectUsedDependencies(context, callback));
    for (const dependency of usedDependencies) {
        if (!declaredDependencies.has(dependency)) {
            context.diagnostics.push(doraHookMissingDependency(deps.array, hookName, dependency));
        }
    }
    for (const [dependency, dependencyNode] of declaredDependencies) {
        if (!usedDependencies.has(dependency)) {
            context.diagnostics.push(doraHookExtraDependency(dependencyNode, hookName, dependency));
        }
    }
}
