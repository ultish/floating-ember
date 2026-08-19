export interface Closable {
  close(): void;
}

let openManager: Closable | null = null;

export function claimOpen(manager: Closable): void {
  if (openManager && openManager !== manager) {
    openManager.close();
  }
  openManager = manager;
}

export function releaseOpen(manager: Closable): void {
  if (openManager === manager) {
    openManager = null;
  }
}
