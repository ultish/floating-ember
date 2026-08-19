import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { computeArrowGeometry } from './arrow-geometry.ts';

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
  guid = guidFor(this);

  get width(): number {
    return this.args.width ?? 14;
  }

  get height(): number {
    return this.args.height ?? 7;
  }

  get tipRadius(): number {
    return this.args.tipRadius ?? 0;
  }

  get strokeWidth(): number {
    return this.args.strokeWidth ?? 1;
  }

  get geometry() {
    return computeArrowGeometry({
      width: this.width,
      height: this.height,
      tipRadius: this.tipRadius,
      strokeWidth: this.strokeWidth,
    });
  }

  get clipPathId(): string {
    return `floating-arrow-clip-${this.guid}`;
  }

  <template>
    {{! template-lint-disable no-inline-styles }}
    {{! fill/stroke="inherit": browsers' UA stylesheet paints svg/path
        elements directly, which beats plain CSS inheritance from an
        ancestor's fill/stroke — these presentation attributes force real
        inheritance without requiring any stylesheet import, and still lose
        to any author CSS rule targeting [data-floating-arrow] directly. }}
    <svg
      data-floating-arrow
      data-stroke-width={{this.geometry.computedStrokeWidth}}
      aria-hidden="true"
      width={{this.geometry.svgWidth}}
      height={{this.geometry.svgHeight}}
      viewBox={{this.geometry.viewBox}}
      fill="inherit"
      stroke="inherit"
      style="position: absolute; pointer-events: none;"
      ...attributes
    >
      {{#if this.strokeWidth}}
        <path
          d={{this.geometry.d}}
          fill="none"
          stroke-width={{this.geometry.computedStrokeWidth}}
          clip-path="url(#{{this.clipPathId}})"
        />
      {{/if}}
      <path d={{this.geometry.d}} stroke="none" />
      <clipPath id={{this.clipPathId}}>
        <rect
          x={{this.geometry.clipX}}
          y={{this.geometry.clipY}}
          width={{this.geometry.clipWidth}}
          height={{this.geometry.clipHeight}}
        />
      </clipPath>
    </svg>
  </template>
}
