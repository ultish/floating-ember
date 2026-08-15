import type { FloatingManager } from './floating-manager.ts';

export function attachTooltipListeners(
  element: Element,
  manager: FloatingManager,
): () => void {
  const enter = (): void => {
    manager.scheduleOpen();
  };
  const leave = (): void => {
    manager.scheduleClose();
  };
  const onFocus = (): void => {
    manager.scheduleOpen();
  };
  const onBlur = (): void => {
    manager.scheduleClose();
  };
  const onKeydown = (event: Event): void => {
    if ((event as KeyboardEvent).key === 'Escape' && manager.isOpen) {
      manager.close();
      event.stopPropagation();
    }
  };

  element.addEventListener('mouseenter', enter);
  element.addEventListener('mouseleave', leave);
  element.addEventListener('focus', onFocus);
  element.addEventListener('blur', onBlur);
  element.addEventListener('keydown', onKeydown);

  return () => {
    element.removeEventListener('mouseenter', enter);
    element.removeEventListener('mouseleave', leave);
    element.removeEventListener('focus', onFocus);
    element.removeEventListener('blur', onBlur);
    element.removeEventListener('keydown', onKeydown);
  };
}

export function attachPopoverTriggerListeners(
  element: Element,
  manager: FloatingManager,
): () => void {
  const onClick = (event: Event): void => {
    event.stopPropagation();
    manager.toggle();
  };
  element.addEventListener('click', onClick);
  return () => {
    element.removeEventListener('click', onClick);
  };
}

export function attachDismissListeners(
  reference: Element,
  floating: Element,
  close: () => void,
): () => void {
  const onPointerDown = (event: Event): void => {
    const target = event.target as Node | null;
    if (!target) {
      return;
    }
    if (floating.contains(target) || reference.contains(target)) {
      return;
    }
    close();
  };
  const onKeydown = (event: Event): void => {
    if ((event as KeyboardEvent).key === 'Escape') {
      close();
    }
  };
  document.addEventListener('pointerdown', onPointerDown, true);
  document.addEventListener('mousedown', onPointerDown, true);
  document.addEventListener('click', onPointerDown, true);
  document.addEventListener('keydown', onKeydown, true);
  return () => {
    document.removeEventListener('pointerdown', onPointerDown, true);
    document.removeEventListener('mousedown', onPointerDown, true);
    document.removeEventListener('click', onPointerDown, true);
    document.removeEventListener('keydown', onKeydown, true);
  };
}

export function syncDescribedBy(
  reference: Element,
  tooltipId: string,
  open: boolean,
): void {
  if (open) {
    reference.setAttribute('aria-describedby', tooltipId);
  } else if (reference.getAttribute('aria-describedby') === tooltipId) {
    reference.removeAttribute('aria-describedby');
  }
}

export function syncExpanded(
  reference: Element,
  floatingId: string,
  open: boolean,
): void {
  reference.setAttribute('aria-expanded', open ? 'true' : 'false');
  reference.setAttribute('aria-haspopup', 'dialog');
  if (open) {
    reference.setAttribute('aria-controls', floatingId);
  } else if (reference.getAttribute('aria-controls') === floatingId) {
    reference.removeAttribute('aria-controls');
  }
}
