class DelayGroup {
  skipDelay = false;
  #reset;
  markOpened() {
    this.skipDelay = true;
    this.#clearReset();
  }
  markClosed() {
    this.#clearReset();
    this.#reset = setTimeout(() => {
      this.skipDelay = false;
    }, 300);
  }
  #clearReset() {
    if (this.#reset !== undefined) {
      clearTimeout(this.#reset);
      this.#reset = undefined;
    }
  }
}
const stack = [];
function pushGroup(group) {
  stack.push(group);
}
function popGroup(group) {
  const index = stack.lastIndexOf(group);
  if (index >= 0) {
    stack.splice(index, 1);
  }
}
function currentGroup() {
  return stack.at(-1);
}

export { DelayGroup as D, popGroup as a, currentGroup as c, pushGroup as p };
//# sourceMappingURL=delay-group-DA_KfSs1.js.map
