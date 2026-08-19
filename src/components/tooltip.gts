import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { modifier as createModifier } from 'ember-modifier';
import type { ModifierLike } from '@glint/template';
import type { Middleware, Placement } from '@floating-ui/dom';
import { warnIfInteractive } from '../-private/assert-content.ts';
import { FloatingManager } from '../-private/floating-manager.ts';
import FloatingArrow from '../-private/floating-arrow.gts';
import {
  attachTooltipListeners,
  syncDescribedBy,
} from '../-private/interactions.ts';
import { resolvePortalTarget } from '../-private/portal.ts';
import { startAutoPosition } from '../-private/position.ts';

export interface TooltipSignature {
  Element: null;
  Args: {
    placement?: Placement;
    delay?: number;
    closeDelay?: number;
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
  };
  Blocks: {
    trigger: [trigger: ModifierLike<{ Element: Element }>];
    content: [];
  };
}

export default class Tooltip extends Component<TooltipSignature> {
  @tracked localOpen = false;

  manager = new FloatingManager({
    exclusive: true,
    onOpenChange: (open) => {
      this.localOpen = open;
      this.#syncDescribedBy(open);
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
      delay: this.args.delay,
      closeDelay: this.args.closeDelay,
      open: this.args.open,
      disabled: this.args.disabled,
      exclusive: true,
      onOpenChange: (open) => {
        this.localOpen = open;
        this.#syncDescribedBy(open);
        this.args.onOpenChange?.(open);
      },
    });
    this.#syncDescribedBy(this.isOpen);
  }

  #syncDescribedBy(open: boolean): void {
    if (this.manager.referenceEl) {
      syncDescribedBy(this.manager.referenceEl, this.manager.id, open);
    }
  }

  setupTrigger = createModifier((element: Element) => {
    this.#syncOptions();
    this.manager.referenceEl = element;
    const stop = attachTooltipListeners(element, this.manager);
    this.#syncDescribedBy(this.isOpen);
    return () => {
      stop();
      syncDescribedBy(element, this.manager.id, false);
      if (this.manager.referenceEl === element) {
        this.manager.referenceEl = null;
      }
    };
  });

  setupFloating = createModifier((element: HTMLElement) => {
    this.manager.floatingEl = element;
    element.style.pointerEvents = 'none';
    element.style.overflow = 'visible';
    warnIfInteractive(element);
    const reference = this.manager.referenceEl;
    const arrowEl = this.args.arrow
      ? element.querySelector('[data-floating-arrow]')
      : null;
    const stop = reference
      ? startAutoPosition(reference, element, {
          placement: this.args.placement,
          middleware: this.args.middleware,
          arrowEl,
        })
      : undefined;
    return () => {
      stop?.();
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
          <div
            role="tooltip"
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
        <div
          role="tooltip"
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
