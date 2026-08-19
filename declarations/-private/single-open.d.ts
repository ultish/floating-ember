export interface Closable {
    close(): void;
}
export declare function claimOpen(manager: Closable): void;
export declare function releaseOpen(manager: Closable): void;
//# sourceMappingURL=single-open.d.ts.map