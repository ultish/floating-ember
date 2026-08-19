import type { FloatingManager } from './floating-manager.ts';
export declare function attachTooltipListeners(element: Element, manager: FloatingManager): () => void;
export declare function attachPopoverTriggerListeners(element: Element, manager: FloatingManager): () => void;
export declare function attachDismissListeners(reference: Element, floating: Element, close: () => void): () => void;
export declare function syncDescribedBy(reference: Element, tooltipId: string, open: boolean): void;
export declare function syncExpanded(reference: Element, floatingId: string, open: boolean): void;
//# sourceMappingURL=interactions.d.ts.map