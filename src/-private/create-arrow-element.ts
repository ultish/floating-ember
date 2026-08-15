import { computeArrowGeometry } from './arrow-geometry.ts';

const SVG_NS = 'http://www.w3.org/2000/svg';

let nextId = 0;

export interface CreateArrowElementOptions {
  width?: number;
  height?: number;
  tipRadius?: number;
  strokeWidth?: number;
}

export function createArrowElement(
  options: CreateArrowElementOptions = {},
): SVGSVGElement {
  const geometry = computeArrowGeometry({
    width: options.width ?? 14,
    height: options.height ?? 7,
    tipRadius: options.tipRadius ?? 0,
    strokeWidth: options.strokeWidth ?? 0,
  });

  const svg = document.createElementNS(SVG_NS, 'svg');
  svg.setAttribute('data-floating-arrow', '');
  svg.dataset['strokeWidth'] = String(geometry.computedStrokeWidth);
  svg.setAttribute('aria-hidden', 'true');
  svg.setAttribute('width', String(geometry.svgWidth));
  svg.setAttribute('height', String(geometry.svgHeight));
  svg.setAttribute('viewBox', geometry.viewBox);
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
    strokePath.setAttribute(
      'stroke-width',
      String(geometry.computedStrokeWidth),
    );
    strokePath.setAttribute('clip-path', `url(#${clipPathId})`);
    svg.append(strokePath);
  }

  const fillPath = document.createElementNS(SVG_NS, 'path');
  fillPath.setAttribute('d', geometry.d);
  fillPath.setAttribute('stroke', 'none');
  svg.append(fillPath);

  return svg;
}
