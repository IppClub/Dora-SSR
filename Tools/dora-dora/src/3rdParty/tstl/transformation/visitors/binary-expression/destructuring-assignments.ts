import * as ts from "typescript";
import { transformBinaryOperation } from ".";
import * as lua from "../../../LuaAST";
import { assertNever, cast } from "../../../utils";
import { TransformationContext } from "../../context";
import { LuaLibFeature, transformLuaLibFunction } from "../../utils/lualib";
import { transformInPrecedingStatementScope } from "../../utils/preceding-statements";
import { isArrayType, isAssignmentPattern } from "../../utils/typescript";
import { moveToPrecedingTemp } from "../expression-list";
import { transformPropertyName } from "../literal";
import {
    transformAssignment,
    transformAssignmentLeftHandSideExpression,
    transformAssignmentStatement,
} from "./assignments";

export function isArrayLength(
    context: TransformationContext,
    expression: ts.Expression
): expression is ts.PropertyAccessExpression | ts.ElementAccessExpression {
    if (!ts.isPropertyAccessExpression(expression) && !ts.isElementAccessExpression(expression)) {
        return false;
    }

    const type = context.checker.getTypeAtLocation(expression.expression);
    if (!isArrayType(context, type)) {
        return false;
    }

    const name = ts.isPropertyAccessExpression(expression)
        ? expression.name.text
        : ts.isStringLiteral(expression.argumentExpression)
        ? expression.argumentExpression.text
        : undefined;

    return name === "length";
}

export function transformDestructuringAssignment(
    context: TransformationContext,
    node: ts.DestructuringAssignment,
    root: lua.Expression,
    rightHasPrecedingStatements: boolean
): lua.Statement[] {
    return transformAssignmentPattern(context, node.left, root, rightHasPrecedingStatements);
}

export function transformAssignmentPattern(
    context: TransformationContext,
    node: ts.AssignmentPattern,
    root: lua.Expression,
    rightHasPrecedingStatements: boolean
): lua.Statement[] {
    switch (node.kind) {
        case ts.SyntaxKind.ObjectLiteralExpression:
            return transformObjectLiteralAssignmentPattern(context, node, root, rightHasPrecedingStatements);
        case ts.SyntaxKind.ArrayLiteralExpression:
            return transformArrayLiteralAssignmentPattern(context, node, root, rightHasPrecedingStatements);
    }
}

function transformArrayLiteralAssignmentPattern(
    context: TransformationContext,
    node: ts.ArrayLiteralExpression,
    root: lua.Expression,
    rightHasPrecedingStatements: boolean
): lua.Statement[] {
    return node.elements.flatMap((element, index) => {
        const indexedRoot = lua.createTableIndexExpression(root, lua.createNumericLiteral(index + 1), element);

        switch (element.kind) {
            case ts.SyntaxKind.ObjectLiteralExpression:
                return transformObjectLiteralAssignmentPattern(
                    context,
                    element as ts.ObjectLiteralExpression,
                    indexedRoot,
                    rightHasPrecedingStatements
                );
            case ts.SyntaxKind.ArrayLiteralExpression:
                return transformArrayLiteralAssignmentPattern(
                    context,
                    element as ts.ArrayLiteralExpression,
                    indexedRoot,
                    rightHasPrecedingStatements
                );
            case ts.SyntaxKind.BinaryExpression:
                const assignedVariable = context.createTempNameForLuaExpression(indexedRoot);

                const assignedVariableDeclaration = lua.createVariableDeclarationStatement(
                    assignedVariable,
                    indexedRoot
                );

                const nilCondition = lua.createBinaryExpression(
                    assignedVariable,
                    lua.createNilLiteral(),
                    lua.SyntaxKind.EqualityOperator
                );

                const { precedingStatements: defaultPrecedingStatements, result: defaultAssignmentStatements } =
                    transformInPrecedingStatementScope(context, () =>
                        transformAssignment(
                            context,
                            (element as ts.BinaryExpression).left,
                            context.transformExpression((element as ts.BinaryExpression).right)
                        )
                    );

                // Keep preceding statements inside if block
                defaultAssignmentStatements.unshift(...defaultPrecedingStatements);

                const elseAssignmentStatements = transformAssignment(
                    context,
                    (element as ts.BinaryExpression).left,
                    assignedVariable
                );

                const ifBlock = lua.createBlock(defaultAssignmentStatements);

                const elseBlock = lua.createBlock(elseAssignmentStatements);

                const ifStatement = lua.createIfStatement(nilCondition, ifBlock, elseBlock, node);

                return [assignedVariableDeclaration, ifStatement];
            case ts.SyntaxKind.Identifier:
            case ts.SyntaxKind.PropertyAccessExpression:
            case ts.SyntaxKind.ElementAccessExpression:
                const { precedingStatements, result: statements } = transformInPrecedingStatementScope(context, () =>
                    transformAssignment(context, element, indexedRoot, rightHasPrecedingStatements)
                );
                return [...precedingStatements, ...statements]; // Keep preceding statements in order
            case ts.SyntaxKind.SpreadElement:
                if (index !== node.elements.length - 1) {
                    // TypeScript error
                    return [];
                }

                const restElements = transformLuaLibFunction(
                    context,
                    LuaLibFeature.ArraySlice,
                    undefined,
                    root,
                    lua.createNumericLiteral(index)
                );

                const { precedingStatements: spreadPrecedingStatements, result: spreadStatements } =
                    transformInPrecedingStatementScope(context, () =>
                        transformAssignment(
                            context,
                            (element as ts.SpreadElement).expression,
                            restElements,
                            rightHasPrecedingStatements
                        )
                    );
                return [...spreadPrecedingStatements, ...spreadStatements]; // Keep preceding statements in order
            case ts.SyntaxKind.OmittedExpression:
                return [];
            default:
                // TypeScript error
                return [];
        }
    });
}

function transformObjectLiteralAssignmentPattern(
    context: TransformationContext,
    node: ts.ObjectLiteralExpression,
    root: lua.Expression,
    rightHasPrecedingStatements: boolean
): lua.Statement[] {
    const result: lua.Statement[] = [];

    for (const property of node.properties) {
        switch (property.kind) {
            case ts.SyntaxKind.ShorthandPropertyAssignment:
                result.push(...transformShorthandPropertyAssignment(context, property, root));
                break;
            case ts.SyntaxKind.PropertyAssignment:
                result.push(...transformPropertyAssignment(context, property, root, rightHasPrecedingStatements));
                break;
            case ts.SyntaxKind.SpreadAssignment:
                result.push(...transformSpreadAssignment(context, property, root, node.properties));
                break;
            case ts.SyntaxKind.MethodDeclaration:
            case ts.SyntaxKind.GetAccessor:
            case ts.SyntaxKind.SetAccessor:
                // TypeScript error
                break;
            default:
                assertNever(property);
        }
    }

    return result;
}

function transformShorthandPropertyAssignment(
    context: TransformationContext,
    node: ts.ShorthandPropertyAssignment,
    root: lua.Expression
): lua.Statement[] {
    const result: lua.Statement[] = [];
    const assignmentVariableName = transformAssignmentLeftHandSideExpression(context, node.name);
    const extractionIndex = lua.createStringLiteral(node.name.text);
    const variableExtractionAssignmentStatements = transformAssignment(
        context,
        node.name,
        lua.createTableIndexExpression(root, extractionIndex)
    );

    result.push(...variableExtractionAssignmentStatements);

    const defaultInitializer = node.objectAssignmentInitializer
        ? context.transformExpression(node.objectAssignmentInitializer)
        : undefined;

    if (defaultInitializer) {
        const nilCondition = lua.createBinaryExpression(
            assignmentVariableName,
            lua.createNilLiteral(),
            lua.SyntaxKind.EqualityOperator
        );

        const assignmentStatements = transformAssignment(context, node.name, defaultInitializer);

        const ifBlock = lua.createBlock(assignmentStatements);

        result.push(lua.createIfStatement(nilCondition, ifBlock, undefined, node));
    }

    return result;
}

function transformPropertyAssignment(
    context: TransformationContext,
    node: ts.PropertyAssignment,
    root: lua.Expression,
    rightHasPrecedingStatements: boolean
): lua.Statement[] {
    const result: lua.Statement[] = [];

    if (isAssignmentPattern(node.initializer)) {
        const propertyAccessString = transformPropertyName(context, node.name);
        const newRootAccess = lua.createTableIndexExpression(root, propertyAccessString);

        if (ts.isObjectLiteralExpression(node.initializer)) {
            return transformObjectLiteralAssignmentPattern(
                context,
                node.initializer,
                newRootAccess,
                rightHasPrecedingStatements
            );
        }

        if (ts.isArrayLiteralExpression(node.initializer)) {
            return transformArrayLiteralAssignmentPattern(
                context,
                node.initializer,
                newRootAccess,
                rightHasPrecedingStatements
            );
        }
    }

    context.pushPrecedingStatements();

    let variableToExtract = transformPropertyName(context, node.name);
    // Must be evaluated before left's preceding statements
    variableToExtract = moveToPrecedingTemp(context, variableToExtract, node.name);
    const extractingExpression = lua.createTableIndexExpression(root, variableToExtract);

    let destructureAssignmentStatements: lua.Statement[];
    if (ts.isBinaryExpression(node.initializer)) {
        if (
            ts.isPropertyAccessExpression(node.initializer.left) ||
            ts.isElementAccessExpression(node.initializer.left)
        ) {
            // Access expressions need their table and index expressions cached to preserve execution order
            const left = cast(context.transformExpression(node.initializer.left), lua.isTableIndexExpression);

            const rightExpression = node.initializer.right;
            const { precedingStatements: defaultPrecedingStatements, result: defaultExpression } =
                transformInPrecedingStatementScope(context, () => context.transformExpression(rightExpression));

            const tableTemp = context.createTempNameForLuaExpression(left.table);
            const indexTemp = context.createTempNameForLuaExpression(left.index);

            const tempsDeclaration = lua.createVariableDeclarationStatement(
                [tableTemp, indexTemp],
                [left.table, left.index]
            );

            // obj[index] = extractingExpression ?? defaultExpression
            const { precedingStatements: rightPrecedingStatements, result: rhs } = transformBinaryOperation(
                context,
                extractingExpression,
                defaultExpression,
                defaultPrecedingStatements,
                ts.SyntaxKind.QuestionQuestionToken,
                node.initializer
            );
            const assignStatement = lua.createAssignmentStatement(
                lua.createTableIndexExpression(tableTemp, indexTemp),
                rhs
            );

            destructureAssignmentStatements = [tempsDeclaration, ...rightPrecedingStatements, assignStatement];
        } else {
            const assignmentLeftHandSide = context.transformExpression(node.initializer.left);

            const nilCondition = lua.createBinaryExpression(
                assignmentLeftHandSide,
                lua.createNilLiteral(),
                lua.SyntaxKind.EqualityOperator
            );

            const ifBlock = lua.createBlock(
                transformAssignmentStatement(context, node.initializer as ts.AssignmentExpression<ts.EqualsToken>)
            );

            destructureAssignmentStatements = [lua.createIfStatement(nilCondition, ifBlock, undefined, node)];
        }
    } else {
        destructureAssignmentStatements = transformAssignment(
            context,
            node.initializer,
            extractingExpression,
            rightHasPrecedingStatements
        );
    }

    result.push(...context.popPrecedingStatements());
    result.push(...destructureAssignmentStatements);

    return result;
}

function transformSpreadAssignment(
    context: TransformationContext,
    node: ts.SpreadAssignment,
    root: lua.Expression,
    properties: ts.NodeArray<ts.ObjectLiteralElementLike>
): lua.Statement[] {
    const usedProperties: lua.TableFieldExpression[] = [];
    for (const property of properties) {
        if (
            (ts.isShorthandPropertyAssignment(property) || ts.isPropertyAssignment(property)) &&
            !ts.isComputedPropertyName(property.name) &&
            !ts.isPrivateIdentifier(property.name)
        ) {
            const name = ts.isIdentifier(property.name)
                ? lua.createStringLiteral(property.name.text)
                : context.transformExpression(property.name);

            usedProperties.push(lua.createTableFieldExpression(lua.createBooleanLiteral(true), name));
        }
    }

    const extractingExpression = transformLuaLibFunction(
        context,
        LuaLibFeature.ObjectRest,
        undefined,
        root,
        lua.createTableExpression(usedProperties)
    );

    return transformAssignment(context, node.expression, extractingExpression);
}
