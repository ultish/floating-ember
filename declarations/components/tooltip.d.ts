import Component from '@glimmer/component';
import type { ModifierLike } from '@glint/template';
import type { Middleware, Placement } from '@floating-ui/dom';
import { FloatingManager } from '../-private/floating-manager.ts';
export interface TooltipSignature {
    Element: null;
    Args: {
        placement?: Placement;
        delay?: number;
        closeDelay?: number;
        open?: boolean;
        onOpenChange?: (open: boolean) => void;
        container?: Element | string;
        disabled?: boolean;
        contentClass?: string;
        middleware?: Middleware[];
        arrow?: boolean;
        arrowWidth?: number;
        arrowHeight?: number;
        arrowTipRadius?: number;
        arrowStrokeWidth?: number;
        renderInPlace?: boolean;
    };
    Blocks: {
        trigger: [trigger: ModifierLike<{
            Element: Element;
        }>];
        content: [];
    };
}
export default class Tooltip extends Component<TooltipSignature> {
    #private;
    localOpen: boolean;
    manager: FloatingManager;
    get isOpen(): boolean;
    get portalTarget(): Element | null;
    setupTrigger: import("ember-modifier").FunctionBasedModifier<{
        Args: {
            Positional: unknown[];
            Named: import("ember-modifier/-private/signature").EmptyObject;
        };
        Element: Element;
    }>;
    setupFloating: import("ember-modifier").FunctionBasedModifier<{
        Args: {
            Positional: unknown[];
            Named: import("ember-modifier/-private/signature").EmptyObject;
        };
        Element: HTMLElement;
    }>;
    willDestroy(): void;
}
//# sourceMappingURL=tooltip.d.ts.map