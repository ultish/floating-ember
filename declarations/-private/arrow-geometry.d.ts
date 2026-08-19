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
export declare function computeArrowGeometry(input: ArrowGeometryInput): ArrowGeometry;
export declare function arrowRotationForSide(side: string): string;
export declare function isHorizontalEdgeSide(side: string): boolean;
//# sourceMappingURL=arrow-geometry.d.ts.map