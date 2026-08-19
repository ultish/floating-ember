import Component from '@glimmer/component';
import type { ModifierLike } from '@glint/template';
import type { Middleware, Placement } from '@floating-ui/dom';
import { FloatingManager } from '../-private/floating-manager.ts';
export interface PopoverSignature {
    Element: null;
    Args: {
        placement?: Placement;
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
        modal?: boolean;
    };
    Blocks: {
        trigger: [trigger: ModifierLike<{
            Element: Element;
        }>];
        content: [];
    };
}
export default class Popover extends Component<PopoverSignature> {
    #private;
    localOpen: boolean;
    manager: FloatingManager;
    get isOpen(): boolean;
    get portalTarget(): Element | null;
    close: () => void;
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
//# sourceMappingURL=popover.d.ts.map