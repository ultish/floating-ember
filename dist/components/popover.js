import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { on } from '@ember/modifier';
import { modifier } from 'ember-modifier';
import { createFocusTrap } from 'focus-trap';
import { F as FloatingManager, r as resolvePortalTarget, s as syncExpanded, a as attachPopoverTriggerListeners, b as startAutoPosition, c as attachDismissListeners } from '../position-CqPSH9z1.js';
import { F as FloatingArrow } from '../floating-arrow-BsVSQ0gj.js';
import { precompileTemplate } from '@ember/template-compilation';
import { setComponentTemplate } from '@ember/component';
import { g, i } from 'decorator-transforms/runtime-esm';

class Popover extends Component {
  static {
    g(this.prototype, "localOpen", [tracked], function () {
      return false;
    });
  }
  #localOpen = (i(this, "localOpen"), void 0);
  manager = new FloatingManager({
    exclusive: false,
    onOpenChange: open => {
      this.localOpen = open;
      this.#syncExpanded(open);
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
      open: this.args.open,
      disabled: this.args.disabled,
      exclusive: false,
      onOpenChange: open => {
        this.localOpen = open;
        this.#syncExpanded(open);
        this.args.onOpenChange?.(open);
      }
    });
    this.#syncExpanded(this.isOpen);
  }
  close = () => {
    this.manager.close();
  };
  #syncExpanded(open) {
    if (this.manager.referenceEl) {
      syncExpanded(this.manager.referenceEl, this.manager.id, open);
    }
  }
  setupTrigger = modifier(element => {
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
  setupFloating = modifier(element => {
    this.manager.floatingEl = element;
    element.tabIndex = -1;
    element.style.overflow = 'visible';
    const reference = this.manager.referenceEl;
    const arrowEl = this.args.arrow ? element.querySelector('[data-floating-arrow]') : null;
    const stopPosition = reference ? startAutoPosition(reference, element, {
      placement: this.args.placement ?? 'bottom-start',
      middleware: this.args.middleware,
      arrowEl
    }) : undefined;
    const stopDismiss = reference ? attachDismissListeners(reference, element, this.close) : undefined;
    const trap = createFocusTrap(element, {
      escapeDeactivates: false,
      allowOutsideClick: true,
      fallbackFocus: element
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
  willDestroy() {
    this.manager.clearTimers();
    super.willDestroy();
  }
  static {
    setComponentTemplate(precompileTemplate("{{yield this.setupTrigger to=\"trigger\"}}\n\n{{#if this.isOpen}}\n  {{#if this.portalTarget}}\n    {{#in-element this.portalTarget insertBefore=null}}\n      {{#if @modal}}\n        <button type=\"button\" data-floating-scrim data-state=\"open\" aria-label=\"Dismiss\" {{on \"click\" this.close}}></button>\n      {{/if}}\n      <div role=\"dialog\" id={{this.manager.id}} class={{@contentClass}} data-state=\"open\" {{this.setupFloating}}>\n        {{yield to=\"content\"}}\n        {{#if @arrow}}\n          <FloatingArrow @width={{@arrowWidth}} @height={{@arrowHeight}} @tipRadius={{@arrowTipRadius}} @strokeWidth={{@arrowStrokeWidth}} />\n        {{/if}}\n      </div>\n    {{/in-element}}\n  {{else}}\n    {{#if @modal}}\n      <button type=\"button\" data-floating-scrim data-state=\"open\" aria-label=\"Dismiss\" {{on \"click\" this.close}}></button>\n    {{/if}}\n    <div role=\"dialog\" id={{this.manager.id}} class={{@contentClass}} data-state=\"open\" {{this.setupFloating}}>\n      {{yield to=\"content\"}}\n      {{#if @arrow}}\n        <span data-floating-arrow aria-hidden=\"true\"></span>\n      {{/if}}\n    </div>\n  {{/if}}\n{{/if}}", {
      strictMode: true,
      scope: () => ({
        on,
        FloatingArrow
      })
    }), this);
  }
}

export { Popover as default };
//# sourceMappingURL=popover.js.map
