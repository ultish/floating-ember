import { modifier } from 'ember-modifier';
import { f as computeArrowGeometry, F as FloatingManager, e as attachTooltipListeners, d as syncDescribedBy, r as resolvePortalTarget, b as startAutoPosition } from '../position-CqPSH9z1.js';

const SVG_NS = 'http://www.w3.org/2000/svg';
let nextId = 0;
function createArrowElement(options = {}) {
  const geometry = computeArrowGeometry({
    width: options.width ?? 14,
    height: options.height ?? 7,
    tipRadius: options.tipRadius ?? 0,
    strokeWidth: options.strokeWidth ?? 1
  });
  const svg = document.createElementNS(SVG_NS, 'svg');
  svg.setAttribute('data-floating-arrow', '');
  svg.dataset['strokeWidth'] = String(geometry.computedStrokeWidth);
  svg.setAttribute('aria-hidden', 'true');
  svg.setAttribute('width', String(geometry.svgWidth));
  svg.setAttribute('height', String(geometry.svgHeight));
  svg.setAttribute('viewBox', geometry.viewBox);
  // See floating-arrow.gts for why these presentation attributes (not CSS)
  // are what makes ancestor fill/stroke reach the arrow with zero imports.
  svg.setAttribute('fill', 'inherit');
  svg.setAttribute('stroke', 'inherit');
  svg.style.position = 'absolute';
  svg.style.pointerEvents = 'none';
  if (geometry.computedStrokeWidth > 0) {
    const clipPathId = `floating-arrow-clip-${String(nextId++)}`;
    const clipPath = document.createElementNS(SVG_NS, 'clipPath');
    clipPath.setAttribute('id', clipPathId);
    const rect = document.createElementNS(SVG_NS, 'rect');
    rect.setAttribute('x', String(geometry.clipX));
    rect.setAttribute('y', String(geometry.clipY));
    rect.setAttribute('width', String(geometry.clipWidth));
    rect.setAttribute('height', String(geometry.clipHeight));
    clipPath.append(rect);
    svg.append(clipPath);
    const strokePath = document.createElementNS(SVG_NS, 'path');
    strokePath.setAttribute('d', geometry.d);
    strokePath.setAttribute('fill', 'none');
    strokePath.setAttribute('stroke-width', String(geometry.computedStrokeWidth));
    strokePath.setAttribute('clip-path', `url(#${clipPathId})`);
    svg.append(strokePath);
  }
  const fillPath = document.createElementNS(SVG_NS, 'path');
  fillPath.setAttribute('d', geometry.d);
  fillPath.setAttribute('stroke', 'none');
  svg.append(fillPath);
  return svg;
}

const tooltip = modifier(function tooltip(element, [text], named) {
  const manager = new FloatingManager({
    delay: named.delay,
    closeDelay: named.closeDelay,
    disabled: named.disabled,
    exclusive: true,
    onOpenChange(open) {
      sync(open);
    }
  });
  manager.referenceEl = element;
  const stopListeners = attachTooltipListeners(element, manager);
  let floating = null;
  let stopPosition;
  const sync = open => {
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
      let arrowEl = null;
      if (named.arrow) {
        arrowEl = createArrowElement({
          width: named.arrowWidth,
          height: named.arrowHeight,
          tipRadius: named.arrowTipRadius,
          strokeWidth: named.arrowStrokeWidth
        });
        floating.append(arrowEl);
      }
      resolvePortalTarget()?.append(floating);
      manager.floatingEl = floating;
      stopPosition = startAutoPosition(element, floating, {
        placement: named.placement,
        arrowEl
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

export { tooltip as default };
//# sourceMappingURL=tooltip.js.map
