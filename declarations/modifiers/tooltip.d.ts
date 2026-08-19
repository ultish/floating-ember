import type { Placement } from '@floating-ui/dom';
interface TooltipModifierNamed {
    placement?: Placement;
    delay?: number;
    closeDelay?: number;
    disabled?: boolean;
    contentClass?: string;
    arrow?: boolean;
    arrowWidth?: number;
    arrowHeight?: number;
    arrowTipRadius?: number;
    arrowStrokeWidth?: number;
}
declare const tooltip: import("ember-modifier").FunctionBasedModifier<{
    Args: {
        Positional: [string];
        Named: TooltipModifierNamed;
    };
    Element: Element;
}>;
export default tooltip;
//# sourceMappingURL=tooltip.d.ts.map