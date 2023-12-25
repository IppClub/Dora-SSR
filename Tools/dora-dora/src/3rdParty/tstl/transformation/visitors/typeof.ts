import * as ts from "typescript";
import * as lua from "../../LuaAST";
import { LuaLibFeature } from "../../LuaLib";
import { FunctionVisitor, TransformationContext } from "../context";
import { transformLuaLibFunction } from "../utils/lualib";
import { transformBinaryOperation } from "./binary-expression";

export const transformTypeOfExpression: FunctionVisitor<ts.TypeOfExpression> = (node, context) => {
    const innerExpression = context.transformExpression(node.expression);
    return transformLuaLibFunction(context, LuaLibFeature.TypeOf, node, innerExpression);
};

export function transformTypeOfBinaryExpression(
    context: TransformationContext,
    node: ts.BinaryExpression
): lua.Expression | undefined {
    const operator = node.operatorToken.kind;
    if (
        operator !== ts.SyntaxKind.EqualsEqualsToken &&
        operator !== ts.SyntaxKind.EqualsEqualsEqualsToken &&
        operator !== ts.SyntaxKind.ExclamationEqualsToken &&
        operator !== ts.SyntaxKind.ExclamationEqualsEqualsToken
    ) {
        return;
    }

    let literalExpression: ts.Expression;
    let typeOfExpression: ts.TypeOfExpression;
    if (ts.isTypeOfExpression(node.left)) {
        typeOfExpression = node.left;
        literalExpression = node.right;
    } else if (ts.isTypeOfExpression(node.right)) {
        typeOfExpression = node.right;
        literalExpression = node.left;
    } else {
        return;
    }

    const comparedExpression = context.transformExpression(literalExpression);
    if (!lua.isStringLiteral(comparedExpression)) return;

    if (comparedExpression.value === "object") {
        comparedExpression.value = "table";
    } else if (comparedExpression.value === "undefined") {
        comparedExpression.value = "nil";
    }

    const innerExpression = context.transformExpression(typeOfExpression.expression);
    const typeCall = lua.createCallExpression(lua.createIdentifier("type"), [innerExpression], typeOfExpression);
    const { precedingStatements, result } = transformBinaryOperation(
        context,
        typeCall,
        comparedExpression,
        [],
        operator,
        node
    );
    context.addPrecedingStatements(precedingStatements);
    return result;
}
