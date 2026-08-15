import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { modifier as createModifier } from 'ember-modifier';
import type { ModifierLike } from '@glint/template';
import { createFocusTrap } from 'focus-trap';
import type { Middleware, Placement } from '@floating-ui/dom';
import { FloatingManager } from '../-private/floating-manager.ts';
import FloatingArrow from '../-private/floating-arrow.gts';
import {
  attachDismissListeners,
  attachPopoverTriggerListeners,
  syncExpanded,
} from '../-private/interactions.ts';
import { resolvePortalTarget } from '../-private/portal.ts';
import { startAutoPosition } from '../-private/position.ts';

export interface PopoverSignature {
  Element: null;
  Args: {
    placement?: Placement;
    open?: boolean;
    onOpenChange?: (open: boolean) => void;
    container?: Element | string;
    disabled?: boolean;
    contentClass?: string;
    middleware?: Middleware[];
    arrow?: boolean;
    arrowWidth?: number;
    arrowHeight?: number;
    arrowTipRadius?: number;
    arrowStrokeWidth?: number;
    renderInPlace?: boolean;
    modal?: boolean;
  };
  Blocks: {
    trigger: [trigger: ModifierLike<{ Element: Element }>];
    content: [];
  };
}

export default class Popover extends Component<PopoverSignature> {
  @tracked localOpen = false;

  manager = new FloatingManager({
    exclusive: false,
    onOpenChange: (open) => {
      this.localOpen = open;
      this.#syncExpanded(open);
      this.args.onOpenChange?.(open);
    },
  });

  get isOpen(): boolean {
    return this.args.open ?? this.localOpen;
  }

  get portalTarget(): Element | null {
    if (this.args.renderInPlace) {
      return null;
    }
    return resolvePortalTarget(this.args.container);
  }

  #syncOptions(): void {
    this.manager.update({
      open: this.args.open,
      disabled: this.args.disabled,
      exclusive: false,
      onOpenChange: (open) => {
        this.localOpen = open;
        this.#syncExpanded(open);
        this.args.onOpenChange?.(open);
      },
    });
    this.#syncExpanded(this.isOpen);
  }

  close = (): void => {
    this.manager.close();
  };

  #syncExpanded(open: boolean): void {
    if (this.manager.referenceEl) {
      syncExpanded(this.manager.referenceEl, this.manager.id, open);
    }
  }

  setupTrigger = createModifier((element: Element) => {
    this.#syncOptions();
    this.manager.referenceEl = element;
    const stop = attachPopoverTriggerListeners(element, this.manager);
    this.#syncExpanded(this.isOpen);
    return () => {
      stop();
      syncExpanded(element, this.manager.id, false);
      if (this.manager.referenceEl === element) {
        this.manager.referenceEl = null;
      }
    };
  });

  setupFloating = createModifier((element: HTMLElement) => {
    this.manager.floatingEl = element;
    element.tabIndex = -1;
    element.style.overflow = 'visible';
    const reference = this.manager.referenceEl;
    const arrowEl = this.args.arrow
      ? element.querySelector('[data-floating-arrow]')
      : null;
    const stopPosition = reference
      ? startAutoPosition(reference, element, {
          placement: this.args.placement ?? 'bottom-start',
          middleware: this.args.middleware,
          arrowEl,
        })
      : undefined;
    const stopDismiss = reference
      ? attachDismissListeners(reference, element, this.close)
      : undefined;
    const trap = createFocusTrap(element, {
      escapeDeactivates: false,
      allowOutsideClick: true,
      fallbackFocus: element,
    });
    trap.activate();
    return () => {
      trap.deactivate();
      stopDismiss?.();
      stopPosition?.();
      if (this.manager.floatingEl === element) {
        this.manager.floatingEl = null;
      }
    };
  });

  willDestroy(): void {
    this.manager.clearTimers();
    super.willDestroy();
  }

  <template>
    {{yield this.setupTrigger to="trigger"}}

    {{#if this.isOpen}}
      {{#if this.portalTarget}}
        {{#in-element this.portalTarget insertBefore=null}}
          {{#if @modal}}
            <button
              type="button"
              data-floating-scrim
              data-state="open"
              aria-label="Dismiss"
              {{on "click" this.close}}
            ></button>
          {{/if}}
          <div
            role="dialog"
            id={{this.manager.id}}
            class={{@contentClass}}
            data-state="open"
            {{this.setupFloating}}
          >
            {{yield to="content"}}
            {{#if @arrow}}
              <FloatingArrow
                @width={{@arrowWidth}}
                @height={{@arrowHeight}}
                @tipRadius={{@arrowTipRadius}}
                @strokeWidth={{@arrowStrokeWidth}}
              />
            {{/if}}
          </div>
        {{/in-element}}
      {{else}}
        {{#if @modal}}
          <button
            type="button"
            data-floating-scrim
            data-state="open"
            aria-label="Dismiss"
            {{on "click" this.close}}
          ></button>
        {{/if}}
        <div
          role="dialog"
          id={{this.manager.id}}
          class={{@contentClass}}
          data-state="open"
          {{this.setupFloating}}
        >
          {{yield to="content"}}
          {{#if @arrow}}
            <span data-floating-arrow aria-hidden="true"></span>
          {{/if}}
        </div>
      {{/if}}
    {{/if}}
  </template>
}
