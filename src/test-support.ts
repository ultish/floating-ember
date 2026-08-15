import { triggerEvent, click } from '@ember/test-helpers';

export async function openTooltip(element: Element): Promise<void> {
  await triggerEvent(element, 'mouseenter');
}

export async function closeTooltip(element: Element): Promise<void> {
  await triggerEvent(element, 'mouseleave');
}

export async function openPopover(element: Element): Promise<void> {
  await click(element);
}

export async function closePopover(element: Element): Promise<void> {
  await click(element);
}
