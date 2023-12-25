import * as ts from "typescript";
import * as lua from "../../../LuaAST";
import { assertNever } from "../../../utils";
import { TransformationContext } from "../../context";
import { transformInPrecedingStatementScope, WithPrecedingStatements } from "../../utils/preceding-statements";
import { transformBinaryOperation } from "./index";
import { transformAssignmentWithRightPrecedingStatements } from "./assignments";
import { isArrayLength } from "./destructuring-assignments";
import { LuaLibFeature, transformLuaLibFunction } from "../../utils/lualib";
import { cannotAssignToNodeOfKind } from "../../utils/diagnostics";

function isLuaExpressionWithSideEffect(expression: lua.Expression) {
    return !(lua.isLiteral(expression) || lua.isIdentifier(expression));
}

function shouldCacheTableIndexExpressions(
    expression: lua.TableIndexExpression,
    rightPrecedingStatements: lua.Statement[]
) {
    return (
        isLuaExpressionWithSideEffect(expression.table) ||
        isLuaExpressionWithSideEffect(expression.index) ||
        rightPrecedingStatements.length > 0
    );
}

// TODO: `as const` doesn't work on enum members
type CompoundAssignmentToken =
    | ts.SyntaxKind.BarToken
    | ts.SyntaxKind.PlusToken
    | ts.SyntaxKind.CaretToken
    | ts.SyntaxKind.MinusToken
    | ts.SyntaxKind.SlashToken
    | ts.SyntaxKind.PercentToken
    | ts.SyntaxKind.AsteriskToken
    | ts.SyntaxKind.AmpersandToken
    | ts.SyntaxKind.AsteriskAsteriskToken
    | ts.SyntaxKind.LessThanLessThanToken
    | ts.SyntaxKind.GreaterThanGreaterThanToken
    | ts.SyntaxKind.GreaterThanGreaterThanGreaterThanToken
    | ts.SyntaxKind.BarBarToken
    | ts.SyntaxKind.AmpersandAmpersandToken
    | ts.SyntaxKind.QuestionQuestionToken;

const compoundToAssignmentTokens: Record<ts.CompoundAssignmentOperator, CompoundAssignmentToken> = {
    [ts.SyntaxKind.BarEqualsToken]: ts.SyntaxKind.BarToken,
    [ts.SyntaxKind.PlusEqualsToken]: ts.SyntaxKind.PlusToken,
    [ts.SyntaxKind.CaretEqualsToken]: ts.SyntaxKind.CaretToken,
    [ts.SyntaxKind.MinusEqualsToken]: ts.SyntaxKind.MinusToken,
    [ts.SyntaxKind.SlashEqualsToken]: ts.SyntaxKind.SlashToken,
    [ts.SyntaxKind.PercentEqualsToken]: ts.SyntaxKind.PercentToken,
    [ts.SyntaxKind.AsteriskEqualsToken]: ts.SyntaxKind.AsteriskToken,
    [ts.SyntaxKind.AmpersandEqualsToken]: ts.SyntaxKind.AmpersandToken,
    [ts.SyntaxKind.AsteriskAsteriskEqualsToken]: ts.SyntaxKind.AsteriskAsteriskToken,
    [ts.SyntaxKind.LessThanLessThanEqualsToken]: ts.SyntaxKind.LessThanLessThanToken,
    [ts.SyntaxKind.GreaterThanGreaterThanEqualsToken]: ts.SyntaxKind.GreaterThanGreaterThanToken,
    [ts.SyntaxKind.GreaterThanGreaterThanGreaterThanEqualsToken]: ts.SyntaxKind.GreaterThanGreaterThanGreaterThanToken,
    [ts.SyntaxKind.BarBarEqualsToken]: ts.SyntaxKind.BarBarToken,
    [ts.SyntaxKind.AmpersandAmpersandEqualsToken]: ts.SyntaxKind.AmpersandAmpersandToken,
    [ts.SyntaxKind.QuestionQuestionEqualsToken]: ts.SyntaxKind.QuestionQuestionToken,
};

export const isCompoundAssignmentToken = (token: ts.BinaryOperator): token is ts.CompoundAssignmentOperator =>
    token in compoundToAssignmentTokens;

export const unwrapCompoundAssignmentToken = (token: ts.CompoundAssignmentOperator): CompoundAssignmentToken =>
    compoundToAssignmentTokens[token];

function transformCompoundAssignment(
    context: TransformationContext,
    expression: ts.Expression,
    lhs: ts.Expression,
    rhs: ts.Expression,
    operator: CompoundAssignmentToken,
    isPostfix: boolean
): WithPrecedingStatements<lua.Expression> {
    if (isArrayLength(context, lhs)) {
        const { precedingStatements, result: lengthSetterStatement } = transformCompoundLengthSetter(
            context,
            expression,
            lhs,
            rhs,
            operator
        );

        return { precedingStatements, result: lengthSetterStatement.expression };
    }

    const left = context.transformExpression(lhs);
    if (!lua.isAssignmentLeftHandSideExpression(left)) {
        context.diagnostics.push(cannotAssignToNodeOfKind(expression, left.kind));
        return { precedingStatements: [], result: left };
    }

    const { precedingStatements: rightPrecedingStatements, result: right } = transformInPrecedingStatementScope(
        context,
        () => context.transformExpression(rhs)
    );

    if (lua.isTableIndexExpression(left)) {
        // Complex property/element accesses need to cache object/index expressions to avoid repeating side-effects
        // local __obj, __index = ${objExpression}, ${indexExpression};
        const obj = context.createTempNameForLuaExpression(left.table);
        const index = context.createTempNameForLuaExpression(left.index);

        const objAndIndexDeclaration = lua.createVariableDeclarationStatement([obj, index], [left.table, left.index]);
        const accessExpression = lua.createTableIndexExpression(obj, index);

        const tmp = context.createTempNameForLuaExpression(left);
        if (isPostfix) {
            // local ____tmp = ____obj[____index];
            // ____obj[____index] = ____tmp ${replacementOperator} ${right};
            // return ____tmp
            const tmpDeclaration = lua.createVariableDeclarationStatement(tmp, accessExpression);
            const { precedingStatements, result: operatorExpression } = transformBinaryOperation(
                context,
                tmp,
                right,
                rightPrecedingStatements,
                operator,
                expression
            );
            const assignStatement = lua.createAssignmentStatement(accessExpression, operatorExpression);
            return {
                precedingStatements: [objAndIndexDeclaration, ...precedingStatements, tmpDeclaration, assignStatement],
                result: tmp,
            };
        } else {
            if (isSetterSkippingCompoundAssignmentOperator(operator)) {
                return {
                    precedingStatements: [
                        objAndIndexDeclaration,
                        ...transformSetterSkippingCompoundAssignment(
                            accessExpression,
                            operator,
                            right,
                            rightPrecedingStatements
                        ),
                    ],
                    result: left,
                };
            }
            // local ____tmp = ____obj[____index] ${replacementOperator} ${right};
            // ____obj[____index] = ____tmp;
            // return ____tmp
            const { precedingStatements, result: operatorExpression } = transformBinaryOperation(
                context,
                accessExpression,
                right,
                rightPrecedingStatements,
                operator,
                expression
            );
            const tmpDeclaration = lua.createVariableDeclarationStatement(tmp, operatorExpression);
            const assignStatement = lua.createAssignmentStatement(accessExpression, tmp);
            return {
                precedingStatements: [objAndIndexDeclaration, ...precedingStatements, tmpDeclaration, assignStatement],
                result: tmp,
            };
        }
    } else if (isPostfix) {
        // Postfix expressions need to cache original value in temp
        // local ____tmp = ${left};
        // ${left} = ____tmp ${replacementOperator} ${right};
        // return ____tmp
        const tmpIdentifier = context.createTempNameForLuaExpression(left);
        const tmpDeclaration = lua.createVariableDeclarationStatement(tmpIdentifier, left);
        const { precedingStatements, result: operatorExpression } = transformBinaryOperation(
            context,
            tmpIdentifier,
            right,
            rightPrecedingStatements,
            operator,
            expression
        );
        const assignStatements = transformAssignmentWithRightPrecedingStatements(
            context,
            lhs,
            operatorExpression,
            rightPrecedingStatements
        );
        return {
            precedingStatements: [tmpDeclaration, ...precedingStatements, ...assignStatements],
            result: tmpIdentifier,
        };
    } else {
        if (rightPrecedingStatements.length > 0 && isSetterSkippingCompoundAssignmentOperator(operator)) {
            return {
                precedingStatements: transformSetterSkippingCompoundAssignment(
                    left,
                    operator,
                    right,
                    rightPrecedingStatements
                ),
                result: left,
            };
        }

        // Simple expressions
        // ${left} = ${left} ${operator} ${right}
        const { precedingStatements, result: operatorExpression } = transformBinaryOperation(
            context,
            left,
            right,
            rightPrecedingStatements,
            operator,
            expression
        );
        const statements = transformAssignmentWithRightPrecedingStatements(
            context,
            lhs,
            operatorExpression,
            precedingStatements
        );
        return { precedingStatements: statements, result: left };
    }
}

export function transformCompoundAssignmentExpression(
    context: TransformationContext,
    expression: ts.Expression,
    // TODO: Change type to ts.LeftHandSideExpression?
    lhs: ts.Expression,
    rhs: ts.Expression,
    operator: CompoundAssignmentToken,
    isPostfix: boolean
): lua.Expression {
    const { precedingStatements, result } = transformCompoundAssignment(
        context,
        expression,
        lhs,
        rhs,
        operator,
        isPostfix
    );
    context.addPrecedingStatements(precedingStatements);
    return result;
}

export function transformCompoundAssignmentStatement(
    context: TransformationContext,
    node: ts.Node,
    lhs: ts.Expression,
    rhs: ts.Expression,
    operator: CompoundAssignmentToken
): lua.Statement[] {
    if (isArrayLength(context, lhs)) {
        const { precedingStatements, result: lengthSetterStatement } = transformCompoundLengthSetter(
            context,
            node,
            lhs,
            rhs,
            operator
        );

        return [...precedingStatements, lengthSetterStatement];
    }

    const left = context.transformExpression(lhs);
    if (!lua.isAssignmentLeftHandSideExpression(left)) {
        context.diagnostics.push(cannotAssignToNodeOfKind(node, left.kind));
        return [];
    }

    const { precedingStatements: rightPrecedingStatements, result: right } = transformInPrecedingStatementScope(
        context,
        () => context.transformExpression(rhs)
    );

    if (lua.isTableIndexExpression(left) && shouldCacheTableIndexExpressions(left, rightPrecedingStatements)) {
        // Complex property/element accesses need to cache object/index expressions to avoid repeating side-effects
        // local __obj, __index = ${objExpression}, ${indexExpression};
        // ____obj[____index] = ____obj[____index] ${replacementOperator} ${right};
        const obj = context.createTempNameForLuaExpression(left.table);
        const index = context.createTempNameForLuaExpression(left.index);

        const objAndIndexDeclaration = lua.createVariableDeclarationStatement([obj, index], [left.table, left.index]);
        const accessExpression = lua.createTableIndexExpression(obj, index);

        if (isSetterSkippingCompoundAssignmentOperator(operator)) {
            return [
                objAndIndexDeclaration,
                ...transformSetterSkippingCompoundAssignment(
                    accessExpression,
                    operator,
                    right,
                    rightPrecedingStatements,
                    node
                ),
            ];
        }

        const { precedingStatements: rightPrecedingStatements2, result: operatorExpression } = transformBinaryOperation(
            context,
            accessExpression,
            right,
            rightPrecedingStatements,
            operator,
            node
        );
        const assignStatement = lua.createAssignmentStatement(accessExpression, operatorExpression);
        return [objAndIndexDeclaration, ...rightPrecedingStatements2, assignStatement];
    } else {
        if (isSetterSkippingCompoundAssignmentOperator(operator)) {
            return transformSetterSkippingCompoundAssignment(left, operator, right, rightPrecedingStatements, node);
        }

        // Simple statements
        // ${left} = ${left} ${replacementOperator} ${right}
        const { precedingStatements: rightPrecedingStatements2, result: operatorExpression } = transformBinaryOperation(
            context,
            left,
            right,
            rightPrecedingStatements,
            operator,
            node
        );
        return transformAssignmentWithRightPrecedingStatements(
            context,
            lhs,
            operatorExpression,
            rightPrecedingStatements2
        );
    }
}

/* These setter-skipping operators will not execute the setter if result does not change.
 * x.y ||= z does NOT call the x.y setter if x.y is already true.
 * x.y &&= z does NOT call the x.y setter if x.y is already false.
 * x.y ??= z does NOT call the x.y setter if x.y is already not nullish.
 */
type SetterSkippingCompoundAssignmentOperator = ts.LogicalOperator | ts.SyntaxKind.QuestionQuestionToken;

function isSetterSkippingCompoundAssignmentOperator(
    operator: ts.BinaryOperator
): operator is SetterSkippingCompoundAssignmentOperator {
    return (
        operator === ts.SyntaxKind.AmpersandAmpersandToken ||
        operator === ts.SyntaxKind.BarBarToken ||
        operator === ts.SyntaxKind.QuestionQuestionToken
    );
}

function transformSetterSkippingCompoundAssignment(
    lhs: lua.AssignmentLeftHandSideExpression,
    operator: SetterSkippingCompoundAssignmentOperator,
    right: lua.Expression,
    rightPrecedingStatements: lua.Statement[],
    node?: ts.Node
): lua.Statement[] {
    // These assignments have the form 'if x then y = z', figure out what condition x is first.
    let condition: lua.Expression;

    if (operator === ts.SyntaxKind.AmpersandAmpersandToken) {
        condition = lhs;
    } else if (operator === ts.SyntaxKind.BarBarToken) {
        condition = lua.createUnaryExpression(lhs, lua.SyntaxKind.NotOperator);
    } else if (operator === ts.SyntaxKind.QuestionQuestionToken) {
        condition = lua.createBinaryExpression(lhs, lua.createNilLiteral(), lua.SyntaxKind.EqualityOperator);
    } else {
        assertNever(operator);
    }

    // if condition then lhs = rhs end
    return [
        lua.createIfStatement(
            condition,
            lua.createBlock([...rightPrecedingStatements, lua.createAssignmentStatement(lhs, right, node)]),
            undefined,
            node
        ),
    ];
}

function transformCompoundLengthSetter(
    context: TransformationContext,
    node: ts.Node,
    lhs: ts.PropertyAccessExpression | ts.ElementAccessExpression,
    rhs: ts.Expression,
    operator: CompoundAssignmentToken
): WithPrecedingStatements<lua.ExpressionStatement> {
    const { precedingStatements: rightPrecedingStatements, result: right } = transformInPrecedingStatementScope(
        context,
        () => context.transformExpression(rhs)
    );
    const table = context.transformExpression(lhs.expression);
    const lengthExpression = lua.createUnaryExpression(table, lua.SyntaxKind.LengthOperator, lhs);
    const { precedingStatements, result: operatorExpression } = transformBinaryOperation(
        context,
        lengthExpression,
        right,
        rightPrecedingStatements,
        operator,
        node
    );

    const arrayLengthAssignment = lua.createExpressionStatement(
        transformLuaLibFunction(context, LuaLibFeature.ArraySetLength, node, table, operatorExpression)
    );

    return { precedingStatements, result: arrayLengthAssignment };
}
