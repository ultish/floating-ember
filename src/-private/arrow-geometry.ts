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

export interface ArrowGeometryInput {
  width: number;
  height: number;
  tipRadius: number;
  strokeWidth: number;
}

export interface ArrowGeometry {
  d: string;
  computedStrokeWidth: number;
  halfStrokeWidth: number;
  viewBox: string;
  svgWidth: number;
  svgHeight: number;
  clipX: number;
  clipY: number;
  clipWidth: number;
  clipHeight: number;
}

export function computeArrowGeometry(input: ArrowGeometryInput): ArrowGeometry {
  const { width, height, tipRadius, strokeWidth } = input;
  // Strokes are doubled and centered on the path so half the stroke extends
  // outward past the flat edge, overlapping the panel's own border.
  const computedStrokeWidth = strokeWidth * 2;
  const halfStrokeWidth = computedStrokeWidth / 2;
  const svgX = (width / 2) * (tipRadius / -8 + 1);
  const svgY = (height / 2) * (tipRadius / 4);
  const d =
    `M0,0 H${width} L${width - svgX},${height - svgY} ` +
    `Q${width / 2},${height} ${svgX},${height - svgY} Z`;
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
    clipHeight: width,
  };
}

const ROTATION_BY_SIDE: Record<string, string> = {
  top: '',
  bottom: 'rotate(180deg)',
  left: 'rotate(-90deg)',
  right: 'rotate(90deg)',
};

export function arrowRotationForSide(side: string): string {
  return ROTATION_BY_SIDE[side] ?? '';
}

export function isHorizontalEdgeSide(side: string): boolean {
  return side === 'top' || side === 'bottom';
}
