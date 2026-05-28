'use strict';

import Nodes from './nodes';
import Lexer from '../lexer/lexer';
import { parser } from './compiled-parser';

parser.lexer = new Lexer();
parser.yy = Nodes;
parser.yy.declarations = {};
parser.yy.parseError = function parseError(e) {
  throw e;
};
parser.yy.registerDeclaration = function registerDeclaration(
  variableName,
  expression,
  explicitType,
) {
  if (!this.areDeclarationsHandled) {
    if (this.declarations[variableName]) {
      throw new Error(`Duplicate declaration found for variable: ${variableName}`);
    }
    this.declarations[variableName] = {
      variableName,
      expression,
      explicitType,
    };
  }
};


export default parser;
