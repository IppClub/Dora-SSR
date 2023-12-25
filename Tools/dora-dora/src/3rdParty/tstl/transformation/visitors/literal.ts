import * as ts from "typescript";
import * as lua from "../../LuaAST";
import { assertNever } from "../../utils";
import { FunctionVisitor, TransformationContext, Visitors } from "../context";
import { undefinedInArrayLiteral, unsupportedAccessorInObjectLiteral } from "../utils/diagnostics";
import { LuaLibFeature, transformLuaLibFunction } from "../utils/lualib";
import { trackSymbolReference } from "../utils/symbols";
import { isArrayType } from "../utils/typescript";
import { transformFunctionLikeDeclaration } from "./function";
import { moveToPrecedingTemp, transformExpressionList } from "./expression-list";
import { transformIdentifierWithSymbol } from "./identifier";
import { LuaTarget } from "../../CompilerOptions";

// TODO: Move to object-literal.ts?
export function transformPropertyName(context: TransformationContext, node: ts.PropertyName): lua.Expression {
    if (ts.isComputedPropertyName(node)) {
        return context.transformExpression(node.expression);
    } else if (ts.isIdentifier(node)) {
        return lua.createStringLiteral(node.text);
    } else if (ts.isPrivateIdentifier(node)) {
        throw new Error("PrivateIdentifier is not supported");
    } else {
        return context.transformExpression(node);
    }
}

export function createShorthandIdentifier(
    context: TransformationContext,
    valueSymbol: ts.Symbol | undefined,
    propertyIdentifier: ts.Identifier
): lua.Expression {
    return transformIdentifierWithSymbol(context, propertyIdentifier, valueSymbol);
}

const transformNumericLiteralExpression: FunctionVisitor<ts.NumericLiteral> = (expression, context) => {
    if (expression.text === "Infinity") {
        if (context.luaTarget === LuaTarget.Lua50) {
            const one = lua.createNumericLiteral(1);
            const zero = lua.createNumericLiteral(0);
            return lua.createBinaryExpression(one, zero, lua.SyntaxKind.DivisionOperator);
        } else {
            const math = lua.createIdentifier("math");
            const huge = lua.createStringLiteral("huge");
            return lua.createTableIndexExpression(math, huge, expression);
        }
    }

    return lua.createNumericLiteral(Number(expression.text), expression);
};

const transformObjectLiteralExpression: FunctionVisitor<ts.ObjectLiteralExpression> = (expression, context) => {
    const properties: lua.Expression[] = [];
    const initializers: ts.Node[] = [];
    const keyPrecedingStatements: lua.Statement[][] = [];
    const valuePrecedingStatements: lua.Statement[][] = [];
    let lastPrecedingStatementsIndex = -1;

    for (let i = 0; i < expression.properties.length; ++i) {
        const element = expression.properties[i];

        // Transform key and cache preceding statements
        context.pushPrecedingStatements();

        const name = element.name ? transformPropertyName(context, element.name) : undefined;

        let precedingStatements = context.popPrecedingStatements();
        keyPrecedingStatements.push(precedingStatements);
        if (precedingStatements.length > 0) {
            lastPrecedingStatementsIndex = i;
        }

        // Transform value and cache preceding statements
        context.pushPrecedingStatements();

        if (ts.isPropertyAssignment(element)) {
            const expression = context.transformExpression(element.initializer);
            properties.push(lua.createTableFieldExpression(expression, name, element));
            initializers.push(element.initializer);
        } else if (ts.isShorthandPropertyAssignment(element)) {
            const valueSymbol = context.checker.getShorthandAssignmentValueSymbol(element);
            if (valueSymbol) {
                trackSymbolReference(context, valueSymbol, element.name);
            }

            const identifier = createShorthandIdentifier(context, valueSymbol, element.name);
            properties.push(lua.createTableFieldExpression(identifier, name, element));
            initializers.push(element);
        } else if (ts.isMethodDeclaration(element)) {
            const expression = transformFunctionLikeDeclaration(element, context);
            properties.push(lua.createTableFieldExpression(expression, name, element));
            initializers.push(element);
        } else if (ts.isSpreadAssignment(element)) {
            const type = context.checker.getTypeAtLocation(element.expression);
            let tableExpression: lua.Expression;
            if (isArrayType(context, type)) {
                tableExpression = transformLuaLibFunction(
                    context,
                    LuaLibFeature.ArrayToObject,
                    element.expression,
                    context.transformExpression(element.expression)
                );
            } else {
                tableExpression = context.transformExpression(element.expression);
            }

            properties.push(tableExpression);
            initializers.push(element.expression);
        } else if (ts.isAccessor(element)) {
            context.diagnostics.push(unsupportedAccessorInObjectLiteral(element));
        } else {
            assertNever(element);
        }

        precedingStatements = context.popPrecedingStatements();
        valuePrecedingStatements.push(precedingStatements);
        if (precedingStatements.length > 0) {
            lastPrecedingStatementsIndex = i;
        }
    }

    // Expressions referenced before others that produced preceding statements need to be cached in temps
    if (lastPrecedingStatementsIndex >= 0) {
        for (let i = 0; i < properties.length; ++i) {
            const property = properties[i];

            // Bubble up key's preceding statements
            context.addPrecedingStatements(keyPrecedingStatements[i]);

            // Cache computed property name in temp if before the last expression that generated preceding statements
            if (i <= lastPrecedingStatementsIndex && lua.isTableFieldExpression(property) && property.key) {
                property.key = moveToPrecedingTemp(context, property.key, expression.properties[i].name);
            }

            // Bubble up value's preceding statements
            context.addPrecedingStatements(valuePrecedingStatements[i]);

            // Cache property value in temp if before the last expression that generated preceding statements
            if (i < lastPrecedingStatementsIndex) {
                if (lua.isTableFieldExpression(property)) {
                    property.value = moveToPrecedingTemp(context, property.value, initializers[i]);
                } else {
                    properties[i] = moveToPrecedingTemp(context, property, initializers[i]);
                }
            }
        }
    }

    // Sort into field expressions and tables to pass into __TS__ObjectAssign
    let fields: lua.TableFieldExpression[] = [];
    const tableExpressions: lua.Expression[] = [];
    for (const property of properties) {
        if (lua.isTableFieldExpression(property)) {
            fields.push(property);
        } else {
            if (fields.length > 0) {
                tableExpressions.push(lua.createTableExpression(fields));
            }
            tableExpressions.push(property);
            fields = [];
        }
    }

    if (tableExpressions.length === 0) {
        return lua.createTableExpression(fields, expression);
    } else {
        if (fields.length > 0) {
            const tableExpression = lua.createTableExpression(fields, expression);
            tableExpressions.push(tableExpression);
        }

        if (tableExpressions[0].kind !== lua.SyntaxKind.TableExpression) {
            tableExpressions.unshift(lua.createTableExpression(undefined, expression));
        }
        return transformLuaLibFunction(context, LuaLibFeature.ObjectAssign, expression, ...tableExpressions);
    }
};

const transformArrayLiteralExpression: FunctionVisitor<ts.ArrayLiteralExpression> = (expression, context) => {
    // Disallow using undefined/null in array literals
    checkForUndefinedOrNullInArrayLiteral(expression, context);

    const filteredElements = expression.elements.map(e =>
        ts.isOmittedExpression(e) ? ts.factory.createIdentifier("undefined") : e
    );
    const values = transformExpressionList(context, filteredElements).map(e => lua.createTableFieldExpression(e));

    return lua.createTableExpression(values, expression);
};

function checkForUndefinedOrNullInArrayLiteral(array: ts.ArrayLiteralExpression, context: TransformationContext) {
    // Look for last non-nil element in literal
    let lastNonUndefinedIndex = array.elements.length - 1;
    for (; lastNonUndefinedIndex >= 0; lastNonUndefinedIndex--) {
        if (!isUndefinedOrNull(array.elements[lastNonUndefinedIndex])) {
            break;
        }
    }

    // Add diagnostics for non-trailing nil elements in array literal
    for (let i = 0; i < array.elements.length; i++) {
        if (i < lastNonUndefinedIndex && isUndefinedOrNull(array.elements[i])) {
            context.diagnostics.push(undefinedInArrayLiteral(array.elements[i]));
        }
    }
}

function isUndefinedOrNull(node: ts.Node) {
    return (
        node.kind === ts.SyntaxKind.UndefinedKeyword ||
        node.kind === ts.SyntaxKind.NullKeyword ||
        (ts.isIdentifier(node) && node.text === "undefined")
    );
}

export const literalVisitors: Visitors = {
    [ts.SyntaxKind.NullKeyword]: node => lua.createNilLiteral(node),
    [ts.SyntaxKind.TrueKeyword]: node => lua.createBooleanLiteral(true, node),
    [ts.SyntaxKind.FalseKeyword]: node => lua.createBooleanLiteral(false, node),
    [ts.SyntaxKind.NumericLiteral]: transformNumericLiteralExpression,
    [ts.SyntaxKind.StringLiteral]: node => lua.createStringLiteral(node.text, node),
    [ts.SyntaxKind.NoSubstitutionTemplateLiteral]: node => lua.createStringLiteral(node.text, node),
    [ts.SyntaxKind.ObjectLiteralExpression]: transformObjectLiteralExpression,
    [ts.SyntaxKind.ArrayLiteralExpression]: transformArrayLiteralExpression,
};
