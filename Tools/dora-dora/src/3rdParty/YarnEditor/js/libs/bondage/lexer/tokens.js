'use strict';

/**
 * Token identifier -> regular expression to match the lexeme. That's a list of all the token
 * which can be emitted by the lexer. For now, we're slightly bending the style guide,
 * to make sure the debug output of the javascript lexer will (kinda) match the original C# one.
 */
/* eslint-disable key-spacing */
const Tokens = {
  // Special tokens
  Whitespace:           null, // (not used currently)
  Indent:               null,
  Dedent:               null,
  EndOfLine:            /\n/,
  EndOfInput:           null,

  // Literals in ("<<commands>>")
  Number:               /-?[0-9]+(\.[0-9+])?/,
  String:               /"([^"\\]*(?:\\.[^"\\]*)*)"/,

  // Command syntax ("<<foo>>")
  BeginCommand:         /<</,
  EndCommand:           />>/,

  // Variables ("$foo")
  Variable:             /\$([A-Za-z0-9_.])+/,

  // Shortcut syntax ("->")
  ShortcutOption:       /->/,

  // Hashtag ("#something")
  Hashtag:              /#([^(\s|#|//)]+)/, // seems a little hacky to explicitly consider comments here

  // Comment ("// some stuff")
  Comment:              /\/\/.*/,

  // Option syntax ("[[Let's go here|Destination]]")
  OptionStart:          /\[\[/, // [[
  OptionDelimit:        /\|/, // |
  OptionEnd:            /\]\]/, // ]]

  // Command types (specially recognized command word)
  If:                   /if(?!\w)/,
  ElseIf:               /elseif(?!\w)/,
  Else:                 /else(?!\w)/,
  EndIf:                /endif(?!\w)/,
  Jump:                 /jump(?!\w)/,
  Stop:                 /stop(?!\w)/,
  Set:                  /set(?!\w)/,
  Declare:              /declare(?!\w)/,
  As:                   /as(?!\w)/,
  ExplicitType:         /(String|Number|Bool)(?=>>)/,

  // Boolean values
  True:                 /true(?!\w)/,
  False:                /false(?!\w)/,

  // The null value
  Null:                 /null(?!\w)/,

  // Parentheses
  LeftParen:            /\(/,
  RightParen:           /\)/,

  // Parameter delimiters
  Comma:                /,/,

  // Operators
  UnaryMinus:           /-(?!\s)/,

  EqualTo:              /(==|is(?!\w)|eq(?!\w))/, // ==, eq, is
  GreaterThan:          /(>|gt(?!\w))/, // >, gt
  GreaterThanOrEqualTo: /(>=|gte(?!\w))/, // >=, gte
  LessThan:             /(<|lt(?!\w))/, // <, lt
  LessThanOrEqualTo:    /(<=|lte(?!\w))/, // <=, lte
  NotEqualTo:           /(!=|neq(?!\w))/, // !=, neq

  // Logical operators
  Or:                   /(\|\||or(?!\w))/, // ||, or
  And:                  /(&&|and(?!\w))/, // &&, and
  Xor:                  /(\^|xor(?!\w))/, // ^, xor
  Not:                  /(!|not(?!\w))/, // !, not

  // this guy's special because '=' can mean either 'equal to'
  // or 'becomes' depending on context
  EqualToOrAssign:      /(=|to(?!\w))/, // =, to

  Add:                  /\+/, // +
  Minus:                /-/, // -
  Exponent:             /\*\*/, // **
  Multiply:             /\*/, // *
  Divide:               /\//, // /
  Modulo:               /%/, // /

  AddAssign:            /\+=/, // +=
  MinusAssign:          /-=/, // -=
  MultiplyAssign:       /\*=/, // *=
  DivideAssign:         /\/=/, // /=

  Identifier:           /[^\s<>()[\]{},+\-*\/%=!&|^]+/, // a single word, including unicode node titles

  EscapedCharacter:     /\\./, // for escaping \# special characters
  Text:                 /[^\\]/, // generic until we hit other syntax

  // Braces are used for inline expressions. Ignore escaped braces
  // TODO: doesn't work ios
  BeginInlineExp:       /{/, // {
  EndInlineExp:         /}/, // }
};
/* eslint-enable key-spacing */

export default Tokens;
