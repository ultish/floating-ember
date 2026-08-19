export class DelayGroup {
  skipDelay = false;
  #reset: ReturnType<typeof setTimeout> | undefined;

  markOpened(): void {
    this.skipDelay = true;
    this.#clearReset();
  }

  markClosed(): void {
    this.#clearReset();
    this.#reset = setTimeout(() => {
      this.skipDelay = false;
    }, 300);
  }

  #clearReset(): void {
    if (this.#reset !== undefined) {
      clearTimeout(this.#reset);
      this.#reset = undefined;
    }
  }
}

const stack: DelayGroup[] = [];

export function pushGroup(group: DelayGroup): void {
  stack.push(group);
}

export function popGroup(group: DelayGroup): void {
  const index = stack.lastIndexOf(group);
  if (index >= 0) {
    stack.splice(index, 1);
  }
}

export function currentGroup(): DelayGroup | undefined {
  return stack.at(-1);
}
