import Component from '@glimmer/component';
export interface FloatingArrowSignature {
    Element: SVGSVGElement;
    Args: {
        width?: number;
        height?: number;
        tipRadius?: number;
        strokeWidth?: number;
    };
}
export default class FloatingArrow extends Component<FloatingArrowSignature> {
    guid: string;
    get width(): number;
    get height(): number;
    get tipRadius(): number;
    get strokeWidth(): number;
    get geometry(): import("./arrow-geometry.ts").ArrowGeometry;
    get clipPathId(): string;
}
//# sourceMappingURL=floating-arrow.d.ts.map