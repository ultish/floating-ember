import { isTesting } from '@ember/debug';
import { c as currentGroup } from './delay-group-DA_KfSs1.js';
import { autoUpdate, offset, flip, shift, hide, arrow, computePosition } from '@floating-ui/dom';
import { buildWaiter } from '@ember/test-waiters';

let seq = 0;
function nextId(prefix = 'floating') {
  seq += 1;
  return `${prefix}-${seq}`;
}

let openManager = null;
function claimOpen(manager) {
  if (openManager && openManager !== manager) {
    openManager.close();
  }
  openManager = manager;
}
function releaseOpen(manager) {
  if (openManager === manager) {
    openManager = null;
  }
}

class FloatingManager {
  id = nextId('floating');
  referenceEl = null;
  floatingEl = null;
  options;
  #uncontrolledOpen = false;
  #openTimer;
  #closeTimer;
  constructor(options = {}) {
    this.options = options;
  }
  get isControlled() {
    return typeof this.options.open === 'boolean';
  }
  get isOpen() {
    return this.isControlled ? Boolean(this.options.open) : this.#uncontrolledOpen;
  }
  get delay() {
    if (typeof this.options.delay === 'number') {
      return this.options.delay;
    }
    return isTesting() ? 0 : 200;
  }
  get closeDelay() {
    if (typeof this.options.closeDelay === 'number') {
      return this.options.closeDelay;
    }
    return isTesting() ? 0 : 0;
  }
  get group() {
    if (this.options.group === null) {
      return undefined;
    }
    return this.options.group ?? currentGroup();
  }
  update(options) {
    this.options = {
      ...this.options,
      ...options
    };
  }
  open = () => {
    this.#set(true);
  };
  close = () => {
    this.#set(false);
  };
  toggle = () => {
    this.#set(!this.isOpen);
  };
  scheduleOpen = () => {
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
  scheduleClose = () => {
    this.clearTimers();
    const delay = this.closeDelay;
    if (delay <= 0) {
      this.close();
    } else {
      this.#closeTimer = setTimeout(() => this.close(), delay);
    }
  };
  clearTimers() {
    if (this.#openTimer !== undefined) {
      clearTimeout(this.#openTimer);
      this.#openTimer = undefined;
    }
    if (this.#closeTimer !== undefined) {
      clearTimeout(this.#closeTimer);
      this.#closeTimer = undefined;
    }
  }
  #set(open) {
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

/**
 * Geometry for the SVG pointer arrow. Ported from @floating-ui/react's
 * FloatingArrow, which draws the arrow as an SVG triangle (with an optional
 * stroke) instead of a rotated square. A straight border can't be aligned
 * pixel-perfectly with a separately-rasterized rotated shape (the technique
 * this library used before) — subpixel floating-ui coordinates leave a
 * hairline seam where the border shows through. The SVG stroke is drawn at
 * double the requested width and centered on the path, so its outer half
 * intentionally overlaps the panel's own border and covers any such seam
 * regardless of exact subpixel alignment.
 */

function computeArrowGeometry(input) {
  const {
    width,
    height,
    tipRadius,
    strokeWidth
  } = input;
  // Strokes are doubled and centered on the path so half the stroke extends
  // outward past the flat edge, overlapping the panel's own border.
  const computedStrokeWidth = strokeWidth * 2;
  const halfStrokeWidth = computedStrokeWidth / 2;
  const svgX = width / 2 * (tipRadius / -8 + 1);
  const svgY = height / 2 * (tipRadius / 4);
  const d = `M0,0 H${width} L${width - svgX},${height - svgY} ` + `Q${width / 2},${height} ${svgX},${height - svgY} Z`;
  const viewBoxHeight = height > width ? height : width;
  return {
    d,
    computedStrokeWidth,
    halfStrokeWidth,
    viewBox: `0 0 ${width} ${viewBoxHeight}`,
    svgWidth: width + computedStrokeWidth,
    svgHeight: width,
    clipX: -halfStrokeWidth,
    clipY: halfStrokeWidth,
    clipWidth: width + computedStrokeWidth,
    clipHeight: width
  };
}
const ROTATION_BY_SIDE = {
  top: '',
  bottom: 'rotate(180deg)',
  left: 'rotate(-90deg)',
  right: 'rotate(90deg)'
};
function arrowRotationForSide(side) {
  return ROTATION_BY_SIDE[side] ?? '';
}
function isHorizontalEdgeSide(side) {
  return side === 'top' || side === 'bottom';
}

function attachTooltipListeners(element, manager) {
  const enter = () => {
    manager.scheduleOpen();
  };
  const leave = () => {
    manager.scheduleClose();
  };
  const onFocus = () => {
    manager.scheduleOpen();
  };
  const onBlur = () => {
    manager.scheduleClose();
  };
  const onKeydown = event => {
    if (event.key === 'Escape' && manager.isOpen) {
      manager.close();
      event.stopPropagation();
    }
  };
  element.addEventListener('mouseenter', enter);
  element.addEventListener('mouseleave', leave);
  element.addEventListener('focus', onFocus);
  element.addEventListener('blur', onBlur);
  element.addEventListener('keydown', onKeydown);
  return () => {
    element.removeEventListener('mouseenter', enter);
    element.removeEventListener('mouseleave', leave);
    element.removeEventListener('focus', onFocus);
    element.removeEventListener('blur', onBlur);
    element.removeEventListener('keydown', onKeydown);
  };
}
function attachPopoverTriggerListeners(element, manager) {
  const onClick = event => {
    event.stopPropagation();
    manager.toggle();
  };
  element.addEventListener('click', onClick);
  return () => {
    element.removeEventListener('click', onClick);
  };
}
function attachDismissListeners(reference, floating, close) {
  const onPointerDown = event => {
    const target = event.target;
    if (!target) {
      return;
    }
    if (floating.contains(target) || reference.contains(target)) {
      return;
    }
    close();
  };
  const onKeydown = event => {
    if (event.key === 'Escape') {
      close();
    }
  };
  document.addEventListener('pointerdown', onPointerDown, true);
  document.addEventListener('mousedown', onPointerDown, true);
  document.addEventListener('click', onPointerDown, true);
  document.addEventListener('keydown', onKeydown, true);
  return () => {
    document.removeEventListener('pointerdown', onPointerDown, true);
    document.removeEventListener('mousedown', onPointerDown, true);
    document.removeEventListener('click', onPointerDown, true);
    document.removeEventListener('keydown', onKeydown, true);
  };
}
function syncDescribedBy(reference, tooltipId, open) {
  if (open) {
    reference.setAttribute('aria-describedby', tooltipId);
  } else if (reference.getAttribute('aria-describedby') === tooltipId) {
    reference.removeAttribute('aria-describedby');
  }
}
function syncExpanded(reference, floatingId, open) {
  reference.setAttribute('aria-expanded', open ? 'true' : 'false');
  reference.setAttribute('aria-haspopup', 'dialog');
  if (open) {
    reference.setAttribute('aria-controls', floatingId);
  } else if (reference.getAttribute('aria-controls') === floatingId) {
    reference.removeAttribute('aria-controls');
  }
}

function resolvePortalTarget(container) {
  if (typeof document === 'undefined') {
    return null;
  }
  if (container instanceof Element) {
    return container;
  }
  if (typeof container === 'string') {
    return document.querySelector(container);
  }
  return document.body;
}

const waiter = buildWaiter('floating-ember:position');
function startAutoPosition(reference, floating, options = {}) {
  const token = waiter.beginAsync();
  const cleanup = autoUpdate(reference, floating, () => {
    const updateToken = waiter.beginAsync();
    const middleware = [offset(options.offset ?? 8), flip(), shift({
      padding: 8
    }), hide()];
    if (options.arrowEl) {
      middleware.push(arrow({
        element: options.arrowEl,
        padding: 8
      }));
    }
    if (options.middleware) {
      middleware.push(...options.middleware);
    }
    void computePosition(reference, floating, {
      placement: options.placement ?? 'top',
      middleware
    }).then(({
      x,
      y,
      placement,
      middlewareData
    }) => {
      const dpr = window.devicePixelRatio || 1;
      const round = value => Math.round(value * dpr) / dpr;
      Object.assign(floating.style, {
        position: 'absolute',
        left: `${round(x)}px`,
        top: `${round(y)}px`,
        width: 'max-content',
        zIndex: '10000'
      });
      const side = placement.split('-')[0] ?? placement;
      floating.dataset['side'] = side;
      floating.dataset['placement'] = placement;
      if (options.arrowEl instanceof SVGElement && middlewareData.arrow) {
        applyArrowStyle(options.arrowEl, side, middlewareData.arrow.x != null ? round(middlewareData.arrow.x) : middlewareData.arrow.x, middlewareData.arrow.y != null ? round(middlewareData.arrow.y) : middlewareData.arrow.y);
      }
    }).finally(() => {
      waiter.endAsync(updateToken);
    });
  });
  waiter.endAsync(token);
  return cleanup;
}
function applyArrowStyle(arrowEl, side, arrowX, arrowY) {
  const strokeWidth = Number(arrowEl.dataset['strokeWidth'] ?? 0);
  const halfStroke = strokeWidth / 2;
  arrowEl.style.left = '';
  arrowEl.style.right = '';
  arrowEl.style.top = '';
  arrowEl.style.bottom = '';
  if (isHorizontalEdgeSide(side)) {
    if (arrowX != null) {
      arrowEl.style.left = `${arrowX}px`;
    }
    // The flat edge sits exactly at the panel's edge (100%); the stroke's
    // own outward half (see arrow-geometry.ts) covers any subpixel seam.
    arrowEl.style[side === 'top' ? 'top' : 'bottom'] = '100%';
  } else {
    if (arrowY != null) {
      arrowEl.style.top = `${arrowY}px`;
    }
    arrowEl.style[side === 'left' ? 'left' : 'right'] = `calc(100% - ${halfStroke}px)`;
  }
  arrowEl.style.transform = arrowRotationForSide(side);
  arrowEl.dataset['side'] = side;
}

export { FloatingManager as F, attachPopoverTriggerListeners as a, startAutoPosition as b, attachDismissListeners as c, syncDescribedBy as d, attachTooltipListeners as e, computeArrowGeometry as f, resolvePortalTarget as r, syncExpanded as s };
//# sourceMappingURL=position-CqPSH9z1.js.map
