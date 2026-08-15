import {
  arrow,
  autoUpdate,
  computePosition,
  flip,
  hide,
  offset,
  shift,
} from '@floating-ui/dom';
import { buildWaiter } from '@ember/test-waiters';
import {
  arrowRotationForSide,
  isHorizontalEdgeSide,
} from './arrow-geometry.ts';
import type { Middleware, Placement } from '@floating-ui/dom';

const waiter = buildWaiter('floating-ember:position');

export interface PositionOptions {
  placement?: Placement;
  offset?: number;
  middleware?: Middleware[];
  arrowEl?: Element | null;
}

export function startAutoPosition(
  reference: Element,
  floating: HTMLElement,
  options: PositionOptions = {},
): () => void {
  const token = waiter.beginAsync();

  const cleanup = autoUpdate(reference, floating, () => {
    const updateToken = waiter.beginAsync();
    const middleware: Middleware[] = [
      offset(options.offset ?? 8),
      flip(),
      shift({ padding: 8 }),
      hide(),
    ];
    if (options.arrowEl) {
      middleware.push(arrow({ element: options.arrowEl, padding: 8 }));
    }
    if (options.middleware) {
      middleware.push(...options.middleware);
    }

    void computePosition(reference, floating, {
      placement: options.placement ?? 'top',
      middleware,
    })
      .then(({ x, y, placement, middlewareData }) => {
        const dpr = window.devicePixelRatio || 1;
        const round = (value: number): number => Math.round(value * dpr) / dpr;

        Object.assign(floating.style, {
          position: 'absolute',
          left: `${round(x)}px`,
          top: `${round(y)}px`,
          width: 'max-content',
          zIndex: '10000',
        });
        const side = placement.split('-')[0] ?? placement;
        floating.dataset['side'] = side;
        floating.dataset['placement'] = placement;

        if (options.arrowEl instanceof SVGElement && middlewareData.arrow) {
          applyArrowStyle(
            options.arrowEl,
            side,
            middlewareData.arrow.x != null
              ? round(middlewareData.arrow.x)
              : middlewareData.arrow.x,
            middlewareData.arrow.y != null
              ? round(middlewareData.arrow.y)
              : middlewareData.arrow.y,
          );
        }
      })
      .finally(() => {
        waiter.endAsync(updateToken);
      });
  });

  waiter.endAsync(token);
  return cleanup;
}

function applyArrowStyle(
  arrowEl: SVGElement,
  side: string,
  arrowX: number | undefined | null,
  arrowY: number | undefined | null,
): void {
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
    arrowEl.style[side === 'left' ? 'left' : 'right'] =
      `calc(100% - ${halfStroke}px)`;
  }

  arrowEl.style.transform = arrowRotationForSide(side);
  arrowEl.dataset['side'] = side;
}
