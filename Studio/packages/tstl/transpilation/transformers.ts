import * as ts from "typescript";
import { CompilerOptions } from "../CompilerOptions";

export function getTransformers(
    program: ts.Program,
    diagnostics: ts.Diagnostic[],
    customTransformers: ts.CustomTransformers,
    onSourceFile: (sourceFile: ts.SourceFile) => void
): ts.CustomTransformers {
    const luaTransformer: ts.TransformerFactory<ts.SourceFile> = () => sourceFile => {
        onSourceFile(sourceFile);
        return ts.createSourceFile(sourceFile.fileName, "", ts.ScriptTarget.ESNext);
    };

    const transformersFromOptions = loadTransformersFromOptions(program, diagnostics);

    const afterDeclarations = [
        ...(transformersFromOptions.afterDeclarations ?? []),
        ...(customTransformers.afterDeclarations ?? []),
    ];

    const options = program.getCompilerOptions() as CompilerOptions;
    if (options.noImplicitSelf) {
        afterDeclarations.unshift(noImplicitSelfTransformer);
    }

    return {
        afterDeclarations,
        before: [
            ...(customTransformers.before ?? []),
            ...(transformersFromOptions.before ?? []),

            ...(transformersFromOptions.after ?? []),
            ...(customTransformers.after ?? []),
            stripParenthesisExpressionsTransformer,
            luaTransformer,
        ],
    };
}

export const noImplicitSelfTransformer: ts.TransformerFactory<ts.SourceFile | ts.Bundle> = () => node => {
    const transformSourceFile: ts.Transformer<ts.SourceFile> = node => {
        const empty = ts.factory.createNotEmittedStatement(undefined!);
        ts.addSyntheticLeadingComment(empty, ts.SyntaxKind.MultiLineCommentTrivia, "* @noSelfInFile ", true);
        return ts.factory.updateSourceFile(node, [empty, ...node.statements], node.isDeclarationFile);
    };

    return ts.isBundle(node)
        ? ts.factory.updateBundle(node, node.sourceFiles.map(transformSourceFile))
        : transformSourceFile(node);
};

export const stripParenthesisExpressionsTransformer: ts.TransformerFactory<ts.SourceFile> = context => sourceFile => {
    // Remove parenthesis expressions before transforming to Lua, so transpiler is not hindered by extra ParenthesizedExpression nodes
    function unwrapParentheses(node: ts.Expression) {
        while (ts.isParenthesizedExpression(node) && !ts.isOptionalChain(node.expression)) {
            node = node.expression;
        }
        return node;
    }
    function visit(node: ts.Node): ts.Node {
        // For now only call expressions strip their expressions of parentheses, there could be more cases where this is required
        if (ts.isCallExpression(node)) {
            return ts.factory.updateCallExpression(
                node,
                unwrapParentheses(node.expression),
                node.typeArguments,
                node.arguments
            );
        } else if (ts.isVoidExpression(node)) {
            return ts.factory.updateVoidExpression(node, unwrapParentheses(node.expression));
        } else if (ts.isDeleteExpression(node)) {
            return ts.factory.updateDeleteExpression(node, unwrapParentheses(node.expression));
        }

        return ts.visitEachChild(node, visit, context);
    }
    return ts.visitEachChild(sourceFile, visit, context);
};

function loadTransformersFromOptions(program: ts.Program, diagnostics: ts.Diagnostic[]): ts.CustomTransformers {
    const customTransformers: Required<ts.CustomTransformers> = {
        before: [],
        after: [],
        afterDeclarations: [],
    };

    const options = program.getCompilerOptions() as CompilerOptions;
    if (options.jsx === ts.JsxEmit.React) {
        customTransformers.before.push(context => {
            // if target < ES2017, typescript generates some unnecessary additional transformations in transformJSX.
            // We can't control the target compiler option, so we override here.
            const patchedContext: ts.TransformationContext = {
                ...context,
                getCompilerOptions: () => ({
                    ...context.getCompilerOptions(),
                    target: ts.ScriptTarget.ESNext,
                }),
            };
            return ts.transformJsx(patchedContext);
        });
    }
    return customTransformers;
}
