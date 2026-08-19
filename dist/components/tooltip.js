import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { modifier } from 'ember-modifier';
import { F as FloatingManager, r as resolvePortalTarget, d as syncDescribedBy, e as attachTooltipListeners, b as startAutoPosition } from '../position-CqPSH9z1.js';
import { F as FloatingArrow } from '../floating-arrow-BsVSQ0gj.js';
import { precompileTemplate } from '@ember/template-compilation';
import { setComponentTemplate } from '@ember/component';
import { g, i } from 'decorator-transforms/runtime-esm';

const INTERACTIVE = 'a, button, input, select, textarea, [href], [tabindex]:not([tabindex="-1"])';
function warnIfInteractive(element) {
  if (typeof document === 'undefined') {
    return;
  }
  if (element.querySelector(INTERACTIVE)) {
    console.warn('floating-ember: <Tooltip> content contains interactive elements (links, buttons, fields). Use <Popover> for interactive content.');
  }
}

class Tooltip extends Component {
  static {
    g(this.prototype, "localOpen", [tracked], function () {
      return false;
    });
  }
  #localOpen = (i(this, "localOpen"), void 0);
  manager = new FloatingManager({
    exclusive: true,
    onOpenChange: open => {
      this.localOpen = open;
      this.#syncDescribedBy(open);
      this.args.onOpenChange?.(open);
    }
  });
  get isOpen() {
    return this.args.open ?? this.localOpen;
  }
  get portalTarget() {
    if (this.args.renderInPlace) {
      return null;
    }
    return resolvePortalTarget(this.args.container);
  }
  #syncOptions() {
    this.manager.update({
      delay: this.args.delay,
      closeDelay: this.args.closeDelay,
      open: this.args.open,
      disabled: this.args.disabled,
      exclusive: true,
      onOpenChange: open => {
        this.localOpen = open;
        this.#syncDescribedBy(open);
        this.args.onOpenChange?.(open);
      }
    });
    this.#syncDescribedBy(this.isOpen);
  }
  #syncDescribedBy(open) {
    if (this.manager.referenceEl) {
      syncDescribedBy(this.manager.referenceEl, this.manager.id, open);
    }
  }
  setupTrigger = modifier(element => {
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
  setupFloating = modifier(element => {
    this.manager.floatingEl = element;
    element.style.pointerEvents = 'none';
    element.style.overflow = 'visible';
    warnIfInteractive(element);
    const reference = this.manager.referenceEl;
    const arrowEl = this.args.arrow ? element.querySelector('[data-floating-arrow]') : null;
    const stop = reference ? startAutoPosition(reference, element, {
      placement: this.args.placement,
      middleware: this.args.middleware,
      arrowEl
    }) : undefined;
    return () => {
      stop?.();
      if (this.manager.floatingEl === element) {
        this.manager.floatingEl = null;
      }
    };
  });
  willDestroy() {
    this.manager.clearTimers();
    super.willDestroy();
  }
  static {
    setComponentTemplate(precompileTemplate("{{yield this.setupTrigger to=\"trigger\"}}\n\n{{#if this.isOpen}}\n  {{#if this.portalTarget}}\n    {{#in-element this.portalTarget insertBefore=null}}\n      <div role=\"tooltip\" id={{this.manager.id}} class={{@contentClass}} data-state=\"open\" {{this.setupFloating}}>\n        {{yield to=\"content\"}}\n        {{#if @arrow}}\n          <FloatingArrow @width={{@arrowWidth}} @height={{@arrowHeight}} @tipRadius={{@arrowTipRadius}} @strokeWidth={{@arrowStrokeWidth}} />\n        {{/if}}\n      </div>\n    {{/in-element}}\n  {{else}}\n    <div role=\"tooltip\" id={{this.manager.id}} class={{@contentClass}} data-state=\"open\" {{this.setupFloating}}>\n      {{yield to=\"content\"}}\n      {{#if @arrow}}\n        <span data-floating-arrow aria-hidden=\"true\"></span>\n      {{/if}}\n    </div>\n  {{/if}}\n{{/if}}", {
      strictMode: true,
      scope: () => ({
        FloatingArrow
      })
    }), this);
  }
}

export { Tooltip as default };
//# sourceMappingURL=tooltip.js.map
