export declare class DelayGroup {
    #private;
    skipDelay: boolean;
    markOpened(): void;
    markClosed(): void;
}
export declare function pushGroup(group: DelayGroup): void;
export declare function popGroup(group: DelayGroup): void;
export declare function currentGroup(): DelayGroup | undefined;
//# sourceMappingURL=delay-group.d.ts.map