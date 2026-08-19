import { modifier } from 'ember-modifier';
import type { Placement } from '@floating-ui/dom';
import { createArrowElement } from '../-private/create-arrow-element.ts';
import { FloatingManager } from '../-private/floating-manager.ts';
import {
  attachTooltipListeners,
  syncDescribedBy,
} from '../-private/interactions.ts';
import { resolvePortalTarget } from '../-private/portal.ts';
import { startAutoPosition } from '../-private/position.ts';

interface TooltipModifierNamed {
  placement?: Placement;
  delay?: number;
  closeDelay?: number;
  disabled?: boolean;
  contentClass?: string;
  arrow?: boolean;
  arrowWidth?: number;
  arrowHeight?: number;
  arrowTipRadius?: number;
  arrowStrokeWidth?: number;
}

const tooltip = modifier(function tooltip(
  element: Element,
  [text]: [string],
  named: TooltipModifierNamed,
) {
  const manager = new FloatingManager({
    delay: named.delay,
    closeDelay: named.closeDelay,
    disabled: named.disabled,
    exclusive: true,
    onOpenChange(open) {
      sync(open);
    },
  });

  manager.referenceEl = element;
  const stopListeners = attachTooltipListeners(element, manager);

  let floating: HTMLElement | null = null;
  let stopPosition: (() => void) | undefined;

  const sync = (open: boolean): void => {
    syncDescribedBy(element, manager.id, open);
    if (open) {
      if (floating || typeof document === 'undefined') {
        return;
      }
      floating = document.createElement('div');
      floating.id = manager.id;
      floating.setAttribute('role', 'tooltip');
      floating.dataset['state'] = 'open';
      if (named.contentClass) {
        floating.className = named.contentClass;
      }
      floating.style.pointerEvents = 'none';
      floating.style.overflow = 'visible';
      floating.textContent = String(text ?? '');
      let arrowEl: SVGSVGElement | null = null;
      if (named.arrow) {
        arrowEl = createArrowElement({
          width: named.arrowWidth,
          height: named.arrowHeight,
          tipRadius: named.arrowTipRadius,
          strokeWidth: named.arrowStrokeWidth,
        });
        floating.append(arrowEl);
      }
      resolvePortalTarget()?.append(floating);
      manager.floatingEl = floating;
      stopPosition = startAutoPosition(element, floating, {
        placement: named.placement,
        arrowEl,
      });
    } else if (floating) {
      stopPosition?.();
      stopPosition = undefined;
      floating.remove();
      floating = null;
      manager.floatingEl = null;
    }
  };

  return () => {
    manager.clearTimers();
    stopListeners();
    sync(false);
  };
});

export default tooltip;
