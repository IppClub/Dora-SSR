'use strict';

class DefaultVariableStorage {
  constructor() {
    this.data = {};
  }

  set(name, value) {
    this.data[name] = value;
  }

  // Called when a variable is being evaluated.
  get(name) {
    return this.data[name];
  }
}

export default DefaultVariableStorage;
