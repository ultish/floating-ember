import { isTesting } from '@ember/debug';
import { currentGroup, type DelayGroup } from './delay-group.ts';
import { nextId } from './ids.ts';
import { claimOpen, releaseOpen } from './single-open.ts';

export interface ManagerOptions {
  delay?: number;
  closeDelay?: number;
  open?: boolean;
  onOpenChange?: (open: boolean) => void;
  disabled?: boolean;
  group?: DelayGroup | null;
  exclusive?: boolean;
}

export class FloatingManager {
  readonly id = nextId('floating');
  referenceEl: Element | null = null;
  floatingEl: Element | null = null;
  options: ManagerOptions;
  #uncontrolledOpen = false;
  #openTimer: ReturnType<typeof setTimeout> | undefined;
  #closeTimer: ReturnType<typeof setTimeout> | undefined;

  constructor(options: ManagerOptions = {}) {
    this.options = options;
  }

  get isControlled(): boolean {
    return typeof this.options.open === 'boolean';
  }

  get isOpen(): boolean {
    return this.isControlled
      ? Boolean(this.options.open)
      : this.#uncontrolledOpen;
  }

  get delay(): number {
    if (typeof this.options.delay === 'number') {
      return this.options.delay;
    }
    return isTesting() ? 0 : 200;
  }

  get closeDelay(): number {
    if (typeof this.options.closeDelay === 'number') {
      return this.options.closeDelay;
    }
    return isTesting() ? 0 : 0;
  }

  get group(): DelayGroup | undefined {
    if (this.options.group === null) {
      return undefined;
    }
    return this.options.group ?? currentGroup();
  }

  update(options: ManagerOptions): void {
    this.options = { ...this.options, ...options };
  }

  open = (): void => {
    this.#set(true);
  };

  close = (): void => {
    this.#set(false);
  };

  toggle = (): void => {
    this.#set(!this.isOpen);
  };

  scheduleOpen = (): void => {
    this.clearTimers();
    if (this.options.disabled) {
      return;
    }
    const delay = this.group?.skipDelay ? 0 : this.delay;
    if (delay <= 0) {
      this.open();
    } else {
      this.#openTimer = setTimeout(() => this.open(), delay);
    }
  };

  scheduleClose = (): void => {
    this.clearTimers();
    const delay = this.closeDelay;
    if (delay <= 0) {
      this.close();
    } else {
      this.#closeTimer = setTimeout(() => this.close(), delay);
    }
  };

  clearTimers(): void {
    if (this.#openTimer !== undefined) {
      clearTimeout(this.#openTimer);
      this.#openTimer = undefined;
    }
    if (this.#closeTimer !== undefined) {
      clearTimeout(this.#closeTimer);
      this.#closeTimer = undefined;
    }
  }

  #set(open: boolean): void {
    if (this.options.disabled && open) {
      return;
    }
    if (this.isOpen === open) {
      return;
    }
    if (!this.isControlled) {
      this.#uncontrolledOpen = open;
    }
    if (open) {
      if (this.options.exclusive !== false) {
        claimOpen(this);
      }
      this.group?.markOpened();
    } else {
      releaseOpen(this);
      this.group?.markClosed();
    }
    this.options.onOpenChange?.(open);
  }
}
