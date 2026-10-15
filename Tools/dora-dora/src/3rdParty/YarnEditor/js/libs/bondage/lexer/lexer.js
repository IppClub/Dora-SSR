'use strict';

// Syncs with YarnSpinner@e0f6807,
// see https://github.com/thesecretlab/YarnSpinner/blob/master/YarnSpinner/Lexer.cs

import StateMaker from './states';

// As opposed to the original C# implemntation which, tokenize the entire input, before emiting
// a list of tokens, this parser will emit a token each time `lex()` is called. This change
// accomodates the Jison parser. Given the lexer is not entirely context-free
// (Off-side rule, lookaheads), context needs to be remembered between each `lex()` calls.
class Lexer {
  constructor() {
    /** All the possible states for the lexer. */
    this.states = StateMaker.makeStates();

    /** Current state identifier. */
    this.state = 'base';

    /** Original text to lex. */
    this.originalText = '';

    /** Text to lex, splitted into an array of lines. */
    this.lines = [];

    // Properties used to keep track of the context we're in, while tokenizing each line.
    /**
     * Indentation tracker. Each time we encounter an identation, we push a
     * new array which looks like: [indentationLevel, isBaseIndentation]. Basically,
     * isBaseIndentation will be true only for the first level.
     */
    this.indentation = [[0, false]];

    /**
     * Set to true when a state required indentation tracking. Will be set to false, after a
     * an indentation is found.
     */
    this.shouldTrackNextIndentation = false;

    /**
     * The previous level of identation, basically: this.indentation.last()[0].
     */
    this.previousLevelOfIndentation = 0;

    // Reset the locations.
    this.reset();
  }

  /**
   * reset - Reset the lexer location, text and line number. Nothing fancy.
   */
  reset() {
    // Locations, used by both the lexer and the Jison parser.
    this.yytext = '';
    this.yylloc = {
      first_column: 1,
      first_line: 1,
      last_column: 1,
      last_line: 1,
    };
    this.yylineno = 1;
  }

  /**
   * lex - Lex the input and emit the next matched token.
   *
   * @return {string}  Emit the next token found.
   */
  lex() {
    if (this.isAtTheEndOfText()) {
      this.yytext = '';

      // Now that we're at the end of the text, we'll emit as many
      // `Dedent` as necessary, to get back to 0-indentation.
      const indent = this.indentation.pop();
      if (indent && indent[1]) { return 'Dedent'; }

      return 'EndOfInput';
    }

    if (this.isAtTheEndOfLine()) {
      // Get the next token on the current line
      this.advanceLine();
      return 'EndOfLine';
    }

    return this.lexNextTokenOnCurrentLine();
  }

  advanceLine() {
    this.yylineno += 1;
    const currentLine = this.getCurrentLine();
    this.lines[this.yylineno - 1] = currentLine;
    this.previousLevelOfIndentation = this.getLastRecordedIndentation()[0];
    this.yytext = '';
    this.yylloc = {
      first_column: 1,
      first_line: this.yylineno,
      last_column: 1,
      last_line: this.yylineno,
    };
  }

  lexNextTokenOnCurrentLine() {
    const thisIndentation = this.getCurrentLineIndentation();

    if (this.shouldTrackNextIndentation &&
      this.yylloc.first_column === this.yylloc.last_column &&
      thisIndentation > this.previousLevelOfIndentation) {
      this.indentation.push([thisIndentation, true]);
      this.shouldTrackNextIndentation = false;

      this.yylloc.first_column = this.yylloc.last_column;
      this.yylloc.last_column += thisIndentation;
      this.yytext = '';

      return 'Indent';
    } else if (thisIndentation < this.getLastRecordedIndentation()[0]) {
      const indent = this.indentation.pop();
      if (indent[1] && this.yylloc.first_column === this.yylloc.last_column) {
        this.yytext = '';
        this.previousLevelOfIndentation = this.getLastRecordedIndentation()[0];

        return 'Dedent';
      }
    }

    if (thisIndentation === this.previousLevelOfIndentation && this.yylloc.last_column === 1) {
      this.yylloc.last_column += thisIndentation;
    }

    let rule = this.getState().transitions.find(rule => {
      const match = this.getCurrentLine()
        .substring(this.yylloc.last_column - 1)
        .match(rule.regex);
      // Only accept valid matches that are at the beginning of the text
      return match !== null && match.index === 0
    })

    let match = this.getCurrentLine()
      .substring(this.yylloc.last_column - 1)
      .match(rule.regex);

    if (this.yylloc.last_column === 1 && !this.shouldTrackNextIndentation) {
      const spaceMatch = this.getCurrentLine().substring(this.yylloc.last_column - 1).match(/^\s*/);
      this.yylloc.last_column += spaceMatch[0].length;
      rule = this.getState().transitions.find(rule => {
        const match = this.getCurrentLine()
          .substring(this.yylloc.last_column - 1)
          .match(rule.regex);
        // Only accept valid matches that are at the beginning of the text
        return match !== null && match.index === 0
      })
      match = this.getCurrentLine()
        .substring(this.yylloc.last_column - 1)
        .match(rule.regex);
    }

    // Take the matched text off the front of this.text
    const matchedText = match[0];

    // Tell the parser what the text for this token is
    this.yytext = this.getCurrentLine().substr(this.yylloc.last_column - 1, matchedText.length);

    if (rule.token === 'String') {
      // If that's a String, remove the quotes
      this.yytext = this.yytext.substring(1, this.yytext.length - 1);
    }

    // Update our line and column info
    this.yylloc.first_column = this.yylloc.last_column;
    this.yylloc.last_column += matchedText.length;

    // If the rule points to a new state, change it now
    if (rule.state) {
      this.setState(rule.state);

      if (this.shouldTrackNextIndentation) {
        if (this.getLastRecordedIndentation()[0] < thisIndentation) {
          this.indentation.push([thisIndentation, false]);
        }
      }
    }

    const nextState = this.states[rule.state];
    const nextStateHasText = !rule.state || nextState.transitions
      .find((transition) => { return transition.token === 'Text'; });
    // inline expressions and escaped characters interrupt text
    // but should still preserve surrounding whitespace.
    if (
      (rule.token !== 'EndInlineExp' && rule.token !== 'EscapedCharacter')
      || !nextStateHasText // we never want leading whitespace if not in text-supporting state
    ) {
      // Remove leading whitespace characters
      const spaceMatch = this.getCurrentLine().substring(this.yylloc.last_column - 1).match(/^\s*/);
      if (spaceMatch[0]) {
        this.yylloc.last_column += spaceMatch[0].length;
      }
    }

    return rule.token;

    throw new Error(`Invalid syntax in: ${this.getCurrentLine()}`);
  }

  // /////////////// Getters & Setters

  /**
   * setState - set the current state of the lexer.
   *
   * @param  {string} state name of the state
   */
  setState(state) {
    if (this.states[state] === undefined) {
      throw new Error(`Cannot set the unknown state [${state}]`);
    }

    this.state = state;
    if (this.getState().isTrackingNextIndentation) {
      this.shouldTrackNextIndentation = true;
    }
  }

  /**
   * setInput - Set the text on which perform lexical analysis.
   *
   * @param  {string} text the text to lex.
   */
  setInput(text) {
    // Delete carriage return while keeping a similar semantic.
    this.originalText = text.replace(/(\r\n)/g, '\n').replace(/\r/g, '\n').replace(/[\n\r]+$/, '');
    // Transform the input into an array of lines.
    this.lines = this.originalText
      .split('\n')
      .map(line => line.replace(/\t/, '    '))
    ;
    this.reset();
  }

  /**
   * getState - Returns the full current state object (LexerState),
   * rather than its identifier.
   *
   * @return {Object}  the state object.
   */
  getState() {
    return this.states[this.state];
  }

  getCurrentLine() {
    return this.lines[this.yylineno - 1];
  }

  getCurrentLineIndentation() {
    const match = this.getCurrentLine().match(/^(\s*)/g);
    return match[0].length;
  }

  getLastRecordedIndentation() {
    if (this.indentation.length === 0) {
      return [0, false];
    }

    return this.indentation[this.indentation.length - 1];
  }

  // /////////////// Booleans tests
  /**
   * @return {boolean}  `true` when yylloc indicates that the end was reached.
   */
  isAtTheEndOfText() {
    return this.isAtTheEndOfLine() &&
      this.yylloc.first_line >= this.lines.length;
  }

  /**
   * @return {boolean}  `true` when yylloc indicates that the end of the line was reached.
   */
  isAtTheEndOfLine() {
    return this.yylloc.last_column > this.getCurrentLine().length;
  }
}

export default Lexer;
