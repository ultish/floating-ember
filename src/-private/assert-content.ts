const INTERACTIVE =
  'a, button, input, select, textarea, [href], [tabindex]:not([tabindex="-1"])';

export function warnIfInteractive(element: Element): void {
  if (typeof document === 'undefined') {
    return;
  }
  if (element.querySelector(INTERACTIVE)) {
    console.warn(
      'floating-ember: <Tooltip> content contains interactive elements (links, buttons, fields). Use <Popover> for interactive content.',
    );
  }
}
