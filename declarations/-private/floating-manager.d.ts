import { type DelayGroup } from './delay-group.ts';
export interface ManagerOptions {
    delay?: number;
    closeDelay?: number;
    open?: boolean;
    onOpenChange?: (open: boolean) => void;
    disabled?: boolean;
    group?: DelayGroup | null;
    exclusive?: boolean;
}
export declare class FloatingManager {
    #private;
    readonly id: string;
    referenceEl: Element | null;
    floatingEl: Element | null;
    options: ManagerOptions;
    constructor(options?: ManagerOptions);
    get isControlled(): boolean;
    get isOpen(): boolean;
    get delay(): number;
    get closeDelay(): number;
    get group(): DelayGroup | undefined;
    update(options: ManagerOptions): void;
    open: () => void;
    close: () => void;
    toggle: () => void;
    scheduleOpen: () => void;
    scheduleClose: () => void;
    clearTimers(): void;
}
//# sourceMappingURL=floating-manager.d.ts.map