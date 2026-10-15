'use strict';

import Tokens from './tokens';

/**
 * A LexState object represents one of the states in which the lexer can be.
 */
class LexerState {
  constructor() {
    /** A list of transition for the given state. */
    this.transitions = [];
    /** A special, unique transition for matching spans of text in any state. */
    this.textRule = null;
    /**
     * Whether or not this state is context-bound by indentation
     * (will make the lexer emit Indent and Dedent tokens).
     */
    this.isTrackingNextIndentation = false;
  }

  /**
   * addTransition - Define a new transition for this state.
   *
   * @param  {type} token - the token to match
   * @param  {string} [state] - the state to which transition; if not provided, will
   *                            remain in the same state.
   * @param  {boolean} [delimitsText] - `true` if the token is a text delimiter. A text delimiters
   *                                    is a token which should be considered as a token, even if it
   *                                    doesn't start the line.
   * @return {Object} - returns the LexState itself for chaining.
   */
  addTransition(token, state, delimitsText) {
    this.transitions.push({
      token: token,
      regex: Tokens[token],
      state: state || null,
      delimitsText: delimitsText || false,
    });

    return this; // Return this for chaining
  }

  /**
   * addTextRule - Match all the way up to any of the other transitions in this state.
   *               The text rule can only be added once.
   *
   * @param  {type} type  description
   * @param  {type} state description
   * @return {Object} - returns the LexState itself for chaining.
   */
  addTextRule(type, state) {
    if (this.textRule) {
      throw new Error('Cannot add more than one text rule to a state.');
    }

    // Go through the regex of the other transitions in this state, and create a regex that will
    // match all text, up to any of those transitions.
    const rules = [];
    this.transitions.forEach((transition) => {
      if (transition.delimitsText) {
        // Surround the rule in parens
        rules.push(`(${transition.regex.source})`);
      }
    });

    // Join the rules that we got above on a |, then put them all into a negative lookahead.
    const textPattern = `((?!${rules.join('|')}).)+`;
    this.addTransition(type, state);

    // Update the regex in the transition we just added to our new one.
    this.textRule = this.transitions[this.transitions.length - 1];
    this.textRule.regex = new RegExp(textPattern);

    return this;
  }

  /**
   * setTrackNextIndentation - tell this state whether to track indentation.
   *
   * @param  {boolean} track - `true` to track, `false` otherwise.
   * @return {Object} - returns the LexState itself for chaining.
   */
  setTrackNextIndentation(track) {
    this.isTrackingNextIndentation = track;
    return this;
  }
}

export default LexerState;
