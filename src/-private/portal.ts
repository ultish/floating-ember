export function resolvePortalTarget(
  container?: Element | string,
): Element | null {
  if (typeof document === 'undefined') {
    return null;
  }
  if (container instanceof Element) {
    return container;
  }
  if (typeof container === 'string') {
    return document.querySelector(container);
  }
  return document.body;
}
