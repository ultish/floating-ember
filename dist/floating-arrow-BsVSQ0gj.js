import Component from '@glimmer/component';
import { guidFor } from '@ember/object/internals';
import { f as computeArrowGeometry } from './position-CqPSH9z1.js';
import { precompileTemplate } from '@ember/template-compilation';
import { setComponentTemplate } from '@ember/component';

class FloatingArrow extends Component {
  guid = guidFor(this);
  get width() {
    return this.args.width ?? 14;
  }
  get height() {
    return this.args.height ?? 7;
  }
  get tipRadius() {
    return this.args.tipRadius ?? 0;
  }
  get strokeWidth() {
    return this.args.strokeWidth ?? 1;
  }
  get geometry() {
    return computeArrowGeometry({
      width: this.width,
      height: this.height,
      tipRadius: this.tipRadius,
      strokeWidth: this.strokeWidth
    });
  }
  get clipPathId() {
    return `floating-arrow-clip-${this.guid}`;
  }
  static {
    setComponentTemplate(precompileTemplate("{{!-- template-lint-disable no-inline-styles --}}\n{{!-- fill/stroke=\"inherit\": browsers' UA stylesheet paints svg/path\n    elements directly, which beats plain CSS inheritance from an\n    ancestor's fill/stroke \u2014 these presentation attributes force real\n    inheritance without requiring any stylesheet import, and still lose\n    to any author CSS rule targeting [data-floating-arrow] directly. --}}\n<svg data-floating-arrow data-stroke-width={{this.geometry.computedStrokeWidth}} aria-hidden=\"true\" width={{this.geometry.svgWidth}} height={{this.geometry.svgHeight}} viewBox={{this.geometry.viewBox}} fill=\"inherit\" stroke=\"inherit\" style=\"position: absolute; pointer-events: none;\" ...attributes>\n  {{#if this.strokeWidth}}\n    <path d={{this.geometry.d}} fill=\"none\" stroke-width={{this.geometry.computedStrokeWidth}} clip-path=\"url(#{{this.clipPathId}})\" />\n  {{/if}}\n  <path d={{this.geometry.d}} stroke=\"none\" />\n  <clipPath id={{this.clipPathId}}>\n    <rect x={{this.geometry.clipX}} y={{this.geometry.clipY}} width={{this.geometry.clipWidth}} height={{this.geometry.clipHeight}} />\n  </clipPath>\n</svg>", {
      strictMode: true
    }), this);
  }
}

export { FloatingArrow as F };
//# sourceMappingURL=floating-arrow-BsVSQ0gj.js.map
