import type { Middleware, Placement } from '@floating-ui/dom';
export interface PositionOptions {
    placement?: Placement;
    offset?: number;
    middleware?: Middleware[];
    arrowEl?: Element | null;
}
export declare function startAutoPosition(reference: Element, floating: HTMLElement, options?: PositionOptions): () => void;
//# sourceMappingURL=position.d.ts.map